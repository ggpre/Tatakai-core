import React from 'react';
import { Anime } from '@/types';
import TVCard from './TVCard';
import { ScrollArea, ScrollBar } from '@/components/ui/scroll-area';
import { cn } from '@/lib/utils';

interface TVCarouselProps {
  title: string;
  items: Anime[];
  onItemSelect: (anime: Anime) => void;
  onItemPlay?: (anime: Anime) => void;
  className?: string;
  cardSize?: 'sm' | 'md' | 'lg';
  showTitle?: boolean;
}

const TVCarousel: React.FC<TVCarouselProps> = ({
  title,
  items,
  onItemSelect,
  onItemPlay,
  className,
  cardSize = 'md',
  showTitle = true
}) => {
  if (!items || items.length === 0) {
    return null;
  }

  return (
    <div className={cn('tv-carousel', className)}>
      {showTitle && (
        <h2 className="text-tv-xl font-semibold text-white mb-4 px-tv-safe">
          {title}
        </h2>
      )}
      
      <ScrollArea className="w-full">
        <div className="tv-carousel__container px-tv-safe">
          {items.map((anime, index) => (
            <TVCard
              key={`${anime.id}-${index}`}
              anime={anime}
              focusId={`${title.toLowerCase().replace(/\s+/g, '-')}-card-${index}`}
              onSelect={() => onItemSelect(anime)}
              onPlay={onItemPlay ? () => onItemPlay(anime) : undefined}
              size={cardSize}
              className="tv-carousel__item"
            />
          ))}
        </div>
        <ScrollBar orientation="horizontal" />
      </ScrollArea>
    </div>
  );
};

export default TVCarousel;