import { useQuery } from "@tanstack/react-query";
import { fetchStreamingSources, fetchWatchanimeworldSources, fetchAnimeHindiDubbedData, extractEmbedVideo } from "@/lib/api";
import type { StreamingData, StreamingSource } from "@/lib/api";
import { slugToSearchQuery, parseEpisodeUrl, stringSimilarity } from "@/integrations/watchanimeworld";
import { parseEpisodeNumber } from "@/integrations/animehindidubbed";

/**
 * Combined hook that fetches HiAnime, WatchAnimeWorld, and AnimeHindiDubbed sources
 */
export function useCombinedSources(
  episodeId: string | undefined,
  animeName: string | undefined,
  episodeNumber: number | undefined,
  server: string = "hd-2",
  category: string = "sub"
) {
  return useQuery<StreamingData & { hasWatchAnimeWorld: boolean; hasAnimeHindiDubbed: boolean }, Error>({
    queryKey: ["combined-sources", episodeId, animeName, episodeNumber, server, category],
    queryFn: async () => {
      if (!episodeId) throw new Error("Episode ID required");

      // Fetch HiAnime sources
      const hiAnimeData = await fetchStreamingSources(episodeId, server, category);

      // Try to find and fetch WatchAnimeWorld sources
      let watchAwSources: StreamingSource[] = [];
      let hasWatchAnimeWorld = false;
      
      // Try to find and fetch AnimeHindiDubbed sources
      let animeHindiSources: StreamingSource[] = [];
      let hasAnimeHindiDubbed = false;

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

      // Try to fetch AnimeHindiDubbed sources
      if (episodeId && episodeNumber !== undefined) {
        try {
          const baseSlug = episodeId.split('?')[0];
          const animeSlug = baseSlug.replace(/-\d+$/, '');
          
          console.log('AnimeHindiDubbed: animeSlug=', animeSlug, 'episodeNumber=', episodeNumber);
          
          if (animeSlug) {
            const animeData = await fetchAnimeHindiDubbedData(animeSlug);
            
            // Convert episode number to format used by AnimeHindiDubbed
            // Try simple format first ("01", "02", etc.)
            const episodeKey = episodeNumber.toString().padStart(2, '0');
            
            // Find episode in Berlin server (Servabyss)
            const berlinEpisode = animeData.servers.servabyss?.find(
              ep => ep.name === episodeKey || 
                    parseEpisodeNumber(ep.name)?.episode === episodeNumber
            );
            
            // Find episode in Madrid server (Vidgroud)
            const madridEpisode = animeData.servers.vidgroud?.find(
              ep => ep.name === episodeKey || 
                    parseEpisodeNumber(ep.name)?.episode === episodeNumber
            );
            
            if (berlinEpisode) {
              animeHindiSources.push({
                url: berlinEpisode.url,
                isM3U8: false,
                quality: '720p',
                language: 'Berlin',
                langCode: 'berlin',
                isDub: true,
                providerName: 'Berlin',
                isEmbed: true,
                needsHeadless: true,
              });
              hasAnimeHindiDubbed = true;
              console.log('Found Berlin (Servabyss) source for episode', episodeNumber);
            }
            
            if (madridEpisode) {
              animeHindiSources.push({
                url: madridEpisode.url,
                isM3U8: false,
                quality: '720p',
                language: 'Madrid',
                langCode: 'madrid',
                isDub: true,
                providerName: 'Madrid',
                isEmbed: true,
                needsHeadless: true,
              });
              hasAnimeHindiDubbed = true;
              console.log('Found Madrid (Vidgroud) source for episode', episodeNumber);
            }
          }
        } catch (error) {
          console.warn('Failed to fetch AnimeHindiDubbed sources:', error);
          // Silently fail - just don't show AnimeHindiDubbed sources
        }
      }

      // Combine sources
      const combinedSources = [...hiAnimeData.sources, ...watchAwSources, ...animeHindiSources];

      // Try to extract direct video URLs from embed sources using Puppeteer service
      const processedSources: StreamingSource[] = [];
      
      for (const source of combinedSources) {
        // Only process embed sources (WatchAnimeWorld, AnimeHindiDubbed)
        if (source.isEmbed && source.url) {
          try {
            console.log(`[Extractor] Attempting to extract from: ${source.url}`);
            
            const extraction = await extractEmbedVideo(source.url, 30000);
            
            if (extraction.success && extraction.sources && extraction.sources.length > 0) {
              console.log(`[Extractor] Successfully extracted ${extraction.sources.length} source(s)`);
              
              // Convert extracted sources to StreamingSource format and add both direct + fallback iframe
              for (const extracted of extraction.sources) {
                // Skip Google Cloud Storage URLs with billing issues
                if (extracted.url.includes('storage.googleapis.com')) {
                  console.warn(`[Extractor] Skipping Google Storage URL (likely billing/auth issue): ${extracted.url}`);
                  continue;
                }
                
                processedSources.push({
                  url: extracted.url,
                  isM3U8: extracted.type === 'hls',
                  quality: extracted.quality || source.quality || '720p',
                  language: source.language,
                  langCode: source.langCode,
                  isDub: source.isDub,
                  providerName: `${source.providerName} (Direct)`,
                  isEmbed: false,
                  needsHeadless: false,
                });
              }
              
              // Also keep original embed as fallback
              processedSources.push({
                ...source,
                providerName: `${source.providerName} (Embed)`,
              });
            } else {
              // Extraction failed, keep as embed source (will use iframe)
              console.log(`[Extractor] Failed to extract from ${source.providerName}: ${extraction.error || 'No sources found'}`);
              processedSources.push(source);
            }
          } catch (error) {
            // On error, keep original embed source
            console.warn(`[Extractor] Error processing embed:`, error);
            processedSources.push(source);
          }
        } else {
          // Non-embed sources pass through unchanged
          processedSources.push(source);
        }
      }

      return {
        ...hiAnimeData,
        sources: processedSources,
        hasWatchAnimeWorld,
        hasAnimeHindiDubbed,
      };
    },
    enabled: !!episodeId,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}
