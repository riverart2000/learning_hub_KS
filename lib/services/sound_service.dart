import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  
  static const String _soundEnabledKey = 'sound_enabled';

  // Initialize and load sound preference
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
  }

  // Get current sound setting
  bool get isSoundEnabled => _soundEnabled;

  // Toggle sound on/off
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, _soundEnabled);
  }

  // Set sound enabled/disabled
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, _soundEnabled);
  }

  // Play correct answer sound
  // Uses simple beep sound via URL - higher pitch for correct
  Future<void> playCorrectSound() async {
    if (!_soundEnabled) return;
    
    try {
      await _audioPlayer.stop();
      // Play a pleasant beep sound (high pitch)
      // Using a data URL for a simple sine wave beep at 800Hz
      await _audioPlayer.play(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2000/2000-preview.mp3'),
        volume: 0.3,
      );
    } catch (e) {
      // Silently fail - sound is not critical to functionality
      // You can also use system sounds via platform channels if needed
      try {
        // Fallback to system feedback
        await SystemChannels.platform.invokeMethod('SystemSound.play', 'SystemSoundType.click');
      } catch (_) {
        // Ignore if system sound also fails
      }
    }
  }

  // Play incorrect answer sound
  // Uses simple beep sound via URL - lower pitch for incorrect
  Future<void> playIncorrectSound() async {
    if (!_soundEnabled) return;
    
    try {
      await _audioPlayer.stop();
      // Play a buzz sound (low pitch)
      await _audioPlayer.play(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2955/2955-preview.mp3'),
        volume: 0.3,
      );
    } catch (e) {
      // Silently fail - sound is not critical
      try {
        // Fallback to system feedback
        await SystemChannels.platform.invokeMethod('SystemSound.play', 'SystemSoundType.click');
      } catch (_) {
        // Ignore if system sound also fails
      }
    }
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}

