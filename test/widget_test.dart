import 'package:flutter_test/flutter_test.dart';

import 'package:poliscope/src/app.dart';
import 'package:poliscope/src/data/questionnaire_repository.dart';
import 'package:poliscope/src/models/questionnaire_models.dart';

void main() {
  testWidgets('shows the landing page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PoliscopeApp(repository: _FakeQuestionnaireRepository()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Mode express'), findsOneWidget);
    expect(find.text('Mode complet'), findsOneWidget);
    expect(find.text('Le test politique qui te ressemble.'), findsOneWidget);
  });
}

class _FakeQuestionnaireRepository implements QuestionnaireRepository {
  @override
  Future<int> createSession({String? respondentName}) async => 1;

  @override
  Future<void> initialize() async {}

  @override
  Future<QuizBundle> loadQuiz({required QuizMode mode}) {
    throw UnimplementedError();
  }

  @override
  Future<QuizResult> loadResult({
    required int sessionId,
    required int totalQuestions,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveAnswer({
    required int sessionId,
    required int questionId,
    required int optionId,
  }) async {}
}
