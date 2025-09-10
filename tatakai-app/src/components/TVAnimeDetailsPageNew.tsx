'use client';

import React, { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { AnimeAPI, type AnimeInfoResponse, type AnimeEpisodesResponse } from '@/lib/api';
import { TVNavigationProvider } from './tv/ReactTVProvider';
import { Focusable } from './tv/Focusable';
import VerticalList from './tv/VerticalListNew';
import { Skeleton } from '@/components/ui/skeleton';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Play } from 'lucide-react';

interface Episode {
  number: number;
  title: string;
  episodeId: string;
  isFiller?: boolean;
}

interface AnimeDetails {
  id: string;
  title: string;
  image: string;
  description: string;
  genres: string[];
  status: string;
  releaseDate: string;
  rating: string;
  duration: string;
  totalEpisodes: number;
  type: string;
}

interface Episode {
  number: number;
  title: string;
  episodeId: string;
  isFiller?: boolean;
}

// Action button component

const ActionButton: React.FC<{
  id: string;
  groupId: string;
  icon: React.ReactNode;
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}> = ({ id, groupId, icon, label, onClick, variant = 'secondary' }) => {
  return (
    <Focusable
      id={id}
      groupId={groupId}
      onSelect={onClick}
      className="tv-button"
      focusClassName="tv-focused"
    >
      <button
        className={`
          flex items-center gap-3 px-8 py-4 rounded-lg font-semibold transition-all duration-200 text-xl
          ${variant === 'primary' 
            ? 'bg-red-600 hover:bg-red-700 text-white' 
            : 'bg-white/20 hover:bg-white/30 text-white backdrop-blur-sm'
          }
        `}
      >
        <span className="text-2xl">{icon}</span>
        {label}
      </button>
    </Focusable>
  );
};

const HeroSection: React.FC<{ 
  anime: AnimeDetails;
  onWatchClick: () => void;
  onBackClick: () => void;
}> = ({ anime, onWatchClick, onBackClick }) => {
  const handleAddToList = () => {
    console.log('Add to list:', anime.title);
  };

  const handleFavorite = () => {
    console.log('Add to favorites:', anime.title);
  };

  const handleShare = () => {
    console.log('Share:', anime.title);
  };

  return (
    <div className="relative w-full aspect-[21/9] min-h-[60vh] max-h-[70vh] mb-12 overflow-hidden" data-section="hero">
      <img
        src={anime.image || '/placeholder-anime.jpg'}
        alt={anime.title}
        className="w-full h-full object-cover object-center"
      />
      <div className="absolute inset-0 bg-gradient-to-r from-black/95 via-black/60 to-black/30">
        <div className="flex flex-col h-full p-8 lg:p-16">
          {/* Back Button */}
          <div className="mb-6">
            <Focusable
              id="back-button"
              groupId="hero-actions"
              onSelect={onBackClick}
              className="tv-button back"
            >
              <button className="flex items-center gap-3 bg-black/60 hover:bg-black/80 text-white px-6 py-3 rounded-lg backdrop-blur-sm transition-all">
                <span className="text-xl">←</span>
                <span className="font-medium">Back</span>
              </button>
            </Focusable>
          </div>

          {/* Main Content */}
          <div className="flex-1 flex flex-col justify-center max-w-6xl">
            <div className="flex items-center gap-4 mb-4">
              <span className="bg-red-600 text-white px-4 py-2 rounded-lg text-base font-semibold">
                {anime.type}
              </span>
              <span className="text-gray-300 text-lg">{anime.releaseDate}</span>
            </div>
            
            <h1 className="text-5xl lg:text-6xl font-bold text-white mb-6 drop-shadow-lg leading-tight">
              {anime.title}
            </h1>
            
            <div className="flex items-center gap-8 mb-6">
              <div className="flex items-center gap-2">
                <span className="text-2xl">⭐</span>
                <span className="text-white font-semibold text-xl">{anime.rating}</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-xl">⏰</span>
                <span className="text-gray-300 text-lg">{anime.duration}</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-xl">📅</span>
                <span className="text-gray-300 text-lg">{anime.status}</span>
              </div>
            </div>

            <p className="text-lg text-gray-200 mb-8 line-clamp-3 drop-shadow leading-relaxed max-w-4xl">
              {anime.description}
            </p>

            <div className="flex items-center gap-3 mb-6 flex-wrap">
              {anime.genres.slice(0, 6).map((genre, index) => (
                <span key={index} className="bg-white/20 text-white px-3 py-1 rounded-full text-sm backdrop-blur-sm">
                  {genre}
                </span>
              ))}
            </div>

            {/* Action Buttons */}
            <div className="flex items-center gap-4">
              <ActionButton
                id="watch-now"
                groupId="hero-actions"
                icon={<Play className="w-6 h-6" />}
                label="Watch Now"
                onClick={onWatchClick}
                variant="primary"
              />
              <ActionButton
                id="add-list"
                groupId="hero-actions"
                icon={<span className="text-2xl">➕</span>}
                label="My List"
                onClick={handleAddToList}
              />
              <ActionButton
                id="favorite"
                groupId="hero-actions"
                icon={<span className="text-2xl">❤️</span>}
                label="Favorite"
                onClick={handleFavorite}
              />
              <ActionButton
                id="share"
                groupId="hero-actions"
                icon={<span className="text-2xl">📤</span>}
                label="Share"
                onClick={handleShare}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const EpisodesSection: React.FC<{
  episodes: Episode[];
  animeId: string;
}> = ({ episodes, animeId }) => {
  const [showAllEpisodes, setShowAllEpisodes] = useState(false);
  const router = useRouter();
  
  if (episodes.length === 0) return null;

  const displayedEpisodes = showAllEpisodes ? episodes : episodes.slice(0, 20);

  return (
    <div className="mb-16 py-12" data-section="episodes">
      <div className="px-12 mb-8">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-4xl font-bold text-white">Episodes ({episodes.length})</h2>
          {episodes.length > 20 && (
            <Focusable
              id="show-all-episodes"
              groupId="episodes-actions"
              onSelect={() => {
                setShowAllEpisodes(!showAllEpisodes);
              }}
              className="tv-button"
              focusClassName="tv-focused"
            >
              <button className="bg-white/20 hover:bg-white/30 text-white px-6 py-3 rounded-lg backdrop-blur-sm transition-all text-lg font-medium">
                {showAllEpisodes ? '📋 Show Less' : '📋 Show All Episodes'}
              </button>
            </Focusable>
          )}
        </div>
        
        {/* Episodes List using VerticalList for better TV navigation */}
        <VerticalList 
          id="episodes-list"
          spacing={12}
          className="max-h-[600px] overflow-y-auto custom-scrollbar pr-4"
        >
          {displayedEpisodes.map((episode, index) => (
            <Focusable
              key={episode.episodeId}
              id={`episode-${index}`}
              groupId="episodes-list"
              onSelect={() => router.push(`/tv/watch/${animeId}?ep=${episode.number}`)}
              className="tv-episode-list-item"
              focusClassName="tv-focused"
            >
              <div className="bg-gray-800/90 hover:bg-gray-700/90 rounded-lg p-6 cursor-pointer transition-all duration-200 border-2 border-transparent flex items-center space-x-6">
                {/* Episode Number */}
                <div className="flex-shrink-0 w-16 h-16 bg-blue-600/20 border border-blue-500/30 rounded-lg flex items-center justify-center">
                  <span className="text-2xl font-bold text-blue-300">{episode.number}</span>
                </div>
                
                {/* Episode Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center space-x-3 mb-2">
                    <h3 className="text-xl font-semibold text-white truncate">
                      {episode.title || `Episode ${episode.number}`}
                    </h3>
                    {episode.isFiller && (
                      <span className="bg-amber-500/20 text-amber-300 border border-amber-500/30 px-3 py-1 rounded-full text-sm font-medium">
                        Filler
                      </span>
                    )}
                  </div>
                  
                  <div className="flex items-center space-x-4 text-xs text-gray-500">
                    <span>📺 Episode {episode.number}</span>
                    <span>🎬 Click to watch</span>
                  </div>
                </div>

                {/* Play Icon */}
                <div className="flex-shrink-0">
                  <div className="w-12 h-12 bg-white/10 rounded-full flex items-center justify-center">
                    <Play className="w-6 h-6 text-white" />
                  </div>
                </div>
              </div>
            </Focusable>
          ))}
        </VerticalList>

        {/* Instructions */}
        <div className="mt-8 p-4 bg-gray-800/50 rounded-lg backdrop-blur-sm">
          <h3 className="font-bold mb-2 text-lg text-white">🎮 Episodes List Navigation:</h3>
          <div className="grid grid-cols-2 gap-4 text-sm text-gray-300">
            <div>
              <div>• ↑ ↓ Navigate through episodes</div>
              <div>• Enter: Watch selected episode</div>
              <div>• Back: Return to previous section</div>
            </div>
            <div>
              <div>• Total episodes: {displayedEpisodes.length}</div>
              <div>• Showing: {showAllEpisodes ? 'All episodes' : 'First 20 episodes'}</div>
              <div>• Format: Vertical list layout</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const TVAnimeDetailsPageNew: React.FC = () => {
  const params = useParams();
  const router = useRouter();
  const animeId = params?.id as string;
  
  const [animeData, setAnimeData] = useState<AnimeInfoResponse | null>(null);
  const [episodes, setEpisodes] = useState<AnimeEpisodesResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchAnimeData = async () => {
      if (!animeId) return;
      
      try {
        setLoading(true);
        setError(null);

        const [animeInfo, episodesData] = await Promise.all([
          AnimeAPI.getAnimeInfo(animeId),
          AnimeAPI.getAnimeEpisodes(animeId)
        ]);

        if (animeInfo.success) {
          setAnimeData(animeInfo);
        } else {
          setError('Failed to load anime details');
        }

        if (episodesData.success) {
          setEpisodes(episodesData);
        }
      } catch (err) {
        console.error('Error fetching anime data:', err);
        setError('Unable to connect to anime service');
      } finally {
        setLoading(false);
      }
    };

    fetchAnimeData();
  }, [animeId]);

  const convertToAnimeDetails = (data: AnimeInfoResponse): AnimeDetails => {
    const anime = data.data.anime;
    return {
      id: animeId,
      title: anime.info.name,
      image: anime.info.poster,
      description: anime.info.description,
      genres: anime.moreInfo.genres || [],
      status: anime.moreInfo.status || 'Unknown',
      releaseDate: anime.moreInfo.aired || 'Unknown',
      rating: anime.info.stats?.rating || '8.0',
      duration: anime.moreInfo.duration || '24min',
      totalEpisodes: anime.info.stats?.episodes?.sub || 0,
      type: anime.info.stats?.type || 'TV'
    };
  };

  const convertToEpisodes = (data: AnimeEpisodesResponse): Episode[] => {
    return data.data.episodes.map((ep) => ({
      number: ep.number,
      title: ep.title,
      episodeId: ep.episodeId,
      isFiller: ep.isFiller
    }));
  };

  const handleWatchClick = () => {
    if (episodes && episodes.data.episodes.length > 0) {
      router.push(`/tv/watch/${animeId}?ep=1`);
    }
  };

  const handleBackClick = () => {
    router.back();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-black text-white p-8">
        <div className="space-y-8">
          <Skeleton className="h-96 w-full rounded-lg" />
          <Skeleton className="h-8 w-64" />
          <div className="flex gap-4">
            {[1, 2, 3, 4, 5].map((i) => (
              <Skeleton key={i} className="h-32 w-80 rounded-lg" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (error || !animeData) {
    return (
      <div className="min-h-screen bg-black text-white p-8">
        <Alert variant="destructive">
          <AlertDescription>
            {error || 'Failed to load anime details'}
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  const animeDetails = convertToAnimeDetails(animeData);
  const episodesList = episodes ? convertToEpisodes(episodes) : [];

  return (
    <TVNavigationProvider initialFocus="watch-now">
      <div className="min-h-screen bg-black text-white tv-page-container">
        {/* Hero Section */}
        <div className="w-full tv-hero-section" data-section="hero">
          <HeroSection 
            anime={animeDetails}
            onWatchClick={handleWatchClick}
            onBackClick={handleBackClick}
          />
        </div>

        {/* Content Sections */}
        <div className="py-8">
          <VerticalList id="main-sections" spacing={40}>
            {episodesList.length > 0 && (
              <EpisodesSection 
                episodes={episodesList}
                animeId={animeId}
              />
            )}
          </VerticalList>
        </div>
      </div>
    </TVNavigationProvider>
  );
};

export default TVAnimeDetailsPageNew;
