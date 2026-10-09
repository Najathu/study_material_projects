import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets.dart';
import 'lessons.dart';
import 'quiz_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mastered = ref.watch(masteredTopicsProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Stack Academy'),
        actions: [
          IconButton(
            tooltip: 'Network inspector',
            icon: const Icon(Icons.network_check),
            onPressed: () => showNetworkLog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Learn the modern Flutter app stack', style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Each lesson has three tabs: Learn (explanation + code), '
            'Try it (a live demo) and Quiz. This app itself is built with '
            'everything it teaches. Open the source next to it while you study.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: mastered.length / lessons.length,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
            '${mastered.length} / ${lessons.length} quizzes passed',
            style: text.bodySmall,
          ),
          const SizedBox(height: 16),
          for (final (i, lesson) in lessons.indexed)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: lesson.color.withValues(alpha: 0.15),
                  foregroundColor: lesson.color,
                  child: Icon(lesson.icon),
                ),
                title: Text('${i + 1}. ${lesson.title}'),
                subtitle: Text(
                  lesson.oneLiner,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: mastered.contains(lesson.topic)
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.chevron_right),
                // GO_ROUTER: navigate by URL. "/lesson/riverpod" etc.
                onTap: () => context.go('/lesson/${lesson.topic.name}'),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Final project: Pet Store'),
              subtitle: const Text(
                'A real feature using all six together: OpenAPI-generated '
                'client → Dio → Freezed models → Riverpod → GoRouter.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/pets'),
            ),
          ),
        ],
      ),
    );
  }
}
