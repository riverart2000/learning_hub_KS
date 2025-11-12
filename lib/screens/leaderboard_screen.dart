import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import '../providers/gamification_provider.dart';
import '../models/achievement.dart';
import '../models/user_stats.dart';
import '../widgets/common_sticky_header.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, gamification, child) {
        if (!gamification.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final stats = gamification.stats;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverStickyHeader(
                header: const CommonStickyHeader(currentScreen: 'leaderboard'),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Level Card
                      Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Level ${stats.currentLevel}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '${stats.totalXP} XP',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: stats.levelProgress(),
                                  minHeight: 12,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${stats.xpForNextLevel() - (stats.totalXP % stats.xpForNextLevel())} XP to Level ${stats.currentLevel + 1}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tab Bar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                          tabs: const [
                            Tab(text: 'Achievements'),
                            Tab(text: 'Statistics'),
                            Tab(text: 'Progress'),
                          ],
                        ),
                      ),

                      // Tab Content
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 400,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAchievementsTab(gamification),
                            _buildStatisticsTab(stats),
                            _buildProgressTab(gamification),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementsTab(GamificationProvider gamification) {
    final unlocked = gamification.getUnlockedAchievements();
    final locked = gamification.getLockedAchievements();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unlocked.isNotEmpty) ...[
          Text(
            'Unlocked (${unlocked.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...unlocked.map((achievement) => _buildAchievementCard(achievement, true)),
          const SizedBox(height: 24),
        ],
        Text(
          'Locked (${locked.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...locked.map((achievement) => _buildAchievementCard(achievement, false)),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool unlocked) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: unlocked ? 2 : 1,
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.6,
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: unlocked
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            achievement.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: unlocked ? null : TextDecoration.none,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(achievement.description),
              if (!unlocked) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: achievement.progressPercentage,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${achievement.currentProgress}/${achievement.requiredProgress}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          trailing: unlocked
              ? Chip(
                  label: Text('+${achievement.xpReward} XP'),
                  backgroundColor: Colors.green[100],
                  labelStyle: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                )
              : Icon(Icons.lock, color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(UserStats stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Quizzes Completed',
          '${stats.quizzesCompleted}',
          Icons.quiz,
          Colors.blue,
        ),
        _buildStatCard(
          'Flashcards Reviewed',
          '${stats.flashcardsReviewed}',
          Icons.style,
          Colors.green,
        ),
        _buildStatCard(
          'Study Sessions',
          '${stats.studySessionsCompleted}',
          Icons.book,
          Colors.purple,
        ),
        _buildStatCard(
          'Total Study Time',
          '${stats.totalStudyTimeMinutes} min',
          Icons.access_time,
          Colors.orange,
        ),
        _buildStatCard(
          'Current Streak',
          '${stats.currentStreak} days',
          Icons.local_fire_department,
          Colors.red,
        ),
        _buildStatCard(
          'Longest Streak',
          '${stats.longestStreak} days',
          Icons.emoji_events,
          Colors.amber,
        ),
        _buildStatCard(
          'Average Quiz Score',
          '${stats.averageQuizScore.toStringAsFixed(1)}%',
          Icons.grade,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTab(GamificationProvider gamification) {
    final stats = gamification.stats;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Streak Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Current Streak',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${stats.currentStreak}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    stats.currentStreak == 1 ? 'day' : 'days',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                if (stats.longestStreak > stats.currentStreak) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Best: ${stats.longestStreak} days',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Subject Mastery
        if (stats.subjectMastery.isNotEmpty) ...[
          Text(
            'Subject Mastery',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...stats.subjectMastery.entries.map((entry) {
            final subject = entry.key;
            final correct = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.school),
                title: Text(subject),
                trailing: Chip(
                  label: Text('$correct correct'),
                  backgroundColor: Colors.green[100],
                  labelStyle: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

