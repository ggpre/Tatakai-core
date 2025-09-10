import React, { useState, useEffect } from 'react';
import { NavigationProvider } from '@/context/NavigationProvider';
import TVLayout from '@/components/tv/TVLayout';
import TVHomePage from '@/components/tv/TVHomePage';
import TVVideoPlayer from '@/components/tv/TVVideoPlayer';
import { Anime, Episode } from '@/types';
import { getAnimeEpisodes, getEpisodeSources } from '@/services/api';
import { isWebOS } from '@/lib/utils';

// Simple routing state
type Route = 
  | { type: 'home' }
  | { type: 'search' }
  | { type: 'trending' }
  | { type: 'movies' }
  | { type: 'series' }
  | { type: 'settings' }
  | { type: 'anime'; anime: Anime }
  | { type: 'watch'; anime: Anime; episode?: Episode };

const App: React.FC = () => {
  const [currentRoute, setCurrentRoute] = useState<Route>({ type: 'home' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Initialize WebOS specific features
  useEffect(() => {
    if (isWebOS()) {
      console.log('WebOS TV environment detected');
      
      // Handle WebOS back button
      if (typeof window !== 'undefined' && (window as any).webOSTV) {
        (window as any).webOSTV.platformBack = {
          getMenuKey: () => {
            // Handle back navigation
            handleBack();
          }
        };
      }
    }
  }, []);

  const handleNavigation = (path: string) => {
    switch (path) {
      case '/':
        setCurrentRoute({ type: 'home' });
        break;
      case '/search':
        setCurrentRoute({ type: 'search' });
        break;
      case '/trending':
        setCurrentRoute({ type: 'trending' });
        break;
      case '/movies':
        setCurrentRoute({ type: 'movies' });
        break;
      case '/series':
        setCurrentRoute({ type: 'series' });
        break;
      case '/settings':
        setCurrentRoute({ type: 'settings' });
        break;
      default:
        setCurrentRoute({ type: 'home' });
    }
  };

  const handleAnimeSelect = (anime: Anime) => {
    setCurrentRoute({ type: 'anime', anime });
  };

  const handleAnimePlay = async (anime: Anime) => {
    try {
      setLoading(true);
      setError(null);
      
      // Get episodes for the anime
      const episodes = await getAnimeEpisodes(anime.id);
      
      if (episodes && episodes.length > 0) {
        // Play the first episode
        const firstEpisode = episodes[0];
        setCurrentRoute({ 
          type: 'watch', 
          anime, 
          episode: firstEpisode 
        });
      } else {
        // No episodes found, just go to anime details
        setCurrentRoute({ type: 'anime', anime });
      }
    } catch (err) {
      console.error('Failed to load episodes:', err);
      setError('Failed to load episodes');
      // Fallback to anime details
      setCurrentRoute({ type: 'anime', anime });
    } finally {
      setLoading(false);
    }
  };

  const handleBack = () => {
    // Simple back navigation
    if (currentRoute.type !== 'home') {
      setCurrentRoute({ type: 'home' });
    }
  };

  const getCurrentPath = (): string => {
    switch (currentRoute.type) {
      case 'home': return '/';
      case 'search': return '/search';
      case 'trending': return '/trending';
      case 'movies': return '/movies';
      case 'series': return '/series';
      case 'settings': return '/settings';
      default: return '/';
    }
  };

  const renderCurrentPage = () => {
    if (loading) {
      return (
        <div className="flex items-center justify-center h-screen">
          <div className="text-center">
            <div className="w-16 h-16 border-4 border-rose-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
            <p className="text-tv-lg text-zinc-400">Loading...</p>
          </div>
        </div>
      );
    }

    switch (currentRoute.type) {
      case 'home':
        return (
          <TVHomePage
            onAnimeSelect={handleAnimeSelect}
            onAnimePlay={handleAnimePlay}
          />
        );

      case 'watch':
        return (
          <WatchPage
            anime={currentRoute.anime}
            episode={currentRoute.episode}
            onBack={handleBack}
          />
        );

      case 'search':
      case 'trending':
      case 'movies':
      case 'series':
      case 'settings':
      case 'anime':
        return (
          <div className="flex items-center justify-center h-screen">
            <div className="text-center">
              <h1 className="text-tv-2xl text-white mb-4">
                {currentRoute.type.charAt(0).toUpperCase() + currentRoute.type.slice(1)}
              </h1>
              <p className="text-tv-base text-zinc-400">
                This page is coming soon!
              </p>
            </div>
          </div>
        );

      default:
        return (
          <TVHomePage
            onAnimeSelect={handleAnimeSelect}
            onAnimePlay={handleAnimePlay}
          />
        );
    }
  };

  return (
    <NavigationProvider initialFocus="nav-home">
      <div className="app-container">
        {error && (
          <div className="fixed top-4 right-4 bg-red-500 text-white px-4 py-2 rounded-lg z-50">
            {error}
          </div>
        )}
        
        <TVLayout
          currentPath={getCurrentPath()}
          onNavigate={handleNavigation}
        >
          {renderCurrentPage()}
        </TVLayout>
      </div>
    </NavigationProvider>
  );
};

// Watch Page Component
interface WatchPageProps {
  anime: Anime;
  episode?: Episode;
  onBack: () => void;
}

const WatchPage: React.FC<WatchPageProps> = ({ anime, episode, onBack }) => {
  const [videoSrc, setVideoSrc] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadVideoSource = async () => {
      if (!episode) return;

      try {
        setLoading(true);
        setError(null);
        
        const episodeData = await getEpisodeSources(episode.episodeId);
        
        if (episodeData.sources && episodeData.sources.length > 0) {
          // Use the first available source
          setVideoSrc(episodeData.sources[0].url);
        } else {
          throw new Error('No video sources found');
        }
      } catch (err) {
        console.error('Failed to load video source:', err);
        setError('Failed to load video');
      } finally {
        setLoading(false);
      }
    };

    loadVideoSource();
  }, [episode]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-rose-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-tv-lg text-zinc-400">Loading video...</p>
        </div>
      </div>
    );
  }

  if (error || !videoSrc) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <p className="text-tv-lg text-red-400 mb-4">{error || 'Video not available'}</p>
          <button onClick={onBack} className="tv-button tv-button--primary">
            Go Back
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen">
      <TVVideoPlayer
        src={videoSrc}
        poster={anime.poster}
        autoPlay={true}
        onBack={onBack}
      />
    </div>
  );
};

export default App;