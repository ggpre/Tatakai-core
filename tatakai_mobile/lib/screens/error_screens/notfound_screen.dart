import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  
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
                    color: AppThemes.accentPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppThemes.accentPink,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceXl),
                const Text(
                  '404',
                  style: TextStyle(
                    color: AppThemes.accentPink,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceSm),
                const Text(
                  'Page Not Found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceMd),
                Text(
                  'The page you are looking for doesn\'t exist or has been moved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceXxl),
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('Go Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.accentPink,
                    foregroundColor: Colors.white,
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
