import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/app_logger.dart';

/// Service for showing beautiful achievement unlock notifications using custom overlays
class AchievementNotificationService {
  static OverlayEntry? _currentOverlay;

  /// Show achievement unlock notification
  static void showAchievementUnlocked(
    BuildContext context,
    Achievement achievement,
  ) {
    if (!context.mounted) return;

    try {
      _showOverlayNotification(
        context,
        icon: Text(
          achievement.icon,
          style: const TextStyle(fontSize: 40),
        ),
        title: achievement.title,
        subtitle: achievement.description,
        color: _getCategoryColor(achievement.category),
        duration: const Duration(seconds: 3),
      );

      AppLogger.info(
        'Showed achievement unlock: ${achievement.title}',
        tag: 'AchievementNotification',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to show achievement notification',
        tag: 'AchievementNotification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Show level up notification
  static void showLevelUp(
    BuildContext context,
    int newLevel,
  ) {
    if (!context.mounted) return;

    try {
      _showOverlayNotification(
        context,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 3),
          ),
          child: Text(
            '$newLevel',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ),
        title: 'Level Up!',
        subtitle: 'You are now Level $newLevel',
        color: Colors.purple,
        duration: const Duration(seconds: 3),
      );

      AppLogger.info(
        'Showed level up: $newLevel',
        tag: 'AchievementNotification',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to show level up notification',
        tag: 'AchievementNotification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Show streak milestone notification
  static void showStreakMilestone(
    BuildContext context,
    int streakDays,
  ) {
    if (!context.mounted) return;

    try {
      String emoji = '🔥';
      if (streakDays >= 30) {
        emoji = '🔥🔥🔥';
      } else if (streakDays >= 7) {
        emoji = '🔥🔥';
      }

      _showOverlayNotification(
        context,
        icon: Text(
          emoji,
          style: const TextStyle(fontSize: 40),
        ),
        title: '$streakDays Day Streak!',
        subtitle: 'Keep up the great work!',
        color: Colors.orange,
        duration: const Duration(seconds: 3),
      );

      AppLogger.info(
        'Showed streak milestone: $streakDays days',
        tag: 'AchievementNotification',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to show streak notification',
        tag: 'AchievementNotification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Show XP gained notification
  static void showXPGained(
    BuildContext context,
    int xpAmount,
    String reason,
  ) {
    if (!context.mounted) return;

    try {
      _showOverlayNotification(
        context,
        icon: const Icon(
          Icons.star,
          color: Colors.white,
          size: 40,
        ),
        title: '+$xpAmount XP',
        subtitle: reason,
        color: Colors.blue,
        duration: const Duration(seconds: 2),
      );

      AppLogger.debug(
        'Showed XP gained: +$xpAmount for $reason',
        tag: 'AchievementNotification',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to show XP notification',
        tag: 'AchievementNotification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Show custom notification
  static void showCustomNotification(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget icon,
    Color color = Colors.teal,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    try {
      _showOverlayNotification(
        context,
        icon: icon,
        title: title,
        subtitle: subtitle,
        color: color,
        duration: duration,
      );

      AppLogger.debug(
        'Showed custom notification: $title',
        tag: 'AchievementNotification',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to show custom notification',
        tag: 'AchievementNotification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Internal method to show overlay notification
  static void _showOverlayNotification(
    BuildContext context, {
    required Widget icon,
    required String title,
    required String subtitle,
    required Color color,
    required Duration duration,
  }) {
    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AchievementNotificationWidget(
        icon: icon,
        title: title,
        subtitle: subtitle,
        color: color,
        onDismiss: () {
          overlayEntry.remove();
          if (_currentOverlay == overlayEntry) {
            _currentOverlay = null;
          }
        },
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (_currentOverlay == overlayEntry) {
        overlayEntry.remove();
        _currentOverlay = null;
      }
    });
  }

  /// Get color based on achievement category
  static Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.quiz:
        return Colors.blue;
      case AchievementCategory.flashcard:
        return Colors.green;
      case AchievementCategory.study:
        return Colors.purple;
      case AchievementCategory.streak:
        return Colors.orange;
      case AchievementCategory.mastery:
        return Colors.red;
      case AchievementCategory.general:
        return Colors.teal;
    }
  }
}

/// Custom achievement notification widget with slide-in animation
class _AchievementNotificationWidget extends StatefulWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onDismiss;

  const _AchievementNotificationWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<_AchievementNotificationWidget> createState() =>
      _AchievementNotificationWidgetState();
}

class _AchievementNotificationWidgetState
    extends State<_AchievementNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onTap: () async {
                await _controller.reverse();
                widget.onDismiss();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.icon,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
