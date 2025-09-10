import React from 'react';
import { Anime } from '@/types';
import { getImageUrl } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import Focusable from './Focusable';
import { Play, Info, Star } from 'lucide-react';
import { cn } from '@/lib/utils';

interface TVHeroProps {
  anime: Anime;
  onPlay: () => void;
  onInfo: () => void;
  className?: string;
}

const TVHero: React.FC<TVHeroProps> = ({
  anime,
  onPlay,
  onInfo,
  className
}) => {
  return (
    <div className={cn('tv-hero relative', className)}>
      {/* Background Image */}
      <div className="absolute inset-0">
        <img
          src={getImageUrl(anime.poster)}
          alt={anime.name}
          className="tv-hero__background"
          loading="eager"
        />
        <div className="absolute inset-0 bg-gradient-to-r from-black/90 via-black/60 to-transparent" />
        <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-transparent to-transparent" />
      </div>

      {/* Content */}
      <div className="tv-hero__content relative z-10">
        <div className="max-w-4xl">
          {/* Title */}
          <h1 className="tv-hero__title">
            {anime.name}
          </h1>

          {/* Japanese Title */}
          {anime.jname && (
            <p className="text-tv-lg text-zinc-300 mb-4 font-medium">
              {anime.jname}
            </p>
          )}

          {/* Meta Information */}
          <div className="flex items-center gap-4 mb-6 text-tv-base">
            {anime.rank && (
              <div className="flex items-center gap-1 text-rose-400">
                <Star size={16} fill="currentColor" />
                <span>#{anime.rank}</span>
              </div>
            )}
            
            {anime.type && (
              <span className="bg-zinc-800/80 px-3 py-1 rounded-lg">
                {anime.type}
              </span>
            )}
            
            {anime.episodes && anime.episodes.sub > 0 && (
              <span className="bg-zinc-800/80 px-3 py-1 rounded-lg">
                {anime.episodes.sub} Episodes
              </span>
            )}
            
            {anime.rating && (
              <span className="bg-zinc-800/80 px-3 py-1 rounded-lg">
                {anime.rating}
              </span>
            )}
            
            {anime.duration && (
              <span className="bg-zinc-800/80 px-3 py-1 rounded-lg">
                {anime.duration}
              </span>
            )}
          </div>

          {/* Description */}
          {anime.description && (
            <p className="tv-hero__description">
              {anime.description}
            </p>
          )}

          {/* Action Buttons */}
          <div className="tv-hero__actions">
            <Focusable
              id="hero-play"
              onEnter={onPlay}
            >
              <Button variant="tv" size="tv-lg" className="gap-3">
                <Play size={20} fill="white" />
                Play Now
              </Button>
            </Focusable>

            <Focusable
              id="hero-info"
              onEnter={onInfo}
            >
              <Button variant="tv-outline" size="tv-lg" className="gap-3">
                <Info size={20} />
                More Info
              </Button>
            </Focusable>
          </div>

          {/* Additional Info */}
          {anime.otherInfo && anime.otherInfo.length > 0 && (
            <div className="mt-6 flex flex-wrap gap-2">
              {anime.otherInfo.slice(0, 3).map((info, index) => (
                <span
                  key={index}
                  className="text-tv-sm text-zinc-400 bg-zinc-900/50 px-2 py-1 rounded"
                >
                  {info}
                </span>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default TVHero;