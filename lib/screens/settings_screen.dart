import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../services/hive_service.dart';
import '../services/app_config_service.dart';
import '../services/auth_service.dart';
import '../widgets/common_sticky_header.dart';
import 'terms_privacy_screen.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final user = UserService.getCurrentUser();
          
          return CustomScrollView(
            slivers: [
              SliverStickyHeader(
                header: const CommonStickyHeader(currentScreen: 'settings'),
                sliver: SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
              // User Profile Card
              if (user != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Profile',
                              textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ) ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                          displayFullTextOnTap: true,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(user.email),
                          trailing: const Icon(Icons.edit),
                          onTap: () => _showEditProfileDialog(context, user),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Theme Settings Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText(
                            'Appearance',
                            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ) ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                        totalRepeatCount: 1,
                        displayFullTextOnTap: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // Dark Mode Toggle
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Switch between light and dark themes'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleDarkMode();
                        },
                        secondary: Icon(
                          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        ),
                      ),
                      
                      const Divider(),
                      
                      // Color Scheme Selection
                      ListTile(
                        title: const Text('Color Scheme'),
                        subtitle: Text('Current: ${themeProvider.colorScheme}'),
                        leading: const Icon(Icons.palette),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showColorSchemeDialog(context, themeProvider);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // User Stats Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            'Statistics',
                            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ) ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            colors: [
                              Colors.blue,
                              Colors.green,
                              Colors.amber,
                              Colors.blue,
                            ],
                          ),
                        ],
                        totalRepeatCount: 1,
                        displayFullTextOnTap: true,
                      ),
                      const SizedBox(height: 16),
                      
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getUserStats(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final stats = snapshot.data!;
                            return Column(
                              children: [
                                _buildStatRow('Total Score', '${stats['totalScore']?.toStringAsFixed(0) ?? '0'}'),
                                _buildStatRow('High Score', '${stats['highScore']?.toStringAsFixed(0) ?? '0'}'),
                                _buildStatRow('Completed Units', '${stats['completedUnits'] ?? 0}'),
                                _buildStatRow('Mastered Units', '${stats['masteredUnits'] ?? 0}'),
                                _buildStatRow('Average Score', '${stats['averageScore']?.toStringAsFixed(1) ?? '0.0'}%'),
                                _buildStatRow('Completion Rate', '${stats['completionRate']?.toStringAsFixed(1) ?? '0.0'}%'),
                              ],
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // About & Developer Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ListTile(
                        leading: const Icon(Icons.school, color: Colors.blue),
                        title: Text(AppConfigService.appName),
                        subtitle: Text('Version ${AppConfigService.appVersion}'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.description, color: Colors.green),
                        title: const Text('About this App'),
                        subtitle: Text(AppConfigService.appDescription),
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      const Divider(height: 24),
                      
                      Text(
                        'Developer',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      const ListTile(
                        leading: Icon(Icons.code, color: Colors.purple),
                        title: Text('Built with Flutter'),
                        subtitle: Text('Cross-platform app development framework by Google'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.developer_mode, color: Colors.orange),
                        title: const Text('Developed by'),
                        subtitle: _buildLinkableText('${AppConfigService.developerName}\n${AppConfigService.developerBio}'),
                        isThreeLine: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.email_outlined, color: Colors.blue),
                        title: const Text('Contact'),
                        subtitle: Text(AppConfigService.developerEmail),
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.business_outlined, color: Colors.purple),
                        title: Text(AppConfigService.organization),
                        subtitle: const Text('Clean, fast, and private technology'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.privacy_tip, color: Colors.teal),
                        title: const Text('Privacy & Data'),
                        subtitle: Text(AppConfigService.privacyNote),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TermsPrivacyScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Delete Account Button
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _showDeleteAccountDialog,
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          label: const Text(
                            'Delete Account',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Center(
                        child: Text(
                          AppConfigService.copyright,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkableText(String text) {
    const String linkText = 'Joe Bains';
    const String linkUrl = 'https://www.linkedin.com/in/joebains/';
    
    if (!text.contains(linkText)) {
      return Text(text);
    }
    
    final parts = text.split(linkText);
    final textSpans = <TextSpan>[];
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        textSpans.add(TextSpan(text: parts[i]));
      }
      if (i < parts.length - 1) {
        textSpans.add(
          TextSpan(
            text: linkText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.parse(linkUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
        );
      }
    }
    
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: textSpans,
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserStats() async {
    final user = UserService.getCurrentUser();
    if (user != null) {
      return UserService.getUserStats(user.id);
    }
    return {};
  }

  void _showEditProfileDialog(BuildContext context, user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email cannot be empty';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _updateUserProfile(
                  user.id,
                  nameController.text.trim(),
                  emailController.text.trim(),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateUserProfile(String userId, String newName, String newEmail) async {
    final user = UserService.getCurrentUser();
    if (user != null && user.id == userId) {
      user.name = newName;
      user.email = newEmail;
      // Save the updated user (preserving photoPath and other data)
      await user.save(); // HiveObject.save() persists changes
      await HiveService.saveUser(user);
      setState(() {}); // Refresh to show new profile
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showColorSchemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color Theme'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: themeProvider.availableSchemes.length,
            itemBuilder: (context, index) {
              final schemeName = themeProvider.availableSchemes[index];
              final isSelected = themeProvider.colorScheme == schemeName;
              
              return Card(
                elevation: isSelected ? 4 : 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  selected: isSelected,
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(
                    schemeName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: isSelected ? const Text('Current theme') : null,
                  trailing: Icon(
                    Icons.palette,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  onTap: () {
                    themeProvider.setColorScheme(schemeName);
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final user = UserService.getCurrentUser();
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Account?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('• Your profile (name and email)'),
            const Text('• All your scores from the cloud'),
            const Text('• Your leaderboard ranking'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your local learning progress will remain on this device',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _handleDeleteAccount(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    Navigator.of(context).pop(); // Close dialog

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deleting account...'),
              ],
            ),
          ),
        ),
      ),
    );

    final authService = AuthService();
    final (success, error) = await authService.deleteAccount();

    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to welcome screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to delete account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

