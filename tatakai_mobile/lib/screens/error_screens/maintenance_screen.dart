import 'package:flutter/material.dart';
import 'package:tatakai_mobile/config/theme.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});
  
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
                    color: AppThemes.accentPinkLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    size: 64,
                    color: AppThemes.accentPinkLight,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceXl),
                const Text(
                  'Under Maintenance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceMd),
                Text(
                  'We\'re working on some improvements.\nPlease check back soon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceXxl),
                Container(
                  padding: const EdgeInsets.all(AppThemes.spaceLg),
                  decoration: BoxDecoration(
                    color: AppThemes.darkSurface,
                    borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppThemes.accentPink,
                        size: 20,
                      ),
                      const SizedBox(width: AppThemes.spaceSm),
                      Text(
                        'Expected downtime: ~30 minutes',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
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
