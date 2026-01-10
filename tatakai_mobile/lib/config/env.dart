class Config {
  // API Configuration
  static const String apiBaseUrl = 
      'https://aniwatch-api-taupe-eight.vercel.app/api/v2/hianime';
  static const String proxyUrl = 
      'https://xkbzamfyupjafugqeaby.supabase.co/functions/v1/rapid-service';
  
  // Supabase Configuration
  static const String supabaseUrl = 
      'https://xkbzamfyupjafugqeaby.supabase.co';
  static const String supabaseAnonKey = 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhrem'
      'Jhpmbllc3BqYWZ1Z3FlYWJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDcxNTk2MDUsImV4cCI6Mj'
      'AyMjczNTYwNX0.hiKONZyoLpTAkFpQL5DWIQ_1_OWjmj3';
  
  // Database URL (for reference in documentation)
  static const String databaseUrl = 
      'postgresql://postgres:TAStataai25#@db.xkbzamfyupjafugqeaby.supabase.co:5432/postgres';
  
  // WatchAnimeWorld Scraper
  static const String watchanimeworldScraperUrl =
      'https://xkbzamfyupjafugqeaby.supabase.co/functions/v1/watchanimeworld-scraper';
  
  // App Configuration
  static const String appName = 'Tatakai';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableDownloads = true;
  static const bool enableNotifications = true;
  
  // Video Player Configuration
  static const int videoBufferDuration = 30; // seconds
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Cache Configuration
  static const int maxCacheSize = 500; // MB
  static const Duration cacheExpiry = Duration(hours: 24);
  
  // Download Configuration
  static const int maxConcurrentDownloads = 3;
  static const String downloadPath = '/storage/emulated/0/Tatakai/Downloads';
  
  // Notification Configuration
  static const String fcmTopicAll = 'all_users';
  static const String fcmTopicAnimeUpdates = 'anime_updates';
  static const String fcmTopicMaintenanceAlerts = 'maintenance_alerts';
}
