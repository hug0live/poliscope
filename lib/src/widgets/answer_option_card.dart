import 'package:flutter/material.dart';

import '../models/questionnaire_models.dart';
import '../theme.dart';

class AnswerOptionCard extends StatelessWidget {
  const AnswerOptionCard({
    super.key,
    required this.option,
    required this.accentColor,
    required this.onTap,
    this.selected = false,
    this.enabled = true,
  });

  final QuizOption option;
  final Color accentColor;
  final VoidCallback onTap;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1 : 0.985,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.86),
                  ],
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.72),
          border: Border.all(
            color: selected
                ? accentColor.withValues(alpha: 0.85)
                : AppPalette.line.withValues(alpha: 0.9),
            width: selected ? 1.6 : 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.1),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected
                          ? accentColor
                          : accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      option.code,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: selected ? Colors.white : AppPalette.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppPalette.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.arrow_outward_rounded,
                    color: selected
                        ? accentColor
                        : AppPalette.mutedInk.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
