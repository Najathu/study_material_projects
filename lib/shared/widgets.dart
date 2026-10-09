import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network_log.dart';

/// Monospace, selectable code with a copy button.
class CodeBlock extends StatelessWidget {
  const CodeBlock(this.code, {super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 12, 40, 12),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Copy',
              iconSize: 18,
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Copied')));
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled card used by the demos.
class DemoCard extends StatelessWidget {
  const DemoCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: text.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: text.bodySmall),
            ],
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Live list of every HTTP call made through our Dio instance.
/// It just watches [networkLogProvider]: the interceptor writes, the UI reads.
class NetworkLogView extends ConsumerWidget {
  const NetworkLogView({super.key, this.maxItems = 8});

  final int maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(networkLogProvider);
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('No requests yet. Press a button above.'),
      );
    }
    return Column(
      children: [
        for (final e in entries.take(maxItems))
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: _StatusChip(entry: e),
            title: Text(
              '${e.method} ${Uri.parse(e.url).path}'
              '${Uri.parse(e.url).hasQuery ? '?${Uri.parse(e.url).query}' : ''}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            subtitle: Text(
              e.durationMs == null
                  ? 'in flight…'
                  : '${e.durationMs} ms${e.error != null ? ' · ${e.error}' : ''}',
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => ref.read(networkLogProvider.notifier).clear(),
            child: const Text('Clear log'),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final code = entry.statusCode;
    final color = switch (code) {
      null when entry.durationMs == null => Colors.blueGrey,
      null => Colors.red,
      < 300 => Colors.green,
      < 500 => Colors.orange,
      _ => Colors.red,
    };
    return SizedBox(
      width: 44,
      child: Chip(
        label: Text(
          code?.toString() ?? (entry.durationMs == null ? '…' : 'ERR'),
        ),
        labelStyle: const TextStyle(fontSize: 11, color: Colors.white),
        backgroundColor: color,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        side: BorderSide.none,
      ),
    );
  }
}

/// Opens the network log in a bottom sheet from anywhere.
void showNetworkLog(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network inspector (fed by a Dio interceptor)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            NetworkLogView(maxItems: 30),
          ],
        ),
      ),
    ),
  );
}
