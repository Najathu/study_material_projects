import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lessons.dart';

/// Remembers which option was picked for each quiz question.
/// Key: "topic/questionIndex" → chosen option index.
class QuizAnswers extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {};

  static String keyFor(Topic topic, int question) => '${topic.name}/$question';

  void answer(Topic topic, int question, int option) {
    state = {...state, keyFor(topic, question): option};
  }

  void reset(Topic topic) {
    state = {
      for (final e in state.entries)
        if (!e.key.startsWith('${topic.name}/')) e.key: e.value,
    };
  }
}

final quizAnswersProvider = NotifierProvider<QuizAnswers, Map<String, int>>(
  QuizAnswers.new,
);

/// DERIVED provider: computed from quizAnswersProvider.
/// A lesson counts as "mastered" when every quiz answer is correct.
final masteredTopicsProvider = Provider<Set<Topic>>((ref) {
  final answers = ref.watch(quizAnswersProvider);
  return {
    for (final lesson in lessons)
      if (lesson.quiz.indexed.every(
        (q) =>
            answers[QuizAnswers.keyFor(lesson.topic, q.$1)] == q.$2.answerIndex,
      ))
        lesson.topic,
  };
});
