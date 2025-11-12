import 'package:flutter/foundation.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:async';
import 'dart:io';
import '../models/user.dart';
import '../utils/app_logger.dart';
import 'user_service.dart';
import 'hive_service.dart';
import 'firebase_service.dart';

/// Authentication service following SOLID principles with comprehensive error handling
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    AppLogger.debug('AuthService initialized', tag: 'AuthService');
  }

  // Constants for validation
  static const int _dnsLookupTimeoutSeconds = 5;
  static const List<String> _commonTypos = [
    'gmial.com',
    'gmai.com',
    'gmil.com',
    'yahooo.com',
    'yaho.com',
    'hotmial.com',
    'outlok.com',
    'yaoo.com',
  ];

  static const List<String> _fakeDomainPatterns = [
    'test.com',
    'fake.com',
    'example.com',
    'temp.com',
    'testing.com',
    'dummy.com',
    'sample.com',
    'demo.com',
    'invalid.com',
    'none.com',
    'null.com',
    'localhost',
  ];

  // Check if email domain exists by verifying DNS lookup
  Future<bool> _verifyEmailDomainExists(String email) async {
    try {
      final domain = email.split('@').last;
      
      AppLogger.debug('Checking DNS for domain: $domain', tag: 'AuthService');
      
      // Use dart:io InternetAddress lookup to check if domain exists
      try {
        final addresses = await InternetAddress.lookup(domain).timeout(
          Duration(seconds: _dnsLookupTimeoutSeconds),
          onTimeout: () {
            AppLogger.warning(
              'DNS lookup timed out for $domain - allowing login (offline mode)',
              tag: 'AuthService',
            );
            return [];
          },
        );
        
        if (addresses.isNotEmpty) {
          AppLogger.debug(
            'Domain $domain exists with ${addresses.length} DNS record(s)',
            tag: 'AuthService',
          );
          return true;
        } else {
          // Timeout occurred - assume offline, allow login
          AppLogger.warning(
            'DNS timeout - assuming offline mode, allowing login',
            tag: 'AuthService',
          );
          return true;
        }
      } on SocketException catch (e) {
        AppLogger.warning('DNS lookup failed: ${e.message}', tag: 'AuthService');
        
        // Check if it's a "network unreachable" or "no internet" error
        if (e.message.contains('Network is unreachable') ||
            e.message.contains('No route to host') ||
            e.message.contains('unreachable') ||
            e.osError?.errorCode == 101 || // Network unreachable
            e.osError?.errorCode == 7) {   // No address associated with hostname
          AppLogger.info(
            'No internet connection - OFFLINE MODE - allowing login',
            tag: 'AuthService',
          );
          return true; // Allow login in offline mode
        }
        
        // Only reject if domain definitely doesn't exist (NXDOMAIN)
        if (e.osError?.errorCode == 8 || // NXDOMAIN (name not found)
            e.osError?.errorCode == -2 || // Name or service not known  
            e.message.contains('Failed host lookup')) {
          AppLogger.warning('Domain does not exist (NXDOMAIN)', tag: 'AuthService');
          return false;
        }
        
        // For all other errors, be lenient (assume offline/network issues)
        AppLogger.warning(
          'Network issue, allowing login (offline mode)',
          tag: 'AuthService',
        );
        return true;
      }
    } catch (e) {
      AppLogger.error(
        'Domain verification error - allowing login (offline mode)',
        tag: 'AuthService',
        error: e,
      );
      // On any error, be lenient and allow (don't block users)
      return true;
    }
  }

  // Manual login with name and email
  Future<(User?, String?)> loginWithNameEmail({
    required String name,
    required String email,
  }) async {
    try {
      AppLogger.info('Login attempt', tag: 'AuthService', data: {'email': email});

      if (name.trim().isEmpty) {
        return (null, 'Name cannot be empty');
      }
      
      if (email.trim().isEmpty) {
        return (null, 'Email cannot be empty');
      }

      // Enhanced email validation
      if (!EmailValidator.validate(email)) {
        return (null, 'Please enter a valid email address');
      }
      
      // Additional check for common typos and invalid domains
      final lowercaseEmail = email.toLowerCase().trim();
      
      // Check for common typos
      for (final typo in _commonTypos) {
        if (lowercaseEmail.endsWith(typo)) {
          return (null, 'Please check your email domain spelling');
        }
      }
      
      // Check for obviously fake domains
      final domain = lowercaseEmail.split('@').last;
      
      if (_fakeDomainPatterns.contains(domain)) {
        return (null, 'Please use a real email address');
      }
      
      // Check for valid TLD
      if (!lowercaseEmail.contains('.') || 
          lowercaseEmail.endsWith('.') ||
          domain.split('.').last.length < 2) {
        return (null, 'Email domain appears invalid');
      }
      
      // Verify domain exists via DNS lookup (disabled on macOS due to network restrictions)
      // Note: Basic email format validation is already done by EmailValidator above
      if (!kIsWeb && !Platform.isMacOS) {
        final domainExists = await _verifyEmailDomainExists(lowercaseEmail);
        if (!domainExists) {
          return (null, 'This email domain does not exist. Please use a valid email address.');
        }
      } else {
        AppLogger.info(
          'Skipping DNS verification on macOS/Web (using basic email format validation only)',
          tag: 'AuthService',
        );
      }

      // Check if user already exists locally with this email
      final existingUser = await UserService.findUserByEmail(lowercaseEmail);
      
      User user;
      if (existingUser != null) {
        // User exists - return existing user (preserves photoPath, ID, and all data)
        AppLogger.info(
          'Returning existing user',
          tag: 'AuthService',
          data: {'id': existingUser.id, 'name': existingUser.name},
        );
        user = existingUser;
        // Update name if it changed
        if (existingUser.name != name.trim()) {
          existingUser.name = name.trim();
          await existingUser.save();
          await HiveService.saveUser(existingUser);
        }
      } else {
        // New user - create fresh
        AppLogger.info('Creating new user', tag: 'AuthService');
        user = await UserService.createUser(
          name: name.trim(),
          email: lowercaseEmail,
        );
      }
      
      AppLogger.info('Login successful', tag: 'AuthService', data: {'userId': user.id});
      return (user, null);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Login error',
        tag: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return (null, 'Login error: $e');
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final user = UserService.getCurrentUser();
    final loggedIn = user != null && user.name != 'Student';
    AppLogger.debug('isLoggedIn check', tag: 'AuthService', data: {'loggedIn': loggedIn});
    return loggedIn;
  }

  // Logout
  Future<void> logout() async {
    try {
      AppLogger.info('User logout initiated', tag: 'AuthService');
      // Clear current user
      await UserService.clearCurrentUser();
      AppLogger.info('User logged out successfully', tag: 'AuthService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Logout error',
        tag: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Delete account and all data
  Future<(bool, String?)> deleteAccount() async {
    try {
      final user = UserService.getCurrentUser();
      if (user == null) {
        return (false, 'No user is currently logged in');
      }

      AppLogger.info(
        'Account deletion initiated',
        tag: 'AuthService',
        data: {'name': user.name, 'email': user.email},
      );

      // Delete from Firebase (cloud data)
      final firebaseService = FirebaseService();
      final (success, errorMessage) = await firebaseService.deleteUserAccount(user.name, user.email);
      
      if (!success) {
        AppLogger.error(
          'Failed to delete cloud data',
          tag: 'AuthService',
          error: errorMessage,
        );
        return (false, errorMessage ?? 'Failed to delete cloud data');
      }

      // Clear all local data
      AppLogger.info('Clearing local data', tag: 'AuthService');
      await UserService.clearCurrentUser();
      
      // Optionally, you could clear all Hive boxes here if you want to remove ALL local data
      // await HiveService.clearAllUserData();
      
      AppLogger.info('Account deletion completed - all cloud data removed', tag: 'AuthService');
      return (true, null);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error during account deletion',
        tag: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return (false, 'Failed to delete account: $e');
    }
  }
}

