'use client';

import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import HeroSection from '@/components/HeroSection';
import AnimeCarousel from '@/components/AnimeCarousel';
import Top10Section from '@/components/Top10Section';
import { AnimeAPI, type HomePageData } from '@/lib/api';
import { Skeleton } from '@/components/ui/skeleton';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { AlertCircle } from 'lucide-react';

const HomePage = () => {
  const [homeData, setHomeData] = useState<HomePageData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchHomeData = async () => {
      try {
        setLoading(true);
        const data = await AnimeAPI.getHomePage();
        
        if (data.success) {
          setHomeData(data);
        } else {
          setError('Failed to load anime data');
        }
      } catch (err) {
        console.error('Error fetching home data:', err);
        setError('Unable to connect to anime service');
      } finally {
        setLoading(false);
      }
    };

    fetchHomeData();
  }, []);

  const fadeInUp = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0 }
  };

  if (loading) {
    return (
      <div className="min-h-screen">
        {/* Hero Skeleton */}
        <div className="h-screen relative">
          <Skeleton className="absolute inset-0" />
          <div className="absolute inset-0 bg-gradient-to-r from-background via-background/80 to-transparent" />
          <div className="relative z-10 h-full flex items-center max-w-7xl mx-auto px-4">
            <div className="max-w-2xl space-y-4">
              <Skeleton className="h-4 w-32" />
              <Skeleton className="h-16 w-full" />
              <Skeleton className="h-4 w-3/4" />
              <Skeleton className="h-20 w-full" />
              <div className="flex space-x-4">
                <Skeleton className="h-12 w-32" />
                <Skeleton className="h-12 w-32" />
              </div>
            </div>
          </div>
        </div>

        {/* Content Skeletons */}
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 space-y-12">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="space-y-6">
              <Skeleton className="h-8 w-64" />
              <div className="flex space-x-4 overflow-x-auto">
                {[...Array(6)].map((_, j) => (
                  <div key={j} className="flex-shrink-0 w-48">
                    <Skeleton className="h-64 w-full mb-3" />
                    <Skeleton className="h-4 w-full mb-2" />
                    <Skeleton className="h-3 w-3/4" />
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <Alert className="max-w-md">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>
            {error}. Please try refreshing the page.
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  if (!homeData?.data) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-muted-foreground">No data available</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      {homeData.data.spotlightAnimes && homeData.data.spotlightAnimes.length > 0 && (
        <HeroSection spotlightAnimes={homeData.data.spotlightAnimes} />
      )}

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Latest Episodes */}
        {homeData.data.latestEpisodeAnimes && homeData.data.latestEpisodeAnimes.length > 0 && (
          <motion.div
            initial="hidden"
            animate="visible"
            variants={fadeInUp}
            transition={{ delay: 0.2 }}
          >
            <AnimeCarousel
              title="Latest Episodes"
              animes={homeData.data.latestEpisodeAnimes}
              size="md"
              viewAllLink="/category/recently-updated"
            />
          </motion.div>
        )}

        {/* Top 10 Section */}
        {homeData.data.top10Animes && (
          <motion.div
            initial="hidden"
            animate="visible"
            variants={fadeInUp}
            transition={{ delay: 0.4 }}
          >
            <Top10Section top10Animes={homeData.data.top10Animes} />
          </motion.div>
        )}

        {/* Trending Anime */}
        {homeData.data.trendingAnimes && homeData.data.trendingAnimes.length > 0 && (
          <motion.div
            initial="hidden"
            animate="visible"
            variants={fadeInUp}
            transition={{ delay: 0.6 }}
          >
            <AnimeCarousel
              title="Trending Now"
              animes={homeData.data.trendingAnimes}
              showRank={true}
              size="md"
              viewAllLink="/trending"
            />
          </motion.div>
        )}

        {/* Most Popular */}
        {homeData.data.mostPopularAnimes && homeData.data.mostPopularAnimes.length > 0 && (
          <motion.div
            initial="hidden"
            animate="visible"
            variants={fadeInUp}
            transition={{ delay: 0.8 }}
          >
            <AnimeCarousel
              title="Most Popular"
              animes={homeData.data.mostPopularAnimes}
              size="md"
              viewAllLink="/category/most-popular"
            />
          </motion.div>
        )}

        {/* Top Airing */}
        {homeData.data.topAiringAnimes && homeData.data.topAiringAnimes.length > 0 && (
          <motion.div
            initial="hidden"
            animate="visible"
            variants={fadeInUp}
            transition={{ delay: 1.0 }}
          >
            <AnimeCarousel
              title="Currently Airing"
              animes={homeData.data.topAiringAnimes}
              size="md"
              viewAllLink="/category/top-airing"
            />
          </motion.div>
        )}

        {/* Most Favorite */}
        {homeData.data.mostFavoriteAnimes && homeData.data.mostFavoriteAnimes.length > 0 && (
          <motion.div
            initial="hidden"
            animate="visible"
            variants={fadeInUp}
            transition={{ delay: 1.2 }}
          >
            <AnimeCarousel
              title="Top Rated"
              animes={homeData.data.mostFavoriteAnimes}
              size="md"
              viewAllLink="/category/most-favorite"
            />
          </motion.div>
        )}

        {/* Recently Completed */}
        {homeData.data.latestCompletedAnimes && homeData.data.latestCompletedAnimes.length > 0 && (
          <motion.div
            initial="hidden"
            animate="visible"
            variants={fadeInUp}
            transition={{ delay: 1.4 }}
          >
            <AnimeCarousel
              title="Recently Completed"
              animes={homeData.data.latestCompletedAnimes}
              size="md"
              viewAllLink="/category/completed"
            />
          </motion.div>
        )}

        {/* Top Upcoming */}
        {homeData.data.topUpcomingAnimes && homeData.data.topUpcomingAnimes.length > 0 && (
          <motion.div
            initial="hidden"
            animate="visible"
            variants={fadeInUp}
            transition={{ delay: 1.6 }}
            className="pb-12"
          >
            <AnimeCarousel
              title="Upcoming Anime"
              animes={homeData.data.topUpcomingAnimes}
              size="md"
              viewAllLink="/category/top-upcoming"
            />
          </motion.div>
        )}
      </div>
    </div>
  );
};

export default HomePage;
