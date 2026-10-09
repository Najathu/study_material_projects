import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/export.dart';
import '../../core/dio_provider.dart';
import '../../core/petstore_providers.dart';
import '../../shared/widgets.dart';

/// THE WHOLE STACK IN ONE SCREEN
///  * GoRouter: the selected status lives in the URL (/pets?status=sold).
///  * Riverpod: petsByStatusProvider(status) caches + exposes AsyncValue.
///  * OpenAPI/Swagger: the provider calls the generated PetClient.
///  * Dio: does the HTTP underneath (see the network inspector).
///  * Freezed: every item is an immutable generated `Pet`.
class PetListScreen extends ConsumerWidget {
  const PetListScreen({super.key, this.initialStatus});

  final String? initialStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        PetStatus.values.asNameMap()[initialStatus] ?? PetStatus.available;
    final pets = ref.watch(petsByStatusProvider(status));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Store'),
        actions: [
          IconButton(
            tooltip: 'Network inspector',
            icon: const Icon(Icons.network_check),
            onPressed: () => showNetworkLog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add pet'),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          // push() waits until AddPetScreen calls context.pop(pet).
          final created = await context.push<Pet>('/pets/new');
          if (created == null) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text('Created "${created.name}" (id ${created.id})'),
            ),
          );
          // Throw away the cached list so it is fetched again.
          ref.invalidate(petsByStatusProvider);
        },
      ),
      body: Column(
        children: [
          const _InventoryBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<PetStatus>(
              segments: [
                for (final s in PetStatus.$valuesDefined)
                  ButtonSegment(value: s, label: Text(s.name)),
              ],
              selected: {status},
              // The URL is the single source of truth for the filter.
              // replace() swaps this page's URL without growing the back stack.
              onSelectionChanged: (s) =>
                  context.replace('/pets?status=${s.first.name}'),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(petsByStatusProvider(status).future),
              // RIVERPOD: AsyncValue has exactly three states.
              child: switch (pets) {
                AsyncData(:final value) when value.isEmpty => ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No pets with this status.')),
                    ),
                  ],
                ),
                AsyncData(:final value) => ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, i) => _PetTile(pet: value[i]),
                ),
                AsyncError(:final error) => ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_off, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            describeDioError(error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () =>
                                ref.invalidate(petsByStatusProvider(status)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PetTile extends StatelessWidget {
  const _PetTile({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final tags = pet.tags?.map((t) => t.name).whereType<String>().join(', ');
    return ListTile(
      leading: CircleAvatar(
        child: Text(pet.name.isEmpty ? '?' : pet.name[0].toUpperCase()),
      ),
      title: Text(pet.name.isEmpty ? '(no name)' : pet.name),
      subtitle: Text(
        [
          'id ${pet.id}',
          if (pet.category?.name != null) pet.category!.name!,
          if (tags != null && tags.isNotEmpty) tags,
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/pets/${pet.id}'),
    );
  }
}

/// A second, independent provider on the same screen with its own loading
/// state. `.value` is null while loading/on error, so we just hide the bar.
/// (The shared sandbox returns whatever keys people created, so we show the
/// raw map instead of assuming "available/pending/sold".)
class _InventoryBar extends ConsumerWidget {
  const _InventoryBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider).value;
    if (inventory == null) return const SizedBox(height: 8);
    final entries = inventory.entries.where((e) => e.key.length < 20).take(4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('GET /store/inventory →', style: TextStyle(fontSize: 12)),
          for (final e in entries)
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text('${e.key}: ${e.value}'),
            ),
        ],
      ),
    );
  }
}
