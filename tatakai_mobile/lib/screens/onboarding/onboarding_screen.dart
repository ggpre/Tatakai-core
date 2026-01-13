import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppThemes.accentPink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppThemes.accentPink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tatakai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Welcome text
              const Text(
                'Welcome to Tatakai',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Your ultimate anime streaming companion.\nWatch, track, and discover anime.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 3),
              
              // Features list
              _buildFeatureItem(Icons.play_circle_outline, 'Stream anime in HD quality'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.download_outlined, 'Download for offline viewing'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.favorite_outline, 'Track your watchlist'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.notifications_outlined, 'Get notified about new episodes'),
              
              const Spacer(flex: 2),
              
              // Get Started button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.accentPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sign in option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/auth'),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppThemes.accentPink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppThemes.accentPink.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppThemes.accentPink,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
