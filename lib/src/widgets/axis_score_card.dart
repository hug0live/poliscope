import 'package:flutter/material.dart';

import '../models/questionnaire_models.dart';
import '../theme.dart';
import 'poliscope_backdrop.dart';

class AxisScoreCard extends StatelessWidget {
  const AxisScoreCard({
    super.key,
    required this.score,
    required this.accentColor,
  });

  final AxisScore score;
  final Color accentColor;

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
              Expanded(
                child: Text(score.axisLabel, style: theme.textTheme.titleLarge),
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
                  _signedScore(score.normalizedScore),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppPalette.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(score.leaningLabel, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth - 20;
              final left = (score.trackPosition * trackWidth)
                  .clamp(0, trackWidth)
                  .toDouble();

              return SizedBox(
                height: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      top: 7,
                      bottom: 7,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              AppPalette.ink.withValues(alpha: 0.12),
                              accentColor.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: trackWidth / 2,
                      top: 2,
                      bottom: 2,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: AppPalette.ink.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      left: left,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  score.negativePole,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppPalette.mutedInk,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  score.positivePole,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppPalette.mutedInk,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _signedScore(double value) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}';
  }
}
