import 'package:flutter/material.dart';

import '../data/questionnaire_repository.dart';
import '../models/questionnaire_models.dart';
import '../theme.dart';
import '../widgets/poliscope_backdrop.dart';
import 'questionnaire_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final QuestionnaireRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _revealed = false;

  static const List<String> _profiles = <String>[
    'Gauche sociale',
    'Écologiste',
    'Centre progressiste',
    'Droite républicaine',
    'Droite nationale',
    'Libertaire solidaire',
  ];

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

    return Scaffold(
      body: PoliscopeBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 700),
                      opacity: _revealed ? 1 : 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        offset: _revealed ? Offset.zero : const Offset(0, 0.08),
                        child: PoliscopePanel(
                          accentColor: AppPalette.coral,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppPalette.coral.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Questionnaire politique',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppPalette.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Le test politique qui te ressemble.',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontSize: 42,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Tu réponds au feeling, l’app compare tes choix sur plusieurs axes et te montre les courants politiques français qui te ressemblent le plus.',
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: const [
                                  _InfoChip(
                                    icon: Icons.auto_awesome_rounded,
                                    label: '8 profils',
                                  ),
                                  _InfoChip(
                                    icon: Icons.tune_rounded,
                                    label: '5 axes',
                                  ),
                                  _InfoChip(
                                    icon: Icons.smartphone_rounded,
                                    label: 'Mobile-first',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 850),
                      opacity: _revealed ? 1 : 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 850),
                        curve: Curves.easeOutCubic,
                        offset: _revealed ? Offset.zero : const Offset(0, 0.12),
                        child: Column(
                          children: [
                            _ModeCard(
                              mode: QuizMode.express,
                              accentColor: AppPalette.sky,
                              ctaLabel: 'Je veux un aperçu rapide',
                              onTap: () => _openQuiz(QuizMode.express),
                            ),
                            const SizedBox(height: 14),
                            _ModeCard(
                              mode: QuizMode.complete,
                              accentColor: AppPalette.lime,
                              ctaLabel: 'Je vais au bout du test',
                              onTap: () => _openQuiz(QuizMode.complete),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    PoliscopePanel(
                      accentColor: AppPalette.gold,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ce que tu vas trouver ici',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 14),
                          const _FeatureLine(
                            title: 'Pas de jargon inutile',
                            description:
                                'Les questions ont été reformulées pour être directes et compréhensibles.',
                          ),
                          const SizedBox(height: 12),
                          const _FeatureLine(
                            title: 'Un résultat nuancé',
                            description:
                                'On parle de proximité politique, pas d’étiquette définitive.',
                          ),
                          const SizedBox(height: 12),
                          const _FeatureLine(
                            title: 'Un vrai rythme mobile',
                            description:
                                'Grandes cartes, progression claire, et un mode express qui évite le tunnel de 200 questions.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    PoliscopePanel(
                      accentColor: AppPalette.cyan,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quelques profils que tu peux croiser',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _profiles
                                .map(
                                  (profile) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppPalette.line,
                                      ),
                                    ),
                                    child: Text(
                                      profile,
                                      style: theme.textTheme.labelLarge,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ],
                      ),
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

  void _openQuiz(QuizMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            QuestionnaireScreen(repository: widget.repository, mode: mode),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
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
