import 'package:dio/dio.dart';
import 'package:tatakai_mobile/models/image_models.dart';

class ImageService {
  final Dio _dio = Dio();
  
  static const String _waifuApiBase = 'https://api.waifu.pics';
  static const String _waifuImApi = 'https://api.waifu.im/search';
  static const String _nekosApi = 'https://nekos.best/api/v2';
  
  final List<String> _femaleCategories = [
    'waifu', 'neko', 'shinobu', 'megumin', 'awoo', 'smug', 
    'smile', 'happy', 'wink', 'blush'
  ];
  
  final List<String> _bannerCategories = ['waifu', 'neko', 'shinobu', 'megumin', 'awoo'];

  Future<List<AnimeImage>> fetchRandomImages({
    required String type, // 'avatar' or 'banner'
    String gender = 'any',
    int limit = 12,
  }) async {
    final List<AnimeImage> images = [];
    
    if (type == 'banner') {
      // Fetch banner images (landscape-ish usually, but waifu.pics are mostly standard aspect, 
      // web uses them as banners anyway)
      final fetchPromises = List.generate(limit, (index) async {
        try {
          final category = _bannerCategories[index % _bannerCategories.length];
          final response = await _dio.get('$_waifuApiBase/sfw/$category');
          if (response.statusCode == 200) {
            return AnimeImage(
              id: 'waifu-${DateTime.now().millisecondsSinceEpoch}-$index',
              url: response.data['url'],
              gender: 'female',
            );
          }
        } catch (e) {
          print('Error fetching banner image: $e');
        }
        return null;
      });
      
      final results = await Future.wait(fetchPromises);
      images.addAll(results.whereType<AnimeImage>());
      return images;
    }
    
    // Avatar fetching
    final fetchPromises = <Future<AnimeImage?>>[];
    
    // Male images
    if (gender == 'male' || gender == 'any') {
      final maleCount = gender == 'male' ? limit : (limit / 2).floor();
      
      // Try nekos.best
      fetchPromises.add(() async {
        try {
          final response = await _dio.get('$_nekosApi/husbando', queryParameters: {'amount': maleCount});
          if (response.statusCode == 200 && response.data['results'] is List) {
            final results = response.data['results'] as List;
            // Since this returns multiple, we can't easily fit into the Future<AnimeImage?> pattern 
            // without refactoring or just handling here.
            // Let's just return nothing here and handle side-effect or change architecture.
            // Better: make helper methods.
            return null; // Handled separately
          }
        } catch (e) { print(e); }
        return null;
      }());
    }
    
    // Re-structure to generic lists then combine
    List<AnimeImage> maleImages = [];
    List<AnimeImage> femaleImages = [];
    
    if (gender == 'male' || gender == 'any') {
      final maleCount = gender == 'male' ? limit : (limit / 2).floor();
      try {
        final response = await _dio.get('$_nekosApi/husbando', queryParameters: {'amount': maleCount});
        if (response.statusCode == 200 && response.data['results'] is List) {
           final list = response.data['results'] as List;
           maleImages.addAll(list.map((e) => AnimeImage(
             id: 'husbando-${DateTime.now().microsecondsSinceEpoch}', 
             url: e['url'], 
             gender: 'male'
           )));
        }
      } catch (e) {
        // Fallback to waifu.im
        try {
           final response = await _dio.get('$_waifuImApi', queryParameters: {
             'included_tags': 'husbando',
             'is_nsfw': 'false',
             'limit': maleCount - maleImages.length
           });
           if (response.statusCode == 200 && response.data['images'] is List) {
             final list = response.data['images'] as List;
             maleImages.addAll(list.map((e) => AnimeImage(
               id: 'husbando-im-${e['image_id']}', 
               url: e['url'], 
               gender: 'male'
             )));
           }
        } catch (e2) { print(e2); }
      }
    }
    
    if (gender == 'female' || gender == 'any') {
      final femaleCount = gender == 'female' ? limit : (limit / 2).ceil();
      final futures = List.generate(femaleCount, (index) async {
         try {
           final category = _femaleCategories[index % _femaleCategories.length];
           final response = await _dio.get('$_waifuApiBase/sfw/$category');
           if (response.statusCode == 200) {
             return AnimeImage(
               id: 'waifu-${DateTime.now().millisecondsSinceEpoch}-$index',
               url: response.data['url'],
               gender: 'female',
             );
           }
         } catch (e) {}
         return null;
      });
      
      final results = await Future.wait(futures);
      femaleImages.addAll(results.whereType<AnimeImage>());
    }
    
    images.addAll(maleImages);
    images.addAll(femaleImages);
    images.shuffle();
    
    return images.take(limit).toList();
  }
}
