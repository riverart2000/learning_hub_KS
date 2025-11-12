import 'package:flutter/foundation.dart' hide Category;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_progress.dart';
import '../models/subcategory_progress.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import 'hive_service.dart';

class ProgressTrackingService {
  static const String _categoryProgressBox = 'category_progress';
  static const String _subcategoryProgressBox = 'subcategory_progress';

  // Get or create category progress for a user
  static CategoryProgress getCategoryProgress(String userId, String categoryId) {
    final box = Hive.box<CategoryProgress>(_categoryProgressBox);
    final key = '${userId}_$categoryId';
    
    CategoryProgress? progress = box.get(key);
    if (progress == null) {
      // Calculate total questions in this category
      final totalQuestions = _calculateCategoryQuestions(categoryId);
      
      progress = CategoryProgress(
        categoryId: categoryId,
        userId: userId,
        totalQuestions: totalQuestions,
      );
      box.put(key, progress);
    }
    
    return progress;
  }

  // Get or create subcategory progress for a user
  static SubcategoryProgress getSubcategoryProgress(String userId, String subcategoryId) {
    final box = Hive.box<SubcategoryProgress>(_subcategoryProgressBox);
    final key = '${userId}_$subcategoryId';
    
    SubcategoryProgress? progress = box.get(key);
    if (progress == null) {
      // Calculate total questions in this subcategory
      final totalQuestions = _calculateSubcategoryQuestions(subcategoryId);
      
      progress = SubcategoryProgress(
        subcategoryId: subcategoryId,
        userId: userId,
        totalQuestions: totalQuestions,
      );
      box.put(key, progress);
    }
    
    return progress;
  }

  // Track learning unit completion (for retakes)
  static final Map<String, Map<String, int>> _learningUnitScores = {};
  // Structure: { 'userId_categoryId': { 'learningUnitId': correctAnswers } }
  
  static final Map<String, Map<String, int>> _learningUnitAttempted = {};
  // Structure: { 'userId_categoryId': { 'learningUnitId': questionsAttempted } }
  
  // Update category progress after quiz
  static Future<void> updateCategoryProgress({
    required String userId,
    required String categoryId,
    required String learningUnitId,
    required int questionsAttempted,
    required int correctAnswers,
    required int totalQuestionsInUnit,
  }) async {
    final box = Hive.box<CategoryProgress>(_categoryProgressBox);
    final key = '${userId}_$categoryId';
    final scoreKey = '${userId}_$categoryId';
    
    // Initialize score and attempted tracking for this category if needed
    _learningUnitScores[scoreKey] ??= {};
    _learningUnitAttempted[scoreKey] ??= {};
    
    // Store the BEST score for this learning unit
    final previousCorrect = _learningUnitScores[scoreKey]![learningUnitId] ?? 0;
    final previousAttempted = _learningUnitAttempted[scoreKey]![learningUnitId] ?? 0;
    
    if (correctAnswers > previousCorrect) {
      // Better score - update it
      _learningUnitScores[scoreKey]![learningUnitId] = correctAnswers;
      _learningUnitAttempted[scoreKey]![learningUnitId] = questionsAttempted;
      debugPrint('📈 Improved score for $learningUnitId: $previousCorrect → $correctAnswers (attempted: $questionsAttempted)');
    } else if (correctAnswers == previousCorrect && questionsAttempted > previousAttempted) {
      // Same correct answers but attempted more questions
      _learningUnitAttempted[scoreKey]![learningUnitId] = questionsAttempted;
    }
    
    // Recalculate total progress based on BEST scores for each learning unit
    CategoryProgress progress = getCategoryProgress(userId, categoryId);
    
    // Calculate total attempted and correct based on best scores
    int totalAttempted = 0;
    int totalCorrect = 0;
    
    // Get all learning units in this category
    final category = HiveService.getCategory(categoryId);
    if (category != null) {
      final subcategories = HiveService.getSubCategoriesByCategory(categoryId);
      for (final subcat in subcategories) {
        final units = HiveService.getLearningUnitsBySubCategory(subcat.id);
        for (final unit in units) {
          final unitScore = _learningUnitScores[scoreKey]![unit.id];
          final unitAttempted = _learningUnitAttempted[scoreKey]![unit.id];
          if (unitScore != null && unitScore > 0 && unitAttempted != null) {
            totalAttempted += unitAttempted;
            totalCorrect += unitScore;
          }
        }
      }
    }
    
    progress.attemptedQuestions = totalAttempted;
    progress.correctAnswers = totalCorrect;
    progress.lastAccessedAt = DateTime.now();
    
    if (progress.isCompleted) {
      progress.completedAt = DateTime.now();
    }
    
    await box.put(key, progress);
    debugPrint('✅ Category progress updated: $categoryId - ${progress.attemptedQuestions}/${progress.totalQuestions} (${progress.accuracy.toStringAsFixed(1)}%)');
  }

  // Update subcategory progress after quiz
  static Future<void> updateSubcategoryProgress({
    required String userId,
    required String subcategoryId,
    required String learningUnitId,
    required int questionsAttempted,
    required int correctAnswers,
    required int totalQuestionsInUnit,
  }) async {
    final box = Hive.box<SubcategoryProgress>(_subcategoryProgressBox);
    final key = '${userId}_$subcategoryId';
    final scoreKey = '${userId}_$subcategoryId';
    
    // Initialize score and attempted tracking for this subcategory if needed
    _learningUnitScores[scoreKey] ??= {};
    _learningUnitAttempted[scoreKey] ??= {};
    
    // Store the BEST score for this learning unit
    final previousCorrect = _learningUnitScores[scoreKey]![learningUnitId] ?? 0;
    final previousAttempted = _learningUnitAttempted[scoreKey]![learningUnitId] ?? 0;
    
    if (correctAnswers > previousCorrect) {
      // Better score - update it
      _learningUnitScores[scoreKey]![learningUnitId] = correctAnswers;
      _learningUnitAttempted[scoreKey]![learningUnitId] = questionsAttempted;
      debugPrint('📈 Improved score for $learningUnitId: $previousCorrect → $correctAnswers (attempted: $questionsAttempted)');
    } else if (correctAnswers == previousCorrect && questionsAttempted > previousAttempted) {
      // Same correct answers but attempted more questions
      _learningUnitAttempted[scoreKey]![learningUnitId] = questionsAttempted;
    }
    
    // Recalculate total progress based on BEST scores for each learning unit
    SubcategoryProgress progress = getSubcategoryProgress(userId, subcategoryId);
    
    // Calculate total attempted and correct based on best scores
    int totalAttempted = 0;
    int totalCorrect = 0;
    
    final units = HiveService.getLearningUnitsBySubCategory(subcategoryId);
    for (final unit in units) {
      final unitScore = _learningUnitScores[scoreKey]![unit.id];
      final unitAttempted = _learningUnitAttempted[scoreKey]![unit.id];
      if (unitScore != null && unitScore > 0 && unitAttempted != null) {
        totalAttempted += unitAttempted;
        totalCorrect += unitScore;
      }
    }
    
    progress.attemptedQuestions = totalAttempted;
    progress.correctAnswers = totalCorrect;
    progress.lastAccessedAt = DateTime.now();
    
    if (progress.isCompleted) {
      progress.completedAt = DateTime.now();
    }
    
    await box.put(key, progress);
    debugPrint('✅ Subcategory progress updated: $subcategoryId - ${progress.attemptedQuestions}/${progress.totalQuestions} (${progress.accuracy.toStringAsFixed(1)}%)');
  }

  // Record quiz completion and update all relevant progress
  static Future<void> recordQuizCompletion({
    required String userId,
    required String learningUnitId,
    required int questionsAttempted,
    required int correctAnswers,
  }) async {
    try {
      // Get the learning unit
      final learningUnit = HiveService.getLearningUnit(learningUnitId);
      if (learningUnit == null) {
        debugPrint('⚠️ Learning unit not found: $learningUnitId');
        return;
      }

      // Get the subcategory
      final subcategory = HiveService.getSubCategory(learningUnit.subCategoryId);
      if (subcategory == null) {
        debugPrint('⚠️ Subcategory not found: ${learningUnit.subCategoryId}');
        return;
      }

      // Get total questions in this learning unit for tracking best scores
      final totalQuestionsInUnit = HiveService.getQuestionsByLearningUnit(learningUnitId).length;
      
      // Update subcategory progress
      await updateSubcategoryProgress(
        userId: userId,
        subcategoryId: subcategory.id,
        learningUnitId: learningUnitId,
        questionsAttempted: questionsAttempted,
        correctAnswers: correctAnswers,
        totalQuestionsInUnit: totalQuestionsInUnit,
      );

      // Update category progress
      await updateCategoryProgress(
        userId: userId,
        categoryId: subcategory.categoryId,
        learningUnitId: learningUnitId,
        questionsAttempted: questionsAttempted,
        correctAnswers: correctAnswers,
        totalQuestionsInUnit: totalQuestionsInUnit,
      );

      debugPrint('✅ Quiz completion recorded for learning unit: $learningUnitId');
    } catch (e) {
      debugPrint('❌ Error recording quiz completion: $e');
    }
  }

  // Calculate total questions in a category
  static int _calculateCategoryQuestions(String categoryId) {
    int total = 0;
    
    // Get all subcategories in this category
    final subcategories = HiveService.getSubCategoriesByCategory(categoryId);
    
    for (final subcategory in subcategories) {
      total += _calculateSubcategoryQuestions(subcategory.id);
    }
    
    return total;
  }

  // Calculate total questions in a subcategory
  static int _calculateSubcategoryQuestions(String subcategoryId) {
    int total = 0;
    
    // Get all learning units in this subcategory
    final learningUnits = HiveService.getLearningUnitsBySubCategory(subcategoryId);
    
    for (final unit in learningUnits) {
      final questions = HiveService.getQuestionsByLearningUnit(unit.id);
      total += questions.length;
    }
    
    return total;
  }

  // Reset progress for a category
  static Future<void> resetCategoryProgress(String userId, String categoryId) async {
    final box = Hive.box<CategoryProgress>(_categoryProgressBox);
    final key = '${userId}_$categoryId';
    await box.delete(key);
    debugPrint('🔄 Reset category progress: $categoryId');
  }

  // Reset progress for a subcategory
  static Future<void> resetSubcategoryProgress(String userId, String subcategoryId) async {
    final box = Hive.box<SubcategoryProgress>(_subcategoryProgressBox);
    final key = '${userId}_$subcategoryId';
    await box.delete(key);
    debugPrint('🔄 Reset subcategory progress: $subcategoryId');
  }

  // Get all categories with their progress status for a user
  static List<(Category, CategoryProgress)> getAllCategoriesWithProgress(String userId) {
    final categories = HiveService.getAllCategories();
    final result = <(Category, CategoryProgress)>[];
    
    for (final category in categories) {
      final progress = getCategoryProgress(userId, category.id);
      result.add((category, progress));
    }
    
    return result;
  }

  // Get all subcategories with their progress status for a user and category
  static List<(SubCategory, SubcategoryProgress)> getSubcategoriesWithProgress(
    String userId,
    String categoryId,
  ) {
    final subcategories = HiveService.getSubCategoriesByCategory(categoryId);
    final result = <(SubCategory, SubcategoryProgress)>[];
    
    for (final subcategory in subcategories) {
      final progress = getSubcategoryProgress(userId, subcategory.id);
      result.add((subcategory, progress));
    }
    
    return result;
  }
}

