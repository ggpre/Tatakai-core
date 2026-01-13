import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tatakai_mobile/config/theme.dart';

class DMCAScreen extends StatelessWidget {
  const DMCAScreen({super.key});

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
          'DMCA Notice',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppThemes.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceMd),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: AppThemes.spaceMd),
                  Expanded(
                    child: Text(
                      'Tatakai does not host any content. All content is provided by third-party sources.',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppThemes.spaceLg),
            _buildSection(
              'Copyright Policy',
              'Tatakai respects the intellectual property rights of others. If you believe that your copyrighted work has been copied in a way that constitutes copyright infringement, please provide us with the following information.',
            ),
            _buildSection(
              'DMCA Notice Requirements',
              '1. A physical or electronic signature of the copyright owner.\n'
              '2. Identification of the copyrighted work claimed to have been infringed.\n'
              '3. Identification of the material that is claimed to be infringing.\n'
              '4. Your contact information (address, phone number, email).\n'
              '5. A statement that you have a good faith belief that the use is not authorized.\n'
              '6. A statement that the information is accurate and you are authorized to act on behalf of the copyright owner.',
            ),
            _buildSection(
              'Submit a DMCA Notice',
              'DMCA notices should be sent to our designated copyright agent. Contact information is available through the app.',
            ),
            _buildSection(
              'Counter-Notice',
              'If you believe your content was removed in error, you may file a counter-notice with the same information requirements.',
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
