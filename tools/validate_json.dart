import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 JSON Validation Tool for Learning Hub');
  print('=' * 60);
  print('');

  final report = await validateAllFiles();
  
  // Print report
  print(report);
  
  // Save report to file
  final reportFile = File('tools/validation_report.md');
  await reportFile.writeAsString(report);
  print('📄 Report saved to: tools/validation_report.md');
  
  // Exit with appropriate code
  exit(report.contains('❌ VALIDATION FAILED') ? 1 : 0);
}

Future<String> validateAllFiles() async {
  final buffer = StringBuffer();
  
  try {
    // Read manifest
    final manifestFile = File('assets/data/manifest.json');
    if (!await manifestFile.exists()) {
      return '❌ CRITICAL: manifest.json not found';
    }

    final manifestContent = await manifestFile.readAsString();
    final manifest = json.decode(manifestContent);
    final List<String> files = List<String>.from(manifest['dataFiles'] ?? []);

    buffer.writeln('📋 Found ${files.length} files in manifest');
    buffer.writeln('');

    // Global tracking
    final allCategoryIds = <String, String>{};  // id -> file
    final allSubcategoryIds = <String, String>{};
    final allLearningUnitIds = <String, String>{};
    final allQuestionIds = <String, String>{};
    final allQuestionTexts = <String, String>{};
    
    int totalQuestions = 0;
    int criticalIssues = 0;
    int errors = 0;
    int warnings = 0;
    int infos = 0;

    // Validate each file
    for (final fileName in files) {
      final filePath = 'assets/data/$fileName';
      final file = File(filePath);

      if (!await file.exists()) {
        buffer.writeln('❌ $fileName - FILE NOT FOUND');
        criticalIssues++;
        continue;
      }

      try {
        final content = await file.readAsString();
        final dynamic decoded = json.decode(content);

        if (decoded is! Map<String, dynamic>) {
          buffer.writeln('ℹ️  $fileName - Skipped (not object format)');
          continue;
        }

        final data = decoded;
        final fileIssues = <String>[];

        // Validate categories
        if (data.containsKey('categories')) {
          final issues = _validateCategories(data['categories'], fileName, allCategoryIds);
          fileIssues.addAll(issues);
        }

        // Validate subcategories
        if (data.containsKey('subcategories')) {
          final issues = _validateSubcategories(data['subcategories'], fileName, allSubcategoryIds, allCategoryIds);
          fileIssues.addAll(issues);
        }

        // Validate learning units
        if (data.containsKey('learningUnits')) {
          final issues = _validateLearningUnits(data['learningUnits'], fileName, allLearningUnitIds, allSubcategoryIds);
          fileIssues.addAll(issues);
        }

        // Validate questions
        if (data.containsKey('questions')) {
          final questionData = data['questions'] as List;
          totalQuestions += questionData.length;
          final issues = _validateQuestions(questionData, fileName, allQuestionIds, allQuestionTexts, allLearningUnitIds);
          fileIssues.addAll(issues);
        }

        // Summarize file
        if (fileIssues.isEmpty) {
          final qCount = data['questions'] != null ? (data['questions'] as List).length : 0;
          buffer.writeln('✅ $fileName - $qCount questions, no issues');
        } else {
          buffer.writeln('⚠️  $fileName - ${fileIssues.length} issue(s):');
          for (final issue in fileIssues) {
            buffer.writeln('   $issue');
            if (issue.startsWith('🔴')) {
              criticalIssues++;
            } else if (issue.startsWith('❌')) errors++;
            else if (issue.startsWith('⚠️')) warnings++;
            else infos++;
          }
        }
        buffer.writeln('');

      } catch (e) {
        buffer.writeln('❌ $fileName - PARSE ERROR: $e');
        criticalIssues++;
        buffer.writeln('');
      }
    }

    // Summary
    buffer.writeln('=' * 60);
    buffer.writeln('📊 SUMMARY');
    buffer.writeln('=' * 60);
    buffer.writeln('Files processed: ${files.length}');
    buffer.writeln('Total questions: $totalQuestions');
    buffer.writeln('Total categories: ${allCategoryIds.length}');
    buffer.writeln('Total subcategories: ${allSubcategoryIds.length}');
    buffer.writeln('Total learning units: ${allLearningUnitIds.length}');
    buffer.writeln('');
    buffer.writeln('Issues found:');
    buffer.writeln('  🔴 Critical: $criticalIssues');
    buffer.writeln('  ❌ Errors: $errors');
    buffer.writeln('  ⚠️  Warnings: $warnings');
    buffer.writeln('  ℹ️  Info: $infos');
    buffer.writeln('');

    if (criticalIssues > 0 || errors > 0) {
      buffer.writeln('❌ VALIDATION FAILED');
      buffer.writeln('Please fix critical issues and errors before deployment.');
    } else if (warnings > 0) {
      buffer.writeln('⚠️  VALIDATION PASSED WITH WARNINGS');
      buffer.writeln('Consider addressing warnings to improve quality.');
    } else {
      buffer.writeln('✅ VALIDATION PASSED');
      buffer.writeln('All files are valid and ready for deployment!');
    }

  } catch (e) {
    buffer.writeln('❌ VALIDATION FAILED: $e');
  }

  return buffer.toString();
}

List<String> _validateCategories(dynamic categories, String fileName, Map<String, String> allIds) {
  final issues = <String>[];
  
  if (categories is! List) {
    issues.add('❌ categories must be an array');
    return issues;
  }

  for (final category in categories) {
    if (category is! Map<String, dynamic>) continue;

    final id = category['id'] as String?;
    final name = category['name'] as String?;
    final description = category['description'] as String?;

    if (id == null || id.isEmpty) {
      issues.add('🔴 CRITICAL: Category missing id');
    } else {
      if (allIds.containsKey(id)) {
        issues.add('🔴 CRITICAL: Category ID "$id" duplicated in ${allIds[id]}');
      }
      allIds[id] = fileName;
    }

    if (name == null || name.isEmpty) {
      issues.add('❌ Category [$id] missing name');
    }

    if (description == null || description.length < 20) {
      issues.add('⚠️  Category [$id] description too short or missing');
    }
  }

  return issues;
}

List<String> _validateSubcategories(dynamic subcategories, String fileName, Map<String, String> allIds, Map<String, String> categoryIds) {
  final issues = <String>[];
  
  if (subcategories is! List) {
    issues.add('❌ subcategories must be an array');
    return issues;
  }

  for (final subcategory in subcategories) {
    if (subcategory is! Map<String, dynamic>) continue;

    final id = subcategory['id'] as String?;
    final categoryId = subcategory['categoryId'] as String?;
    final name = subcategory['name'] as String?;

    if (id == null || id.isEmpty) {
      issues.add('🔴 CRITICAL: Subcategory missing id');
    } else {
      if (allIds.containsKey(id)) {
        issues.add('🔴 CRITICAL: Subcategory ID "$id" duplicated in ${allIds[id]}');
      }
      allIds[id] = fileName;
    }

    if (categoryId == null || categoryId.isEmpty) {
      issues.add('❌ Subcategory [$id] missing categoryId');
    } else if (!categoryIds.containsKey(categoryId)) {
      issues.add('❌ Subcategory [$id] references non-existent category "$categoryId"');
    }

    if (name == null || name.isEmpty) {
      issues.add('❌ Subcategory [$id] missing name');
    }
  }

  return issues;
}

List<String> _validateLearningUnits(dynamic learningUnits, String fileName, Map<String, String> allIds, Map<String, String> subcategoryIds) {
  final issues = <String>[];
  
  if (learningUnits is! List) {
    issues.add('❌ learningUnits must be an array');
    return issues;
  }

  final validTypes = {'flashcard', 'quiz', 'lesson', 'video', 'exercise', 'mixed'};
  final validDifficulties = {'beginner', 'intermediate', 'advanced'};

  for (final unit in learningUnits) {
    if (unit is! Map<String, dynamic>) continue;

    final id = unit['id'] as String?;
    final subCategoryId = unit['subCategoryId'] as String?;
    final type = unit['type'] as String?;
    final difficulty = unit['difficulty'] as String?;

    if (id == null || id.isEmpty) {
      issues.add('🔴 CRITICAL: Learning unit missing id');
    } else {
      if (allIds.containsKey(id)) {
        issues.add('🔴 CRITICAL: Learning unit ID "$id" duplicated in ${allIds[id]}');
      }
      allIds[id] = fileName;
    }

    if (subCategoryId == null || subCategoryId.isEmpty) {
      issues.add('❌ Learning unit [$id] missing subCategoryId');
    } else if (!subcategoryIds.containsKey(subCategoryId)) {
      issues.add('❌ Learning unit [$id] references non-existent subcategory "$subCategoryId"');
    }

    if (type != null && !validTypes.contains(type)) {
      issues.add('❌ Learning unit [$id] invalid type "$type"');
    }

    if (difficulty != null && !validDifficulties.contains(difficulty)) {
      issues.add('❌ Learning unit [$id] invalid difficulty "$difficulty"');
    }
  }

  return issues;
}

List<String> _validateQuestions(List<dynamic> questions, String fileName, Map<String, String> allIds, Map<String, String> allTexts, Map<String, String> learningUnitIds) {
  final issues = <String>[];
  final validDifficulties = {'beginner', 'intermediate', 'advanced'};

  for (final question in questions) {
    if (question is! Map<String, dynamic>) continue;

    final id = question['id'] as String?;
    final learningUnitId = question['learningUnitId'] as String?;
    final questionText = question['question'] as String?;
    final correctAnswer = question['correctAnswer'] as String?;
    final difficulty = question['difficulty'] as String?;
    final timeLimit = question['timeLimit'];

    if (id == null || id.isEmpty) {
      issues.add('🔴 CRITICAL: Question missing id');
      continue;
    }

    // Check for duplicate IDs
    if (allIds.containsKey(id)) {
      issues.add('🔴 CRITICAL: Duplicate question ID "$id" (also in ${allIds[id]})');
    }
    allIds[id] = fileName;

    if (learningUnitId == null || learningUnitId.isEmpty) {
      issues.add('❌ Question [$id] missing learningUnitId');
    } else if (!learningUnitIds.containsKey(learningUnitId)) {
      issues.add('❌ Question [$id] references non-existent learning unit "$learningUnitId"');
    }

    if (questionText == null || questionText.isEmpty) {
      issues.add('🔴 CRITICAL: Question [$id] missing question text');
    } else {
      // Check for duplicate question text
      if (allTexts.containsKey(questionText)) {
        issues.add('⚠️  Question [$id] has duplicate text (also in ${allTexts[questionText]})');
      }
      allTexts[questionText] = fileName;

      if (questionText.length < 10) {
        issues.add('⚠️  Question [$id] text too short (<10 chars)');
      } else if (questionText.length > 500) {
        issues.add('⚠️  Question [$id] text very long (>500 chars)');
      }
    }

    if (correctAnswer == null || correctAnswer.isEmpty) {
      issues.add('🔴 CRITICAL: Question [$id] missing correctAnswer');
    }

    if (difficulty != null && !validDifficulties.contains(difficulty)) {
      issues.add('❌ Question [$id] invalid difficulty "$difficulty"');
    }

    if (timeLimit != null && timeLimit is int) {
      if (timeLimit < 10) {
        issues.add('⚠️  Question [$id] time limit too short (${timeLimit}s < 10s)');
      } else if (timeLimit > 300) {
        issues.add('⚠️  Question [$id] time limit too long (${timeLimit}s > 300s)');
      }
    }

    // Quality checks
    if (question['hint'] == null) {
      issues.add('ℹ️  Question [$id] missing hint');
    }

    if (question['explanation'] == null) {
      issues.add('ℹ️  Question [$id] missing explanation');
    }
  }

  return issues;
}









