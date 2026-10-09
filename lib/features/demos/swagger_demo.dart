import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/export.dart';
import '../../core/dio_provider.dart';
import '../../core/petstore_providers.dart';
import '../../shared/widgets.dart';

/// Uses the GENERATED client: no URLs, no JSON parsing, just typed methods.
class SwaggerDemo extends ConsumerStatefulWidget {
  const SwaggerDemo({super.key});

  @override
  ConsumerState<SwaggerDemo> createState() => _SwaggerDemoState();
}

class _SwaggerDemoState extends ConsumerState<SwaggerDemo> {
  String _code = '';
  String _result = '';
  bool _busy = false;

  Future<void> _call(
    String code,
    Future<String> Function(PetstoreApi) run,
  ) async {
    setState(() {
      _busy = true;
      _code = code;
      _result = '';
    });
    try {
      _result = await run(ref.read(petstoreApiProvider));
    } catch (e) {
      _result = '❌ ${describeDioError(e)}';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DemoCard(
          title: 'Swagger UI – interactive docs',
          subtitle:
              'Open these in a browser. The first is the real Petstore Swagger UI. '
              'In the editor, paste openapi/petstore.yaml to see our spec rendered.',
          children: [
            for (final url in const [
              'https://petstore3.swagger.io',
              'https://editor.swagger.io',
              'https://petstore3.swagger.io/api/v3/openapi.json',
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.link),
                title: SelectableText(url),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Copied $url')));
                  },
                ),
              ),
          ],
        ),
        DemoCard(
          title: 'Call the generated client',
          subtitle:
              'Compare with the Dio demo: no paths, no maps. The results are '
              'typed Freezed objects. Requests still go through our Dio, so '
              'they show up in the network inspector.',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _call('final Map<String, int> inv =\n'
                            '    await api.store.getInventory();', (api) async {
                          final inv = await api.store.getInventory();
                          final top = inv.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));
                          return '${inv.runtimeType}\n'
                              '${top.take(8).map((e) => '${e.key}: ${e.value}').join('\n')}';
                        }),
                  child: const Text('getInventory()'),
                ),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _call('final List<Pet> pets = await api.pet\n'
                            '    .findPetsByStatus(status: PetStatus.sold);', (
                          api,
                        ) async {
                          final pets = await api.pet.findPetsByStatus(
                            status: PetStatus.sold,
                          );
                          return '${pets.length} pets, first 3:\n\n'
                              '${pets.take(3).join('\n\n')}';
                        }),
                  child: const Text('findPetsByStatus(sold)'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _call('final Pet pet = await api.pet.addPet(\n'
                            "  body: Pet(id: 777001, name: 'Generated Gary',\n"
                            '      status: PetStatus.pending, photoUrls: []),\n'
                            ');', (api) async {
                          final pet = await api.pet.addPet(
                            body: const Pet(
                              id: 777001,
                              name: 'Generated Gary',
                              status: PetStatus.pending,
                              photoUrls: [],
                            ),
                          );
                          return 'Server returned a typed Pet:\n$pet';
                        }),
                  child: const Text('addPet(...)'),
                ),
              ],
            ),
            if (_code.isNotEmpty) CodeBlock(_code),
            if (_busy) const LinearProgressIndicator(),
            if (_result.isNotEmpty) CodeBlock(_result),
          ],
        ),
        DemoCard(
          title: 'Regenerate it yourself',
          subtitle:
              'Edit openapi/petstore.yaml (e.g. add a "nickname" string to Pet), '
              'then run these two commands and look at lib/api/generated/models/pet.dart.',
          children: [
            const CodeBlock(
              'dart run swagger_parser\n'
              'dart run build_runner build',
            ),
            FilledButton.icon(
              icon: const Icon(Icons.pets),
              label: const Text('See it all together: Pet Store'),
              onPressed: () => context.push('/pets'),
            ),
          ],
        ),
      ],
    );
  }
}
