import { Background } from "@/components/layout/Background";
import { Sidebar } from "@/components/layout/Sidebar";
import { MobileNav } from "@/components/layout/MobileNav";
import { AnimeCardWithPreview } from "@/components/anime/AnimeCardWithPreview";
import { Skeleton } from "@/components/ui/skeleton-custom";
import { usePersonalizedRecommendations, useGenrePreferences } from "@/hooks/useRecommendations";
import { useWatchlist, useBulkRemoveFromWatchlist } from "@/hooks/useWatchlist";
import { useAuth } from "@/contexts/AuthContext";
import { Heart, Sparkles, TrendingUp, BookOpen, CheckCircle, Clock, Pause, X, Filter } from "lucide-react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { getProxiedImageUrl } from "@/lib/api";

type TabType = 'for-you' | 'all' | 'watching' | 'completed' | 'plan' | 'on-hold' | 'dropped';

const TABS: { id: TabType; label: string; icon: React.ReactNode }[] = [
  { id: 'for-you', label: 'For You', icon: <Sparkles className="w-4 h-4" /> },
  { id: 'all', label: 'All', icon: <BookOpen className="w-4 h-4" /> },
  { id: 'watching', label: 'Watching', icon: <TrendingUp className="w-4 h-4" /> },
  { id: 'completed', label: 'Completed', icon: <CheckCircle className="w-4 h-4" /> },
  { id: 'plan', label: 'Plan to Watch', icon: <Clock className="w-4 h-4" /> },
  { id: 'on-hold', label: 'On Hold', icon: <Pause className="w-4 h-4" /> },
  { id: 'dropped', label: 'Dropped', icon: <X className="w-4 h-4" /> },
];

const STATUS_MAP: Record<TabType, string | null> = {
  'for-you': null,
  'all': null,
  'watching': 'watching',
  'completed': 'completed',
  'plan': 'plan_to_watch',
  'on-hold': 'on_hold',
  'dropped': 'dropped',
};

export default function FavoritesPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>('for-you');
  const [sortBy, setSortBy] = useState<'recent' | 'alpha' | 'favorites'>('recent');
  const [selectMode, setSelectMode] = useState(false);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  
  const { data: recommendations, isLoading: loadingRecs } = usePersonalizedRecommendations(24);
  const { data: genrePrefs } = useGenrePreferences();
  const { data: watchlist, isLoading: loadingWatchlist } = useWatchlist();
  const bulkRemove = useBulkRemoveFromWatchlist();
  
  // Filter watchlist by status
  const filteredWatchlist = watchlist?.filter(item => {
    if (activeTab === 'all') return true;
    const statusFilter = STATUS_MAP[activeTab];
    return statusFilter ? item.status === statusFilter : true;
  }) || [];
  
  // Show for-you tab content
  const showRecommendations = activeTab === 'for-you';
  const isLoading = showRecommendations ? loadingRecs : loadingWatchlist;

  if (!user) {
    return (
      <div className="min-h-screen bg-background text-foreground overflow-x-hidden">
        <Background />
        <Sidebar />
        
        <main className="relative z-10 pl-4 md:pl-32 pr-4 md:pr-6 py-4 md:py-6 max-w-[1800px] mx-auto pb-24 md:pb-6">
          <div className="flex flex-col items-center justify-center min-h-[60vh] text-center">
            <Heart className="w-16 h-16 text-muted-foreground mb-4" />
            <h1 className="text-2xl font-bold mb-2">Your Favorites</h1>
            <p className="text-muted-foreground mb-6">
              Sign in to see personalized recommendations and manage your watchlist
            </p>
            <button
              onClick={() => navigate('/auth')}
              className="px-6 py-3 rounded-xl bg-primary text-primary-foreground font-medium hover:bg-primary/90 transition-colors"
            >
              Sign In
            </button>
          </div>
        </main>
        
        <MobileNav />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background text-foreground overflow-x-hidden">
      <Background />
      <Sidebar />

      <main className="relative z-10 pl-4 md:pl-32 pr-4 md:pr-6 py-4 md:py-6 max-w-[1800px] mx-auto pb-24 md:pb-6">
        {/* Header */}
        <div className="mb-6 md:mb-8">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-3 rounded-xl bg-gradient-to-br from-pink-500 to-rose-500">
              <Heart className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl md:text-3xl font-bold">My Favorites</h1>
              <p className="text-muted-foreground text-sm">
                {showRecommendations 
                  ? 'Personalized recommendations based on your taste'
                  : `${filteredWatchlist.length} anime in your list`
                }
              </p>
            </div>
          </div>

          {/* Tabs and actions */}
          <div className="flex items-center justify-between gap-4 mb-2">
            <div className="flex flex-wrap gap-2 overflow-x-auto pb-2">
              {TABS.map(tab => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all whitespace-nowrap ${
                    activeTab === tab.id
                      ? 'bg-primary text-primary-foreground shadow-lg shadow-primary/25'
                      : 'bg-card/60 hover:bg-card text-muted-foreground hover:text-foreground border border-border/30'
                  }`}
                >
                  {tab.icon}
                  {tab.label}
                  {tab.id !== 'for-you' && watchlist && (
                    <span className="ml-1 text-xs opacity-70">
                      ({tab.id === 'all' 
                        ? watchlist.length 
                        : watchlist.filter(w => w.status === STATUS_MAP[tab.id]).length
                      })
                    </span>
                  )}
                </button>
              ))}
            </div>

            <div className="flex items-center gap-2">
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as any)}
                className="bg-card/80 text-sm px-3 py-2 rounded-lg border border-border/30"
              >
                <option value="recent">Recently Updated</option>
                <option value="alpha">Alphabetical</option>
                <option value="favorites">Most Favorited</option>
              </select>

              <button
                onClick={() => setSelectMode(v => !v)}
                className={`px-3 py-2 rounded-lg text-sm ${selectMode ? 'bg-primary text-primary-foreground' : 'bg-card/80 text-muted-foreground'}`}
              >
                {selectMode ? 'Cancel' : 'Select'}
              </button>

              {selectMode && (
                <button
                  onClick={async () => {
                    if (selectedIds.length === 0) return;
                    if (!confirm(`Delete ${selectedIds.length} items from your watchlist?`)) return;
                    await bulkRemove.mutateAsync(selectedIds);
                    setSelectedIds([]);
                    setSelectMode(false);
                  }}
                  className="px-3 py-2 rounded-lg bg-destructive text-destructive-foreground text-sm"
                >
                  Delete Selected
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Genre Preferences - only show on For You tab */}
        {showRecommendations && genrePrefs && genrePrefs.length > 0 && (
          <div className="mb-6 p-4 rounded-xl bg-gradient-to-r from-pink-500/10 via-purple-500/10 to-indigo-500/10 border border-pink-500/20">
            <div className="flex items-center gap-2 mb-3">
              <Filter className="w-4 h-4 text-pink-500" />
              <span className="text-sm font-medium">Your Top Genres</span>
            </div>
            <div className="flex flex-wrap gap-2">
              {genrePrefs.slice(0, 8).map(pref => (
                <button
                  key={pref.genre}
                  onClick={() => navigate(`/genre/${encodeURIComponent(pref.genre)}`)}
                  className="px-3 py-1 rounded-full text-xs bg-card/80 hover:bg-card border border-border/30 transition-colors"
                >
                  {pref.genre}
                  <span className="ml-1 text-muted-foreground">({pref.count})</span>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Content */}
        {isLoading ? (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3 md:gap-4">
            {Array.from({ length: 12 }).map((_, i) => (
              <Skeleton key={i} className="aspect-[3/4] rounded-xl" />
            ))}
          </div>
        ) : showRecommendations ? (
          recommendations && recommendations.length > 0 ? (
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3 md:gap-4">
              {recommendations.map((rec, index) => (
                <div key={rec.anime.id} className="relative group">
                  <AnimeCardWithPreview anime={rec.anime} />
                  {/* Recommendation reason tooltip */}
                  <div className="absolute bottom-0 left-0 right-0 p-2 bg-gradient-to-t from-background via-background/80 to-transparent opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">
                    <p className="text-xs text-primary truncate">{rec.reason}</p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-12">
              <Sparkles className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-medium mb-2">Building Your Recommendations</h3>
              <p className="text-muted-foreground text-sm max-w-md mx-auto">
                Add more anime to your watchlist or watch more episodes to get personalized recommendations.
              </p>
            </div>
          )
        ) : filteredWatchlist.length > 0 ? (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4 md:gap-5">
            {filteredWatchlist.map(item => (
              <div 
                key={item.id} 
                className="relative group"
              >
                <div className="aspect-[3/4] rounded-2xl overflow-hidden border-2 border-border/40 bg-card/80 backdrop-blur-sm shadow-lg hover:shadow-2xl hover:shadow-primary/20 transition-all duration-300 hover:-translate-y-1">
                  <img
                    src={getProxiedImageUrl(item.anime_poster || '')}
                    alt={item.anime_name}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                    onClick={() => navigate(`/anime/${item.anime_id}`)}
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-background via-background/50 to-transparent opacity-90 group-hover:opacity-70 transition-opacity" />
                  
                  {/* Status badge */}
                  <div className="absolute top-3 right-3 px-3 py-1 rounded-full bg-primary/90 backdrop-blur-sm text-xs font-semibold text-primary-foreground capitalize shadow-lg">
                    {item.status.replace('_', ' ')}
                  </div>
                  
                  <div className="absolute bottom-0 left-0 right-0 p-4 flex items-center justify-between gap-2">
                    <h4 className="font-bold text-sm md:text-base line-clamp-2 group-hover:text-primary transition-colors drop-shadow-lg">
                      {item.anime_name}
                    </h4>
                    {selectMode && (
                      <input
                        type="checkbox"
                        checked={selectedIds.includes(item.anime_id)}
                        onChange={(e) => {
                          if (e.target.checked) setSelectedIds(s => [...s, item.anime_id]);
                          else setSelectedIds(s => s.filter(id => id !== item.anime_id));
                        }}
                        className="w-4 h-4"
                      />
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <BookOpen className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-medium mb-2">No Anime Here Yet</h3>
            <p className="text-muted-foreground text-sm">
              {activeTab === 'all' 
                ? 'Start adding anime to your watchlist!'
                : `No anime with this status yet.`
              }
            </p>
          </div>
        )}
      </main>

      <MobileNav />
    </div>
  );
}
