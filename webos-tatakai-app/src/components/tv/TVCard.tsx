import React from 'react';
import { Anime } from '@/types';
import { getImageUrl } from '@/lib/utils';
import Focusable from './Focusable';
import { Card } from '@/components/ui/card';
import { Play, Info } from 'lucide-react';
import { cn } from '@/lib/utils';

interface TVCardProps {
  anime: Anime;
  focusId: string;
  onSelect: () => void;
  onPlay?: () => void;
  className?: string;
  size?: 'sm' | 'md' | 'lg';
}

const TVCard: React.FC<TVCardProps> = ({
  anime,
  focusId,
  onSelect,
  onPlay,
  className,
  size = 'md'
}) => {
  const sizeClasses = {
    sm: 'w-32',
    md: 'w-40',
    lg: 'w-48'
  };

  return (
    <Focusable
      id={focusId}
      onEnter={onSelect}
      className={cn('flex-shrink-0', sizeClasses[size], className)}
    >
      <Card className="overflow-hidden group cursor-pointer h-full">
        {/* Poster Image */}
        <div className="relative aspect-[2/3] overflow-hidden">
          <img
            src={getImageUrl(anime.poster)}
            alt={anime.name}
            className="tv-card__image object-cover w-full h-full group-hover:scale-105 transition-transform duration-300"
            loading="lazy"
          />
          
          {/* Overlay on Focus */}
          <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 group-[.tv-focused]:opacity-100 transition-opacity duration-300 flex items-center justify-center">
            <div className="flex gap-2">
              {onPlay && (
                <button className="p-2 bg-rose-500 rounded-full hover:bg-rose-600 transition-colors">
                  <Play size={20} fill="white" />
                </button>
              )}
              <button className="p-2 bg-zinc-800/80 rounded-full hover:bg-zinc-700/80 transition-colors">
                <Info size={20} />
              </button>
            </div>
          </div>

          {/* Episode Count Badge */}
          {anime.episodes && (
            <div className="absolute top-2 left-2 bg-black/80 text-white text-tv-xs px-2 py-1 rounded">
              {anime.episodes.sub > 0 && `${anime.episodes.sub} EP`}
              {anime.episodes.dub > 0 && anime.episodes.sub > 0 && ' • '}
              {anime.episodes.dub > 0 && `${anime.episodes.dub} DUB`}
            </div>
          )}

          {/* Rating Badge */}
          {anime.rank && (
            <div className="absolute top-2 right-2 bg-rose-500 text-white text-tv-xs px-2 py-1 rounded">
              #{anime.rank}
            </div>
          )}
        </div>

        {/* Content */}
        <div className="tv-card__content">
          <h3 className="tv-card__title line-clamp-2" title={anime.name}>
            {anime.name}
          </h3>
          
          {anime.jname && (
            <p className="tv-card__subtitle line-clamp-1" title={anime.jname}>
              {anime.jname}
            </p>
          )}

          <div className="tv-card__meta">
            {anime.type && (
              <span className="bg-zinc-800 px-2 py-1 rounded text-tv-xs">
                {anime.type}
              </span>
            )}
            {anime.rating && (
              <span className="text-tv-xs">
                {anime.rating}
              </span>
            )}
            {anime.duration && (
              <span className="text-tv-xs">
                {anime.duration}
              </span>
            )}
          </div>
        </div>
      </Card>
    </Focusable>
  );
};

export default TVCard;