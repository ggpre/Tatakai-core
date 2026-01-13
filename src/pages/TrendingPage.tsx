import { Background } from "@/components/layout/Background";
import { Sidebar } from "@/components/layout/Sidebar";
import { MobileNav } from "@/components/layout/MobileNav";
import { AnimeCardWithPreview } from "@/components/anime/AnimeCardWithPreview";
import { Skeleton } from "@/components/ui/skeleton-custom";
import { useTrendingAnime, formatViewCount } from "@/hooks/useViews";
import { fetchHome, TrendingAnime as ApiTrendingAnime, AnimeCard } from "@/lib/api";
import { Flame, TrendingUp, Clock, Sparkles } from "lucide-react";
import { Sparkline } from '@/components/ui/Sparkline';
import { useState } from "react";
import { useQuery } from "@tanstack/react-query";

type TimeFrame = 'today' | 'week' | 'month' | 'all';

// Convert API trending anime to AnimeCard format for our component
function trendingToCard(trending: ApiTrendingAnime): AnimeCard {
  return {
    id: trending.id,
    name: trending.name,
    poster: trending.poster,
    type: 'TV',
    episodes: { sub: 0, dub: 0 },
    rating: undefined,
  };
}

export default function TrendingPage() {
  const [timeFrame, setTimeFrame] = useState<TimeFrame>('week');

  // Use improved trending RPC with timeframe
  const { data: internalTrending, isLoading: loadingInternal } = useTrendingAnime(50, timeFrame);

  // Fallback to API trending
  const { data: homepageData, isLoading: loadingHomepage } = useQuery({
    queryKey: ['homepage'],
    queryFn: fetchHome,
    staleTime: 300000,
  });

  const isLoading = loadingInternal || loadingHomepage;

  // If we have internal trending data, use it; otherwise fall back to API
  const hasInternalData = internalTrending && internalTrending.length > 0;

  // Get anime cards from API homepage data
  const apiTrending = homepageData?.trendingAnimes || [];

  const timeFrameButtons: { id: TimeFrame; label: string; icon: React.ReactNode }[] = [
    { id: 'today', label: 'Today', icon: <Clock className="w-4 h-4" /> },
    { id: 'week', label: 'This Week', icon: <TrendingUp className="w-4 h-4" /> },
    { id: 'month', label: 'This Month', icon: <Flame className="w-4 h-4" /> },
    { id: 'all', label: 'All Time', icon: <Sparkles className="w-4 h-4" /> },
  ];


  return (
    <div className="min-h-screen bg-background text-foreground overflow-x-hidden">
      <Background />
      <Sidebar />

      <main className="relative z-10 pl-4 md:pl-32 pr-4 md:pr-6 py-4 md:py-6 max-w-[1800px] mx-auto pb-24 md:pb-6">
        {/* Header */}
        <div className="mb-6 md:mb-8">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-3 rounded-xl bg-gradient-to-br from-orange-500 to-red-500">
              <Flame className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl md:text-3xl font-bold">Trending Anime</h1>
              <p className="text-muted-foreground text-sm">
                See what everyone's watching right now
              </p>
            </div>
          </div>

          {/* Time Frame Selector */}
          <div className="flex flex-wrap gap-2">
            {timeFrameButtons.map(btn => (
              <button
                key={btn.id}
                onClick={() => setTimeFrame(btn.id)}
                className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all ${
                  timeFrame === btn.id
                    ? 'bg-primary text-primary-foreground shadow-lg shadow-primary/25'
                    : 'bg-card/60 hover:bg-card text-muted-foreground hover:text-foreground border border-border/30'
                }`}
              >
                {btn.icon}
                {btn.label}
              </button>
            ))}
          </div>
        </div>

        {/* Stats Bar */}
        {hasInternalData && (
          <div className="mb-6 p-4 rounded-xl bg-gradient-to-r from-orange-500/10 via-red-500/10 to-pink-500/10 border border-orange-500/20">
            <div className="flex flex-wrap gap-6 text-sm">
              <div className="flex items-center gap-2">
                <TrendingUp className="w-4 h-4 text-orange-500" />
                <span className="text-muted-foreground">Tracking</span>
                <span className="font-bold">{internalTrending.length}</span>
                <span className="text-muted-foreground">anime</span>
              </div>
              <div className="flex items-center gap-2">
                <Flame className="w-4 h-4 text-red-500" />
                <span className="text-muted-foreground">Top anime has</span>
                <span className="font-bold">
                  {formatViewCount(internalTrending[0]?.views_week || 0)}
                </span>
                <span className="text-muted-foreground">weekly views</span>
              </div>
            </div>
          </div>
        )}

        {/* Content */}
        {isLoading ? (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3 md:gap-4">
            {Array.from({ length: 18 }).map((_, i) => (
              <Skeleton key={i} className="aspect-[3/4] rounded-xl" />
            ))}
          </div>
        ) : hasInternalData ? (
          <div className="space-y-6">
            <div className="text-center py-4 text-muted-foreground">
              <p>View-based trending is being calculated using recent views, completion, and favorites.</p>
              <p className="text-sm mt-2">Showing community-driven trending with timeframe set to <strong>{timeFrame}</strong>.</p>
            </div>

            {/* Internal Trending Grid with sparklines */}
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4 md:gap-5">
              {internalTrending.map((t: any, index: number) => (
                <div key={t.anime_id} className="relative group">
                  <div className="absolute -top-3 -left-3 z-20 w-10 h-10 rounded-full bg-gradient-to-br from-orange-500 via-red-500 to-pink-500 flex items-center justify-center text-white text-sm font-bold shadow-2xl shadow-orange-500/50 ring-2 ring-background group-hover:scale-110 transition-transform duration-300">
                    {index + 1}
                  </div>

                  <div className="hover:scale-[1.02] transition-transform duration-300">
                    <AnimeCardWithPreview anime={trendingToCard({ id: t.anime_id, name: t.anime_id, poster: '' })} />

                    <div className="mt-2 flex items-center justify-between px-2">
                      <div className="text-xs text-muted-foreground">{formatViewCount(t.views_week || t.views_window || 0)} views</div>
                      <div className="w-20">
                        <Sparkline series={t.sparkline as any} />
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4 md:gap-5">
            {apiTrending.map((anime, index) => (
              <div key={anime.id} className="relative group">
                {/* Rank Badge with glow */}
                <div className="absolute -top-3 -left-3 z-20 w-10 h-10 rounded-full bg-gradient-to-br from-orange-500 via-red-500 to-pink-500 flex items-center justify-center text-white text-sm font-bold shadow-2xl shadow-orange-500/50 ring-2 ring-background group-hover:scale-110 transition-transform duration-300">
                  {index + 1}
                </div>
                <div className="hover:scale-[1.02] transition-transform duration-300">
                  <AnimeCardWithPreview anime={trendingToCard(anime)} />
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      <MobileNav />
    </div>
  );
}
