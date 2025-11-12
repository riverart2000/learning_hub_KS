import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/user_preferences.dart';
import '../models/learning_unit.dart';
import '../theme/app_theme.dart';
import '../utils/app_logger.dart';

/// Theme provider following SOLID principles with proper error handling
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _colorScheme = 'Material Deep Purple'; // Default FlexColorScheme
  String? _currentUserId;

  bool get isDarkMode => _isDarkMode;
  String get colorScheme => _colorScheme;

  ThemeData get currentTheme => AppTheme.getTheme(
    isDarkMode: _isDarkMode,
    colorScheme: _colorScheme,
  );

  void setCurrentUser(String userId) {
    if (userId.trim().isEmpty) {
      AppLogger.warning('Attempted to set empty userId', tag: 'ThemeProvider');
      return;
    }

    _currentUserId = userId;
    _loadUserPreferences();
  }

  void _loadUserPreferences() {
    if (_currentUserId == null) return;

    try {
      final preferences = HiveService.getUserPreferences(_currentUserId!);
      if (preferences != null) {
        _isDarkMode = preferences.isDarkMode;
        _colorScheme = preferences.colorScheme;
        notifyListeners();
        AppLogger.debug(
          'User preferences loaded',
          tag: 'ThemeProvider',
          data: {'isDarkMode': _isDarkMode, 'colorScheme': _colorScheme},
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to load user preferences',
        tag: 'ThemeProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> toggleDarkMode() async {
    try {
      _isDarkMode = !_isDarkMode;
      await _savePreferences();
      notifyListeners();
      AppLogger.debug('Dark mode toggled', tag: 'ThemeProvider', data: {'isDarkMode': _isDarkMode});
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to toggle dark mode',
        tag: 'ThemeProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> setColorScheme(String scheme) async {
    if (scheme.trim().isEmpty) {
      AppLogger.warning('Attempted to set empty color scheme', tag: 'ThemeProvider');
      return;
    }

    // Accept any scheme name from AppTheme.schemes
    if (AppTheme.schemes.containsKey(scheme)) {
      try {
        _colorScheme = scheme;
        await _savePreferences();
        notifyListeners();
        AppLogger.debug('Color scheme updated', tag: 'ThemeProvider', data: {'scheme': scheme});
      } catch (e, stackTrace) {
        AppLogger.error(
          'Failed to set color scheme',
          tag: 'ThemeProvider',
          error: e,
          stackTrace: stackTrace,
        );
      }
    } else {
      AppLogger.warning('Invalid color scheme', tag: 'ThemeProvider', data: {'scheme': scheme});
    }
  }
  
  List<String> get availableSchemes => AppTheme.schemes.keys.toList();

  Future<void> _savePreferences() async {
    if (_currentUserId == null) {
      AppLogger.warning('Cannot save preferences: no user ID set', tag: 'ThemeProvider');
      return;
    }

    try {
      final preferences = HiveService.getUserPreferences(_currentUserId!) ??
          UserPreferences(
            id: _currentUserId!,
            userId: _currentUserId!,
            preferredCategories: [],
            difficultyPreference: Difficulty.beginner,
            studyRemindersEnabled: true,
          );
      
      preferences.isDarkMode = _isDarkMode;
      preferences.colorScheme = _colorScheme;
      
      await HiveService.saveUserPreferences(preferences);
      AppLogger.debug('User preferences saved', tag: 'ThemeProvider');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save preferences',
        tag: 'ThemeProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
