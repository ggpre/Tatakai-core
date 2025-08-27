export interface Anime {
  id: string;
  name: string;
  poster: string;
  type?: string;
  episodes?: {
    sub: number;
    dub: number;
  };
  jname?: string;
  description?: string;
  rank?: number;
  otherInfo?: string[];
  duration?: string;
  rating?: string;
}

export interface SpotlightAnime extends Anime {
  jname: string;
  description: string;
  rank: number;
  otherInfo: string[];
}

export interface HomePageData {
  success: boolean;
  data: {
    genres: string[];
    latestEpisodeAnimes: Anime[];
    spotlightAnimes: SpotlightAnime[];
    top10Animes: {
      today: Anime[];
      week: Anime[];
      month: Anime[];
    };
    topAiringAnimes: Anime[];
    topUpcomingAnimes: Anime[];
    trendingAnimes: Anime[];
    mostPopularAnimes: Anime[];
    mostFavoriteAnimes: Anime[];
    latestCompletedAnimes: Anime[];
  };
}

// New type definitions for anime info, episodes, and streaming
export interface AnimeInfo {
  id: string;
  name: string;
  poster: string;
  description: string;
  stats: {
    rating: string;
    quality: string;
    episodes: {
      sub: number;
      dub: number;
    };
    type: string;
    duration: string;
  };
  promotionalVideos: Array<{
    title?: string;
    source?: string;
    thumbnail?: string;
  }>;
  characterVoiceActor: Array<{
    character: {
      id: string;
      poster: string;
      name: string;
      cast: string;
    };
    voiceActor: {
      id: string;
      poster: string;
      name: string;
      cast: string;
    };
  }>;
}

export interface AnimeMoreInfo {
  aired: string;
  genres: string[];
  status: string;
  studios: string;
  duration: string;
}

export interface AnimeInfoResponse {
  success: boolean;
  data: {
    anime: {
      info: AnimeInfo;
      moreInfo: AnimeMoreInfo;
    };
    mostPopularAnimes: Anime[];
    recommendedAnimes: Anime[];
    relatedAnimes: Anime[];
    seasons: Array<{
      id: string;
      name: string;
      title: string;
      poster: string;
      isCurrent: boolean;
    }>;
  };
}

export interface Server {
  serverId: number;
  serverName: string;
}

export interface EpisodeServersResponse {
  success: boolean;
  data: {
    episodeId: string;
    episodeNo: number;
    sub: Server[];
    dub: Server[];
    raw: Server[];
  };
}

export interface EpisodeSource {
  url: string;
  isM3U8: boolean;
  quality?: string;
}

export interface Subtitle {
  lang: string;
  url: string;
}

export interface EpisodeSourcesResponse {
  success: boolean;
  data: {
    headers: {
      Referer: string;
      'User-Agent': string;
    };
    sources: EpisodeSource[];
    subtitles: Subtitle[];
    anilistID: number | null;
    malID: number | null;
  };
}

export interface SearchResponse {
  success: boolean;
  data: {
    animes: Anime[];
    mostPopularAnimes: Anime[];
    currentPage: number;
    totalPages: number;
    hasNextPage: boolean;
  };
}

export interface SearchResult {
  success: boolean;
  data: {
    animes: Anime[];
    mostPopularAnimes: Anime[];
    currentPage: number;
    totalPages: number;
    hasNextPage: boolean;
    searchQuery: string;
    searchFilters: Record<string, string>;
  };
}

export interface AnimeDetails {
  success: boolean;
  data: {
    anime: {
      info: {
        id: string;
        name: string;
        poster: string;
        description: string;
        stats: {
          rating: string;
          quality: string;
          episodes: {
            sub: number;
            dub: number;
          };
          type: string;
          duration: string;
        };
        promotionalVideos: Array<{
          title?: string;
          source?: string;
          thumbnail?: string;
        }>;
        characterVoiceActor: Array<{
          character: {
            id: string;
            poster: string;
            name: string;
            cast: string;
          };
          voiceActor: {
            id: string;
            poster: string;
            name: string;
            cast: string;
          };
        }>;
      };
      moreInfo: {
        aired: string;
        genres: string[];
        status: string;
        studios: string;
        duration: string;
      };
    };
    mostPopularAnimes: Anime[];
    recommendedAnimes: Anime[];
    relatedAnimes: Anime[];
    seasons: Array<{
      id: string;
      name: string;
      title: string;
      poster: string;
      isCurrent: boolean;
    }>;
  };
}

export class AnimeAPI {
  private static readonly BASE_URL = '/api/anime';

  // Get home page data
  static async getHomePage(): Promise<HomePageData> {
    const response = await fetch(`${this.BASE_URL}?endpoint=/home`);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  }

  // Get anime details
  static async getAnimeInfo(animeId: string): Promise<AnimeInfoResponse> {
    const response = await fetch(`${this.BASE_URL}?endpoint=/anime/${animeId}`);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  }

  // Get anime episode servers
  static async getEpisodeServers(animeEpisodeId: string): Promise<EpisodeServersResponse> {
    const response = await fetch(`${this.BASE_URL}?endpoint=/episode/servers&animeEpisodeId=${encodeURIComponent(animeEpisodeId)}`);
    
    if (!response.ok) {
      console.error(`Episode servers API error: ${response.status} - ${response.statusText}`);
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  }

  // Get anime episode sources
  static async getEpisodeSources(
    animeEpisodeId: string, 
    server: string = 'hd-1', 
    category: 'sub' | 'dub' | 'raw' = 'sub'
  ): Promise<EpisodeSourcesResponse> {
    const response = await fetch(
      `${this.BASE_URL}?endpoint=/episode/sources&animeEpisodeId=${encodeURIComponent(animeEpisodeId)}&server=${encodeURIComponent(server)}&category=${category}`
    );
    
    if (!response.ok) {
      console.error(`Episode sources API error: ${response.status} - ${response.statusText}`);
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  }

  // Search anime
  static async searchAnime(
    query: string,
    page: number = 1,
    type?: string,
    status?: string,
    genres?: string
  ): Promise<SearchResponse> {
    let endpoint = `/search?q=${encodeURIComponent(query)}&page=${page}`;
    
    if (type) endpoint += `&type=${type}`;
    if (status) endpoint += `&status=${status}`;
    if (genres) endpoint += `&genres=${genres}`;
    
    const response = await fetch(`${this.BASE_URL}?endpoint=${endpoint}`);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  }
}
