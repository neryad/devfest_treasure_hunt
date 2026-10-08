import 'package:devfest_treasure_hunt/domain/entities/challenge_question.dart';
import 'package:devfest_treasure_hunt/domain/entities/gym_challenge.dart';
import 'package:devfest_treasure_hunt/domain/utils/challenge_question_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const question = ChallengeQuestion(
    id: 'q1',
    question: 'Question?',
    options: ['A', 'B'],
    correctAnswer: 'A',
    hint: 'Hint',
    codeSnippet: 'print("A");',
  );

  test('question bank survives JSON round trip', () {
    const challenge = GymChallenge(
      type: ChallengeType.code,
      questionBank: [question],
    );

    final decoded = GymChallenge.fromJson(challenge.toJson());

    expect(decoded, challenge);
    expect(decoded.questionBank.single, question);
  });

  test('legacy JSON without a question bank remains compatible', () {
    final challenge = GymChallenge.fromJson({
      'type': 'trivia',
      'question': 'Legacy?',
      'options': ['Yes', 'No'],
      'correctAnswer': 'Yes',
    });

    expect(challenge.questionBank, isEmpty);
    expect(challenge.question, 'Legacy?');
    expect(challenge.correctAnswer, 'Yes');
  });

  test('selection is deterministic after recreating the bank', () {
    const bank = [
      question,
      ChallengeQuestion(
        id: 'q2',
        question: 'Another?',
        options: ['C', 'D'],
        correctAnswer: 'C',
      ),
    ];
    final recreated = bank
        .map((item) => ChallengeQuestion.fromJson(item.toJson()))
        .toList();

    final first = ChallengeQuestionSelector.select(
      participantId: 'participant-42',
      gymId: 'gym-web',
      bank: bank,
    );
    final afterRestart = ChallengeQuestionSelector.select(
      participantId: 'participant-42',
      gymId: 'gym-web',
      bank: recreated,
    );

    expect(afterRestart?.id, first?.id);
  });

  test('empty banks do not assign a question', () {
    final selected = ChallengeQuestionSelector.select(
      participantId: 'participant-42',
      gymId: 'gym-web',
      bank: const [],
    );

    expect(selected, isNull);
  });
}
