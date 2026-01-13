import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for managing app updates via Firebase Remote Config
class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  
  // Remote config keys
  static const String _keyMinVersion = 'min_app_version';
  static const String _keyLatestVersion = 'latest_app_version';
  static const String _keyUpdateMessage = 'update_message';
  static const String _keyForceUpdate = 'force_update';
  static const String _keyUpdateUrl = 'update_url';
  static const String _keyMaintenanceMode = 'maintenance_mode';
  static const String _keyMaintenanceMessage = 'maintenance_message';

  /// Initialize Firebase Remote Config with defaults
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await _remoteConfig.setDefaults({
        _keyMinVersion: '1.0.0',
        _keyLatestVersion: '1.0.0',
        _keyUpdateMessage: 'A new version is available. Please update for the best experience.',
        _keyForceUpdate: false,
        _keyUpdateUrl: '',
        _keyMaintenanceMode: false,
        _keyMaintenanceMessage: 'The app is currently under maintenance. Please try again later.',
      });

      // Fetch and activate remote config
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Failed to initialize remote config: $e');
    }
  }

  /// Fetch latest remote config values
  Future<void> fetch() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Failed to fetch remote config: $e');
    }
  }

  /// Get minimum required app version
  String get minVersion => _remoteConfig.getString(_keyMinVersion);

  /// Get latest available app version
  String get latestVersion => _remoteConfig.getString(_keyLatestVersion);

  /// Get update message
  String get updateMessage => _remoteConfig.getString(_keyUpdateMessage);

  /// Check if update is forced
  bool get isForceUpdate => _remoteConfig.getBool(_keyForceUpdate);

  /// Get update URL (e.g., Play Store or App Store)
  String get updateUrl => _remoteConfig.getString(_keyUpdateUrl);

  /// Check if maintenance mode is enabled
  bool get isMaintenanceMode => _remoteConfig.getBool(_keyMaintenanceMode);

  /// Get maintenance message
  String get maintenanceMessage => _remoteConfig.getString(_keyMaintenanceMessage);

  /// Compare two version strings (e.g., "1.0.0" vs "1.0.1")
  int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad with zeros if needed
    while (v1Parts.length < 3) v1Parts.add(0);
    while (v2Parts.length < 3) v2Parts.add(0);

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    return 0;
  }

  /// Check if update is required
  Future<UpdateStatus> checkForUpdate() async {
    try {
      // Fetch latest config
      await fetch();

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Check maintenance mode first
      if (isMaintenanceMode) {
        return UpdateStatus(
          type: UpdateType.maintenance,
          message: maintenanceMessage,
        );
      }

      // Check if current version is below minimum required
      if (_compareVersions(currentVersion, minVersion) < 0) {
        return UpdateStatus(
          type: UpdateType.forceUpdate,
          message: updateMessage,
          updateUrl: updateUrl,
          currentVersion: currentVersion,
          latestVersion: this.latestVersion,
        );
      }

      // Check if a newer version is available
      if (_compareVersions(currentVersion, latestVersion) < 0) {
        return UpdateStatus(
          type: isForceUpdate ? UpdateType.forceUpdate : UpdateType.optionalUpdate,
          message: updateMessage,
          updateUrl: updateUrl,
          currentVersion: currentVersion,
          latestVersion: this.latestVersion,
        );
      }

      return UpdateStatus(type: UpdateType.upToDate);
    } catch (e) {
      debugPrint('Failed to check for update: $e');
      return UpdateStatus(type: UpdateType.upToDate);
    }
  }

  /// Launch update URL
  Future<void> launchUpdate() async {
    final url = updateUrl;
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Show update dialog
  static Future<void> showUpdateDialog(
    BuildContext context, 
    UpdateStatus status,
  ) async {
    if (status.type == UpdateType.upToDate) return;

    final isDismissible = status.type != UpdateType.forceUpdate && 
                          status.type != UpdateType.maintenance;

    await showDialog(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => PopScope(
        canPop: isDismissible,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1B1919),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                status.type == UpdateType.maintenance
                    ? Icons.build
                    : Icons.system_update,
                color: const Color(0xFFFF1493),
              ),
              const SizedBox(width: 12),
              Text(
                status.type == UpdateType.maintenance
                    ? 'Maintenance'
                    : 'Update Available',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.message ?? '',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              if (status.currentVersion != null && status.latestVersion != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current: v${status.currentVersion}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Latest: v${status.latestVersion}',
                      style: const TextStyle(
                        color: Color(0xFFFF1493),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            if (isDismissible)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Later',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            if (status.type != UpdateType.maintenance)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  AppUpdateService().launchUpdate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1493),
                ),
                child: const Text(
                  'Update Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Update status types
enum UpdateType {
  upToDate,
  optionalUpdate,
  forceUpdate,
  maintenance,
}

/// Update status data class
class UpdateStatus {
  final UpdateType type;
  final String? message;
  final String? updateUrl;
  final String? currentVersion;
  final String? latestVersion;

  UpdateStatus({
    required this.type,
    this.message,
    this.updateUrl,
    this.currentVersion,
    this.latestVersion,
  });
}
