import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum ValidationLevel { critical, error, warning, info }

class ValidationIssue {
  final String fileName;
  final ValidationLevel level;
  final String message;
  final String? itemId;

  ValidationIssue({
    required this.fileName,
    required this.level,
    required this.message,
    this.itemId,
  });

  @override
  String toString() {
    final prefix = switch (level) {
      ValidationLevel.critical => '🔴 CRITICAL',
      ValidationLevel.error => '❌ ERROR',
      ValidationLevel.warning => '⚠️  WARNING',
      ValidationLevel.info => 'ℹ️  INFO',
    };
    final id = itemId != null ? ' [$itemId]' : '';
    return '$prefix$id: $message';
  }
}

class ValidationReport {
  final List<ValidationIssue> issues = [];
  final Map<String, List<String>> allQuestionIds = {};
  final Map<String, List<String>> allQuestionTexts = {};
  final Map<String, Set<String>> categoryIds = {};
  final Map<String, Set<String>> subcategoryIds = {};
  final Map<String, Set<String>> learningUnitIds = {};
  int filesProcessed = 0;
  int filesWithErrors = 0;
  int filesWithWarnings = 0;

  void addIssue(ValidationIssue issue) {
    issues.add(issue);
    if (issue.level == ValidationLevel.critical || issue.level == ValidationLevel.error) {
      filesWithErrors++;
    } else if (issue.level == ValidationLevel.warning) {
      filesWithWarnings++;
    }
  }

  int get criticalCount => issues.where((i) => i.level == ValidationLevel.critical).length;
  int get errorCount => issues.where((i) => i.level == ValidationLevel.error).length;
  int get warningCount => issues.where((i) => i.level == ValidationLevel.warning).length;
  
  bool get hasErrors => criticalCount > 0 || errorCount > 0;
  bool get isValid => !hasErrors;
}

class JsonValidatorService {
  static const String _assetsDataPath = 'assets/data/';

  /// Validate all JSON files
  static Future<ValidationReport> validateAllFiles() async {
    final report = ValidationReport();

    try {
      // Get list of files from manifest
      final manifestString = await rootBundle.loadString('${_assetsDataPath}manifest.json');
      final manifest = json.decode(manifestString);
      final List<String> files = List<String>.from(manifest['dataFiles'] ?? []);

      debugPrint('🔍 Starting validation of ${files.length} files...');

      // First pass: collect all IDs
      for (final fileName in files) {
        await _collectIds(fileName, report);
      }

      // Second pass: validate each file
      for (final fileName in files) {
        await _validateFile(fileName, report);
        report.filesProcessed++;
      }

      _checkCrossFileReferences(report);

      debugPrint('✅ Validation complete: ${report.filesProcessed} files processed');
      
    } catch (e) {
      debugPrint('❌ Validation error: $e');
      report.addIssue(ValidationIssue(
        fileName: 'manifest.json',
        level: ValidationLevel.critical,
        message: 'Failed to load manifest: $e',
      ));
    }

    return report;
  }

  /// Collect all IDs from a file for cross-reference validation
  static Future<void> _collectIds(String fileName, ValidationReport report) async {
    try {
      final jsonString = await rootBundle.loadString('$_assetsDataPath$fileName');
      final dynamic decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic>) return;
      final data = decoded;

      // Collect category IDs
      if (data.containsKey('categories')) {
        final categories = List<Map<String, dynamic>>.from(data['categories']);
        report.categoryIds[fileName] = categories.map((c) => c['id'] as String).toSet();
      }

      // Collect subcategory IDs
      if (data.containsKey('subcategories')) {
        final subcategories = List<Map<String, dynamic>>.from(data['subcategories']);
        report.subcategoryIds[fileName] = subcategories.map((s) => s['id'] as String).toSet();
      }

      // Collect learning unit IDs
      if (data.containsKey('learningUnits')) {
        final units = List<Map<String, dynamic>>.from(data['learningUnits']);
        report.learningUnitIds[fileName] = units.map((u) => u['id'] as String).toSet();
      }

      // Collect question IDs and texts
      if (data.containsKey('questions')) {
        final questions = List<Map<String, dynamic>>.from(data['questions']);
        report.allQuestionIds[fileName] = questions.map((q) => q['id'] as String).toList();
        report.allQuestionTexts[fileName] = questions.map((q) => q['question'] as String).toList();
      }
    } catch (e) {
      debugPrint('Error collecting IDs from $fileName: $e');
    }
  }

  /// Validate a single file
  static Future<void> _validateFile(String fileName, ValidationReport report) async {
    try {
      final jsonString = await rootBundle.loadString('$_assetsDataPath$fileName');
      final dynamic decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.info,
          message: 'Skipping non-object JSON file',
        ));
        return;
      }

      final data = decoded;

      // Validate categories
      if (data.containsKey('categories')) {
        _validateCategories(fileName, data['categories'], report);
      }

      // Validate subcategories
      if (data.containsKey('subcategories')) {
        _validateSubcategories(fileName, data['subcategories'], report);
      }

      // Validate learning units
      if (data.containsKey('learningUnits')) {
        _validateLearningUnits(fileName, data['learningUnits'], report);
      }

      // Validate questions
      if (data.containsKey('questions')) {
        _validateQuestions(fileName, data['questions'], report);
      }

    } catch (e) {
      report.addIssue(ValidationIssue(
        fileName: fileName,
        level: ValidationLevel.critical,
        message: 'Failed to parse file: $e',
      ));
    }
  }

  /// Validate categories
  static void _validateCategories(String fileName, dynamic categories, ValidationReport report) {
    if (categories is! List) {
      report.addIssue(ValidationIssue(
        fileName: fileName,
        level: ValidationLevel.error,
        message: 'categories must be an array',
      ));
      return;
    }

    final categoryList = categories;
    final ids = <String>{};

    for (var i = 0; i < categoryList.length; i++) {
      final category = categoryList[i];
      
      if (category is! Map<String, dynamic>) continue;

      // Check required fields
      final id = category['id'] as String?;
      final name = category['name'] as String?;
      final description = category['description'] as String?;
      final icon = category['icon'] as String?;

      if (id == null || id.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.critical,
          message: 'Category at index $i missing id',
        ));
      } else {
        // Check for duplicate IDs within file
        if (ids.contains(id)) {
          report.addIssue(ValidationIssue(
            fileName: fileName,
            level: ValidationLevel.critical,
            message: 'Duplicate category id: $id',
            itemId: id,
          ));
        }
        ids.add(id);
      }

      if (name == null || name.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.error,
          message: 'Category missing name',
          itemId: id,
        ));
      }

      if (description == null || description.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.warning,
          message: 'Category missing description',
          itemId: id,
        ));
      } else if (description.length < 20) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.warning,
          message: 'Category description too short (<20 chars)',
          itemId: id,
        ));
      }

      if (icon == null || icon.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.warning,
          message: 'Category missing icon',
          itemId: id,
        ));
      }
    }
  }

  /// Validate subcategories
  static void _validateSubcategories(String fileName, dynamic subcategories, ValidationReport report) {
    if (subcategories is! List) {
      report.addIssue(ValidationIssue(
        fileName: fileName,
        level: ValidationLevel.error,
        message: 'subcategories must be an array',
      ));
      return;
    }

    final subcategoryList = subcategories;
    final ids = <String>{};

    for (var i = 0; i < subcategoryList.length; i++) {
      final subcategory = subcategoryList[i];
      
      if (subcategory is! Map<String, dynamic>) continue;

      final id = subcategory['id'] as String?;
      final categoryId = subcategory['categoryId'] as String?;
      final name = subcategory['name'] as String?;
      final description = subcategory['description'] as String?;

      if (id == null || id.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.critical,
          message: 'Subcategory at index $i missing id',
        ));
      } else {
        if (ids.contains(id)) {
          report.addIssue(ValidationIssue(
            fileName: fileName,
            level: ValidationLevel.critical,
            message: 'Duplicate subcategory id: $id',
            itemId: id,
          ));
        }
        ids.add(id);
      }

      if (categoryId == null || categoryId.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.error,
          message: 'Subcategory missing categoryId',
          itemId: id,
        ));
      }

      if (name == null || name.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.error,
          message: 'Subcategory missing name',
          itemId: id,
        ));
      }

      if (description == null || description.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.warning,
          message: 'Subcategory missing description',
          itemId: id,
        ));
      }
    }
  }

  /// Validate learning units
  static void _validateLearningUnits(String fileName, dynamic learningUnits, ValidationReport report) {
    if (learningUnits is! List) {
      report.addIssue(ValidationIssue(
        fileName: fileName,
        level: ValidationLevel.error,
        message: 'learningUnits must be an array',
      ));
      return;
    }

    final unitList = learningUnits;
    final ids = <String>{};
    final validTypes = {'flashcard', 'quiz', 'lesson', 'video', 'exercise', 'mixed'};
    final validDifficulties = {'beginner', 'intermediate', 'advanced'};

    for (var i = 0; i < unitList.length; i++) {
      final unit = unitList[i];
      
      if (unit is! Map<String, dynamic>) continue;

      final id = unit['id'] as String?;
      final subCategoryId = unit['subCategoryId'] as String?;
      final type = unit['type'] as String?;
      final title = unit['title'] as String?;
      final difficulty = unit['difficulty'] as String?;
      final tags = unit['tags'];

      if (id == null || id.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.critical,
          message: 'Learning unit at index $i missing id',
        ));
      } else {
        if (ids.contains(id)) {
          report.addIssue(ValidationIssue(
            fileName: fileName,
            level: ValidationLevel.critical,
            message: 'Duplicate learning unit id: $id',
            itemId: id,
          ));
        }
        ids.add(id);
      }

      if (subCategoryId == null || subCategoryId.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.error,
          message: 'Learning unit missing subCategoryId',
          itemId: id,
        ));
      }

      if (type == null || !validTypes.contains(type)) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.error,
          message: 'Learning unit has invalid type: $type (must be one of: ${validTypes.join(", ")})',
          itemId: id,
        ));
      }

      if (title == null || title.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.error,
          message: 'Learning unit missing title',
          itemId: id,
        ));
      }

      if (difficulty == null || !validDifficulties.contains(difficulty)) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.error,
          message: 'Learning unit has invalid difficulty: $difficulty',
          itemId: id,
        ));
      }

      if (tags == null || tags is! List || (tags).isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.warning,
          message: 'Learning unit missing tags',
          itemId: id,
        ));
      }
    }
  }

  /// Validate questions
  static void _validateQuestions(String fileName, dynamic questions, ValidationReport report) {
    if (questions is! List) {
      report.addIssue(ValidationIssue(
        fileName: fileName,
        level: ValidationLevel.error,
        message: 'questions must be an array',
      ));
      return;
    }

    final questionList = questions;
    final ids = <String>{};
    final questionTexts = <String>{};
    final validDifficulties = {'beginner', 'intermediate', 'advanced'};

    for (var i = 0; i < questionList.length; i++) {
      final question = questionList[i];
      
      if (question is! Map<String, dynamic>) continue;

      final id = question['id'] as String?;
      final learningUnitId = question['learningUnitId'] as String?;
      final questionText = question['question'] as String?;
      final correctAnswer = question['correctAnswer'] as String?;
      final difficulty = question['difficulty'] as String?;
      final tags = question['tags'];
      final timeLimit = question['timeLimit'];
      final hint = question['hint'] as String?;
      final explanation = question['explanation'] as String?;

      // Check required fields
      if (id == null || id.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.critical,
          message: 'Question at index $i missing id',
        ));
      } else {
        // Check for duplicate IDs within file
        if (ids.contains(id)) {
          report.addIssue(ValidationIssue(
            fileName: fileName,
            level: ValidationLevel.critical,
            message: 'Duplicate question id: $id',
            itemId: id,
          ));
        }
        ids.add(id);
      }

      if (learningUnitId == null || learningUnitId.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.error,
          message: 'Question missing learningUnitId',
          itemId: id,
        ));
      }

      if (questionText == null || questionText.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.critical,
          message: 'Question missing question text',
          itemId: id,
        ));
      } else {
        // Check for duplicate question text
        if (questionTexts.contains(questionText)) {
          report.addIssue(ValidationIssue(
            fileName: fileName,
            level: ValidationLevel.warning,
            message: 'Duplicate question text found',
            itemId: id,
          ));
        }
        questionTexts.add(questionText);

        // Check question length
        if (questionText.length < 10) {
          report.addIssue(ValidationIssue(
            fileName: fileName,
            level: ValidationLevel.warning,
            message: 'Question text too short (<10 chars)',
            itemId: id,
          ));
        } else if (questionText.length > 500) {
          report.addIssue(ValidationIssue(
            fileName: fileName,
            level: ValidationLevel.warning,
            message: 'Question text very long (>500 chars)',
            itemId: id,
          ));
        }
      }

      if (correctAnswer == null || correctAnswer.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.critical,
          message: 'Question missing correctAnswer',
          itemId: id,
        ));
      } else if (correctAnswer.length < 2) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.warning,
          message: 'Answer seems too short (<2 chars)',
          itemId: id,
        ));
      }

      if (difficulty == null || !validDifficulties.contains(difficulty)) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.error,
          message: 'Question has invalid difficulty: $difficulty',
          itemId: id,
        ));
      }

      if (tags == null || tags is! List || (tags).isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.warning,
          message: 'Question missing tags',
          itemId: id,
        ));
      }

      if (timeLimit != null && timeLimit is int) {
        if (timeLimit < 10 || timeLimit > 300) {
          report.addIssue(ValidationIssue(
            fileName: fileName,
            level: ValidationLevel.warning,
            message: 'Unusual time limit: ${timeLimit}s (recommend 10-120s)',
            itemId: id,
          ));
        }
      }

      // Quality checks (warnings only)
      if (hint == null || hint.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.info,
          message: 'Question missing hint',
          itemId: id,
        ));
      }

      if (explanation == null || explanation.isEmpty) {
        report.addIssue(ValidationIssue(
          fileName: fileName,
          level: ValidationLevel.info,
          message: 'Question missing explanation',
          itemId: id,
        ));
      }
    }

    // Check for similar questions (fuzzy matching)
    _checkSimilarQuestions(fileName, questionTexts.toList(), report);
  }

  /// Check for similar questions using basic similarity
  static void _checkSimilarQuestions(String fileName, List<String> questions, ValidationReport report) {
    for (var i = 0; i < questions.length; i++) {
      for (var j = i + 1; j < questions.length; j++) {
        final similarity = _calculateSimilarity(questions[i], questions[j]);
        if (similarity > 0.85) {
          report.addIssue(ValidationIssue(
            fileName: fileName,
            level: ValidationLevel.warning,
            message: 'Similar questions found (${(similarity * 100).toStringAsFixed(0)}% match): "${questions[i].substring(0, 50)}..." and "${questions[j].substring(0, 50)}..."',
          ));
        }
      }
    }
  }

  /// Simple similarity calculation (Jaccard similarity on words)
  static double _calculateSimilarity(String text1, String text2) {
    final words1 = text1.toLowerCase().split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toSet();
    final words2 = text2.toLowerCase().split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toSet();
    
    if (words1.isEmpty || words2.isEmpty) return 0.0;
    
    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;
    
    return union > 0 ? intersection / union : 0.0;
  }

  /// Check cross-file references
  static void _checkCrossFileReferences(ValidationReport report) {
    // Collect all IDs across files
    final allCategoryIds = <String>{};
    final allSubcategoryIds = <String>{};
    final allLearningUnitIds = <String>{};
    final allQuestionIds = <String>{};

    for (final entry in report.categoryIds.entries) {
      for (final id in entry.value) {
        if (allCategoryIds.contains(id)) {
          report.addIssue(ValidationIssue(
            fileName: entry.key,
            level: ValidationLevel.critical,
            message: 'Category ID collision across files: $id',
            itemId: id,
          ));
        }
        allCategoryIds.add(id);
      }
    }

    for (final entry in report.subcategoryIds.entries) {
      for (final id in entry.value) {
        if (allSubcategoryIds.contains(id)) {
          report.addIssue(ValidationIssue(
            fileName: entry.key,
            level: ValidationLevel.critical,
            message: 'Subcategory ID collision across files: $id',
            itemId: id,
          ));
        }
        allSubcategoryIds.add(id);
      }
    }

    for (final entry in report.learningUnitIds.entries) {
      for (final id in entry.value) {
        if (allLearningUnitIds.contains(id)) {
          report.addIssue(ValidationIssue(
            fileName: entry.key,
            level: ValidationLevel.critical,
            message: 'Learning unit ID collision across files: $id',
            itemId: id,
          ));
        }
        allLearningUnitIds.add(id);
      }
    }

    for (final entry in report.allQuestionIds.entries) {
      for (final id in entry.value) {
        if (allQuestionIds.contains(id)) {
          report.addIssue(ValidationIssue(
            fileName: entry.key,
            level: ValidationLevel.warning,
            message: 'Question ID collision across files: $id (may be intentional)',
            itemId: id,
          ));
        }
        allQuestionIds.add(id);
      }
    }

    debugPrint('📊 Global stats: ${allCategoryIds.length} categories, ${allSubcategoryIds.length} subcategories, ${allLearningUnitIds.length} learning units, ${allQuestionIds.length} questions');
  }

  /// Generate human-readable report
  static String generateReport(ValidationReport report) {
    final buffer = StringBuffer();
    
    buffer.writeln('🔍 JSON Validation Report');
    buffer.writeln('=' * 50);
    buffer.writeln('Files processed: ${report.filesProcessed}');
    buffer.writeln('Critical issues: ${report.criticalCount}');
    buffer.writeln('Errors: ${report.errorCount}');
    buffer.writeln('Warnings: ${report.warningCount}');
    buffer.writeln('');

    if (report.issues.isEmpty) {
      buffer.writeln('✅ All files valid - no issues found!');
    } else {
      // Group issues by file
      final issuesByFile = <String, List<ValidationIssue>>{};
      for (final issue in report.issues) {
        issuesByFile.putIfAbsent(issue.fileName, () => []).add(issue);
      }

      for (final entry in issuesByFile.entries) {
        buffer.writeln('📄 ${entry.key}');
        for (final issue in entry.value) {
          buffer.writeln('   ${issue.toString()}');
        }
        buffer.writeln('');
      }
    }

    buffer.writeln('=' * 50);
    buffer.writeln(report.hasErrors ? '❌ VALIDATION FAILED' : '✅ VALIDATION PASSED');
    
    return buffer.toString();
  }
}









