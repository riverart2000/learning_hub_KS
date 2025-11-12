import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../models/subcategory.dart';
import '../models/learning_unit.dart';
import '../models/flashcard.dart';
import '../models/quiz.dart';
import '../models/user_progress.dart';
import '../models/user_preferences.dart';
import '../models/user.dart';
import '../models/category_progress.dart';
import '../models/subcategory_progress.dart';
import '../utils/app_logger.dart';
import 'data_loader_service.dart';
import '../models/question.dart';

/// Local database service using Hive with improved error handling and async patterns
class HiveService {
  static const String _categoriesBox = 'categories';
  static const String _subCategoriesBox = 'subcategories';
  static const String _learningUnitsBox = 'learning_units';
  static const String _flashcardsBox = 'flashcards';
  static const String _quizzesBox = 'quizzes';
  static const String _userProgressBox = 'user_progress';
  static const String _userPreferencesBox = 'user_preferences';
  static const String _usersBox = 'users';
  static const String _questionsBox = 'questions';
  static const String _categoryProgressBox = 'category_progress';
  static const String _subcategoryProgressBox = 'subcategory_progress';

  static Future<void> initHive() async {
    try {
      AppLogger.info('Initializing Hive', tag: 'HiveService');
      await Hive.initFlutter();
      
      // Register adapters
      Hive.registerAdapter(models.CategoryAdapter());
      Hive.registerAdapter(SubCategoryAdapter());
      Hive.registerAdapter(LearningUnitAdapter());
      Hive.registerAdapter(FlashcardAdapter());
      Hive.registerAdapter(QuizAdapter());
      Hive.registerAdapter(UserProgressAdapter());
      Hive.registerAdapter(UserPreferencesAdapter());
      Hive.registerAdapter(UserAdapter());
      Hive.registerAdapter(QuestionAdapter());
      Hive.registerAdapter(CategoryProgressAdapter());
      Hive.registerAdapter(SubcategoryProgressAdapter());
      
      // Register enum adapters
      Hive.registerAdapter(LearningUnitTypeAdapter());
      Hive.registerAdapter(DifficultyAdapter());
      Hive.registerAdapter(HiveLearningUnitTypeAdapter());
      Hive.registerAdapter(HiveDifficultyAdapter());
      Hive.registerAdapter(HiveProgressStatusAdapter());
      Hive.registerAdapter(ProgressStatusAdapter());

      // Open boxes
      await Hive.openBox<models.Category>(_categoriesBox);
      await Hive.openBox<SubCategory>(_subCategoriesBox);
      await Hive.openBox<LearningUnit>(_learningUnitsBox);
      await Hive.openBox<Flashcard>(_flashcardsBox);
      await Hive.openBox<Quiz>(_quizzesBox);
      await Hive.openBox<UserProgress>(_userProgressBox);
      await Hive.openBox<UserPreferences>(_userPreferencesBox);
      await Hive.openBox<User>(_usersBox);
      await Hive.openBox<Question>(_questionsBox);
      await Hive.openBox<CategoryProgress>(_categoryProgressBox);
      await Hive.openBox<SubcategoryProgress>(_subcategoryProgressBox);
      
      AppLogger.info('Hive initialization completed', tag: 'HiveService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize Hive',
        tag: 'HiveService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> loadSampleData() async {
    try {
      AppLogger.info('Loading sample data', tag: 'HiveService');
      // Check if data already exists
      if (DataLoaderService.hasDataAlreadyLoaded()) {
        AppLogger.info('Sample data already loaded', tag: 'HiveService');
        return;
      }

      // Use the new DataLoaderService to load all JSON files
      await DataLoaderService.loadAllDataFiles();
      AppLogger.info('Sample data loading completed', tag: 'HiveService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error loading sample data',
        tag: 'HiveService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Category methods
  static List<models.Category> getAllCategories() {
    final box = Hive.box<models.Category>(_categoriesBox);
    return box.values.toList();
  }

  static models.Category? getCategory(String id) {
    final box = Hive.box<models.Category>(_categoriesBox);
    return box.get(id);
  }

  // SubCategory methods
  static List<SubCategory> getSubCategoriesByCategory(String categoryId) {
    final box = Hive.box<SubCategory>(_subCategoriesBox);
    return box.values.where((sub) => sub.categoryId == categoryId).toList();
  }

  static SubCategory? getSubCategory(String id) {
    final box = Hive.box<SubCategory>(_subCategoriesBox);
    return box.get(id);
  }

  // Learning Unit methods
  static List<LearningUnit> getLearningUnitsBySubCategory(String subCategoryId) {
    final box = Hive.box<LearningUnit>(_learningUnitsBox);
    return box.values.where((unit) => unit.subCategoryId == subCategoryId).toList();
  }

  static List<LearningUnit> getLearningUnitsByType(LearningUnitType type) {
    final box = Hive.box<LearningUnit>(_learningUnitsBox);
    return box.values.where((unit) => unit.type == type).toList();
  }

  static List<LearningUnit> getLearningUnitsByDifficulty(Difficulty difficulty) {
    final box = Hive.box<LearningUnit>(_learningUnitsBox);
    return box.values.where((unit) => unit.difficulty == difficulty).toList();
  }

  static LearningUnit? getLearningUnit(String id) {
    final box = Hive.box<LearningUnit>(_learningUnitsBox);
    return box.get(id);
  }

  static List<LearningUnit> getAllLearningUnits() {
    final box = Hive.box<LearningUnit>(_learningUnitsBox);
    return box.values.toList();
  }

  // Flashcard methods
  static List<Flashcard> getFlashcardsByLearningUnit(String learningUnitId) {
    final box = Hive.box<Flashcard>(_flashcardsBox);
    final flashcards = box.values.where((card) => card.learningUnitId == learningUnitId).toList();
    
    debugPrint('🔍 getFlashcardsByLearningUnit($learningUnitId): Found ${flashcards.length} traditional flashcards');
    
    // If no traditional flashcards found, generate from questions
    if (flashcards.isEmpty) {
      final questions = getQuestionsByLearningUnit(learningUnitId);
      debugPrint('🔍 getFlashcardsByLearningUnit($learningUnitId): Found ${questions.length} questions, generating flashcards');
      if (questions.isNotEmpty) {
        final generatedFlashcards = questions.map((q) => Flashcard.fromJson(q.toFlashcard())).toList();
        debugPrint('🔍 getFlashcardsByLearningUnit($learningUnitId): Generated ${generatedFlashcards.length} flashcards');
        return generatedFlashcards;
      }
    }
    
    return flashcards;
  }

  static List<Flashcard> getAllFlashcards() {
    final box = Hive.box<Flashcard>(_flashcardsBox);
    return box.values.toList();
  }

  // Quiz methods
  static List<Quiz> getQuizzesByLearningUnit(String learningUnitId) {
    final box = Hive.box<Quiz>(_quizzesBox);
    final quizzes = box.values.where((quiz) => quiz.learningUnitId == learningUnitId).toList();
    
    // If no traditional quizzes found, generate from questions
    if (quizzes.isEmpty) {
      final questions = getQuestionsByLearningUnit(learningUnitId);
      if (questions.isEmpty) return [];
      
      // Get the learning unit to find the category
      final learningUnit = getLearningUnit(learningUnitId);
      if (learningUnit == null) return [];
      
      // Get the subcategory to find the category
      final subcategory = getSubCategory(learningUnit.subCategoryId);
      if (subcategory == null) return [];
      
      // Get all questions from the same category
      final allQuestionsInCategory = _getAllQuestionsInCategory(subcategory.categoryId);
      
      // Generate quizzes with wrong answers from the same category
      return questions.map((q) {
        // Get wrong answers from other questions in the same category
        final wrongAnswers = allQuestionsInCategory
            .where((other) => other.id != q.id && other.correctAnswer != q.correctAnswer)
            .map((other) => other.correctAnswer)
            .toList();
        
        wrongAnswers.shuffle();
        
        // Create options: correct answer + 4 wrong answers
        final options = <String>[q.correctAnswer];
        options.addAll(wrongAnswers.take(4));
        
        // If not enough wrong answers, add generic options
        while (options.length < 5) {
          options.add('Option ${String.fromCharCode(65 + options.length - 1)}');
        }
        
        options.shuffle();
        final correctIndex = options.indexOf(q.correctAnswer);
        
        return Quiz(
          id: 'qz_${q.id}',
          learningUnitId: q.learningUnitId,
          question: q.question,
          options: options,
          correctAnswerIndex: correctIndex,
          explanation: q.explanation,
          imageUrl: q.imageUrl,
          timeLimit: q.timeLimit ?? 30,
        );
      }).toList();
    }
    
    return quizzes;
  }
  
  // Helper method to get all questions in a category
  static List<Question> _getAllQuestionsInCategory(String categoryId) {
    final questionsBox = Hive.box<Question>(_questionsBox);
    final subcategories = getSubCategoriesByCategory(categoryId);
    final learningUnitIds = <String>[];
    
    for (final subcategory in subcategories) {
      final units = getLearningUnitsBySubCategory(subcategory.id);
      learningUnitIds.addAll(units.map((u) => u.id));
    }
    
    return questionsBox.values
        .where((q) => learningUnitIds.contains(q.learningUnitId))
        .toList();
  }

  static List<Quiz> getAllQuizzes() {
    final box = Hive.box<Quiz>(_quizzesBox);
    return box.values.toList();
  }

  // User methods
  static Future<void> saveUser(User user) async {
    final box = Hive.box<User>(_usersBox);
    await box.put(user.id, user);
  }

  static User? getCurrentUser() {
    final box = Hive.box<User>(_usersBox);
    return box.values.isNotEmpty ? box.values.first : null;
  }

  static Future<void> clearCurrentUser() async {
    final box = Hive.box<User>(_usersBox);
    await box.clear();
  }

  static Future<void> updateUserScore(String userId, double newScore) async {
    final box = Hive.box<User>(_usersBox);
    final user = box.get(userId);
    if (user != null) {
      user.totalScore += newScore;
      if (newScore > user.highScore) {
        user.highScore = newScore;
      }
      await box.put(userId, user);
    }
  }

  // User Progress methods
  static Future<void> saveUserProgress(UserProgress progress) async {
    final box = Hive.box<UserProgress>(_userProgressBox);
    await box.put(progress.id, progress);
  }

  static UserProgress? getUserProgress(String userId, String learningUnitId) {
    final box = Hive.box<UserProgress>(_userProgressBox);
    return box.values.firstWhere(
      (progress) => progress.userId == userId && progress.learningUnitId == learningUnitId,
      orElse: () => UserProgress(
        id: '${userId}_$learningUnitId',
        userId: userId,
        learningUnitId: learningUnitId,
        status: ProgressStatus.notStarted,
        attempts: 0,
        score: 0.0,
      ),
    );
  }

  static List<UserProgress> getUserProgressList(String userId) {
    final box = Hive.box<UserProgress>(_userProgressBox);
    return box.values.where((progress) => progress.userId == userId).toList();
  }

  // User Preferences methods
  static Future<void> saveUserPreferences(UserPreferences preferences) async {
    final box = Hive.box<UserPreferences>(_userPreferencesBox);
    await box.put(preferences.id, preferences);
  }

  static UserPreferences? getUserPreferences(String userId) {
    final box = Hive.box<UserPreferences>(_userPreferencesBox);
    return box.values.firstWhere(
      (pref) => pref.userId == userId,
      orElse: () => UserPreferences(
        id: userId,
        userId: userId,
        preferredCategories: [],
        difficultyPreference: Difficulty.beginner,
        studyRemindersEnabled: true,
        isDarkMode: false,
        colorScheme: 'green',
      ),
    );
  }

  static List<Question> getQuestionsByLearningUnit(String learningUnitId) {
    final box = Hive.box<Question>(_questionsBox);
    return box.values.where((q) => q.learningUnitId == learningUnitId).toList();
  }

  static List<Question> getAllQuestions() {
    final box = Hive.box<Question>(_questionsBox);
    return box.values.toList();
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}

