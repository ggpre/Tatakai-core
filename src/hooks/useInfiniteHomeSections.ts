import { useInfiniteQuery } from '@tanstack/react-query';
import { fetchGenreAnimes, AnimeCard } from '@/lib/api';

// Section types for unique layouts
export type SectionLayout = 'grid' | 'carousel' | 'featured' | 'compact' | 'masonry';

export interface HomeSection {
  id: string;
  title: string;
  genre: string;
  layout: SectionLayout;
  animes: AnimeCard[];
  icon?: string;
}

// Predefined section configurations with unique layouts
const SECTION_CONFIGS: Array<{ genre: string; layout: SectionLayout; icon?: string }> = [
  { genre: 'action', layout: 'grid', icon: '⚔️' },
  { genre: 'romance', layout: 'carousel', icon: '💕' },
  { genre: 'comedy', layout: 'featured', icon: '😂' },
  { genre: 'fantasy', layout: 'masonry', icon: '✨' },
  { genre: 'sci-fi', layout: 'compact', icon: '🚀' },
  { genre: 'horror', layout: 'grid', icon: '👻' },
  { genre: 'slice-of-life', layout: 'carousel', icon: '🌸' },
  { genre: 'adventure', layout: 'featured', icon: '🗺️' },
  { genre: 'drama', layout: 'masonry', icon: '🎭' },
  { genre: 'supernatural', layout: 'compact', icon: '👁️' },
  { genre: 'sports', layout: 'grid', icon: '⚽' },
  { genre: 'music', layout: 'carousel', icon: '🎵' },
  { genre: 'mystery', layout: 'featured', icon: '🔍' },
  { genre: 'psychological', layout: 'masonry', icon: '🧠' },
  { genre: 'thriller', layout: 'compact', icon: '😱' },
  { genre: 'mecha', layout: 'grid', icon: '🤖' },
  { genre: 'historical', layout: 'carousel', icon: '📜' },
  { genre: 'isekai', layout: 'featured', icon: '🌀' },
  { genre: 'shounen', layout: 'masonry', icon: '💪' },
  { genre: 'seinen', layout: 'compact', icon: '🎯' },
];

// Fetch a single genre section
async function fetchGenreSection(config: typeof SECTION_CONFIGS[0]): Promise<HomeSection> {
  try {
    const data = await fetchGenreAnimes(config.genre, 1);
    return {
      id: `section-${config.genre}-${Date.now()}`,
      title: data.genreName || config.genre.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
      genre: config.genre,
      layout: config.layout,
      animes: data.animes.slice(0, 12),
      icon: config.icon,
    };
  } catch (error) {
    console.warn(`Failed to fetch ${config.genre}:`, error);
    return {
      id: `section-${config.genre}-${Date.now()}`,
      title: config.genre.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
      genre: config.genre,
      layout: config.layout,
      animes: [],
      icon: config.icon,
    };
  }
}

// Hook for infinite scrolling home sections
export function useInfiniteHomeSections() {
  return useInfiniteQuery({
    queryKey: ['infiniteHomeSections'],
    queryFn: async ({ pageParam = 0 }) => {
      // Load 3 sections at a time
      const startIndex = pageParam * 3;
      const configs = SECTION_CONFIGS.slice(startIndex, startIndex + 3);
      
      if (configs.length === 0) {
        return { sections: [], nextPage: null };
      }
      
      const sections = await Promise.all(configs.map(fetchGenreSection));
      const validSections = sections.filter(s => s.animes.length > 0);
      
      return {
        sections: validSections,
        nextPage: startIndex + 3 < SECTION_CONFIGS.length ? pageParam + 1 : null,
      };
    },
    getNextPageParam: (lastPage) => lastPage.nextPage,
    initialPageParam: 0,
    staleTime: 10 * 60 * 1000, // 10 minutes
  });
}
