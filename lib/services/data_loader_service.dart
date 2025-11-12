import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/learning_unit.dart';
import '../models/flashcard.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import 'hive_service.dart';

class DataLoaderService {
  static const String _assetsDataPath = 'assets/data/';
  
  // ID mappings to track original ID -> unique ID and detect collisions
  static final Map<String, String> _categoryIdMap = {};
  static final Map<String, String> _subcategoryIdMap = {};
  static final Map<String, String> _learningUnitIdMap = {};
  
  // Track loaded question texts to prevent duplicates
  static final Set<String> _loadedQuestionTexts = {};
  
  // Counters for generating unique IDs when collisions occur
  static int _idCounter = 0;
  
  /// Loads all JSON files from the assets/data directory and processes them
  static Future<void> loadAllDataFiles() async {
    debugPrint('📚 DataLoaderService.loadAllDataFiles() started');
    // Reset mappings at the start of loading
    _categoryIdMap.clear();
    _subcategoryIdMap.clear();
    _learningUnitIdMap.clear();
    _loadedQuestionTexts.clear(); // Clear duplicate question tracker
    _idCounter = 0;
    
    try {
      // Get the list of JSON files in the assets/data directory
      final List<String> jsonFiles = await _getJsonFilesFromAssets();
      
      if (jsonFiles.isEmpty) {
        debugPrint('No JSON files found in assets/data directory');
        return;
      }
      
      debugPrint('Found ${jsonFiles.length} JSON files to load: ${jsonFiles.join(', ')}');
      
      // Load and process each JSON file
      for (final fileName in jsonFiles) {
        await _loadJsonFile(fileName);
      }
      
      debugPrint('📚 All data files loaded successfully');
      debugPrint('📚 Total questions loaded: ${HiveService.getAllQuestions().length}');
      debugPrint('📚 Total learning units loaded: ${HiveService.getAllLearningUnits().length}');
    } catch (e) {
      debugPrint('Error loading data files: $e');
      rethrow;
    }
  }
  
  /// Gets the list of JSON files from the assets/data directory
  /// Loads from manifest.json if available, falls back to hardcoded list
  static Future<List<String>> _getJsonFilesFromAssets() async {
    try {
      // Try to load the manifest file first
      debugPrint('📋 Loading manifest.json...');
      final String manifestString = await rootBundle.loadString('${_assetsDataPath}manifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestString);
      
      final List<String> dataFiles = List<String>.from(manifest['dataFiles'] ?? []);
      debugPrint('📋 Loaded manifest with ${dataFiles.length} files: ${dataFiles.join(', ')}');
      
      // Verify each file exists before including it
      final List<String> existingFiles = [];
      
      for (final fileName in dataFiles) {
        try {
          await rootBundle.loadString('$_assetsDataPath$fileName');
          existingFiles.add(fileName);
          debugPrint('✓ Verified: $fileName');
        } catch (e) {
          debugPrint('✗ File $fileName listed in manifest but not found, skipping...');
        }
      }
      
      if (existingFiles.isEmpty) {
        debugPrint('⚠️  No valid files found in manifest!');
      }
      
      return existingFiles;
    } catch (manifestError) {
      debugPrint('📋 Manifest not found or invalid, using fallback list: $manifestError');
      
      // Fallback to hardcoded list if manifest fails
      final List<String> fallbackFiles = [
        'sample_data.json',
        'physics_100_qs.json',
        // Add more JSON files here as backup
      ];
      
      debugPrint('📋 Using fallback file list: ${fallbackFiles.join(', ')}');
      
      // Verify fallback files exist
      final List<String> existingFiles = [];
      
      for (final fileName in fallbackFiles) {
        try {
          await rootBundle.loadString('$_assetsDataPath$fileName');
          existingFiles.add(fileName);
          debugPrint('✓ Fallback verified: $fileName');
        } catch (e) {
          debugPrint('✗ Fallback file $fileName not found, skipping...');
        }
      }
      
      return existingFiles;
    }
  }
  
  /// Loads and processes a single JSON file
  static Future<void> _loadJsonFile(String fileName) async {
    try {
      debugPrint('Loading data from $fileName...');
      
      // Load JSON data from assets
      final String jsonString = await rootBundle.loadString('$_assetsDataPath$fileName');
      final dynamic decodedJson = json.decode(jsonString);
      
      // Check if the decoded JSON is a Map (object) or List (array)
      if (decodedJson is! Map<String, dynamic>) {
        debugPrint('Skipping $fileName - not in expected object format (found ${decodedJson.runtimeType})');
        return;
      }
      
      final Map<String, dynamic> jsonData = decodedJson;
      
      // Process different data types if they exist in the JSON
      await _processCategories(jsonData, fileName);
      await _processSubCategories(jsonData, fileName);
      await _processLearningUnits(jsonData, fileName);
      await _processQuestions(jsonData, fileName);
      
      // Keep these for backward compatibility with old format
      await _processFlashcards(jsonData, fileName);
      await _processQuizzes(jsonData, fileName);
      
      debugPrint('Successfully loaded data from $fileName');
    } catch (e) {
      debugPrint('Error loading $fileName: $e');
      // Continue with other files even if one fails
    }
  }
  
  /// Processes categories from JSON data
  static Future<void> _processCategories(Map<String, dynamic> jsonData, String fileName) async {
    if (!jsonData.containsKey('categories')) return;
    
    final categoriesBox = Hive.box<Category>('categories');
    final List<dynamic> categoriesJson = jsonData['categories'];
    
    for (final categoryJson in categoriesJson) {
      try {
        final category = Category.fromJson(categoryJson);
        final originalId = category.id;
        
        // Check if this ID already exists in Hive or our mapping
        String uniqueId = originalId;
        if (categoriesBox.containsKey(originalId) || _categoryIdMap.containsValue(originalId)) {
          // ID collision detected! Generate a unique ID
          uniqueId = '${originalId}_${_idCounter++}';
          debugPrint('⚠️  ID collision for category "$originalId" - using "$uniqueId"');
        }
        
        // Store the mapping
        _categoryIdMap[originalId] = uniqueId;
        
        // Create category with unique ID
        final uniqueCategory = Category(
          id: uniqueId,
          name: category.name,
          description: category.description,
          icon: category.icon,
        );
        await categoriesBox.put(uniqueId, uniqueCategory);
      } catch (e) {
        debugPrint('Error processing category in $fileName: $e');
      }
    }
    
    debugPrint('Loaded ${categoriesJson.length} categories from $fileName');
  }
  
  /// Processes subcategories from JSON data
  static Future<void> _processSubCategories(Map<String, dynamic> jsonData, String fileName) async {
    if (!jsonData.containsKey('subcategories')) return;
    
    final subCategoriesBox = Hive.box<SubCategory>('subcategories');
    final List<dynamic> subCategoriesJson = jsonData['subcategories'];
    
    for (final subCategoryJson in subCategoriesJson) {
      try {
        final subCategory = SubCategory.fromJson(subCategoryJson);
        final originalId = subCategory.id;
        
        // Check for ID collision
        String uniqueId = originalId;
        if (subCategoriesBox.containsKey(originalId) || _subcategoryIdMap.containsValue(originalId)) {
          uniqueId = '${originalId}_${_idCounter++}';
          debugPrint('⚠️  ID collision for subcategory "$originalId" - using "$uniqueId"');
        }
        
        // Store the mapping
        _subcategoryIdMap[originalId] = uniqueId;
        
        // Map category ID to unique ID
        final mappedCategoryId = _categoryIdMap[subCategory.categoryId] ?? subCategory.categoryId;
        
        // Create subcategory with unique ID and mapped category ID
        final uniqueSubCategory = SubCategory(
          id: uniqueId,
          categoryId: mappedCategoryId,
          name: subCategory.name,
          description: subCategory.description,
        );
        await subCategoriesBox.put(uniqueId, uniqueSubCategory);
      } catch (e) {
        debugPrint('Error processing subcategory in $fileName: $e');
      }
    }
    
    debugPrint('Loaded ${subCategoriesJson.length} subcategories from $fileName');
  }
  
  /// Processes learning units from JSON data
  static Future<void> _processLearningUnits(Map<String, dynamic> jsonData, String fileName) async {
    if (!jsonData.containsKey('learningUnits')) return;
    
    final learningUnitsBox = Hive.box<LearningUnit>('learning_units');
    final List<dynamic> learningUnitsJson = jsonData['learningUnits'];
    
    for (final learningUnitJson in learningUnitsJson) {
      try {
        final learningUnit = LearningUnit.fromJson(learningUnitJson);
        final originalId = learningUnit.id;
        
        // Check for ID collision
        String uniqueId = originalId;
        if (learningUnitsBox.containsKey(originalId) || _learningUnitIdMap.containsValue(originalId)) {
          uniqueId = '${originalId}_${_idCounter++}';
          debugPrint('⚠️  ID collision for learning unit "$originalId" - using "$uniqueId"');
        }
        
        // Store the mapping
        _learningUnitIdMap[originalId] = uniqueId;
        
        // Map subcategory ID to unique ID
        final mappedSubCategoryId = _subcategoryIdMap[learningUnit.subCategoryId] ?? learningUnit.subCategoryId;
        
        // Create learning unit with unique ID and mapped subcategory ID
        final uniqueLearningUnit = LearningUnit(
          id: uniqueId,
          subCategoryId: mappedSubCategoryId,
          type: learningUnit.type,
          title: learningUnit.title,
          content: learningUnit.content,
          difficulty: learningUnit.difficulty,
          tags: learningUnit.tags,
          createdAt: learningUnit.createdAt,
          updatedAt: learningUnit.updatedAt,
        );
        await learningUnitsBox.put(uniqueId, uniqueLearningUnit);
      } catch (e) {
        debugPrint('Error processing learning unit in $fileName: $e');
      }
    }
    
    debugPrint('Loaded ${learningUnitsJson.length} learning units from $fileName');
  }
  
  /// Processes questions from JSON data with duplicate filtering
  static Future<void> _processQuestions(Map<String, dynamic> jsonData, String fileName) async {
    if (!jsonData.containsKey('questions')) return;
    
    final questionsBox = Hive.box<Question>('questions');
    final List<dynamic> questionsJson = jsonData['questions'];
    
    int successCount = 0;
    int errorCount = 0;
    int skippedDuplicates = 0;
    
    for (final questionJson in questionsJson) {
      try {
        final question = Question.fromJson(questionJson);
        final originalId = question.id;
        
        // Normalize question text for duplicate detection
        final normalizedText = question.question.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
        
        // Check if this exact question text already exists
        if (_loadedQuestionTexts.contains(normalizedText)) {
          skippedDuplicates++;
          if (skippedDuplicates <= 5) { // Only log first 5 to avoid spam
            debugPrint('⏭️  Skipping duplicate: $originalId');
          }
          continue;
        }
        
        // Questions always get unique IDs by appending counter
        final uniqueId = '${originalId}_${_idCounter++}';
        
        // Map learning unit ID to unique ID
        final mappedLearningUnitId = _learningUnitIdMap[question.learningUnitId] ?? question.learningUnitId;
        
        // Create question with unique ID and mapped learning unit ID
        final uniqueQuestion = Question(
          id: uniqueId,
          learningUnitId: mappedLearningUnitId,
          question: question.question,
          correctAnswer: question.correctAnswer,
          hint: question.hint,
          explanation: question.explanation,
          imageUrl: question.imageUrl,
          audioUrl: question.audioUrl,
          difficulty: question.difficulty,
          tags: question.tags,
          timeLimit: question.timeLimit,
        );
        
        await questionsBox.put(uniqueId, uniqueQuestion);
        _loadedQuestionTexts.add(normalizedText);
        successCount++;
        
      } catch (e, stackTrace) {
        errorCount++;
        debugPrint('❌ Error processing question ${questionJson['id']} in $fileName: $e');
        if (errorCount <= 3) {
          debugPrint('   Stack trace: $stackTrace');
          debugPrint('   Question data: $questionJson');
        }
      }
    }
    
    final statusMsg = skippedDuplicates > 0 
        ? 'Loaded $successCount/${questionsJson.length} questions from $fileName (skipped $skippedDuplicates duplicates${errorCount > 0 ? ", $errorCount errors" : ""})'
        : 'Loaded $successCount/${questionsJson.length} questions from $fileName${errorCount > 0 ? " ($errorCount errors)" : ""}';
    debugPrint(statusMsg);
  }
  
  /// Processes flashcards from JSON data
  static Future<void> _processFlashcards(Map<String, dynamic> jsonData, String fileName) async {
    if (!jsonData.containsKey('flashcards')) return;
    
    final flashcardsBox = Hive.box<Flashcard>('flashcards');
    final List<dynamic> flashcardsJson = jsonData['flashcards'];
    
    for (final flashcardJson in flashcardsJson) {
      try {
        final flashcard = Flashcard.fromJson(flashcardJson);
        await flashcardsBox.put(flashcard.id, flashcard);
      } catch (e) {
        debugPrint('Error processing flashcard in $fileName: $e');
      }
    }
    
    debugPrint('Loaded ${flashcardsJson.length} flashcards from $fileName');
  }
  
  /// Processes quizzes from JSON data
  static Future<void> _processQuizzes(Map<String, dynamic> jsonData, String fileName) async {
    if (!jsonData.containsKey('quizzes')) return;
    
    final quizzesBox = Hive.box<Quiz>('quizzes');
    final List<dynamic> quizzesJson = jsonData['quizzes'];
    
    for (final quizJson in quizzesJson) {
      try {
        final quiz = Quiz.fromJson(quizJson);
        await quizzesBox.put(quiz.id, quiz);
      } catch (e) {
        debugPrint('Error processing quiz in $fileName: $e');
      }
    }
    
    debugPrint('Loaded ${quizzesJson.length} quizzes from $fileName');
  }
  
  /// Checks if any data has already been loaded to avoid duplicates
  static bool hasDataAlreadyLoaded() {
    final categoriesBox = Hive.box<Category>('categories');
    return categoriesBox.isNotEmpty;
  }
  
  /// Clears all data from the boxes (useful for reloading)
  static Future<void> clearAllData() async {
    final categoriesBox = Hive.box<Category>('categories');
    final subCategoriesBox = Hive.box<SubCategory>('subcategories');
    final learningUnitsBox = Hive.box<LearningUnit>('learning_units');
    final flashcardsBox = Hive.box<Flashcard>('flashcards');
    final quizzesBox = Hive.box<Quiz>('quizzes');
    final questionsBox = Hive.box<Question>('questions');
    
    await categoriesBox.clear();
    await subCategoriesBox.clear();
    await learningUnitsBox.clear();
    await flashcardsBox.clear();
    await quizzesBox.clear();
    await questionsBox.clear();
    
    debugPrint('All data cleared from Hive boxes');
  }
  
  /// Prints the current manifest contents (useful for debugging)
  static Future<void> printManifest() async {
    try {
      final String manifestString = await rootBundle.loadString('${_assetsDataPath}manifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestString);
      
      debugPrint('📋 Current Manifest:');
      debugPrint('   Files: ${manifest['dataFiles']}');
      if (manifest.containsKey('version')) {
        debugPrint('   Version: ${manifest['version']}');
      }
      if (manifest.containsKey('description')) {
        debugPrint('   Description: ${manifest['description']}');
      }
      if (manifest.containsKey('lastUpdated')) {
        debugPrint('   Last Updated: ${manifest['lastUpdated']}');
      }
    } catch (e) {
      debugPrint('📋 No manifest found or error reading: $e');
    }
  }
  
  /// Validates that all files in manifest actually exist
  static Future<Map<String, bool>> validateManifest() async {
    final Map<String, bool> results = {};
    
    try {
      final String manifestString = await rootBundle.loadString('${_assetsDataPath}manifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestString);
      final List<String> dataFiles = List<String>.from(manifest['dataFiles'] ?? []);
      
      debugPrint('📋 Validating ${dataFiles.length} files from manifest...');
      
      for (final fileName in dataFiles) {
        try {
          await rootBundle.loadString('$_assetsDataPath$fileName');
          results[fileName] = true;
          debugPrint('✓ $fileName exists');
        } catch (e) {
          results[fileName] = false;
          debugPrint('✗ $fileName missing');
        }
      }
    } catch (e) {
      debugPrint('Error validating manifest: $e');
    }
    
    return results;
  }
  
  /// Adds a new JSON file to the list of known files
  /// This method should be called when new JSON files are added to assets/data
  static void registerJsonFile(String fileName) {
    // In a real implementation, you might want to store this in shared preferences
    // or another persistent storage mechanism
    debugPrint('Registered new JSON file: $fileName');
    debugPrint('Note: Add "$fileName" to the manifest.json file');
  }

  /// Debug method to check data loading status
  static Future<void> debugDataStatus() async {
  debugPrint('\n🔍 === DEBUG DATA STATUS ===');
  
  try {
    // Check categories
    final categoriesBox = Hive.box<Category>('categories');
    debugPrint('📂 Categories: ${categoriesBox.length} items');
    for (final category in categoriesBox.values) {
      debugPrint('   - ${category.id}: ${category.name}');
    }
    
    // Check subcategories
    final subCategoriesBox = Hive.box<SubCategory>('subcategories');
    debugPrint('📁 Subcategories: ${subCategoriesBox.length} items');
    for (final subcat in subCategoriesBox.values) {
      debugPrint('   - ${subcat.id}: ${subcat.name} (parent: ${subcat.categoryId})');
    }
    
    // Check learning units
    final learningUnitsBox = Hive.box<LearningUnit>('learning_units');
    debugPrint('📚 Learning Units: ${learningUnitsBox.length} items');
    for (final unit in learningUnitsBox.values) {
      debugPrint('   - ${unit.id}: ${unit.title} (type: ${unit.type.name}, subcat: ${unit.subCategoryId})');
    }
    
    // Check flashcards
    final flashcardsBox = Hive.box<Flashcard>('flashcards');
    debugPrint('🃏 Flashcards: ${flashcardsBox.length} items');
    final flashcardsByUnit = <String, int>{};
    for (final card in flashcardsBox.values) {
      flashcardsByUnit[card.learningUnitId] = (flashcardsByUnit[card.learningUnitId] ?? 0) + 1;
    }
    for (final entry in flashcardsByUnit.entries) {
      debugPrint('   - ${entry.key}: ${entry.value} flashcards');
    }
    
    // Check quizzes
    final quizzesBox = Hive.box<Quiz>('quizzes');
    debugPrint('❓ Quizzes: ${quizzesBox.length} items');
    final quizzesByUnit = <String, int>{};
    for (final quiz in quizzesBox.values) {
      quizzesByUnit[quiz.learningUnitId] = (quizzesByUnit[quiz.learningUnitId] ?? 0) + 1;
    }
    for (final entry in quizzesByUnit.entries) {
      debugPrint('   - ${entry.key}: ${entry.value} quizzes');
    }

     // Check questions (temporarily disabled)
     final questionsBox = Hive.box<Question>('questions');
     debugPrint('❓ Questions: ${questionsBox.length} items');
     final questionsByUnit = <String, int>{};
     for (final question in questionsBox.values) {
       questionsByUnit[question.learningUnitId] = (questionsByUnit[question.learningUnitId] ?? 0) + 1;
     }
     for (final entry in questionsByUnit.entries) {
       debugPrint('   - ${entry.key}: ${entry.value} questions');
     }
    
    // Cross-reference check
    debugPrint('\n🔗 Cross-Reference Check:');
    for (final unit in learningUnitsBox.values) {
      final flashcardCount = flashcardsByUnit[unit.id] ?? 0;
      final quizCount = quizzesByUnit[unit.id] ?? 0;
      final questionCount = questionsByUnit[unit.id] ?? 0;
      debugPrint('   ${unit.id} (${unit.type.name}): $flashcardCount flashcards, $quizCount quizzes, $questionCount questions');
      
      if (unit.type == LearningUnitType.flashcard && flashcardCount == 0) {
        debugPrint('   ⚠️  WARNING: Flashcard unit has no flashcards!');
      }
      if (unit.type == LearningUnitType.quiz && quizCount == 0) {
        debugPrint('   ⚠️  WARNING: Quiz unit has no quizzes!');
      }
       if (unit.type == LearningUnitType.mixed && questionCount == 0) {
         debugPrint('   ⚠️  WARNING: Mixed unit has no questions!');
       }
    }
    
  } catch (e) {
    debugPrint('❌ Error during debug: $e');
  }
  
  debugPrint('🔍 === END DEBUG ===\n');
  }
}