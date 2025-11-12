import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import '../models/category.dart' as models;
import '../models/user.dart';
import '../services/hive_service.dart';
import '../services/user_service.dart';
import '../services/progress_tracking_service.dart';
import '../services/app_config_service.dart';
import '../models/category_progress.dart';
import '../widgets/common_sticky_header.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<models.Category> categories = [];
  User? currentUser;
  Map<String, dynamic> userStats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final allCategories = HiveService.getAllCategories();
    
    // Filter out categories with no content (subcategories with learning units that have questions/flashcards/quizzes)
    categories = allCategories.where((category) {
      final subcategories = HiveService.getSubCategoriesByCategory(category.id);
      return subcategories.any((subcategory) {
        final learningUnits = HiveService.getLearningUnitsBySubCategory(subcategory.id);
        return learningUnits.any((unit) {
          final flashcards = HiveService.getFlashcardsByLearningUnit(unit.id);
          final quizzes = HiveService.getQuizzesByLearningUnit(unit.id);
          final questions = HiveService.getQuestionsByLearningUnit(unit.id);
          return flashcards.isNotEmpty || quizzes.isNotEmpty || questions.isNotEmpty;
        });
      });
    }).toList();
    
    currentUser = UserService.getCurrentUser();
    
    if (currentUser != null) {
      userStats = UserService.getUserStats(currentUser!.id);
    }
    
    setState(() {});
  }

  Widget _buildProfileAvatar() {
    // Always show the initial; photo functionality retired for privacy compliance
    return CircleAvatar(
      radius: 30,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        currentUser!.name[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverStickyHeader(
              header: const CommonStickyHeader(currentScreen: 'home'),
              sliver: SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
              // User Stats Card
              if (currentUser != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildProfileAvatar(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppConfigService.homeWelcomePrefix}${currentUser!.name}!',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    'Track your progress and keep learning!',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Score',
                                userStats['totalScore']?.toStringAsFixed(0) ?? '0',
                                Icons.score,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildStatCard(
                                'High',
                                userStats['highScore']?.toStringAsFixed(0) ?? '0',
                                Icons.star,
                                Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildStatCard(
                                'Done',
                                '${userStats['completedUnits'] ?? 0}',
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildStatCard(
                                'Master',
                                '${userStats['masteredUnits'] ?? 0}',
                                Icons.military_tech,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Categories Section with App Title
              Text(
                AppConfigService.homeCategoriesTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (categories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.category,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No categories available',
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
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(categories[index]);
                  },
                ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildCategoryCard(models.Category category) {
    // Get progress for this category
    final userId = currentUser?.id ?? 'guest';
    final progress = ProgressTrackingService.getCategoryProgress(userId, category.id);
    
    // Calculate progress percentage
    final progressPercentage = progress.totalQuestions > 0
        ? (progress.attemptedQuestions / progress.totalQuestions)
        : 0.0;
    
    // Determine colors based on status
    Color primaryColor;
    IconData statusIcon;
    
    switch (progress.status) {
      case CategoryStatus.perfect:
        primaryColor = Colors.green.shade600;
        statusIcon = Icons.check_circle;
        break;
      case CategoryStatus.completed:
        primaryColor = Colors.orange.shade600;
        statusIcon = Icons.check_circle_outline;
        break;
      case CategoryStatus.inProgress:
        primaryColor = Colors.blue.shade600;
        statusIcon = Icons.timelapse;
        break;
      case CategoryStatus.notStarted:
        primaryColor = Colors.grey.shade600;
        statusIcon = Icons.chevron_right;
        break;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CategoryScreen(category: category),
              ),
            ).then((_) async {
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) _loadData();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.icon),
                    size: 24,
                    color: primaryColor,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category name
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Progress info
                      if (progress.isStarted) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: progressPercentage,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(progressPercentage * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (progress.accuracy > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${progress.accuracy.toStringAsFixed(0)}% accuracy • ${progress.attemptedQuestions}/${progress.totalQuestions} questions',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Status icon
                Icon(
                  statusIcon,
                  size: 20,
                  color: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
