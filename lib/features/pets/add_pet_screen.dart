import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/generated/export.dart';
import '../../core/dio_provider.dart';
import '../../core/petstore_providers.dart';

/// POSTs a new pet with the generated client and returns it to whoever
/// pushed this screen via `context.pop(pet)`.
class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _category = TextEditingController(text: 'Dogs');
  PetStatus _status = PetStatus.available;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    // Build a Freezed model, then send it. No manual JSON anywhere.
    final draft = Pet(
      id: DateTime.now().millisecondsSinceEpoch % 1000000000,
      name: _name.text.trim(),
      category: Category(id: 1, name: _category.text.trim()),
      status: _status,
      photoUrls: const [],
      tags: const [Tag(id: 1, name: 'study-app')],
    );

    try {
      final created = await ref
          .read(petstoreApiProvider)
          .pet
          .addPet(body: draft);
      if (mounted) context.pop(created); // returns the value to push()
    } catch (e) {
      setState(() => _error = describeDioError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add pet  (POST /pet)')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name (required in the spec)',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<PetStatus>(
              segments: [
                for (final s in PetStatus.$valuesDefined)
                  ButtonSegment(value: s, label: Text(s.name)),
              ],
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: the public Petstore is a shared sandbox. Your pet is '
              'visible to everyone and may be wiped at any time.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
