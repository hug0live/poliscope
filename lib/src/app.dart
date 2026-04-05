import 'package:flutter/material.dart';

import 'data/questionnaire_repository.dart';
import 'screens/home_screen.dart';
import 'theme.dart';
import 'widgets/poliscope_backdrop.dart';

class PoliscopeApp extends StatefulWidget {
  PoliscopeApp({super.key, QuestionnaireRepository? repository})
    : repository = repository ?? SqliteQuestionnaireRepository();

  final QuestionnaireRepository repository;

  @override
  State<PoliscopeApp> createState() => _PoliscopeAppState();
}

class _PoliscopeAppState extends State<PoliscopeApp> {
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = widget.repository.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poliscope',
      debugShowCheckedModeBanner: false,
      theme: buildPoliscopeTheme(),
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _LaunchState(
              title: 'Poliscope',
              subtitle: 'On prépare ton test politique.',
              showSpinner: true,
            );
          }

          if (snapshot.hasError) {
            return _LaunchState(
              title: 'Oups, lancement bloqué',
              subtitle: '${snapshot.error}',
            );
          }

          return HomeScreen(repository: widget.repository);
        },
      ),
    );
  }
}

class _LaunchState extends StatelessWidget {
  const _LaunchState({
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: PoliscopePanel(
                  accentColor: AppPalette.coral,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppPalette.coral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: showSpinner
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppPalette.coral,
                                ),
                              )
                            : const Icon(
                                Icons.error_outline_rounded,
                                color: AppPalette.coral,
                                size: 28,
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
