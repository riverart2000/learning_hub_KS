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
  User? currentUser;
  List<models.Category> categories = [];
  Map<String, CategoryProgress> categoryProgress = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    currentUser = UserService.getCurrentUser();
    if (currentUser != null) {
      categories = HiveService.getAllCategories();
      // Get progress for all categories
      categoryProgress = {};
      for (var category in categories) {
        categoryProgress[category.id] = ProgressTrackingService.getCategoryProgress(currentUser!.id, category.id);
      }
    }
    
    setState(() {});
  }

  Widget _buildProfileAvatar() {
    // Always show initial - photo functionality removed for privacy compliance
    return CircleAvatar(
      radius: 20, // Smaller radius
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        currentUser!.name[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 20, // Smaller font
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverStickyHeader(
            header: const CommonStickyHeader(currentScreen: 'home'),
            sliver: SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Welcome Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0), // Reduced padding
                      child: Row(
                        children: [
                          _buildProfileAvatar(),
                          const SizedBox(width: 12), // Reduced spacing
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppConfigService.homeWelcomePrefix}${currentUser!.name}!',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith( // Smaller title
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2), // Reduced spacing
                                Text(
                                  'Track your progress and keep learning!',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller text
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16), // Reduced spacing
                  
                  // Stats Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0), // Reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith( // Smaller title
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8), // Reduced spacing
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Score',
                                  currentUser!.totalScore.toStringAsFixed(0),
                                  Icons.star,
                                  Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 6), // Reduced spacing
                              Expanded(
                                child: _buildStatCard(
                                  'High',
                                  currentUser!.highScore.toStringAsFixed(0),
                                  Icons.trending_up,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 6), // Reduced spacing
                              Expanded(
                                child: _buildStatCard(
                                  'Done',
                                  categoryProgress.values.where((p) => p.status.name == 'completed').length.toString(),
                                  Icons.check_circle,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 6), // Reduced spacing
                              Expanded(
                                child: _buildStatCard(
                                  'Master',
                                  categoryProgress.values.where((p) => p.status.name == 'mastered').length.toString(),
                                  Icons.emoji_events,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16), // Reduced spacing
                  
                  // Categories Section
                  Text(
                    AppConfigService.homeCategoriesTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ),
          
          // Categories List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                final progress = categoryProgress[category.id];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildCategoryCard(category, progress),
                );
              },
              childCount: categories.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0), // Reduced padding
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8), // Smaller radius
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18), // Smaller icon
          const SizedBox(height: 4), // Reduced spacing
          Text(
            value,
            style: TextStyle(
              fontSize: 16, // Smaller font
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2), // Reduced spacing
          Text(
            label,
            style: TextStyle(
              fontSize: 10, // Smaller font
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(models.Category category, CategoryProgress? progress) {
    final status = progress?.status ?? CategoryStatus.notStarted;
    final score = progress?.accuracy ?? 0.0;
    
    Color statusColor;
    switch (status.name) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'mastered':
        statusColor = Colors.purple;
        break;
      case 'inProgress':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryScreen(category: category),
            ),
          );
          // Refresh data after returning
          await Future.delayed(const Duration(milliseconds: 100));
          _loadData();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getCategoryIcon(category.icon),
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.name.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${score.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'programming':
        return Icons.code;
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'language':
        return Icons.language;
      case 'history':
        return Icons.history_edu;
      case 'art':
        return Icons.palette;
      case 'music':
        return Icons.music_note;
      case 'sports':
        return Icons.sports;
      case 'business':
        return Icons.business;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.school;
    }
  }
}
