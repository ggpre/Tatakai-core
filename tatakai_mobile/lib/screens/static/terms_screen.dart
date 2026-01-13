import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tatakai_mobile/config/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms of Service',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppThemes.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Acceptance of Terms',
              'By accessing and using Tatakai, you agree to be bound by these Terms of Service and all applicable laws and regulations.',
            ),
            _buildSection(
              'User Accounts',
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            _buildSection(
              'Content Guidelines',
              'Users must not upload, post, or transmit any content that is unlawful, harmful, threatening, abusive, defamatory, or otherwise objectionable.',
            ),
            _buildSection(
              'Intellectual Property',
              'All content on this application, including but not limited to text, graphics, logos, and software, is the property of Tatakai or its content suppliers.',
            ),
            _buildSection(
              'Disclaimer',
              'Tatakai is provided on an "as is" basis. We make no warranties, expressed or implied, and hereby disclaim all warranties.',
            ),
            _buildSection(
              'Changes to Terms',
              'We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.',
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
