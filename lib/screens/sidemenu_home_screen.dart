import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
// image_picker removed for privacy compliance
import '../models/category.dart' as models;
import '../models/user.dart';
import '../services/hive_service.dart';
import '../services/user_service.dart';
// image_service removed for privacy compliance
import '../services/progress_tracking_service.dart';
import '../services/app_config_service.dart';
import '../models/category_progress.dart';
import 'category_screen.dart';

class SideMenuHomeScreen extends StatefulWidget {
  const SideMenuHomeScreen({super.key});

  @override
  State<SideMenuHomeScreen> createState() => _SideMenuHomeScreenState();
}

class _SideMenuHomeScreenState extends State<SideMenuHomeScreen> with WidgetsBindingObserver {
  late SideMenuController sideMenuController;
  List<models.Category> categories = [];
  User? currentUser;
  Map<String, dynamic> userStats = {};
  int selectedCategoryIndex = -1; // -1 means dashboard
  int _menuRebuildKey = 0; // Key to force menu rebuild
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    sideMenuController = SideMenuController();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    
    // Auto-refresh every 3 seconds to catch progress updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload data when app becomes active
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _loadData() async {
    debugPrint('🔄 _loadData called - rebuild key: $_menuRebuildKey -> ${_menuRebuildKey + 1}');
    
    final List<models.Category> allCategories = HiveService.getAllCategories();
    
    // Filter out categories with no content
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
    
    debugPrint('📊 Loaded ${categories.length} categories, user stats: ${userStats.length} entries');
    
    setState(() {
      _menuRebuildKey++; // Increment to force menu rebuild
    });
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

  Widget _buildProfileAvatar() {
    // Always show initial - photo functionality removed for privacy compliance
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        currentUser!.name[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      key: ValueKey('dashboard_$_menuRebuildKey'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Row(
            children: [
              _buildProfileAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppConfigService.homeWelcomePrefix}${currentUser?.name ?? "User"}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
          
          const SizedBox(height: 24),
          
          // Stats cards
          Row(
            key: ValueKey('stats_row_$_menuRebuildKey'),
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Score',
                  userStats['totalScore']?.toStringAsFixed(0) ?? '0',
                  Icons.score,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildStatCard(
                  'High Score',
                  userStats['highScore']?.toStringAsFixed(0) ?? '0',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  '${userStats['completedUnits'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildStatCard(
                  'Mastered',
                  '${userStats['masteredUnits'] ?? 0}',
                  Icons.military_tech,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Categories overview
          Text(
            'Your Categories',
            key: ValueKey('categories_title_$_menuRebuildKey'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final userId = currentUser?.id ?? 'guest';
            final progress = ProgressTrackingService.getCategoryProgress(userId, category.id);
            return _buildCategoryOverviewCard(
              category, 
              index,
              key: ValueKey('overview_${category.id}_${progress.status.name}_$_menuRebuildKey'),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOverviewCard(models.Category category, int index, {Key? key}) {
    final userId = currentUser?.id ?? 'guest';
    final progress = ProgressTrackingService.getCategoryProgress(userId, category.id);
    
    // Debug: Print progress for troubleshooting
    debugPrint('🎨 Building card for ${category.name}: Status=${progress.status.name}, Progress=${progress.attemptedQuestions}/${progress.totalQuestions}');
    
    final progressPercentage = progress.totalQuestions > 0
        ? (progress.attemptedQuestions / progress.totalQuestions)
        : 0.0;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor;
    Color cardColor;
    
    switch (progress.status) {
      case CategoryStatus.perfect:
        primaryColor = isDark ? Colors.green.shade400 : Colors.green.shade600;
        cardColor = isDark ? Colors.green.withValues(alpha: 0.15) : Colors.green.shade50;
        debugPrint('   Color: GREEN (perfect)');
        break;
      case CategoryStatus.completed:
        primaryColor = isDark ? Colors.orange.shade400 : Colors.orange.shade600;
        cardColor = isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.shade50;
        debugPrint('   Color: ORANGE (completed)');
        break;
      case CategoryStatus.inProgress:
        primaryColor = isDark ? Colors.blue.shade400 : Colors.blue.shade600;
        cardColor = isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.shade50;
        debugPrint('   Color: BLUE (in progress)');
        break;
      case CategoryStatus.notStarted:
        primaryColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
        cardColor = isDark ? Colors.grey.withValues(alpha: 0.15) : Colors.grey.shade50;
        debugPrint('   Color: GREY (not started)');
        break;
    }
    
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategoryIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category.icon),
                size: 32,
                color: primaryColor,
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
                    if (progress.isStarted) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progressPercentage * 100).toStringAsFixed(0)}% complete • ${progress.accuracy.toStringAsFixed(0)}% accuracy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  List<SideMenuItemDataTile> _buildMenuItems() {
    debugPrint('🎯 Building menu items with key: $_menuRebuildKey');
    
    List<SideMenuItemDataTile> menuItems = [
      SideMenuItemDataTile(
        isSelected: selectedCategoryIndex == -1,
        onTap: () async {
          debugPrint('📱 Dashboard clicked');
          setState(() {
            selectedCategoryIndex = -1;
          });
          // Reload data after switching to dashboard
          await Future.delayed(const Duration(milliseconds: 200));
          if (mounted) _loadData();
        },
        title: 'Dashboard',
        icon: const Icon(Icons.dashboard),
      ),
    ];

    // Add category items
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final userId = currentUser?.id ?? 'guest';
      final progress = ProgressTrackingService.getCategoryProgress(userId, category.id);
      
      debugPrint('🏷️  Menu badge for ${category.name}: ${progress.status.name}');
      
      // Determine badge color based on status
      Color? badgeColor;
      if (progress.isStarted) {
        switch (progress.status) {
          case CategoryStatus.perfect:
            badgeColor = Colors.green.shade600;
            break;
          case CategoryStatus.completed:
            badgeColor = Colors.orange.shade600;
            break;
          case CategoryStatus.inProgress:
            badgeColor = Colors.blue.shade600;
            break;
          default:
            badgeColor = null;
        }
      }
      
      menuItems.add(
        SideMenuItemDataTile(
          isSelected: selectedCategoryIndex == i,
          onTap: () async {
            setState(() {
              selectedCategoryIndex = i;
            });
            // Reload data after navigation
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) _loadData();
          },
          title: category.name,
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(category.icon),
                color: badgeColor ?? Colors.grey.shade700,
              ),
              if (badgeColor != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            key: ValueKey('sidemenu_$_menuRebuildKey'),
            controller: sideMenuController,
            mode: SideMenuMode.auto,
            builder: (data) => SideMenuData(
              header: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    AppConfigService.appName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _loadData(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                  const Divider(),
                ],
              ),
              items: _buildMenuItems(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child: selectedCategoryIndex == -1
                  ? _buildDashboard()
                  : CategoryScreen(
                      key: ValueKey('category_$selectedCategoryIndex'),
                      category: categories[selectedCategoryIndex],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

