import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import '../models/subcategory.dart';
import '../models/learning_unit.dart';
import '../services/hive_service.dart';
import '../widgets/common_sticky_header.dart';
import 'learning_unit_screen.dart';

class SubCategoryScreen extends StatefulWidget {
  final SubCategory subCategory;

  const SubCategoryScreen({
    super.key,
    required this.subCategory,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  List<LearningUnit> learningUnits = [];
  Difficulty? selectedDifficulty;
  List<Difficulty> availableDifficulties = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _initializeDifficulties();
    });
  }

  void _initializeDifficulties() {
    final allUnits = HiveService.getLearningUnitsBySubCategory(widget.subCategory.id);
    
    // Find which difficulties have content
    final difficultiesWithContent = <Difficulty>{};
    
    for (final unit in allUnits) {
      // Check if unit has any content
      final flashcards = HiveService.getFlashcardsByLearningUnit(unit.id);
      final quizzes = HiveService.getQuizzesByLearningUnit(unit.id);
      final questions = HiveService.getQuestionsByLearningUnit(unit.id);
      
      if (flashcards.isNotEmpty || quizzes.isNotEmpty || questions.isNotEmpty) {
        difficultiesWithContent.add(unit.difficulty);
      }
    }
    
    // Sort difficulties in order: beginner, intermediate, advanced
    availableDifficulties = difficultiesWithContent.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    
    // Auto-select if there's only one difficulty, or select the first available
    if (availableDifficulties.isNotEmpty) {
      selectedDifficulty = availableDifficulties.first;
      _loadLearningUnits();
    }
  }

  void _loadLearningUnits() {
    if (selectedDifficulty == null) {
      learningUnits = [];
      return;
    }
    
    final allUnits = HiveService.getLearningUnitsBySubCategory(widget.subCategory.id);
    
    // Filter by difficulty and check if units have content
    learningUnits = allUnits.where((unit) {
      if (unit.difficulty != selectedDifficulty) return false;
      
      // Check if unit has any content
      final flashcards = HiveService.getFlashcardsByLearningUnit(unit.id);
      final quizzes = HiveService.getQuizzesByLearningUnit(unit.id);
      final questions = HiveService.getQuestionsByLearningUnit(unit.id);
      return flashcards.isNotEmpty || quizzes.isNotEmpty || questions.isNotEmpty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverStickyHeader(
            header: const CommonStickyHeader(currentScreen: 'subcategory'),
            sliver: SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // SubCategory Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.topic,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.subCategory.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.subCategory.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Difficulty Filter - only show if there are multiple difficulties
                  if (availableDifficulties.length > 1) ...[
                    AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText(
                          'Difficulty Level',
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                      totalRepeatCount: 1,
                      displayFullTextOnTap: true,
                    ),
                    const SizedBox(height: 10),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableDifficulties.map((difficulty) {
                        String label;
                        Color color;
                        
                        switch (difficulty) {
                          case Difficulty.beginner:
                            label = 'Beginner';
                            color = Colors.green;
                            break;
                          case Difficulty.intermediate:
                            label = 'Intermediate';
                            color = Colors.orange;
                            break;
                          case Difficulty.advanced:
                            label = 'Advanced';
                            color = Colors.red;
                            break;
                        }
                        
                        return _buildDifficultyChip(difficulty, label, color);
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Learning Units Section
                  AnimatedTextKit(
                    animatedTexts: [
                      ScaleAnimatedText(
                        'Learning Activities',
                        textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ) ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                  ),
                  const SizedBox(height: 16),

                  if (learningUnits.isEmpty)
                    SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.school,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedDifficulty != null
                                  ? 'No activities available for ${selectedDifficulty!.name} level'
                                  : 'No activities available',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...learningUnits.map((unit) => _buildLearningUnitCard(unit)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(Difficulty difficulty, String label, Color color) {
    final isSelected = selectedDifficulty == difficulty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? (isDark ? Colors.black : Colors.white) : color,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            selectedDifficulty = difficulty;
          });
          _loadLearningUnits();
        }
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: color,
      checkmarkColor: isDark ? Colors.black : Colors.white,
      side: BorderSide(color: color),
    );
  }

  Widget _buildLearningUnitCard(LearningUnit unit) {
    IconData icon;
    Color iconColor;
    
    switch (unit.type) {
      case LearningUnitType.flashcard:
        icon = Icons.quiz;
        iconColor = Colors.blue;
        break;
      case LearningUnitType.quiz:
        icon = Icons.help_outline;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.school;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          unit.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${unit.type.name.toUpperCase()}'),
            Text('Difficulty: ${unit.difficulty.name.toUpperCase()}'),
          ],
        ),
        trailing: const Icon(Icons.play_arrow),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LearningUnitScreen(learningUnit: unit),
            ),
          ).then((_) {
            // Refresh data when returning from learning unit
            setState(() {
              _loadData();
            });
          });
        },
      ),
    );
  }
}
