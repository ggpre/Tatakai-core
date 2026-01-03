import { useQuery } from '@tanstack/react-query';

interface Season {
  id: string;
  name: string;
  title: string;
  poster: string;
  isCurrent: boolean;
}

interface SeasonsResponse {
  seasons: Season[];
}

export function useAnimeSeasons(animeId: string | undefined) {
  return useQuery({
    queryKey: ['anime-seasons', animeId],
    queryFn: async (): Promise<Season[]> => {
      if (!animeId) return [];

      try {
        // First try to get seasons from the anime info
        const res = await fetch(`https://api.anime-world.co/api/v2/hianime/anime/${animeId}`);
        if (!res.ok) throw new Error('Failed to fetch');
        
        const data = await res.json();
        
        // Check if there are seasons in the related animes
        const relatedAnimes = data.data?.relatedAnimes || [];
        
        // Filter for seasons (usually marked as "Sequel", "Prequel", or similar)
        const seasonRelations = ['Sequel', 'Prequel', 'Parent story', 'Side story', 'Alternative version'];
        
        const seasons = relatedAnimes
          .filter((anime: any) => 
            seasonRelations.some(rel => 
              anime.type?.toLowerCase().includes(rel.toLowerCase()) ||
              anime.name?.toLowerCase().includes('season') ||
              anime.name?.toLowerCase().includes('part')
            ) ||
            // Also check if same series by name similarity
            isSameSeries(data.data?.anime?.info?.name, anime.name)
          )
          .map((anime: any) => ({
            id: anime.id,
            name: anime.name,
            title: anime.name,
            poster: anime.poster,
            isCurrent: anime.id === animeId,
          }));

        // Add current anime to seasons list
        const currentAnime = {
          id: animeId,
          name: data.data?.anime?.info?.name || '',
          title: data.data?.anime?.info?.name || '',
          poster: data.data?.anime?.info?.poster || '',
          isCurrent: true,
        };

        // Check if current anime is already in the list
        if (!seasons.some((s: Season) => s.id === animeId)) {
          seasons.push(currentAnime);
        }

        // Sort by name to get proper season order
        seasons.sort((a: Season, b: Season) => {
          // Extract season numbers if present
          const aNum = extractSeasonNumber(a.name);
          const bNum = extractSeasonNumber(b.name);
          
          if (aNum !== null && bNum !== null) {
            return aNum - bNum;
          }
          return a.name.localeCompare(b.name);
        });

        return seasons;
      } catch (error) {
        console.error('Failed to fetch seasons:', error);
        return [];
      }
    },
    enabled: !!animeId,
    staleTime: 1000 * 60 * 30, // 30 minutes
  });
}

// Helper to check if two anime names are from the same series
function isSameSeries(name1: string | undefined, name2: string | undefined): boolean {
  if (!name1 || !name2) return false;
  
  // Normalize names
  const normalize = (str: string) => str
    .toLowerCase()
    .replace(/season \d+/gi, '')
    .replace(/part \d+/gi, '')
    .replace(/\d+(st|nd|rd|th) season/gi, '')
    .replace(/[^a-z0-9]/g, '')
    .trim();

  const n1 = normalize(name1);
  const n2 = normalize(name2);

  // Check if base names are similar
  return n1.includes(n2) || n2.includes(n1) || n1 === n2;
}

// Helper to extract season number from name
function extractSeasonNumber(name: string): number | null {
  // Match patterns like "Season 2", "2nd Season", "Part 3", etc.
  const patterns = [
    /season (\d+)/i,
    /(\d+)(st|nd|rd|th) season/i,
    /part (\d+)/i,
    /\s+(\d+)$/,
  ];

  for (const pattern of patterns) {
    const match = name.match(pattern);
    if (match) {
      return parseInt(match[1], 10);
    }
  }

  return null;
}
