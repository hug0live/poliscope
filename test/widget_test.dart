import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poliscope/src/app.dart';
import 'package:poliscope/src/data/questionnaire_repository.dart';
import 'package:poliscope/src/models/questionnaire_models.dart';
import 'package:poliscope/src/screens/questionnaire_screen.dart';

void main() {
  for (final width in [320.0, 800.0, 1440.0]) {
    testWidgets('landing layout and both quiz links at $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        PoliscopeApp(repository: _FakeQuestionnaireRepository()),
      );
      await tester.pump();
      expect(find.text('Poliscope'), findsOneWidget);
      expect(find.text('Le test politique qui te ressemble.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final headline = tester.getTopLeft(
        find.text('Le test politique qui te ressemble.'),
      );
      final modes = tester.getTopLeft(find.text('À toi de choisir le rythme'));
      if (width >= 1000) {
        expect(modes.dx, greaterThan(headline.dx + 300));
      } else {
        expect(modes.dy, greaterThan(headline.dy));
      }

      for (final mode in QuizMode.values) {
        final button = find.widgetWithText(
          FilledButton,
          mode == QuizMode.express
              ? 'Commencer le test express'
              : 'Explorer le test complet',
        );
        await tester.ensureVisible(button);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        await tester.tap(button);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(
          tester
              .widget<QuestionnaireScreen>(find.byType(QuestionnaireScreen))
              .mode,
          mode,
        );
        expect(find.text('Une question de test'), findsOneWidget);
        expect(tester.takeException(), isNull);
        Navigator.of(tester.element(find.byType(QuestionnaireScreen))).pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
    });
  }
}

class _FakeQuestionnaireRepository implements QuestionnaireRepository {
  @override
  Future<int> createSession({String? respondentName}) async => 1;

  @override
  Future<void> initialize() async {}

  @override
  Future<QuizBundle> loadQuiz({required QuizMode mode}) async => QuizBundle(
    mode: mode,
    questions: const [
      QuizQuestion(
        id: 1,
        category: 'Économie',
        text: 'Une question de test',
        axisCode: 'eco',
        orientation: 1,
      ),
    ],
    options: const [
      QuizOption(id: 1, code: 'A', label: 'D’accord', numericValue: 1),
    ],
    axes: const [],
  );

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
