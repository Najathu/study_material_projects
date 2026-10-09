import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_provider.dart';
import '../../core/petstore_providers.dart';
import '../../shared/widgets.dart';

/// Reached via /pets/:id. The id comes from GoRouter's path parameters;
/// the data comes from a Riverpod `family` provider keyed by that id.
class PetDetailScreen extends ConsumerWidget {
  const PetDetailScreen({super.key, required this.petId});

  final int petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petByIdProvider(petId));
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pet #$petId'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(petByIdProvider(petId)),
          ),
        ],
      ),
      body: switch (pet) {
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(value.name, style: text.headlineMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('status: ${value.status ?? '-'}')),
                Chip(label: Text('category: ${value.category?.name ?? '-'}')),
                for (final t in value.tags ?? const [])
                  Chip(
                    avatar: const Icon(Icons.sell_outlined, size: 16),
                    label: Text(t.name ?? '?'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Freezed toString()', style: text.titleSmall),
            CodeBlock('$value'),
            Text('Freezed toJson()', style: text.titleSmall),
            CodeBlock(
              const JsonEncoder.withIndent('  ').convert(value.toJson()),
            ),
            const SizedBox(height: 8),
            Text(
              'Path: /pets/$petId → state.pathParameters[\'id\'] → '
              'petByIdProvider($petId) → api.pet.getPetById(petId: $petId) → '
              'Dio GET /pet/$petId → Pet.fromJson',
              style: text.bodySmall,
            ),
          ],
        ),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(describeDioError(error), textAlign: TextAlign.center),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
