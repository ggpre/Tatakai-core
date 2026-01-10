import { useEffect, useRef, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { GlassPanel } from '@/components/ui/GlassPanel';
import { Button } from '@/components/ui/button';
import { AnimeCard, getProxiedImageUrl } from '@/lib/api';
import { useInfiniteHomeSections, type HomeSection, type SectionLayout } from '@/hooks/useInfiniteHomeSections';
import { Play, Star, Loader2, ChevronRight, Sparkles } from 'lucide-react';
import { cn } from '@/lib/utils';

interface SectionCardProps {
  anime: AnimeCard;
  size?: 'small' | 'medium' | 'large';
}

function SectionCard({ anime, size = 'medium' }: SectionCardProps) {
  const navigate = useNavigate();
  
  const sizeClasses = {
    small: 'aspect-[3/4]',
    medium: 'aspect-[3/4]',
    large: 'aspect-[2/3] md:aspect-[3/4]',
  };

  return (
    <GlassPanel
      hoverEffect
      className="group cursor-pointer overflow-hidden"
      onClick={() => navigate(`/anime/${anime.id}`)}
    >
      <div className={cn("relative", sizeClasses[size])}>
        <img
          src={getProxiedImageUrl(anime.poster)}
          alt={anime.name}
          className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-background via-transparent to-transparent" />
        
        {anime.type && (
          <div className="absolute top-3 left-3 px-2 py-1 rounded-md bg-primary/80 text-primary-foreground text-xs font-bold">
            {anime.type}
          </div>
        )}

        {anime.rating && (
          <div className="absolute top-3 right-3 flex items-center gap-1 px-2 py-1 rounded-md bg-background/80 backdrop-blur text-xs font-bold">
            <Star className="w-3 h-3 fill-amber text-amber" />
            {anime.rating}
          </div>
        )}

        <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
          <div className="w-12 h-12 rounded-full bg-foreground/90 flex items-center justify-center transform scale-75 group-hover:scale-100 transition-transform">
            <Play className="w-5 h-5 fill-background text-background ml-0.5" />
          </div>
        </div>

        <div className="absolute bottom-0 left-0 right-0 p-3">
          <h4 className="font-bold text-sm line-clamp-2 group-hover:text-primary transition-colors">
            {anime.name}
          </h4>
          <div className="flex gap-2 mt-1 text-xs text-muted-foreground">
            <span>SUB {anime.episodes.sub}</span>
            {anime.episodes.dub > 0 && <span>• DUB {anime.episodes.dub}</span>}
          </div>
        </div>
      </div>
    </GlassPanel>
  );
}

// Grid layout - standard 6 column grid
function GridLayout({ animes }: { animes: AnimeCard[] }) {
  return (
    <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
      {animes.slice(0, 6).map((anime, i) => (
        <motion.div
          key={anime.id}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: i * 0.05 }}
        >
          <SectionCard anime={anime} />
        </motion.div>
      ))}
    </div>
  );
}

// Carousel layout - horizontal scrolling
function CarouselLayout({ animes }: { animes: AnimeCard[] }) {
  return (
    <div className="flex gap-4 overflow-x-auto pb-4 snap-x snap-mandatory scrollbar-hide">
      {animes.slice(0, 10).map((anime, i) => (
        <motion.div
          key={anime.id}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: i * 0.05 }}
          className="flex-shrink-0 w-40 md:w-48 snap-start"
        >
          <SectionCard anime={anime} size="small" />
        </motion.div>
      ))}
    </div>
  );
}

// Featured layout - 1 large + 4 small
function FeaturedLayout({ animes }: { animes: AnimeCard[] }) {
  const navigate = useNavigate();
  if (animes.length === 0) return null;
  
  const featured = animes[0];
  const rest = animes.slice(1, 5);

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {/* Featured card */}
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="md:col-span-1 lg:row-span-2"
      >
        <GlassPanel
          hoverEffect
          className="group cursor-pointer overflow-hidden h-full"
          onClick={() => navigate(`/anime/${featured.id}`)}
        >
          <div className="relative h-full min-h-[400px]">
            <img
              src={getProxiedImageUrl(featured.poster)}
              alt={featured.name}
              className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-background via-background/30 to-transparent" />
            
            <div className="absolute bottom-0 left-0 right-0 p-6">
              <span className="px-3 py-1 rounded-full bg-primary text-primary-foreground text-xs font-bold mb-3 inline-block">
                Featured
              </span>
              <h3 className="font-bold text-xl line-clamp-2 mb-2">{featured.name}</h3>
              <div className="flex items-center gap-3 text-sm text-muted-foreground">
                {featured.type && <span>{featured.type}</span>}
                {featured.rating && (
                  <span className="flex items-center gap-1">
                    <Star className="w-3 h-3 fill-amber text-amber" />
                    {featured.rating}
                  </span>
                )}
              </div>
            </div>
          </div>
        </GlassPanel>
      </motion.div>

      {/* Smaller cards */}
      <div className="md:col-span-1 lg:col-span-2 grid grid-cols-2 gap-4">
        {rest.map((anime, i) => (
          <motion.div
            key={anime.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 + i * 0.05 }}
          >
            <SectionCard anime={anime} />
          </motion.div>
        ))}
      </div>
    </div>
  );
}

// Compact layout - small cards in a tight grid
function CompactLayout({ animes }: { animes: AnimeCard[] }) {
  return (
    <div className="grid grid-cols-3 md:grid-cols-6 lg:grid-cols-8 gap-3">
      {animes.slice(0, 8).map((anime, i) => (
        <motion.div
          key={anime.id}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: i * 0.03 }}
        >
          <SectionCard anime={anime} size="small" />
        </motion.div>
      ))}
    </div>
  );
}

// Masonry-like layout - varied sizes
function MasonryLayout({ animes }: { animes: AnimeCard[] }) {
  if (animes.length < 6) return <GridLayout animes={animes} />;

  return (
    <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 auto-rows-[200px]">
      {animes.slice(0, 6).map((anime, i) => {
        const isLarge = i === 0 || i === 3;
        return (
          <motion.div
            key={anime.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.05 }}
            className={cn(
              isLarge && 'row-span-2 col-span-1 md:col-span-2'
            )}
          >
            <SectionCard anime={anime} size={isLarge ? 'large' : 'medium'} />
          </motion.div>
        );
      })}
    </div>
  );
}

// Get layout component based on type
function getLayoutComponent(layout: SectionLayout) {
  switch (layout) {
    case 'carousel':
      return CarouselLayout;
    case 'featured':
      return FeaturedLayout;
    case 'compact':
      return CompactLayout;
    case 'masonry':
      return MasonryLayout;
    default:
      return GridLayout;
  }
}

// Single section component
function HomeSection({ section }: { section: HomeSection }) {
  const navigate = useNavigate();
  const LayoutComponent = getLayoutComponent(section.layout);

  if (section.animes.length === 0) return null;

  return (
    <motion.section
      initial={{ opacity: 0, y: 40 }}
      animate={{ opacity: 1, y: 0 }}
      className="mb-16"
    >
      <div className="flex items-center justify-between mb-6 px-2">
        <h3 className="font-display text-2xl font-semibold tracking-tight flex items-center gap-3">
          {section.icon && <span className="text-2xl">{section.icon}</span>}
          <span>{section.title}</span>
        </h3>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate(`/genre/${section.genre}`)}
          className="gap-1 text-muted-foreground hover:text-foreground"
        >
          View All
          <ChevronRight className="w-4 h-4" />
        </Button>
      </div>

      <LayoutComponent animes={section.animes} />
    </motion.section>
  );
}

// Main infinite sections component
export function InfiniteHomeSections() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
    error,
  } = useInfiniteHomeSections();

  const loadMoreRef = useRef<HTMLDivElement>(null);

  // Intersection Observer for infinite scroll
  const handleObserver = useCallback((entries: IntersectionObserverEntry[]) => {
    const target = entries[0];
    if (target.isIntersecting && hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  }, [fetchNextPage, hasNextPage, isFetchingNextPage]);

  useEffect(() => {
    const observer = new IntersectionObserver(handleObserver, {
      root: null,
      rootMargin: '200px',
      threshold: 0.1,
    });

    if (loadMoreRef.current) {
      observer.observe(loadMoreRef.current);
    }

    return () => observer.disconnect();
  }, [handleObserver]);

  if (error) {
    return null;
  }

  const allSections = data?.pages.flatMap(page => page.sections) || [];

  return (
    <div className="mt-16">
      {/* Section Header */}
      <div className="flex items-center gap-3 mb-10 px-2">
        <Sparkles className="w-6 h-6 text-primary" />
        <h2 className="font-display text-3xl font-bold">Explore by Genre</h2>
      </div>

      {/* Loading skeleton for initial load */}
      {isLoading && (
        <div className="space-y-16">
          {[...Array(2)].map((_, i) => (
            <div key={i} className="animate-pulse">
              <div className="h-8 bg-muted rounded w-48 mb-6" />
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                {[...Array(6)].map((_, j) => (
                  <div key={j} className="aspect-[3/4] bg-muted rounded-xl" />
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Rendered sections */}
      {allSections.map((section) => (
        <HomeSection key={section.id} section={section} />
      ))}

      {/* Load more trigger */}
      <div ref={loadMoreRef} className="h-20 flex items-center justify-center">
        {isFetchingNextPage && (
          <div className="flex items-center gap-3 text-muted-foreground">
            <Loader2 className="w-5 h-5 animate-spin" />
            <span>Loading more sections...</span>
          </div>
        )}
      </div>

      {/* End message */}
      {!hasNextPage && allSections.length > 0 && (
        <div className="text-center py-8 text-muted-foreground">
          <p>You've explored all genres! 🎉</p>
        </div>
      )}
    </div>
  );
}
