import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets.dart';
import '../demos/dio_demo.dart';
import '../demos/freezed_demo.dart';
import '../demos/openapi_demo.dart';
import '../demos/riverpod_demo.dart';
import '../demos/router_demo.dart';
import '../demos/swagger_demo.dart';
import 'lessons.dart';
import 'quiz_state.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final lesson = lessonFor(topic);
    final next = topic.index + 1 < Topic.values.length
        ? Topic.values[topic.index + 1]
        : null;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lesson.title),
          actions: [
            IconButton(
              tooltip: 'Network inspector',
              icon: const Icon(Icons.network_check),
              onPressed: () => showNetworkLog(context),
            ),
            if (next != null)
              TextButton(
                onPressed: () => context.go('/lesson/${next.name}'),
                child: const Text('Next →'),
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'Learn'),
              Tab(icon: Icon(Icons.science), text: 'Try it'),
              Tab(icon: Icon(Icons.quiz), text: 'Quiz'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LearnTab(lesson: lesson),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [_demoFor(topic)],
            ),
            _QuizTab(lesson: lesson),
          ],
        ),
      ),
    );
  }

  Widget _demoFor(Topic topic) => switch (topic) {
    Topic.riverpod => const RiverpodDemo(),
    Topic.dio => const DioDemo(),
    Topic.freezed => const FreezedDemo(),
    Topic.goRouter => const RouterDemo(),
    Topic.openapi => const OpenApiDemo(),
    Topic.swagger => const SwaggerDemo(),
  };
}

class _LearnTab extends StatelessWidget {
  const _LearnTab({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: lesson.color.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('In one sentence', style: text.labelLarge),
                const SizedBox(height: 4),
                Text(lesson.oneLiner, style: text.titleMedium),
                const Divider(height: 24),
                Text('💡 Analogy', style: text.labelLarge),
                const SizedBox(height: 4),
                Text(lesson.analogy),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final s in lesson.sections) ...[
          const SizedBox(height: 16),
          Text(s.heading, style: text.titleLarge),
          if (s.body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(s.body, style: text.bodyMedium?.copyWith(height: 1.5)),
          ],
          if (s.code != null) CodeBlock(s.code!),
        ],
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️ Common mistakes', style: text.titleMedium),
                const SizedBox(height: 8),
                for (final m in lesson.mistakes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $m'),
                  ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📂 Read in this project', style: text.titleMedium),
                const SizedBox(height: 8),
                for (final f in lesson.filesInThisApp)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      f,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Next: open the "Try it" tab →',
          textAlign: TextAlign.center,
          style: text.bodySmall,
        ),
      ],
    );
  }
}

class _QuizTab extends ConsumerWidget {
  const _QuizTab({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(quizAnswersProvider);
    final passed = ref.watch(masteredTopicsProvider).contains(lesson.topic);
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (passed)
          const Card(
            color: Colors.green,
            child: ListTile(
              leading: Icon(Icons.emoji_events, color: Colors.white),
              title: Text(
                'All correct, lesson mastered!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        for (final (qi, q) in lesson.quiz.indexed)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Q${qi + 1}. ${q.question}', style: text.titleSmall),
                  const SizedBox(height: 8),
                  for (final (oi, option) in q.options.indexed)
                    _QuizOption(
                      label: option,
                      chosen: answers[QuizAnswers.keyFor(lesson.topic, qi)],
                      index: oi,
                      correct: q.answerIndex,
                      onTap: () => ref
                          .read(quizAnswersProvider.notifier)
                          .answer(lesson.topic, qi, oi),
                    ),
                  if (answers[QuizAnswers.keyFor(lesson.topic, qi)] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Why: ${q.why}', style: text.bodySmall),
                    ),
                ],
              ),
            ),
          ),
        TextButton(
          onPressed: () =>
              ref.read(quizAnswersProvider.notifier).reset(lesson.topic),
          child: const Text('Reset quiz'),
        ),
      ],
    );
  }
}

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.label,
    required this.chosen,
    required this.index,
    required this.correct,
    required this.onTap,
  });

  final String label;
  final int? chosen;
  final int index;
  final int correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final answered = chosen != null;
    final isChosen = chosen == index;
    final Color? color = !answered
        ? null
        : index == correct
        ? Colors.green
        : isChosen
        ? Colors.red
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          foregroundColor: color,
          side: color == null ? null : BorderSide(color: color, width: 2),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
