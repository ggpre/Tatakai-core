import React, { useState, useEffect } from 'react';
import { HomePageData, Anime } from '@/types';
import { getHomeData } from '@/services/api';
import TVHero from './TVHero';
import TVCarousel from './TVCarousel';
import { ScrollArea } from '@/components/ui/scroll-area';

interface TVHomePageProps {
  onAnimeSelect: (anime: Anime) => void;
  onAnimePlay: (anime: Anime) => void;
}

const TVHomePage: React.FC<TVHomePageProps> = ({
  onAnimeSelect,
  onAnimePlay
}) => {
  const [homeData, setHomeData] = useState<HomePageData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchHomeData = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await getHomeData();
        setHomeData(data);
      } catch (err) {
        console.error('Failed to fetch home data:', err);
        setError('Failed to load home page data');
      } finally {
        setLoading(false);
      }
    };

    fetchHomeData();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-rose-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-tv-lg text-zinc-400">Loading anime...</p>
        </div>
      </div>
    );
  }

  if (error || !homeData) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <p className="text-tv-lg text-red-400 mb-4">{error || 'Failed to load data'}</p>
          <button 
            onClick={() => window.location.reload()}
            className="tv-button tv-button--primary"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  // Get featured anime for hero section
  const featuredAnime = homeData.spotlightAnimes?.[0] || homeData.trendingAnimes?.[0];

  return (
    <ScrollArea className="h-screen">
      <div className="space-y-8 pb-8">
        {/* Hero Section */}
        {featuredAnime && (
          <TVHero
            anime={featuredAnime}
            onPlay={() => onAnimePlay(featuredAnime)}
            onInfo={() => onAnimeSelect(featuredAnime)}
          />
        )}

        {/* Trending Anime */}
        {homeData.trendingAnimes && homeData.trendingAnimes.length > 0 && (
          <TVCarousel
            title="Trending Now"
            items={homeData.trendingAnimes}
            onItemSelect={onAnimeSelect}
            onItemPlay={onAnimePlay}
            cardSize="lg"
          />
        )}

        {/* Most Popular */}
        {homeData.mostPopularAnimes && homeData.mostPopularAnimes.length > 0 && (
          <TVCarousel
            title="Most Popular"
            items={homeData.mostPopularAnimes}
            onItemSelect={onAnimeSelect}
            onItemPlay={onAnimePlay}
          />
        )}

        {/* Latest Episodes */}
        {homeData.latestEpisodeAnimes && homeData.latestEpisodeAnimes.length > 0 && (
          <TVCarousel
            title="Latest Episodes"
            items={homeData.latestEpisodeAnimes}
            onItemSelect={onAnimeSelect}
            onItemPlay={onAnimePlay}
          />
        )}

        {/* Top Airing */}
        {homeData.topAiringAnimes && homeData.topAiringAnimes.length > 0 && (
          <TVCarousel
            title="Currently Airing"
            items={homeData.topAiringAnimes}
            onItemSelect={onAnimeSelect}
            onItemPlay={onAnimePlay}
          />
        )}

        {/* Top 10 Today */}
        {homeData.top10Animes?.today && homeData.top10Animes.today.length > 0 && (
          <TVCarousel
            title="Top 10 Today"
            items={homeData.top10Animes.today}
            onItemSelect={onAnimeSelect}
            onItemPlay={onAnimePlay}
            cardSize="sm"
          />
        )}

        {/* Most Favorite */}
        {homeData.mostFavoriteAnimes && homeData.mostFavoriteAnimes.length > 0 && (
          <TVCarousel
            title="Most Favorite"
            items={homeData.mostFavoriteAnimes}
            onItemSelect={onAnimeSelect}
            onItemPlay={onAnimePlay}
          />
        )}

        {/* Latest Completed */}
        {homeData.latestCompletedAnimes && homeData.latestCompletedAnimes.length > 0 && (
          <TVCarousel
            title="Recently Completed"
            items={homeData.latestCompletedAnimes}
            onItemSelect={onAnimeSelect}
            onItemPlay={onAnimePlay}
          />
        )}

        {/* Top Upcoming */}
        {homeData.topUpcomingAnimes && homeData.topUpcomingAnimes.length > 0 && (
          <TVCarousel
            title="Coming Soon"
            items={homeData.topUpcomingAnimes}
            onItemSelect={onAnimeSelect}
            cardSize="sm"
          />
        )}
      </div>
    </ScrollArea>
  );
};

export default TVHomePage;