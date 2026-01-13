import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/config/theme.dart';

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});
  
  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
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
          'System Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppThemes.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppThemes.spaceXl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemes.ratingGreen.withOpacity(0.2),
                    AppThemes.ratingGreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                border: Border.all(
                  color: AppThemes.ratingGreen.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppThemes.ratingGreen,
                    size: 48,
                  ),
                  const SizedBox(height: AppThemes.spaceMd),
                  const Text(
                    'All Systems Operational',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceXs),
                  Text(
                    'Last checked: Just now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppThemes.spaceXl),
            
            // Services status
            Text(
              'Services',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppThemes.spaceMd),
            
            _buildServiceItem('Streaming API', true, '99.9%'),
            _buildServiceItem('Video Servers', true, '99.8%'),
            _buildServiceItem('User Authentication', true, '100%'),
            _buildServiceItem('Database', true, '99.9%'),
            _buildServiceItem('Push Notifications', true, '99.5%'),
            _buildServiceItem('Download Service', true, '99.7%'),
            
            const SizedBox(height: AppThemes.spaceXl),
            
            // Recent incidents
            Text(
              'Recent Incidents',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppThemes.spaceMd),
            
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceLg),
              decoration: BoxDecoration(
                color: AppThemes.darkSurface,
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Colors.white.withOpacity(0.3),
                      size: 40,
                    ),
                    const SizedBox(height: AppThemes.spaceMd),
                    Text(
                      'No incidents in the last 30 days',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppThemes.spaceXxl),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServiceItem(String name, bool isOperational, String uptime) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppThemes.spaceSm),
      padding: const EdgeInsets.all(AppThemes.spaceMd),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOperational ? AppThemes.ratingGreen : Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: AppThemes.spaceMd),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            isOperational ? 'Operational' : 'Issue',
            style: TextStyle(
              color: isOperational 
                  ? AppThemes.ratingGreen 
                  : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppThemes.spaceMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemes.spaceSm,
              vertical: AppThemes.spaceXs,
            ),
            decoration: BoxDecoration(
              color: AppThemes.darkBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              uptime,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
