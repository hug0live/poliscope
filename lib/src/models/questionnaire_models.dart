enum QuizMode { express, complete }

const List<String> axisDisplayOrder = <String>[
  'eco',
  'auth',
  'cult',
  'eu',
  'ecolo',
];

extension QuizModeX on QuizMode {
  String get label => switch (this) {
    QuizMode.express => 'Mode express',
    QuizMode.complete => 'Mode complet',
  };

  String get subtitle => switch (this) {
    QuizMode.express => '25 questions bien choisies pour un résultat rapide.',
    QuizMode.complete => 'Les 200 questions pour une lecture plus fine.',
  };

  int get questionCount => switch (this) {
    QuizMode.express => 25,
    QuizMode.complete => 200,
  };

  String get durationLabel => switch (this) {
    QuizMode.express => '3 min',
    QuizMode.complete => '12 min',
  };
}

class QuizBundle {
  const QuizBundle({
    required this.mode,
    required this.questions,
    required this.options,
    required this.axes,
  });

  final QuizMode mode;
  final List<QuizQuestion> questions;
  final List<QuizOption> options;
  final List<AxisDefinition> axes;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.category,
    required this.text,
    required this.axisCode,
    required this.orientation,
  });

  final int id;
  final String category;
  final String text;
  final String axisCode;
  final int orientation;
}

class QuizOption {
  const QuizOption({
    required this.id,
    required this.code,
    required this.label,
    required this.numericValue,
  });

  final int id;
  final String code;
  final String label;
  final int numericValue;
}

class AxisDefinition {
  const AxisDefinition({
    required this.code,
    required this.label,
    required this.negativePole,
    required this.positivePole,
  });

  final String code;
  final String label;
  final String negativePole;
  final String positivePole;
}

class AxisScore {
  const AxisScore({
    required this.axisCode,
    required this.axisLabel,
    required this.negativePole,
    required this.positivePole,
    required this.rawScore,
    required this.answeredCount,
    required this.totalQuestions,
    required this.normalizedScore,
  });

  final String axisCode;
  final String axisLabel;
  final String negativePole;
  final String positivePole;
  final int rawScore;
  final int answeredCount;
  final int totalQuestions;
  final double normalizedScore;

  double get clampedScore {
    if (normalizedScore < -2) {
      return -2;
    }
    if (normalizedScore > 2) {
      return 2;
    }
    return normalizedScore;
  }

  double get trackPosition => (clampedScore + 2) / 4;

  bool get isNeutral => clampedScore.abs() < 0.35;

  String get leaningLabel {
    if (isNeutral) {
      return 'Position plutôt nuancée sur cet axe.';
    }
    if (clampedScore.isNegative) {
      return 'Tu penches vers $negativePole.';
    }
    return 'Tu penches vers $positivePole.';
  }
}

class ProfileMatch {
  const ProfileMatch({
    required this.profileCode,
    required this.profileLabel,
    required this.description,
    required this.distance,
    required this.matchPercent,
  });

  final String profileCode;
  final String profileLabel;
  final String description;
  final double distance;
  final double matchPercent;
}

class QuizResult {
  const QuizResult({
    required this.sessionId,
    required this.winner,
    required this.matches,
    required this.axisScores,
    required this.answeredCount,
    required this.totalQuestions,
  });

  final int sessionId;
  final ProfileMatch winner;
  final List<ProfileMatch> matches;
  final List<AxisScore> axisScores;
  final int answeredCount;
  final int totalQuestions;
}
