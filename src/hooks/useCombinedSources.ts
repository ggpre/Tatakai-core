import { useQuery } from "@tanstack/react-query";
import { fetchStreamingSources, fetchWatchanimeworldSources } from "@/lib/api";
import type { StreamingData, StreamingSource } from "@/lib/api";
import { slugToSearchQuery, parseEpisodeUrl, stringSimilarity } from "@/integrations/watchanimeworld";

/**
 * Combined hook that fetches both HiAnime and WatchAnimeWorld sources
 */
export function useCombinedSources(
  episodeId: string | undefined,
  animeName: string | undefined,
  episodeNumber: number | undefined,
  server: string = "hd-2",
  category: string = "sub"
) {
  return useQuery<StreamingData & { hasWatchAnimeWorld: boolean }, Error>({
    queryKey: ["combined-sources", episodeId, animeName, episodeNumber, server, category],
    queryFn: async () => {
      if (!episodeId) throw new Error("Episode ID required");

      // Fetch HiAnime sources
      const hiAnimeData = await fetchStreamingSources(episodeId, server, category);

      // Try to find and fetch WatchAnimeWorld sources
      let watchAwSources: StreamingSource[] = [];
      let hasWatchAnimeWorld = false;

      if (episodeId && episodeNumber !== undefined) {
        try {
          // Extract anime slug from episodeId (format: "anime-slug-355?ep=7882")
          // NOTE: The number in the slug (355) is the HiAnime anime ID, NOT the episode number!
          // The actual episode number comes from episodeNumber parameter
          
          const baseSlug = episodeId.split('?')[0]; // Remove ?ep= part
          
          // Remove the trailing anime ID number to get just the anime name slug
          // e.g., "naruto-shippuden-355" -> "naruto-shippuden"
          const animeSlug = baseSlug.replace(/-\d+$/, '');
          
          console.log('WatchAnimeWorld: episodeId=', episodeId, 'animeSlug=', animeSlug, 'episodeNumber=', episodeNumber);
          
          if (!animeSlug) {
            throw new Error('Could not determine anime slug');
          }
          
          const watchAwSlug = `${animeSlug}-1x${episodeNumber}`;
          
          console.log('Attempting to fetch WatchAnimeWorld sources for:', watchAwSlug);
          
          const watchAwData = await fetchWatchanimeworldSources(watchAwSlug);
          
          console.log('WatchAnimeWorld API returned:', watchAwData.sources.length, 'sources');
          
          // Include all sources with valid URLs
          // Sources with needsHeadless=true will be played via iframe embed
          // Sources with isM3U8=true can be played directly
          const validSources = watchAwData.sources.filter(source => {
            return source.url && source.url.length > 0;
          }).map(source => ({
            ...source,
            // Mark as embed type for iframe playback if not m3u8
            isEmbed: !source.isM3U8 && source.needsHeadless,
          }));

          if (validSources.length > 0) {
            watchAwSources = validSources;
            hasWatchAnimeWorld = true;
            console.log(`Found ${validSources.length} valid WatchAnimeWorld sources`);
          } else {
            console.log('No valid WatchAnimeWorld sources found');
          }
        } catch (error) {
          console.warn('Failed to fetch WatchAnimeWorld sources:', error);
          // Silently fail - just don't show WatchAnimeWorld sources
        }
      }

      // Combine sources
      const combinedSources = [...hiAnimeData.sources, ...watchAwSources];

      return {
        ...hiAnimeData,
        sources: combinedSources,
        hasWatchAnimeWorld,
      };
    },
    enabled: !!episodeId,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}
