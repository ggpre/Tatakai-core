import 'package:dio/dio.dart';
import 'package:tatakai_mobile/config/env.dart';
import 'package:tatakai_mobile/models/anime.dart';
import 'package:tatakai_mobile/models/episode_model.dart';

class ApiService {
  late final Dio _dio;
  late final Dio _proxyDio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));
    
    _proxyDio = Dio(BaseOptions(
      baseUrl: Config.proxyUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'apikey': Config.supabaseAnonKey,
        'Authorization': 'Bearer ${Config.supabaseAnonKey}',
      },
    ));
    // Add logging for proxy requests to help debug proxy/fetch issues
    _proxyDio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  // Helper to unwrap API responses
  T _unwrapData<T>(dynamic payload, T Function(dynamic) parser) {
    if (payload is Map<String, dynamic>) {
      if (payload.containsKey('success') && payload['success'] == true) {
        try {
          return parser(payload['data']);
        } catch (e, st) {
          print('[ApiService] parse error for success envelope: $e\nPayload: ${payload['data']}\n$st');
          rethrow;
        }
      }
      if (payload.containsKey('status') && payload['status'] >= 200 && payload['status'] < 300) {
        try {
          return parser(payload['data']);
        } catch (e, st) {
          print('[ApiService] parse error for proxy envelope: $e\nPayload: ${payload['data']}\n$st');
          rethrow;
        }
      }
    }

    try {
      return parser(payload);
    } catch (e, st) {
      print('[ApiService] parse error for raw payload: $e\nPayload: $payload\n$st');
      rethrow;
    }
  }
  
  // Retry wrapper with exponential backoff
  Future<T> _retryRequest<T>(
    Future<T> Function() request, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 300 * (1 << attempt)));
      }
    }
    throw Exception('Max retries exceeded');
  }
  
  // Proxy request wrapper
  Future<Response> _proxyGet(String url, {Map<String, dynamic>? params}) async {
    try {
      final response = await _proxyDio.get(
        '',
        queryParameters: {
          'url': url,
          'type': 'api',
          'referer': Uri.parse(Config.apiBaseUrl).origin,
          'apikey': Config.supabaseAnonKey,
          ...?params,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<HomeData> fetchHome() async {
    return _retryRequest(() async {
      try {
        // Try the featured endpoint first as mentioned by user
        final response = await _proxyGet('${Config.apiBaseUrl}/anime/featured-0');
        return _unwrapData(response.data, (data) => HomeData.fromJson(data));
      } catch (e) {
        // Fallback to home endpoint
        try {
          final response = await _proxyGet('${Config.apiBaseUrl}/home');
          return _unwrapData(response.data, (data) => HomeData.fromJson(data));
        } catch (e) {
          // Final fallback to direct API call
          final directResponse = await _dio.get('/home');
          return _unwrapData(directResponse.data, (data) => HomeData.fromJson(data));
        }
      }
    });
  }
  
  Future<AnimeInfoResponse> fetchAnimeInfo(String animeId) async {
    return _retryRequest(() async {
      try {
        final response = await _proxyGet('${Config.apiBaseUrl}/anime/$animeId');
        return _unwrapData(response.data, (data) => AnimeInfoResponse.fromJson(data));
      } catch (e) {
        final directResponse = await _dio.get('/anime/$animeId');
        return _unwrapData(directResponse.data, (data) => AnimeInfoResponse.fromJson(data));
      }
    });
  }
  
  Future<EpisodeList> fetchEpisodes(String animeId) async {
    return _retryRequest(() async {
      try {
        final response = await _proxyGet('${Config.apiBaseUrl}/anime/$animeId/episodes');
        return _unwrapData(response.data, (data) => EpisodeList.fromJson(data));
      } catch (e) {
        final directResponse = await _dio.get('/anime/$animeId/episodes');
        return _unwrapData(directResponse.data, (data) => EpisodeList.fromJson(data));
      }
    });
  }
  
  Future<EpisodeServers> fetchEpisodeServers(String episodeId) async {
    return _retryRequest(() async {
      try {
        final response = await _proxyGet(
          '${Config.apiBaseUrl}/episode/servers',
          params: {'animeEpisodeId': episodeId},
        );
        return _unwrapData(response.data, (data) => EpisodeServers.fromJson(data));
      } catch (e) {
        final directResponse = await _dio.get(
          '/episode/servers',
          queryParameters: {'animeEpisodeId': episodeId},
        );
        return _unwrapData(directResponse.data, (data) => EpisodeServers.fromJson(data));
      }
    });
  }
  
  Future<StreamingData> fetchStreamingSources(
    String episodeId, {
    String server = 'hd-1',
    String category = 'sub',
  }) async {
    return _retryRequest(() async {
      try {
        final response = await _proxyGet(
          '${Config.apiBaseUrl}/episode/sources',
          params: {
            'animeEpisodeId': episodeId,
            'server': server,
            'category': category,
          },
        );
        return _unwrapData(response.data, (data) => StreamingData.fromJson(data));
      } catch (e) {
        final directResponse = await _dio.get(
          '/episode/sources',
          queryParameters: {
            'animeEpisodeId': episodeId,
            'server': server,
            'category': category,
          },
        );
        return _unwrapData(directResponse.data, (data) => StreamingData.fromJson(data));
      }
    });
  }
  
  Future<SearchResult> searchAnime(String query, {int page = 1}) async {
    return _retryRequest(() async {
      try {
        final response = await _proxyGet(
          '${Config.apiBaseUrl}/search',
          params: {'q': query, 'page': page.toString()},
        );
        return _unwrapData(response.data, (data) => SearchResult.fromJson(data));
      } catch (e) {
        final directResponse = await _dio.get(
          '/search',
          queryParameters: {'q': query, 'page': page},
        );
        return _unwrapData(directResponse.data, (data) => SearchResult.fromJson(data));
      }
    });
  }
  
  Future<Map<String, dynamic>> fetchGenreAnimes(String genre, {int page = 1}) async {
    return _retryRequest(() async {
      try {
        final response = await _proxyGet(
          '${Config.apiBaseUrl}/genre/$genre',
          params: {'page': page.toString()},
        );
        return _unwrapData(response.data, (data) => data as Map<String, dynamic>);
      } catch (e) {
        final directResponse = await _dio.get(
          '/genre/$genre',
          queryParameters: {'page': page},
        );
        return _unwrapData(directResponse.data, (data) => data as Map<String, dynamic>);
      }
    });
  }
  
  String getProxiedVideoUrl(String videoUrl, {String? referer}) {
    if (videoUrl.contains('/functions/v1/rapid-service')) {
      return videoUrl;
    }
    
    final params = {
      'url': videoUrl,
      'type': 'video',
      if (referer != null) 'referer': referer,
      'apikey': Config.supabaseAnonKey,
    };
    
    final uri = Uri.parse(Config.proxyUrl).replace(
      queryParameters: params,
    );
    
    return uri.toString();
  }
  
  String getProxiedImageUrl(String imageUrl) {
    if (!imageUrl.startsWith('http') || 
        imageUrl.contains('/functions/v1/rapid-service')) {
      return imageUrl;
    }
    
    final params = {
      'url': imageUrl,
      'type': 'image',
      'apikey': Config.supabaseAnonKey,
    };
    
    final uri = Uri.parse(Config.proxyUrl).replace(
      queryParameters: params,
    );
    
    return uri.toString();
  }
  
  String getProxiedSubtitleUrl(String subtitleUrl) {
    if (!subtitleUrl.startsWith('http') || 
        subtitleUrl.contains('/functions/v1/rapid-service')) {
      return subtitleUrl;
    }
    
    final params = {
      'url': subtitleUrl,
      'apikey': Config.supabaseAnonKey,
    };
    
    final uri = Uri.parse(Config.proxyUrl).replace(
      queryParameters: params,
    );
    
    return uri.toString();
  }


  // WatchAnimeWorld Scraper
  Future<Map<String, dynamic>> fetchWatchAnimeWorldSources(String episodeUrl) async {
    final uri = Uri.parse('${Config.supabaseUrl}/functions/v1/watchanimeworld-scraper').replace(
      queryParameters: {
        'episodeUrl': episodeUrl,
        'apikey': Config.supabaseAnonKey,
      },
    );

    final response = await _dio.getUri(
      uri,
      options: Options(
        headers: {
          'apikey': Config.supabaseAnonKey,
          'Authorization': 'Bearer ${Config.supabaseAnonKey}',
        },
      ),
    );
    
    return _unwrapData(response.data, (data) => data as Map<String, dynamic>);
  }

  // AnimeHindiDubbed Scraper
  Future<Map<String, dynamic>> fetchAnimeHindiDubbedData(String slug) async {
    final uri = Uri.parse('${Config.supabaseUrl}/functions/v1/animehindidubbed-scraper').replace(
      queryParameters: {
        'action': 'anime',
        'slug': slug,
        'apikey': Config.supabaseAnonKey,
      },
    );

    final response = await _dio.getUri(
      uri,
      options: Options(
        headers: {
          'apikey': Config.supabaseAnonKey,
          'Authorization': 'Bearer ${Config.supabaseAnonKey}',
        },
      ),
    );
    
    return _unwrapData(response.data, (data) => data as Map<String, dynamic>);
  }
}
