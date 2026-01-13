import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Background } from "@/components/layout/Background";
import { Sidebar } from "@/components/layout/Sidebar";
import { MobileNav } from "@/components/layout/MobileNav";
import { Header } from "@/components/layout/Header";
import { AnimeGrid } from "@/components/anime/AnimeGrid";
import { useQuery } from "@tanstack/react-query";
import { fetchHome } from "@/lib/api";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { CardSkeleton } from "@/components/ui/skeleton-custom";
import { ArrowLeft, TrendingUp, Star, Clock, Flame, Heart } from "lucide-react";

export default function CollectionsPage() {
  const navigate = useNavigate();
  const { data, isLoading } = useQuery({
    queryKey: ['home'],
    queryFn: fetchHome,
    staleTime: 5 * 60 * 1000,
  });

  const [activeTab, setActiveTab] = useState("trending");

  return (
    <div className="min-h-screen bg-background text-foreground overflow-x-hidden">
      <Background />
      <Sidebar />

      <main className="relative z-10 pl-6 md:pl-32 pr-6 py-6 max-w-[1800px] mx-auto pb-24 md:pb-6">
        <Header />
        
        {/* Back Button */}
        <button
          onClick={() => navigate(-1)}
          className="flex items-center gap-2 text-muted-foreground hover:text-foreground transition-colors mb-6"
        >
          <ArrowLeft className="w-5 h-5" />
          <span>Back</span>
        </button>

        {/* Page Title */}
        <div className="mb-8">
          <h1 className="text-3xl md:text-4xl font-black tracking-tight mb-2">
            Anime Collections
          </h1>
          <p className="text-muted-foreground">
            Explore our curated collections of anime
          </p>
        </div>

        {/* Tabs for different collections */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-2 md:grid-cols-5 gap-2 mb-8">
            <TabsTrigger value="trending" className="gap-2">
              <TrendingUp className="w-4 h-4" />
              Trending
            </TabsTrigger>
            <TabsTrigger value="popular" className="gap-2">
              <Flame className="w-4 h-4" />
              Most Popular
            </TabsTrigger>
            <TabsTrigger value="favorites" className="gap-2">
              <Heart className="w-4 h-4" />
              Most Favorite
            </TabsTrigger>
            <TabsTrigger value="airing" className="gap-2">
              <Star className="w-4 h-4" />
              Top Airing
            </TabsTrigger>
            <TabsTrigger value="completed" className="gap-2">
              <Clock className="w-4 h-4" />
              Latest Completed
            </TabsTrigger>
          </TabsList>

          <TabsContent value="trending" className="mt-0">
            {isLoading ? (
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                {Array.from({ length: 12 }).map((_, i) => (
                  <CardSkeleton key={i} />
                ))}
              </div>
            ) : (
              <AnimeGrid 
                animes={data?.trendingAnimes || []} 
                title="Trending Anime"
                showTitle={false}
              />
            )}
          </TabsContent>

          <TabsContent value="popular" className="mt-0">
            {isLoading ? (
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                {Array.from({ length: 12 }).map((_, i) => (
                  <CardSkeleton key={i} />
                ))}
              </div>
            ) : (
              <AnimeGrid 
                animes={data?.mostPopularAnimes || []} 
                title="Most Popular Anime"
                showTitle={false}
              />
            )}
          </TabsContent>

          <TabsContent value="favorites" className="mt-0">
            {isLoading ? (
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                {Array.from({ length: 12 }).map((_, i) => (
                  <CardSkeleton key={i} />
                ))}
              </div>
            ) : (
              <AnimeGrid 
                animes={data?.mostFavoriteAnimes || []} 
                title="Most Favorite Anime"
                showTitle={false}
              />
            )}
          </TabsContent>

          <TabsContent value="airing" className="mt-0">
            {isLoading ? (
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                {Array.from({ length: 12 }).map((_, i) => (
                  <CardSkeleton key={i} />
                ))}
              </div>
            ) : (
              <AnimeGrid 
                animes={data?.topAiringAnimes || []} 
                title="Top Airing Anime"
                showTitle={false}
              />
            )}
          </TabsContent>

          <TabsContent value="completed" className="mt-0">
            {isLoading ? (
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                {Array.from({ length: 12 }).map((_, i) => (
                  <CardSkeleton key={i} />
                ))}
              </div>
            ) : (
              <AnimeGrid 
                animes={data?.latestCompletedAnimes || []} 
                title="Latest Completed Anime"
                showTitle={false}
              />
            )}
          </TabsContent>
        </Tabs>
      </main>

      <MobileNav />
    </div>
  );
}
