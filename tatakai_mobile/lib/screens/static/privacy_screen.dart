import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tatakai_mobile/config/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppThemes.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly, such as account information (email, username), and usage data to improve our services.',
            ),
            _buildSection(
              'How We Use Your Information',
              'Your information is used to provide and improve our services, personalize your experience, and communicate with you about updates.',
            ),
            _buildSection(
              'Data Storage',
              'Your data is stored securely using industry-standard encryption. We use Supabase for authentication and data management.',
            ),
            _buildSection(
              'Third-Party Services',
              'We use Firebase for push notifications and analytics. These services have their own privacy policies.',
            ),
            _buildSection(
              'Your Rights',
              'You can request access to, correction of, or deletion of your personal data at any time by contacting us.',
            ),
            _buildSection(
              'Data Retention',
              'We retain your data as long as your account is active. You may request deletion at any time.',
            ),
            _buildSection(
              'Contact Us',
              'If you have questions about this privacy policy, please contact us through the app.',
            ),
            const SizedBox(height: AppThemes.spaceXl),
            Text(
              'Last updated: January 2026',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemes.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppThemes.spaceSm),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
