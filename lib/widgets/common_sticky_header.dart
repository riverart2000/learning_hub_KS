import 'package:flutter/material.dart';
import 'package:feedback/feedback.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../services/sound_service.dart';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/welcome_screen.dart';
import '../main.dart' show sendFeedback;

class CommonStickyHeader extends StatefulWidget {
  final String? currentScreen; // To highlight current screen icon
  
  const CommonStickyHeader({
    super.key,
    this.currentScreen,
  }) : super();

  @override
  State<CommonStickyHeader> createState() => _CommonStickyHeaderState();
  
  // Create a unique key for each screen to force new quote
  @override
  Key? get key => ValueKey(currentScreen);
}

class _CommonStickyHeaderState extends State<CommonStickyHeader> {
  Quote? _currentQuote;
  final SoundService _soundService = SoundService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeHeader();
  }
  
  @override
  void didUpdateWidget(CommonStickyHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Get new quote when screen changes
    if (oldWidget.currentScreen != widget.currentScreen) {
      debugPrint('🔄 Screen changed from ${oldWidget.currentScreen} to ${widget.currentScreen}');
      _currentQuote = QuoteService.getRandomQuote();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _initializeHeader() async {
    if (!_isInitialized) {
      await _soundService.init();
      _currentQuote = QuoteService.getRandomQuote();
      _isInitialized = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _refreshQuote() {
    debugPrint('🔄 Manually refreshing quote');
    setState(() {
      _currentQuote = QuoteService.getRandomQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Navigation Icons Row
              LayoutBuilder(
                builder: (context, constraints) {
                  // Check if we're on a narrow screen
                  final isNarrowScreen = constraints.maxWidth < 600;
                  
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isNarrowScreen ? 2.0 : 8.0,
                      vertical: isNarrowScreen ? 4.0 : 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildIconButton(
                                icon: Icons.home,
                                label: 'Home',
                                isActive: widget.currentScreen == 'home',
                                isCompact: isNarrowScreen,
                                onPressed: () {
                                  if (widget.currentScreen != 'home') {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                                (route) => false,
                              );
                            }
                          },
                        ),
                        _buildIconButton(
                          icon: Icons.leaderboard,
                          label: 'Board',
                          isActive: widget.currentScreen == 'leaderboard',
                          isCompact: isNarrowScreen,
                          onPressed: () {
                            if (widget.currentScreen != 'leaderboard') {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                              );
                            }
                          },
                        ),
                        _buildIconButton(
                          icon: _soundService.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                          label: 'Sound',
                          isActive: false,
                          isCompact: isNarrowScreen,
                          onPressed: () async {
                            await _soundService.toggleSound();
                            setState(() {});
                          },
                        ),
                        _buildIconButton(
                          icon: Icons.feedback,
                          label: 'Feedback',
                          isActive: false,
                          isCompact: isNarrowScreen,
                          onPressed: () {
                            BetterFeedback.of(context).show((feedback) {
                              sendFeedback(context, feedback);
                            });
                          },
                        ),
                              _buildIconButton(
                                icon: Icons.settings,
                                label: 'Settings',
                                isActive: widget.currentScreen == 'settings',
                                isCompact: isNarrowScreen,
                                onPressed: () {
                                  if (widget.currentScreen != 'settings') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        // Logout Button
                        _buildIconButton(
                          icon: Icons.logout,
                          label: 'Logout',
                          isActive: false,
                          isCompact: isNarrowScreen,
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to logout? Another user can then login.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true) {
                              await AuthService().logout();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              // Quote Section
              if (_currentQuote != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_currentQuote!.text} — ${_currentQuote!.author}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _refreshQuote,
                        tooltip: 'New Quote',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
    bool isCompact = false,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 4 : 12,
            vertical: isCompact ? 4 : 8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isCompact ? 20 : 24,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: isCompact ? 2 : 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: isCompact ? 9 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

