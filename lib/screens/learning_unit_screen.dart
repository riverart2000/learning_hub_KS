import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import '../models/learning_unit.dart';
import '../models/user_progress.dart';
import '../models/subcategory_progress.dart';
import '../services/hive_service.dart';
import '../services/user_service.dart';
import '../services/progress_tracking_service.dart';
import '../widgets/common_sticky_header.dart';
import 'flashcard_game_screen.dart';
import 'quiz_game_screen.dart';
import 'study_review_screen.dart';

class LearningUnitScreen extends StatefulWidget {
  final LearningUnit learningUnit;

  const LearningUnitScreen({
    super.key,
    required this.learningUnit,
  });

  @override
  State<LearningUnitScreen> createState() => _LearningUnitScreenState();
}

class _LearningUnitScreenState extends State<LearningUnitScreen> {
  UserProgress? progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    final user = UserService.getCurrentUser();
    setState(() {
      progress = user != null 
          ? UserService.getUserProgress(user.id, widget.learningUnit.id)
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverStickyHeader(
            header: const CommonStickyHeader(currentScreen: 'learning_unit'),
            sliver: SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Learning Unit Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            _getTypeIcon(widget.learningUnit.type),
                            size: 28,
                            color: _getTypeColor(widget.learningUnit.type),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.learningUnit.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      widget.learningUnit.type.name.toUpperCase(),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getDifficultyColor(widget.learningUnit.difficulty).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        widget.learningUnit.difficulty.name.toUpperCase(),
                                        style: TextStyle(
                                          color: _getDifficultyColor(widget.learningUnit.difficulty),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress Card (if available)
                  if (progress != null) ...[
                    Builder(
                      builder: (context) {
                        final currentProgress = progress!;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Progress',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildProgressStat(
                                        'Status',
                                        currentProgress.status.name.toUpperCase(),
                                        _getStatusIcon(currentProgress.status),
                                        _getStatusColor(currentProgress.status),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _buildProgressStat(
                                        'Best Score',
                                        '${currentProgress.score.toStringAsFixed(1)}%',
                                        Icons.star,
                                        Colors.amber,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _buildProgressStat(
                                        'Attempts',
                                        '${currentProgress.attempts}',
                                        Icons.refresh,
                                        Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _buildProgressStat(
                                        'Last Reviewed',
                                        currentProgress.lastReviewed != null 
                                            ? _formatDate(currentProgress.lastReviewed!)
                                            : 'Never',
                                        Icons.schedule,
                                        Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action Buttons
                  AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Start Learning',
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        colors: [
                          Colors.blue,
                          Colors.purple,
                          Colors.green,
                          Colors.blue,
                        ],
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                  ),
                  const SizedBox(height: 12),

                  _buildActionButton(),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    switch (widget.learningUnit.type) {
      case LearningUnitType.flashcard:
        return _buildFlashcardButton();
      case LearningUnitType.quiz:
        return _buildQuizButton();
      case LearningUnitType.mixed:
        return _buildMixedButton();
      default:
        return const Center(
          child: Text('This learning unit type is not yet supported'),
        );
    }
  }

  Widget _buildFlashcardButton() {
    final flashcards = HiveService.getFlashcardsByLearningUnit(widget.learningUnit.id);
    
    return Card(
      child: InkWell(
        onTap: flashcards.isNotEmpty ? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FlashcardGameScreen(
                learningUnitId: widget.learningUnit.id,
              ),
            ),
          ).then((_) async {
            // Small delay to ensure Hive writes complete
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) _loadProgress();
          });
        } : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz,
                  size: 40,
                  color: flashcards.isNotEmpty ? Colors.blue : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  'Flashcards',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: flashcards.isNotEmpty ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  flashcards.isNotEmpty 
                      ? '${flashcards.length} cards'
                      : 'No cards',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (flashcards.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FlashcardGameScreen(
                            learningUnitId: widget.learningUnit.id,
                          ),
                        ),
                      ).then((_) async {
            // Small delay to ensure Hive writes complete
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) _loadProgress();
          });
                    },
                    child: const Text('Start'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizButton() {
    final quizzes = HiveService.getQuizzesByLearningUnit(widget.learningUnit.id);
    
    return Card(
      child: InkWell(
        onTap: quizzes.isNotEmpty ? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QuizGameScreen(
                learningUnitId: widget.learningUnit.id,
              ),
            ),
          ).then((_) async {
            // Small delay to ensure Hive writes complete
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) _loadProgress();
          });
        } : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 40,
                  color: quizzes.isNotEmpty ? Colors.purple : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  'Quiz',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: quizzes.isNotEmpty ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quizzes.isNotEmpty 
                      ? '${quizzes.length} questions'
                      : 'No questions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (quizzes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuizGameScreen(
                            learningUnitId: widget.learningUnit.id,
                          ),
                        ),
                      ).then((_) async {
            // Small delay to ensure Hive writes complete
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) _loadProgress();
          });
                    },
                    child: const Text('Start'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMixedButton() {
    final flashcards = HiveService.getFlashcardsByLearningUnit(widget.learningUnit.id);
    final quizzes = HiveService.getQuizzesByLearningUnit(widget.learningUnit.id);
    final questions = HiveService.getQuestionsByLearningUnit(widget.learningUnit.id);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Study Mode section
          Card(
            child: InkWell(
              onTap: questions.isNotEmpty ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StudyReviewScreen(
                      learningUnitId: widget.learningUnit.id,
                    ),
                  ),
                ).then((_) async {
            // Small delay to ensure Hive writes complete
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) _loadProgress();
          });
              } : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 48,
                      color: questions.isNotEmpty ? Colors.teal : Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Study Mode',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: questions.isNotEmpty ? null : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            questions.isNotEmpty 
                                ? '${questions.length} questions available'
                                : 'No study material available',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (questions.isNotEmpty)
                      const Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Flashcards section - color matches subcategory progress
          Builder(
            builder: (context) {
              // Get current user and subcategory progress
              final currentUser = UserService.getCurrentUser();
              final userId = currentUser?.id ?? 'guest';
              final subcategoryProgress = ProgressTrackingService.getSubcategoryProgress(
                userId, 
                widget.learningUnit.subCategoryId,
              );
              
              // Determine color based on progress status
              final isDark = Theme.of(context).brightness == Brightness.dark;
              Color cardColor;
              Color iconColor;
              switch (subcategoryProgress.status) {
                case SubcategoryStatus.perfect:
                  cardColor = isDark ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50;
                  iconColor = isDark ? Colors.green.shade400 : Colors.green;
                  break;
                case SubcategoryStatus.completed:
                  cardColor = isDark ? Colors.orange.shade900.withValues(alpha: 0.3) : Colors.orange.shade50;
                  iconColor = isDark ? Colors.orange.shade400 : Colors.orange;
                  break;
                case SubcategoryStatus.inProgress:
                  cardColor = isDark ? Colors.yellow.shade900.withValues(alpha: 0.3) : Colors.yellow.shade50;
                  iconColor = isDark ? Colors.yellow.shade400 : Colors.yellow.shade700;
                  break;
                case SubcategoryStatus.notStarted:
                  cardColor = isDark ? Colors.grey.shade800.withValues(alpha: 0.3) : Colors.grey.shade50;
                  iconColor = flashcards.isNotEmpty ? (isDark ? Colors.blue.shade400 : Colors.blue) : Colors.grey;
                  break;
              }
              
              return Card(
                color: cardColor,
                child: InkWell(
                  onTap: flashcards.isNotEmpty ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FlashcardGameScreen(
                          learningUnitId: widget.learningUnit.id,
                        ),
                      ),
                    ).then((_) async {
            // Small delay to ensure Hive writes complete
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) _loadProgress();
          });
                  } : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 48,
                          color: iconColor,
                        ),
                        const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Study Flashcards',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: flashcards.isNotEmpty ? null : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flashcards.isNotEmpty 
                                ? '${flashcards.length} cards available'
                                : 'No flashcards available',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                        if (flashcards.isNotEmpty)
                          const Icon(Icons.arrow_forward_ios, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Quiz section - color matches subcategory progress
          Builder(
            builder: (context) {
              // Get current user and subcategory progress
              final currentUser = UserService.getCurrentUser();
              final userId = currentUser?.id ?? 'guest';
              final subcategoryProgress = ProgressTrackingService.getSubcategoryProgress(
                userId, 
                widget.learningUnit.subCategoryId,
              );
              
              // Determine color based on progress status
              final isDarkQuiz = Theme.of(context).brightness == Brightness.dark;
              Color cardColor;
              Color iconColor;
              switch (subcategoryProgress.status) {
                case SubcategoryStatus.perfect:
                  cardColor = isDarkQuiz ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50;
                  iconColor = isDarkQuiz ? Colors.green.shade400 : Colors.green;
                  break;
                case SubcategoryStatus.completed:
                  cardColor = isDarkQuiz ? Colors.orange.shade900.withValues(alpha: 0.3) : Colors.orange.shade50;
                  iconColor = isDarkQuiz ? Colors.orange.shade400 : Colors.orange;
                  break;
                case SubcategoryStatus.inProgress:
                  cardColor = isDarkQuiz ? Colors.yellow.shade900.withValues(alpha: 0.3) : Colors.yellow.shade50;
                  iconColor = isDarkQuiz ? Colors.yellow.shade400 : Colors.yellow.shade700;
                  break;
                case SubcategoryStatus.notStarted:
                  cardColor = isDarkQuiz ? Colors.grey.shade800.withValues(alpha: 0.3) : Colors.grey.shade50;
                  iconColor = quizzes.isNotEmpty ? (isDarkQuiz ? Colors.purple.shade400 : Colors.purple) : Colors.grey;
                  break;
              }
              
              return Card(
                color: cardColor,
                child: InkWell(
                  onTap: quizzes.isNotEmpty ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QuizGameScreen(
                          learningUnitId: widget.learningUnit.id,
                        ),
                      ),
                    ).then((_) async {
            // Small delay to ensure Hive writes complete
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) _loadProgress();
          });
                  } : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 48,
                          color: iconColor,
                        ),
                        const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Take Quiz',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: quizzes.isNotEmpty ? null : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            quizzes.isNotEmpty 
                                ? '${quizzes.length} questions available'
                                : 'No quiz questions available',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                        if (quizzes.isNotEmpty)
                          const Icon(Icons.arrow_forward_ios, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(LearningUnitType type) {
    switch (type) {
      case LearningUnitType.flashcard:
        return Icons.quiz;
      case LearningUnitType.quiz:
        return Icons.help_outline;
      case LearningUnitType.mixed:
        return Icons.school;
      default:
        return Icons.school;
    }
  }

  Color _getTypeColor(LearningUnitType type) {
    switch (type) {
      case LearningUnitType.flashcard:
        return Colors.blue;
      case LearningUnitType.quiz:
        return Colors.purple;
      case LearningUnitType.mixed:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.advanced:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.notStarted:
        return Icons.play_circle_outline;
      case ProgressStatus.inProgress:
        return Icons.refresh;
      case ProgressStatus.completed:
        return Icons.check_circle;
      case ProgressStatus.mastered:
        return Icons.star;
    }
  }

  Color _getStatusColor(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.notStarted:
        return Colors.grey;
      case ProgressStatus.inProgress:
        return Colors.blue;
      case ProgressStatus.completed:
        return Colors.green;
      case ProgressStatus.mastered:
        return Colors.amber;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

