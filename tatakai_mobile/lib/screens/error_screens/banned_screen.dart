import 'package:flutter/material.dart';
import 'package:tatakai_mobile/config/theme.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppThemes.spaceXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.block,
                    size: 64,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceXl),
                const Text(
                  'Account Suspended',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceMd),
                Text(
                  'Your account has been suspended due to violation of our terms of service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceXxl),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Contact Support'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemes.accentPink,
                    side: const BorderSide(color: AppThemes.accentPink),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppThemes.spaceXl,
                      vertical: AppThemes.spaceMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppThemes.radiusPill),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
