import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_config_service.dart';
import '../widgets/common_sticky_header.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverStickyHeader(
            header: const CommonStickyHeader(currentScreen: 'settings'),
            sliver: SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Privacy Policy Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last updated: October 29, 2025',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Introduction'),
                          _buildParagraph(context,
                            'Learning Hub ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Information We Collect'),
                          _buildParagraph(context,
                            'Personal Information:\n'
                            '• Name and Email Address: Collected during account creation for user identification and progress tracking\n'
                            '• Profile Photo: Optional image you choose to upload for your profile\n'
                            '• Learning Progress Data: Quiz scores, study progress, and completion status'
                          ),
                          const SizedBox(height: 12),
                          _buildParagraph(context,
                            'Device Information:\n'
                            '• Device Type: Android device information for app optimization\n'
                            '• App Usage Data: Features used, time spent in app, and performance metrics\n'
                            '• Crash Reports: Anonymous technical data to improve app stability'
                          ),
                          const SizedBox(height: 12),
                          _buildParagraph(context,
                            'Data Storage:\n'
                            '• Local Storage: All data is primarily stored locally on your device using secure local databases\n'
                            '• Cloud Sync: Basic user profile and progress data may be synced across devices (optional)'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'How We Use Your Information'),
                          _buildParagraph(context,
                            'We use the collected information to:\n'
                            '• Provide and maintain the Learning Hub service\n'
                            '• Track your learning progress and achievements\n'
                            '• Sync your data across devices (when enabled)\n'
                            '• Improve app performance and user experience\n'
                            '• Provide customer support\n'
                            '• Send important app updates and notifications'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Data Sharing and Disclosure'),
                          _buildParagraph(context,
                            'We Do NOT:\n'
                            '• Sell your personal information to third parties\n'
                            '• Share your data with advertisers\n'
                            '• Track you across other websites or apps\n'
                            '• Use your data for marketing purposes outside the app'
                          ),
                          const SizedBox(height: 12),
                          _buildParagraph(context,
                            'We May Share Data Only When:\n'
                            '• Required by law or legal process\n'
                            '• Necessary to protect our rights or safety\n'
                            '• With your explicit consent\n'
                            '• In case of app transfer or acquisition (with notice)'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Data Security'),
                          _buildParagraph(context,
                            'We implement appropriate security measures to protect your information:\n'
                            '• Local Encryption: Data stored on your device is encrypted\n'
                            '• Secure Transmission: Data transmission uses industry-standard encryption\n'
                            '• Access Controls: Limited access to personal data\n'
                            '• Regular Updates: Security measures are regularly updated'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Your Rights and Choices'),
                          _buildParagraph(context,
                            'You have the right to:\n'
                            '• Access: View your personal data stored in the app\n'
                            '• Correction: Update or correct your information\n'
                            '• Deletion: Delete your account and associated data\n'
                            '• Export: Export your learning progress data\n'
                            '• Opt-out: Disable data sync and analytics'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Data Retention'),
                          _buildParagraph(context,
                            '• Account Data: Retained until you delete your account\n'
                            '• Learning Progress: Stored locally and can be synced across devices\n'
                            '• Analytics Data: Anonymized data may be retained for app improvement\n'
                            '• Support Data: Customer support communications retained for 2 years'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Children\'s Privacy'),
                          _buildParagraph(context,
                            'Learning Hub is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you are a parent and believe your child has provided us with personal information, please contact us.'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Third-Party Services'),
                          _buildParagraph(context,
                            'Our app may use the following third-party services:\n'
                            '• Firebase: For app analytics and crash reporting (Google)\n'
                            '• Google Play Services: For app functionality and updates\n'
                            '• Device Storage: Local device storage for data persistence\n\n'
                            'These services have their own privacy policies, and we encourage you to review them.'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'International Data Transfers'),
                          _buildParagraph(context,
                            'Your data may be processed and stored in countries other than your own. We ensure appropriate safeguards are in place to protect your data in accordance with this Privacy Policy.'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Changes to This Privacy Policy'),
                          _buildParagraph(context,
                            'We may update this Privacy Policy from time to time. We will notify you of any changes by:\n'
                            '• Posting the new Privacy Policy in the app\n'
                            '• Sending you an email notification\n'
                            '• Updating the "Last updated" date'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Compliance'),
                          _buildParagraph(context,
                            'This Privacy Policy complies with:\n'
                            '• Google Play Store requirements\n'
                            '• General Data Protection Regulation (GDPR)\n'
                            '• California Consumer Privacy Act (CCPA)\n'
                            '• Children\'s Online Privacy Protection Act (COPPA)'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Data Controller'),
                          _buildLinkableParagraph(context,
                            'PlainOS by Joe Bains is the data controller for the personal information processed through Learning Hub.'
                          ),
                          const SizedBox(height: 16),
                          
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PlainOS Philosophy: We believe in clean, fast, and private technology. Your data belongs to you, and we\'re committed to keeping it that way.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Terms of Service Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms of Service',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last updated: October 29, 2025',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Agreement to Terms'),
                          _buildParagraph(context,
                            'By downloading, installing, or using Learning Hub ("the App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App.'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Description of Service'),
                          _buildLinkableParagraph(context,
                            'Learning Hub is a minimalist learning application developed by PlainOS by Joe Bains. The App provides:\n'
                            '• Educational content and quizzes\n'
                            '• Progress tracking and analytics\n'
                            '• Study tools and flashcards\n'
                            '• User profile management'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'User Accounts'),
                          _buildParagraph(context,
                            'Account Creation:\n'
                            '• You must provide accurate information when creating an account\n'
                            '• You are responsible for maintaining the security of your account\n'
                            '• You must be at least 13 years old to create an account\n\n'
                            'Account Responsibilities:\n'
                            '• Keep your login credentials secure\n'
                            '• Notify us immediately of any unauthorized use\n'
                            '• You are responsible for all activities under your account'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Acceptable Use'),
                          _buildParagraph(context,
                            'Permitted Uses:\n'
                            '• Personal learning and education\n'
                            '• Non-commercial use only\n'
                            '• Compliance with all applicable laws\n\n'
                            'Prohibited Uses:\n'
                            'You may not:\n'
                            '• Use the App for any illegal purpose\n'
                            '• Attempt to reverse engineer or modify the App\n'
                            '• Share your account with others\n'
                            '• Use automated systems to access the App\n'
                            '• Interfere with the App\'s operation\n'
                            '• Violate any applicable laws or regulations'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Intellectual Property'),
                          _buildLinkableParagraph(context,
                            'Our Rights:\n'
                            '• Learning Hub and its content are owned by PlainOS by Joe Bains\n'
                            '• All trademarks, logos, and service marks are our property\n'
                            '• The App is protected by copyright and other intellectual property laws\n\n'
                            'Your Rights:\n'
                            '• You retain ownership of content you create within the App\n'
                            '• You grant us a license to use your content to provide the service\n'
                            '• You may export your learning progress data'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Privacy'),
                          _buildParagraph(context,
                            'Your privacy is important to us. Please review our Privacy Policy, which explains how we collect, use, and protect your information.'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Disclaimers'),
                          _buildParagraph(context,
                            'No Warranties:\n'
                            'THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING:\n'
                            '• Merchantability\n'
                            '• Fitness for a particular purpose\n'
                            '• Non-infringement\n'
                            '• Accuracy or reliability\n\n'
                            'Educational Content:\n'
                            '• Educational content is provided for informational purposes\n'
                            '• We do not guarantee the accuracy or completeness of content\n'
                            '• Users should verify information independently when necessary'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Limitation of Liability'),
                          _buildParagraph(context,
                            'TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR:\n'
                            '• ANY INDIRECT, INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES\n'
                            '• LOSS OF DATA, PROFITS, OR BUSINESS OPPORTUNITIES\n'
                            '• DAMAGES RESULTING FROM USE OR INABILITY TO USE THE APP\n'
                            '• DAMAGES EXCEEDING THE AMOUNT PAID FOR THE APP (IF ANY)'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Indemnification'),
                          _buildParagraph(context,
                            'You agree to indemnify and hold us harmless from any claims, damages, or expenses arising from:\n'
                            '• Your use of the App\n'
                            '• Your violation of these Terms\n'
                            '• Your violation of any third-party rights'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Termination'),
                          _buildParagraph(context,
                            'By You:\n'
                            '• You may stop using the App at any time\n'
                            '• You may delete your account through the App settings\n\n'
                            'By Us:\n'
                            'We may terminate or suspend your access if you:\n'
                            '• Violate these Terms\n'
                            '• Engage in fraudulent or illegal activity\n'
                            '• Fail to pay required fees (if any)\n\n'
                            'Effect of Termination:\n'
                            '• Your right to use the App ceases immediately\n'
                            '• We may delete your account and data\n'
                            '• Certain provisions survive termination'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Updates and Changes'),
                          _buildParagraph(context,
                            'App Updates:\n'
                            '• We may update the App from time to time\n'
                            '• Updates may include new features or bug fixes\n'
                            '• Some updates may be required for continued use\n\n'
                            'Terms Updates:\n'
                            '• We may modify these Terms at any time\n'
                            '• We will notify you of significant changes\n'
                            '• Continued use constitutes acceptance of new Terms'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Governing Law'),
                          _buildParagraph(context,
                            'These Terms are governed by the laws of England and Wales, without regard to conflict of law principles.'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Dispute Resolution'),
                          _buildParagraph(context,
                            'Any disputes arising from these Terms or the App will be resolved through:\n'
                            '1. Good faith negotiations\n'
                            '2. Binding arbitration if negotiations fail\n'
                            '3. Courts of competent jurisdiction in England and Wales'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Severability'),
                          _buildParagraph(context,
                            'If any provision of these Terms is found to be unenforceable, the remaining provisions will remain in full force and effect.'
                          ),
                          const SizedBox(height: 24),
                          
                          _buildSectionTitle(context, 'Entire Agreement'),
                          _buildParagraph(context,
                            'These Terms, together with our Privacy Policy, constitute the entire agreement between you and us regarding the App.'
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Contact Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Us',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildParagraph(context,
                            'If you have any questions about these policies or our data practices, please contact us:'
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.business_outlined, color: Colors.purple),
                            title: const Text('Organization'),
                            subtitle: Text(AppConfigService.organization),
                            contentPadding: EdgeInsets.zero,
                          ),
                          ListTile(
                            leading: const Icon(Icons.email_outlined, color: Colors.blue),
                            title: const Text('Email'),
                            subtitle: Text(AppConfigService.developerEmail),
                            contentPadding: EdgeInsets.zero,
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
                  
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        height: 1.6,
      ),
    );
  }

  Widget _buildLinkableParagraph(BuildContext context, String text) {
    const String linkText = 'Joe Bains';
    const String linkUrl = 'https://www.linkedin.com/in/joebains/';
    
    if (!text.contains(linkText)) {
      return Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.6,
        ),
      );
    }
    
    final parts = text.split(linkText);
    final textSpans = <TextSpan>[];
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        textSpans.add(TextSpan(
          text: parts[i],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ));
      }
      if (i < parts.length - 1) {
        textSpans.add(
          TextSpan(
            text: linkText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
              height: 1.6,
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
      text: TextSpan(children: textSpans),
    );
  }
}