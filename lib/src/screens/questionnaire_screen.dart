import 'package:flutter/material.dart';

import '../data/questionnaire_repository.dart';
import '../models/questionnaire_models.dart';
import '../theme.dart';
import '../widgets/answer_option_card.dart';
import '../widgets/poliscope_backdrop.dart';
import 'result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({
    super.key,
    required this.repository,
    required this.mode,
  });

  final QuestionnaireRepository repository;
  final QuizMode mode;

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  static const int _previewThreshold = 8;

  QuizBundle? _bundle;
  int? _sessionId;
  Object? _error;
  int _currentIndex = 0;
  bool _busy = false;
  final Map<int, int> _answers = <int, int>{};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    if (_bundle == null) {
      return _StateScaffold(
        title: _error == null
            ? 'On te prépare un parcours aux petits oignons.'
            : 'Impossible de charger le questionnaire.',
        subtitle: _error == null
            ? 'On assemble les questions et les axes de ta session.'
            : '$_error',
        showSpinner: _error == null,
      );
    }

    final bundle = _bundle!;
    final question = bundle.questions[_currentIndex];
    final progress = (_currentIndex + 1) / bundle.questions.length;
    final accentColor = axisColor(question.axisCode);
    final selectedOptionId = _answers[question.id];
    final answeredCount = _answers.length;
    final canPreview =
        answeredCount >= _previewThreshold &&
        answeredCount < bundle.questions.length;
    final theme = Theme.of(context);

    return Scaffold(
      body: PoliscopeBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.mode.label,
                                style: theme.textTheme.titleLarge,
                              ),
                              Text(
                                '$answeredCount réponse${answeredCount > 1 ? 's' : ''} enregistrée${answeredCount > 1 ? 's' : ''}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PoliscopePanel(
                      accentColor: accentColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Question ${_currentIndex + 1} / ${bundle.questions.length}',
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  axisPillLabel(question.axisCode),
                                  style: theme.textTheme.labelLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: AppPalette.line.withValues(
                                alpha: 0.65,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Réponds au feeling. À partir de $_previewThreshold réponses, on peut déjà te donner une première tendance.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 360),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.08, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: SingleChildScrollView(
                          key: ValueKey<int>(question.id),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PoliscopePanel(
                                accentColor: accentColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        _Tag(
                                          icon: axisIcon(question.axisCode),
                                          label: question.category,
                                          color: accentColor,
                                        ),
                                        _Tag(
                                          icon: Icons.bolt_rounded,
                                          label: selectedOptionId == null
                                              ? 'À répondre'
                                              : 'Réponse enregistrée',
                                          color: AppPalette.ink,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      question.text,
                                      style: theme.textTheme.headlineLarge
                                          ?.copyWith(
                                            fontSize: 34,
                                            height: 1.05,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Pas besoin de chercher la réponse parfaite: prends la position qui te ressemble le plus.',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              for (final option in bundle.options) ...[
                                AnswerOptionCard(
                                  option: option,
                                  accentColor: accentColor,
                                  selected: selectedOptionId == option.id,
                                  enabled: !_busy,
                                  onTap: () => _recordAnswer(option.id),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _currentIndex > 0 && !_busy
                                ? _goToPrevious
                                : null,
                            icon: const Icon(Icons.keyboard_backspace_rounded),
                            label: const Text('Question précédente'),
                          ),
                        ),
                      ],
                    ),
                    if (canPreview) ...[
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _finishQuiz(requirePreview: true),
                        icon: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_rounded),
                        label: const Text('Voir ma tendance maintenant'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _bootstrap() async {
    try {
      final bundle = await widget.repository.loadQuiz(mode: widget.mode);
      final sessionId = await widget.repository.createSession(
        respondentName: widget.mode.name,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _bundle = bundle;
        _sessionId = sessionId;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error);
    }
  }

  Future<void> _recordAnswer(int optionId) async {
    final bundle = _bundle;
    final sessionId = _sessionId;
    if (bundle == null || sessionId == null || _busy) {
      return;
    }

    final question = bundle.questions[_currentIndex];
    setState(() {
      _busy = true;
      _answers[question.id] = optionId;
    });

    await widget.repository.saveAnswer(
      sessionId: sessionId,
      questionId: question.id,
      optionId: optionId,
    );

    if (!mounted) {
      return;
    }

    if (_currentIndex == bundle.questions.length - 1) {
      await _finishQuiz();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) {
      return;
    }

    setState(() {
      _currentIndex += 1;
      _busy = false;
    });
  }

  Future<void> _finishQuiz({bool requirePreview = false}) async {
    final bundle = _bundle;
    final sessionId = _sessionId;

    if (bundle == null || sessionId == null) {
      return;
    }

    if (_answers.isEmpty) {
      _showMessage('Il faut au moins une réponse pour sortir une tendance.');
      return;
    }

    if (requirePreview && _answers.length < _previewThreshold) {
      _showMessage(
        'Encore quelques réponses et on pourra te montrer un aperçu fiable.',
      );
      return;
    }

    setState(() => _busy = true);

    try {
      final result = await widget.repository.loadResult(
        sessionId: sessionId,
        totalQuestions: bundle.questions.length,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(result: result, mode: widget.mode),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('Le calcul du résultat a bloqué: $error');
      setState(() => _busy = false);
    }
  }

  void _goToPrevious() {
    if (_currentIndex == 0 || _busy) {
      return;
    }
    setState(() => _currentIndex -= 1);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StateScaffold extends StatelessWidget {
  const _StateScaffold({
    required this.title,
    required this.subtitle,
    this.showSpinner = false,
  });

  final String title;
  final String subtitle;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PoliscopeBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: PoliscopePanel(
                  accentColor: AppPalette.sky,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppPalette.sky.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: showSpinner
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.8,
                                  color: AppPalette.sky,
                                ),
                              )
                            : const Icon(
                                Icons.error_outline_rounded,
                                color: AppPalette.sky,
                              ),
                      ),
                      const SizedBox(height: 20),
                      Text(title, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(subtitle, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppPalette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
