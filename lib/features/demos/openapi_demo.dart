import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/widgets.dart';

/// Shows the real spec file bundled with the app and how each part of it
/// turned into Dart code.
class OpenApiDemo extends StatelessWidget {
  const OpenApiDemo({super.key});

  static const _mapping = [
    ('servers[0].url', 'Dio BaseOptions.baseUrl'),
    ('tags: [pet]', 'class PetClient (one client per tag)'),
    ('operationId: getPetById', 'Future<Pet> getPetById(...)'),
    ('GET /pet/{petId}', "@GET('/pet/{petId}')"),
    ('in: path  name: petId', "@Path('petId') required int petId"),
    ('in: query name: status', "@Query('status') PetStatus status"),
    ('requestBody: Pet', '@Body() required Pet body'),
    ("responses '200': array of Pet", 'Future<List<Pet>>'),
    ('components/schemas/Pet', '@freezed abstract class Pet'),
    ('required: [name]', 'required String name'),
    ('id (not required)', 'int? id'),
    ('enum: [available, ...]', 'enum PetStatus'),
    ('additionalProperties: integer', 'Map<String, int>'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DemoCard(
          title: 'Spec → Dart, line by line',
          subtitle:
              'Left: what is written in openapi/petstore.yaml. '
              'Right: what swagger_parser generated in lib/api/generated/.',
          children: [
            Table(
              columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
              border: TableBorder.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              children: [
                const TableRow(
                  children: [
                    _Cell('OpenAPI (YAML)', header: true),
                    _Cell('Generated Dart', header: true),
                  ],
                ),
                for (final (spec, dart) in _mapping)
                  TableRow(children: [_Cell(spec), _Cell(dart)]),
              ],
            ),
          ],
        ),
        DemoCard(
          title: 'The actual spec file',
          subtitle:
              'Bundled as an asset. Read the comments: they explain each part.',
          children: [
            FutureBuilder<String>(
              future: rootBundle.loadString('openapi/petstore.yaml'),
              builder: (context, snap) => switch (snap) {
                AsyncSnapshot(hasData: true, :final data?) => CodeBlock(data),
                AsyncSnapshot(hasError: true, :final error) => Text('$error'),
                _ => const LinearProgressIndicator(),
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {this.header = false});

  final String text;
  final bool header;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: header ? null : 'monospace',
          fontSize: 12,
          fontWeight: header ? FontWeight.bold : null,
        ),
      ),
    );
  }
}
