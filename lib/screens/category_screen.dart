import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/subcategory_progress.dart';
import '../models/user.dart';
import '../services/hive_service.dart';
import '../services/user_service.dart';
import '../services/progress_tracking_service.dart';
import '../widgets/common_sticky_header.dart';
import 'subcategory_screen.dart';
import 'learning_unit_screen.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<SubCategory> subCategories = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      currentUser = UserService.getCurrentUser();
      _loadSubCategories();
    });
  }

  void _loadSubCategories() {
    final allSubcategories = HiveService.getSubCategoriesByCategory(widget.category.id);
    
    // Filter out subcategories with no content
    subCategories = allSubcategories.where((subcategory) {
      final learningUnits = HiveService.getLearningUnitsBySubCategory(subcategory.id);
      return learningUnits.any((unit) {
        final flashcards = HiveService.getFlashcardsByLearningUnit(unit.id);
        final quizzes = HiveService.getQuizzesByLearningUnit(unit.id);
        final questions = HiveService.getQuestionsByLearningUnit(unit.id);
        return flashcards.isNotEmpty || quizzes.isNotEmpty || questions.isNotEmpty;
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverStickyHeader(
            header: const CommonStickyHeader(currentScreen: 'category'),
            sliver: SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Category Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(widget.category.icon),
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.category.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.category.description,
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

                  // Subcategories Section
                  AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Topics',
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.tertiary,
                          Theme.of(context).colorScheme.primary,
                        ],
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                  ),
                  const SizedBox(height: 12),

                  if (subCategories.isEmpty)
                    const SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.topic,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No topics available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...subCategories.map((subCategory) => _buildSubCategoryCard(subCategory)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'science':
        return Icons.science;
      case 'history_edu':
        return Icons.history_edu;
      case 'public':
        return Icons.public;
      case 'computer':
        return Icons.computer;
      case 'terminal':
        return Icons.terminal;
      case 'web':
        return Icons.web;
      case 'widgets':
        return Icons.widgets;
      case 'phone_android':
        return Icons.phone_android;
      case 'code':
        return Icons.code;
      case 'developer_mode':
        return Icons.developer_mode;
      default:
        return Icons.category;
    }
  }

  Widget _buildSubCategoryCard(SubCategory subCategory) {
    // Get progress for this subcategory
    final userId = currentUser?.id ?? 'guest';
    final progress = ProgressTrackingService.getSubcategoryProgress(userId, subCategory.id);
    
    // Determine color based on status and theme brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardColor;
    Color circleColor;
    switch (progress.status) {
      case SubcategoryStatus.perfect:
        cardColor = isDark ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50;
        circleColor = isDark ? Colors.green.shade800.withValues(alpha: 0.5) : Colors.green.shade100;
        break;
      case SubcategoryStatus.completed:
        cardColor = isDark ? Colors.orange.shade900.withValues(alpha: 0.3) : Colors.orange.shade50;
        circleColor = isDark ? Colors.orange.shade800.withValues(alpha: 0.5) : Colors.orange.shade100;
        break;
      case SubcategoryStatus.inProgress:
        cardColor = isDark ? Colors.yellow.shade900.withValues(alpha: 0.3) : Colors.yellow.shade50;
        circleColor = isDark ? Colors.yellow.shade800.withValues(alpha: 0.5) : Colors.yellow.shade100;
        break;
      case SubcategoryStatus.notStarted:
        cardColor = isDark ? Colors.grey.shade800.withValues(alpha: 0.3) : Colors.grey.shade50;
        circleColor = isDark ? Colors.grey.shade700.withValues(alpha: 0.5) : Colors.grey.shade200;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: circleColor,
          child: Icon(
            Icons.topic,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          subCategory.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subCategory.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${progress.attemptedQuestions}/${progress.totalQuestions} questions',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                if (progress.isStarted) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• ${progress.accuracy.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Check if there's only one learning unit in this subcategory
          final learningUnits = HiveService.getLearningUnitsBySubCategory(subCategory.id);
          
          if (learningUnits.length == 1) {
            // Skip to learning unit screen directly if only one activity
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LearningUnitScreen(learningUnit: learningUnits.first),
              ),
            ).then((_) async {
              // Small delay to ensure Hive writes complete
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) setState(() => _loadData());
            });
          } else {
            // Show subcategory screen if multiple learning units
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SubCategoryScreen(subCategory: subCategory),
              ),
            ).then((_) async {
              // Small delay to ensure Hive writes complete
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) setState(() => _loadData());
            });
          }
        },
      ),
    );
  }
}

