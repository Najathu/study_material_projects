import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets.dart';

// ── Providers used only by this demo ────────────────────────────────────────

/// 1. A Notifier: state (int) + methods that change it.
class Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final counterProvider = NotifierProvider<Counter, int>(Counter.new);

/// 2. A derived Provider: recomputes whenever counterProvider changes.
final counterInfoProvider = Provider<String>((ref) {
  final n = ref.watch(counterProvider);
  return '$n is ${n.isEven ? 'even' : 'odd'}, $n² = ${n * n}';
});

/// Lifecycle messages so you can SEE providers being created and disposed.
class LifecycleLog extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  void add(String msg) {
    final t = TimeOfDay.now();
    final m = t.minute.toString().padLeft(2, '0');
    // Schedule to avoid modifying a provider while another is building.
    Future.microtask(
      () => state = ['${t.hour}:$m  $msg', ...state].take(6).toList(),
    );
  }
}

final lifecycleLogProvider = NotifierProvider<LifecycleLog, List<String>>(
  LifecycleLog.new,
);

/// 3. An autoDispose StreamProvider: a ticking clock.
/// Created when first watched, disposed when nobody watches anymore.
final tickerProvider = StreamProvider.autoDispose<int>((ref) {
  final log = ref.read(lifecycleLogProvider.notifier);
  log.add('tickerProvider CREATED');
  ref.onDispose(() => log.add('tickerProvider DISPOSED'));
  return Stream.periodic(const Duration(seconds: 1), (i) => i + 1);
});

// ── UI ──────────────────────────────────────────────────────────────────────

class RiverpodDemo extends ConsumerStatefulWidget {
  const RiverpodDemo({super.key});

  @override
  ConsumerState<RiverpodDemo> createState() => _RiverpodDemoState();
}

class _RiverpodDemoState extends ConsumerState<RiverpodDemo> {
  bool _showTicker = false;

  @override
  Widget build(BuildContext context) {
    // ref.watch → this widget rebuilds when the counter changes.
    final count = ref.watch(counterProvider);
    final info = ref.watch(counterInfoProvider);

    // ref.listen → side effects (snackbar), not rebuilding.
    ref.listen(counterProvider, (previous, next) {
      if (next == 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ref.listen fired: you reached 10!')),
        );
      }
    });

    return Column(
      children: [
        DemoCard(
          title: '1 · Notifier + ref.watch / ref.read',
          subtitle:
              'The buttons call ref.read(counterProvider.notifier).increment(). '
              'The number uses ref.watch, so it rebuilds.',
          children: [
            Center(
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.remove),
                  onPressed: () =>
                      ref.read(counterProvider.notifier).decrement(),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      ref.read(counterProvider.notifier).increment(),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => ref.read(counterProvider.notifier).reset(),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const Text('Tip: reach 10 to see ref.listen trigger a snackbar.'),
          ],
        ),
        DemoCard(
          title: '2 · Derived provider',
          subtitle:
              'counterInfoProvider watches counterProvider. You never update it '
              'yourself, it recomputes automatically.',
          children: [
            Text(info, style: Theme.of(context).textTheme.titleMedium),
            const CodeBlock(
              '''final counterInfoProvider = Provider<String>((ref) {
  final n = ref.watch(counterProvider);
  return '\$n is \${n.isEven ? 'even' : 'odd'}';
});''',
            ),
          ],
        ),
        const DemoCard(
          title: '3 · State survives navigation',
          subtitle:
              'Providers live in ProviderScope, not in the widget. Go back to '
              'the home screen, come back: the counter is still there. '
              '(It is NOT autoDispose.)',
          children: [],
        ),
        DemoCard(
          title: '4 · autoDispose + StreamProvider',
          subtitle:
              'Toggle the clock. Showing it makes a widget watch tickerProvider '
              '(created). Hiding it means nobody watches → disposed.',
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show ticking clock'),
              value: _showTicker,
              onChanged: (v) => setState(() => _showTicker = v),
            ),
            if (_showTicker) const _TickerText(),
            const SizedBox(height: 8),
            for (final line in ref.watch(lifecycleLogProvider))
              Text(
                line,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
          ],
        ),
        DemoCard(
          title: '5 · FutureProvider with real data',
          subtitle:
              'The Pet Store screen uses FutureProvider.family + AsyncValue '
              'for loading / error / data.',
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.pets),
              label: const Text('Open Pet Store'),
              onPressed: () => context.push('/pets'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TickerText extends ConsumerWidget {
  const _TickerText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tick = ref.watch(tickerProvider);
    return Text(switch (tick) {
      AsyncData(:final value) => '⏱ $value seconds since created',
      AsyncError(:final error) => 'Error: $error',
      _ => '⏱ starting…',
    }, style: Theme.of(context).textTheme.titleMedium);
  }
}
