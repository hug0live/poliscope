import 'package:flutter/material.dart';

import '../data/questionnaire_repository.dart';
import '../models/questionnaire_models.dart';
import '../theme.dart';
import '../widgets/poliscope_backdrop.dart';
import 'questionnaire_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.repository});

  final QuestionnaireRepository repository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PoliscopeBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.explore_rounded,
                          color: AppPalette.coral,
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Text('Poliscope', style: theme.textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 40),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 800;
                        final introduction = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TES IDÉES, EN PERSPECTIVE',
                              style: theme.textTheme.labelLarge?.copyWith(
                                letterSpacing: 2,
                                color: AppPalette.mutedInk,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Le test politique qui te ressemble.',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: wide ? 64 : 42,
                                height: 1.08,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Économie, écologie, société… Explore tes convictions et découvre les courants politiques français les plus proches de tes idées.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 18,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final code in axisDisplayOrder)
                                  Chip(
                                    avatar: Icon(
                                      axisIcon(code),
                                      size: 18,
                                      color: AppPalette.ink,
                                    ),
                                    label: Text(axisPillLabel(code)),
                                    backgroundColor: axisColor(
                                      code,
                                    ).withValues(alpha: 0.12),
                                    side: BorderSide.none,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '5 axes de réflexion · 8 profils de référence',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        );
                        final modes = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'À toi de choisir le rythme',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _ModeCard(
                              mode: QuizMode.express,
                              accentColor: AppPalette.sky,
                              ctaLabel: 'Commencer le test express',
                              onTap: () => _openQuiz(context, QuizMode.express),
                            ),
                            const SizedBox(height: 16),
                            _ModeCard(
                              mode: QuizMode.complete,
                              accentColor: AppPalette.lime,
                              ctaLabel: 'Explorer le test complet',
                              onTap: () =>
                                  _openQuiz(context, QuizMode.complete),
                            ),
                          ],
                        );
                        return wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 6, child: introduction),
                                  const SizedBox(width: 64),
                                  Expanded(flex: 5, child: modes),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  introduction,
                                  const SizedBox(height: 32),
                                  modes,
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 40),
                    PoliscopePanel(
                      accentColor: AppPalette.coral,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mieux te situer, sans te coller une étiquette.',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 24),
                          const _FeatureLine(
                            title: '01 · Donne ton point de vue',
                            description:
                                'Choisis la réponse qui te correspond le mieux. Tu peux revenir à la question précédente pour la modifier.',
                          ),
                          const SizedBox(height: 18),
                          const _FeatureLine(
                            title: '02 · Découvre tes proximités',
                            description:
                                'Compare les profils proches de tes réponses et retrouve ton positionnement sur chacun des cinq axes.',
                          ),
                          const SizedBox(height: 18),
                          const _FeatureLine(
                            title: '03 · Garde ton esprit critique',
                            description:
                                'Le résultat est une piste de réflexion, pas une identité définitive ni une consigne de vote.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Poliscope · Un point de départ pour réfléchir à tes idées.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openQuiz(BuildContext context, QuizMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuestionnaireScreen(repository: repository, mode: mode),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.accentColor,
    required this.ctaLabel,
    required this.onTap,
  });

  final QuizMode mode;
  final Color accentColor;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PoliscopePanel(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Icon(
                  mode == QuizMode.express
                      ? Icons.flash_on_rounded
                      : Icons.layers_rounded,
                  color: accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mode.label, style: theme.textTheme.headlineMedium),
                    Text(
                      '${mode.durationLabel} • ${mode.questionCount} questions',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(mode.subtitle, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: accentColor == AppPalette.sky
                  ? AppPalette.ink
                  : accentColor,
              foregroundColor: accentColor == AppPalette.sky
                  ? Colors.white
                  : AppPalette.ink,
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            color: AppPalette.ink,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppPalette.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
