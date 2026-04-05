import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/questionnaire_models.dart';

abstract class QuestionnaireRepository {
  Future<void> initialize();

  Future<QuizBundle> loadQuiz({required QuizMode mode});

  Future<int> createSession({String? respondentName});

  Future<void> saveAnswer({
    required int sessionId,
    required int questionId,
    required int optionId,
  });

  Future<QuizResult> loadResult({
    required int sessionId,
    required int totalQuestions,
  });
}

class SqliteQuestionnaireRepository implements QuestionnaireRepository {
  SqliteQuestionnaireRepository({
    this.assetPath = 'assets/data/questionnaire_politique_15_25.sqlite',
    this.webAssetPath = 'assets/data/questionnaire_politique_15_25.json',
  });

  final String assetPath;
  final String webAssetPath;

  static const Map<String, int> _expressTargets = <String, int>{
    'eco': 7,
    'auth': 5,
    'cult': 5,
    'eu': 4,
    'ecolo': 4,
  };

  static const String _axisSortSql = '''
CASE axis_code
  WHEN 'eco' THEN 0
  WHEN 'auth' THEN 1
  WHEN 'cult' THEN 2
  WHEN 'eu' THEN 3
  ELSE 4
END
''';

  Database? _database;
  bool _copiedSeedThisLaunch = false;
  List<QuizQuestion>? _questionCache;
  List<QuizOption>? _optionCache;
  List<AxisDefinition>? _axisCache;
  _WebSeedData? _webSeedData;
  int _nextWebSessionId = 1;
  final Map<int, Map<int, int>> _webAnswersBySession = <int, Map<int, int>>{};

  @override
  Future<void> initialize() async {
    if (kIsWeb) {
      await _loadWebSeedData();
      return;
    }
    await _openDatabase();
  }

  @override
  Future<QuizBundle> loadQuiz({required QuizMode mode}) async {
    if (kIsWeb) {
      final seed = await _loadWebSeedData();
      return QuizBundle(
        mode: mode,
        questions: switch (mode) {
          QuizMode.express => _buildExpressQuestionSet(seed.questions),
          QuizMode.complete => List<QuizQuestion>.unmodifiable(seed.questions),
        },
        options: List<QuizOption>.unmodifiable(seed.options),
        axes: List<AxisDefinition>.unmodifiable(seed.axes),
      );
    }

    final database = await _openDatabase();
    final questions = await _loadQuestions(database);
    final options = await _loadOptions(database);
    final axes = await _loadAxes(database);

    return QuizBundle(
      mode: mode,
      questions: switch (mode) {
        QuizMode.express => _buildExpressQuestionSet(questions),
        QuizMode.complete => List<QuizQuestion>.unmodifiable(questions),
      },
      options: List<QuizOption>.unmodifiable(options),
      axes: List<AxisDefinition>.unmodifiable(axes),
    );
  }

  @override
  Future<int> createSession({String? respondentName}) async {
    if (kIsWeb) {
      final sessionId = _nextWebSessionId++;
      _webAnswersBySession[sessionId] = <int, int>{};
      return sessionId;
    }

    final database = await _openDatabase();
    return database.insert('sessions', <String, Object?>{
      'respondent_name': respondentName,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> saveAnswer({
    required int sessionId,
    required int questionId,
    required int optionId,
  }) async {
    if (kIsWeb) {
      _webAnswersBySession.putIfAbsent(
        sessionId,
        () => <int, int>{},
      )[questionId] = optionId;
      return;
    }

    final database = await _openDatabase();
    await database.insert('answers', <String, Object?>{
      'session_id': sessionId,
      'question_id': questionId,
      'option_id': optionId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<QuizResult> loadResult({
    required int sessionId,
    required int totalQuestions,
  }) async {
    if (kIsWeb) {
      final seed = await _loadWebSeedData();
      final answers = _webAnswersBySession[sessionId];

      if (answers == null || answers.isEmpty) {
        throw StateError(
          'Aucun résultat n’a pu être calculé pour cette session.',
        );
      }

      final rawScoreByAxis = <String, int>{};
      final answeredCountByAxis = <String, int>{};

      for (final entry in answers.entries) {
        final question = seed.questionsById[entry.key];
        final option = seed.optionsById[entry.value];
        if (question == null || option == null) {
          continue;
        }

        rawScoreByAxis.update(
          question.axisCode,
          (value) => value + (option.numericValue * question.orientation),
          ifAbsent: () => option.numericValue * question.orientation,
        );
        answeredCountByAxis.update(
          question.axisCode,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }

      final axisScores = axisDisplayOrder
          .where(answeredCountByAxis.containsKey)
          .map((axisCode) {
            final axis = seed.axesByCode[axisCode]!;
            final answeredCount = answeredCountByAxis[axisCode]!;
            final rawScore = rawScoreByAxis[axisCode]!;
            return AxisScore(
              axisCode: axisCode,
              axisLabel: axis.label,
              negativePole: axis.negativePole,
              positivePole: axis.positivePole,
              rawScore: rawScore,
              answeredCount: answeredCount,
              totalQuestions:
                  seed.totalQuestionsByAxis[axisCode] ?? answeredCount,
              normalizedScore: _roundTo(rawScore / answeredCount, 3),
            );
          })
          .toList(growable: false);

      final matches =
          seed.profiles.map((profile) {
            final profileTargets = seed.profileTargets[profile.code]!;
            var distance = 0.0;
            for (final axisScore in axisScores) {
              final targetValue = profileTargets[axisScore.axisCode];
              if (targetValue == null) {
                continue;
              }
              distance += (axisScore.normalizedScore - targetValue).abs();
            }
            return ProfileMatch(
              profileCode: profile.code,
              profileLabel: profile.label,
              description: profile.description,
              distance: _roundTo(distance, 3),
              matchPercent: _roundTo(100 - ((distance / 20) * 100), 1),
            );
          }).toList()..sort((left, right) {
            final distanceComparison = left.distance.compareTo(right.distance);
            if (distanceComparison != 0) {
              return distanceComparison;
            }
            return left.profileLabel.compareTo(right.profileLabel);
          });

      return QuizResult(
        sessionId: sessionId,
        winner: matches.first,
        matches: List<ProfileMatch>.unmodifiable(matches),
        axisScores: axisScores,
        answeredCount: answers.length,
        totalQuestions: totalQuestions,
      );
    }

    final database = await _openDatabase();

    final matchesRows = await database.rawQuery(
      '''
      SELECT *
      FROM v_session_profile_matches
      WHERE session_id = ?
      ORDER BY distance ASC, profile_label ASC
      ''',
      <Object?>[sessionId],
    );

    if (matchesRows.isEmpty) {
      throw StateError(
        'Aucun résultat n’a pu être calculé pour cette session.',
      );
    }

    final axisRows = await database.rawQuery(
      '''
      SELECT *
      FROM v_session_axis_scores
      WHERE session_id = ?
      ORDER BY $_axisSortSql
      ''',
      <Object?>[sessionId],
    );

    final answeredCount =
        _readFirstInt(
          await database.rawQuery(
            'SELECT COUNT(*) FROM answers WHERE session_id = ?',
            <Object?>[sessionId],
          ),
        ) ??
        0;

    final matches = matchesRows
        .map(_profileMatchFromRow)
        .toList(growable: false);
    final axisScores = axisRows.map(_axisScoreFromRow).toList(growable: false);

    return QuizResult(
      sessionId: sessionId,
      winner: matches.first,
      matches: matches,
      axisScores: axisScores,
      answeredCount: answeredCount,
      totalQuestions: totalQuestions,
    );
  }

  Future<Database> _openDatabase() async {
    if (_database != null) {
      return _database!;
    }

    if (kIsWeb) {
      throw UnsupportedError(
        'Ce mode de stockage n’est pas disponible sur le web.',
      );
    }

    final file = await _ensureWritableDatabase();
    final factory = _resolveDatabaseFactory();
    final database = await factory.openDatabase(file.path);

    if (_copiedSeedThisLaunch) {
      await database.transaction((transaction) async {
        await transaction.delete('answers');
        await transaction.delete('sessions');
      });
      _copiedSeedThisLaunch = false;
    }

    _database = database;
    return database;
  }

  Future<File> _ensureWritableDatabase() async {
    final directory = await getApplicationSupportDirectory();
    final databaseFile = File(
      p.join(directory.path, 'poliscope_questionnaire.sqlite'),
    );

    if (await databaseFile.exists()) {
      return databaseFile;
    }

    await databaseFile.parent.create(recursive: true);
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await databaseFile.writeAsBytes(bytes, flush: true);
    _copiedSeedThisLaunch = true;
    return databaseFile;
  }

  DatabaseFactory _resolveDatabaseFactory() {
    if (kIsWeb) {
      throw UnsupportedError(
        'Cette version de Poliscope est pensée en priorité pour mobile et desktop.',
      );
    }

    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      return databaseFactoryFfi;
    }

    return databaseFactory;
  }

  Future<List<QuizQuestion>> _loadQuestions(Database database) async {
    if (_questionCache != null) {
      return _questionCache!;
    }

    final rows = await database.query('questions', orderBy: 'id ASC');
    _questionCache = rows.map(_questionFromRow).toList(growable: false);
    return _questionCache!;
  }

  Future<List<QuizOption>> _loadOptions(Database database) async {
    if (_optionCache != null) {
      return _optionCache!;
    }

    final rows = await database.query('options', orderBy: 'id ASC');
    _optionCache = rows.map(_optionFromRow).toList(growable: false);
    return _optionCache!;
  }

  Future<List<AxisDefinition>> _loadAxes(Database database) async {
    if (_axisCache != null) {
      return _axisCache!;
    }

    final rows = await database.query(
      'axes',
      orderBy: '''
      CASE code
        WHEN 'eco' THEN 0
        WHEN 'auth' THEN 1
        WHEN 'cult' THEN 2
        WHEN 'eu' THEN 3
        ELSE 4
      END
      ''',
    );
    _axisCache = rows.map(_axisFromRow).toList(growable: false);
    return _axisCache!;
  }

  List<QuizQuestion> _buildExpressQuestionSet(List<QuizQuestion> questions) {
    final questionsByAxis = <String, List<QuizQuestion>>{
      for (final axis in axisDisplayOrder) axis: <QuizQuestion>[],
    };

    for (final question in questions) {
      questionsByAxis.putIfAbsent(question.axisCode, () => <QuizQuestion>[]);
      questionsByAxis[question.axisCode]!.add(question);
    }

    final selectedByAxis = <String, List<QuizQuestion>>{};

    for (final axis in axisDisplayOrder) {
      final pool = List<QuizQuestion>.from(questionsByAxis[axis] ?? const []);
      final targetCount = _expressTargets[axis] ?? 0;
      selectedByAxis[axis] = _pickEvenly(pool, targetCount);
    }

    final interleaved = <QuizQuestion>[];
    final queues = <String, List<QuizQuestion>>{
      for (final axis in axisDisplayOrder)
        axis: List<QuizQuestion>.from(selectedByAxis[axis] ?? const []),
    };

    var addedOne = true;
    while (addedOne) {
      addedOne = false;
      for (final axis in axisDisplayOrder) {
        final bucket = queues[axis]!;
        if (bucket.isEmpty) {
          continue;
        }
        interleaved.add(bucket.removeAt(0));
        addedOne = true;
      }
    }

    return List<QuizQuestion>.unmodifiable(interleaved);
  }

  List<QuizQuestion> _pickEvenly(List<QuizQuestion> pool, int targetCount) {
    if (pool.length <= targetCount) {
      return List<QuizQuestion>.unmodifiable(pool);
    }

    final picks = <QuizQuestion>[];
    final usedIds = <int>{};

    for (var index = 0; index < targetCount; index++) {
      final slot = targetCount == 1
          ? 0
          : ((pool.length - 1) * index / (targetCount - 1)).round();
      final question = pool[slot];
      if (usedIds.add(question.id)) {
        picks.add(question);
      }
    }

    if (picks.length == targetCount) {
      return List<QuizQuestion>.unmodifiable(picks);
    }

    for (final question in pool) {
      if (usedIds.add(question.id)) {
        picks.add(question);
      }
      if (picks.length == targetCount) {
        break;
      }
    }

    return List<QuizQuestion>.unmodifiable(picks);
  }

  QuizQuestion _questionFromRow(Map<String, Object?> row) {
    return QuizQuestion(
      id: row['id']! as int,
      category: row['category']! as String,
      text: row['question_text']! as String,
      axisCode: row['axis_code']! as String,
      orientation: row['orientation']! as int,
    );
  }

  QuizOption _optionFromRow(Map<String, Object?> row) {
    return QuizOption(
      id: row['id']! as int,
      code: row['code']! as String,
      label: row['label']! as String,
      numericValue: row['numeric_value']! as int,
    );
  }

  AxisDefinition _axisFromRow(Map<String, Object?> row) {
    return AxisDefinition(
      code: row['code']! as String,
      label: row['label']! as String,
      negativePole: row['negative_pole']! as String,
      positivePole: row['positive_pole']! as String,
    );
  }

  ProfileMatch _profileMatchFromRow(Map<String, Object?> row) {
    return ProfileMatch(
      profileCode: row['profile_code']! as String,
      profileLabel: row['profile_label']! as String,
      description: row['description']! as String,
      distance: (row['distance']! as num).toDouble(),
      matchPercent: (row['match_percent']! as num).toDouble(),
    );
  }

  AxisScore _axisScoreFromRow(Map<String, Object?> row) {
    return AxisScore(
      axisCode: row['axis_code']! as String,
      axisLabel: row['axis_label']! as String,
      negativePole: row['negative_pole']! as String,
      positivePole: row['positive_pole']! as String,
      rawScore: row['raw_score']! as int,
      answeredCount: row['answered_count']! as int,
      totalQuestions: row['total_questions']! as int,
      normalizedScore: (row['normalized_score']! as num).toDouble(),
    );
  }

  Future<_WebSeedData> _loadWebSeedData() async {
    if (_webSeedData != null) {
      return _webSeedData!;
    }

    final rawJson = await rootBundle.loadString(webAssetPath);
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;

    final questions = (decoded['questions'] as List<dynamic>)
        .map((row) => _questionFromRow(Map<String, Object?>.from(row as Map)))
        .toList(growable: false);
    final options = (decoded['options'] as List<dynamic>)
        .map((row) => _optionFromRow(Map<String, Object?>.from(row as Map)))
        .toList(growable: false);
    final axes = (decoded['axes'] as List<dynamic>)
        .map((row) => _axisFromRow(Map<String, Object?>.from(row as Map)))
        .toList(growable: false);
    final profiles = (decoded['profiles'] as List<dynamic>)
        .map(
          (row) =>
              _profileDefinitionFromRow(Map<String, Object?>.from(row as Map)),
        )
        .toList(growable: false);

    final profileTargets = <String, Map<String, double>>{};
    for (final row in decoded['profile_axes'] as List<dynamic>) {
      final map = Map<String, Object?>.from(row as Map);
      final profileCode = map['profile_code']! as String;
      final axisCode = map['axis_code']! as String;
      final targetValue = (map['target_value']! as num).toDouble();
      profileTargets.putIfAbsent(
        profileCode,
        () => <String, double>{},
      )[axisCode] = targetValue;
    }

    final questionsById = <int, QuizQuestion>{
      for (final question in questions) question.id: question,
    };
    final optionsById = <int, QuizOption>{
      for (final option in options) option.id: option,
    };
    final axesByCode = <String, AxisDefinition>{
      for (final axis in axes) axis.code: axis,
    };
    final totalQuestionsByAxis = <String, int>{};
    for (final question in questions) {
      totalQuestionsByAxis.update(
        question.axisCode,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    _webSeedData = _WebSeedData(
      questions: questions,
      options: options,
      axes: axes,
      profiles: profiles,
      questionsById: questionsById,
      optionsById: optionsById,
      axesByCode: axesByCode,
      profileTargets: profileTargets,
      totalQuestionsByAxis: totalQuestionsByAxis,
    );
    return _webSeedData!;
  }

  _ProfileDefinition _profileDefinitionFromRow(Map<String, Object?> row) {
    return _ProfileDefinition(
      code: row['code']! as String,
      label: row['label']! as String,
      description: row['description']! as String,
    );
  }

  int? _readFirstInt(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) {
      return null;
    }

    final value = rows.first.values.first;
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  double _roundTo(double value, int decimals) {
    final factor = decimals == 1 ? 10.0 : 1000.0;
    return (value * factor).round() / factor;
  }
}

class _ProfileDefinition {
  const _ProfileDefinition({
    required this.code,
    required this.label,
    required this.description,
  });

  final String code;
  final String label;
  final String description;
}

class _WebSeedData {
  const _WebSeedData({
    required this.questions,
    required this.options,
    required this.axes,
    required this.profiles,
    required this.questionsById,
    required this.optionsById,
    required this.axesByCode,
    required this.profileTargets,
    required this.totalQuestionsByAxis,
  });

  final List<QuizQuestion> questions;
  final List<QuizOption> options;
  final List<AxisDefinition> axes;
  final List<_ProfileDefinition> profiles;
  final Map<int, QuizQuestion> questionsById;
  final Map<int, QuizOption> optionsById;
  final Map<String, AxisDefinition> axesByCode;
  final Map<String, Map<String, double>> profileTargets;
  final Map<String, int> totalQuestionsByAxis;
}
