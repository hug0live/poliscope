import 'package:flutter/material.dart';

import '../models/questionnaire_models.dart';
import '../theme.dart';
import '../widgets/axis_score_card.dart';
import '../widgets/poliscope_backdrop.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result, required this.mode});

  final QuizResult result;
  final QuizMode mode;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _revealed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final winner = widget.result.winner;
    final strongestAxis = _strongestAxis(widget.result.axisScores);

    return Scaffold(
      body: PoliscopeBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 700),
                  opacity: _revealed ? 1 : 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    offset: _revealed ? Offset.zero : const Offset(0, 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: _backToHome,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              icon: const Icon(Icons.home_rounded),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ton résultat',
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PoliscopePanel(
                          accentColor: AppPalette.coral,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: AppPalette.coral.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Ton courant le plus proche',
                                  style: theme.textTheme.labelLarge,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                winner.profileLabel,
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontSize: 40,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                winner.description,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _ScoreChip(
                                    icon: Icons.favorite_rounded,
                                    label:
                                        '${winner.matchPercent.toStringAsFixed(0)} % de proximité',
                                  ),
                                  _ScoreChip(
                                    icon: Icons.quiz_rounded,
                                    label:
                                        '${widget.result.answeredCount} / ${widget.result.totalQuestions} réponses prises en compte',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              PoliscopePanel(
                                accentColor: axisColor(strongestAxis.axisCode),
                                padding: const EdgeInsets.all(18),
                                fillOpacity: 0.58,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: axisColor(
                                          strongestAxis.axisCode,
                                        ).withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        axisIcon(strongestAxis.axisCode),
                                        color: axisColor(
                                          strongestAxis.axisCode,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ton axe le plus marqué',
                                            style: theme.textTheme.labelLarge,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            strongestAxis.leaningLabel,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        PoliscopePanel(
                          accentColor: AppPalette.sky,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tes proximités les plus fortes',
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 14),
                              for (final entry in widget.result.matches.take(
                                3,
                              )) ...[
                                _MatchRow(match: entry),
                                const SizedBox(height: 12),
                              ],
                              if (widget.mode == QuizMode.express)
                                Text(
                                  'Le mode express te donne déjà une vraie tendance. Si tu veux un résultat encore plus fin, relance le mode complet depuis l’accueil.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ta boussole politique',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        for (final score in widget.result.axisScores) ...[
                          AxisScoreCard(
                            score: score,
                            accentColor: axisColor(score.axisCode),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 6),
                        PoliscopePanel(
                          accentColor: AppPalette.gold,
                          child: Text(
                            'Ce résultat est indicatif. Il sert à situer la proximité entre tes réponses et plusieurs familles politiques françaises, pas à te coller une étiquette pour toujours.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _backToHome,
                          icon: const Icon(Icons.home_rounded),
                          label: const Text('Retour à l’accueil'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AxisScore _strongestAxis(List<AxisScore> scores) {
    return scores.reduce((best, current) {
      return current.clampedScore.abs() > best.clampedScore.abs()
          ? current
          : best;
    });
  }

  void _backToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppPalette.ink),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match});

  final ProfileMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                match.profileLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppPalette.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${match.matchPercent.toStringAsFixed(0)} %',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: match.matchPercent / 100,
            minHeight: 10,
            backgroundColor: AppPalette.line.withValues(alpha: 0.7),
            valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.sky),
          ),
        ),
        const SizedBox(height: 6),
        Text(match.description, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
