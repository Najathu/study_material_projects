import 'dart:convert';

import 'package:flutter/material.dart';

import '../../shared/widgets.dart';
import 'freezed_examples.dart';

class FreezedDemo extends StatefulWidget {
  const FreezedDemo({super.key});

  @override
  State<FreezedDemo> createState() => _FreezedDemoState();
}

class _FreezedDemoState extends State<FreezedDemo> {
  Student _student = const Student(name: 'Ana', age: 24, skills: ['Dart']);
  final List<String> _history = [];

  LoadState _load = const LoadState.idle();

  final _jsonCtrl = TextEditingController(
    text:
        '{"name": "Bo", "age": 30, "skills": ["Flutter"], "is_active": false}',
  );
  String _parsed = '';

  @override
  void dispose() {
    _jsonCtrl.dispose();
    super.dispose();
  }

  void _update(Student Function(Student) change, String code) {
    final before = _student;
    final after = change(before);
    setState(() {
      _student = after;
      _history.insert(0, '$code\n  before: $before\n  after:  $after');
    });
  }

  Future<void> _simulateLoad({required bool fail}) async {
    setState(() => _load = const LoadState.loading());
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(
      () => _load = fail
          ? const LoadState.failure('Server exploded 💥')
          : const LoadState.success(['Riverpod', 'Dio', 'Freezed']),
    );
  }

  @override
  Widget build(BuildContext context) {
    final twin = Student(
      name: _student.name,
      age: _student.age,
      skills: [..._student.skills],
      isActive: _student.isActive,
    );

    return Column(
      children: [
        DemoCard(
          title: '1 · Immutability & copyWith',
          subtitle: 'You can\'t do student.age = 25. You make a changed copy.',
          children: [
            CodeBlock('$_student'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => _update(
                    (s) => s.copyWith(age: s.age + 1),
                    'student.copyWith(age: student.age + 1)',
                  ),
                  child: const Text('Birthday 🎂'),
                ),
                FilledButton(
                  onPressed: () => _update(
                    (s) => s.copyWith(skills: [...s.skills, 'Riverpod']),
                    "student.copyWith(skills: [...skills, 'Riverpod'])",
                  ),
                  child: const Text('Learn skill'),
                ),
                OutlinedButton(
                  onPressed: () => _update(
                    (s) => s.copyWith(isActive: !s.isActive),
                    'student.copyWith(isActive: !isActive)',
                  ),
                  child: const Text('Toggle active'),
                ),
              ],
            ),
            for (final h in _history.take(3)) CodeBlock(h),
          ],
        ),
        DemoCard(
          title: '2 · Value equality (==)',
          subtitle:
              'We build a brand new object with the same values. '
              'Different objects in memory, yet equal.',
          children: [
            CodeBlock(
              'student == twin            → ${_student == twin}\n'
              'identical(student, twin)  → ${identical(_student, twin)}\n'
              'student.hashCode == twin.hashCode → '
              '${_student.hashCode == twin.hashCode}',
            ),
            const Text(
              'Without Freezed, == would be false here. That is why Riverpod '
              'and Flutter can skip rebuilds when "nothing really changed".',
            ),
          ],
        ),
        DemoCard(
          title: '3 · JSON both ways',
          subtitle:
              'toJson() and fromJson() come from json_serializable. '
              'Note @JsonKey(name: "is_active").',
          children: [
            CodeBlock(
              'student.toJson() →\n'
              '${const JsonEncoder.withIndent('  ').convert(_student.toJson())}',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _jsonCtrl,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Edit JSON, then parse it',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                String result;
                try {
                  final map =
                      jsonDecode(_jsonCtrl.text) as Map<String, Object?>;
                  result = 'Student.fromJson(...) →\n${Student.fromJson(map)}';
                } catch (e) {
                  result =
                      '❌ $e\n\nTry removing "name" or making "age" a string '
                      'to see what happens with bad data.';
                }
                setState(() => _parsed = result);
              },
              child: const Text('Student.fromJson'),
            ),
            if (_parsed.isNotEmpty) CodeBlock(_parsed),
          ],
        ),
        DemoCard(
          title: '4 · Sealed union + switch',
          subtitle:
              'LoadState is exactly one of idle / loading / success / failure. '
              'The UI below is a single exhaustive switch.',
          children: [
            Container(
              height: 90,
              alignment: Alignment.center,
              child: switch (_load) {
                Idle() => const Text('Idle. Press a button.'),
                Loading() => const CircularProgressIndicator(),
                Success(:final items) => Text(
                  '✅ Loaded: ${items.join(', ')}',
                  style: const TextStyle(color: Colors.green),
                ),
                Failure(:final message) => Text(
                  '❌ $message',
                  style: const TextStyle(color: Colors.red),
                ),
              },
            ),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () => _simulateLoad(fail: false),
                  child: const Text('Load (success)'),
                ),
                OutlinedButton(
                  onPressed: () => _simulateLoad(fail: true),
                  child: const Text('Load (failure)'),
                ),
              ],
            ),
            CodeBlock('current value: $_load'),
          ],
        ),
        DemoCard(
          title: '5 · Custom methods with ._()',
          subtitle:
              'Money has a getter and an operator thanks to const Money._().',
          children: [
            CodeBlock(
              'const a = Money(cents: 1250);\n'
              'const b = Money(cents: 399);\n'
              '(a + b).formatted → '
              '${(const Money(cents: 1250) + const Money(cents: 399)).formatted}',
            ),
          ],
        ),
      ],
    );
  }
}
