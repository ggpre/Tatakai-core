'use client';

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Clock } from 'lucide-react';
import { AnimeAPI, type Anime } from '@/lib/api';
import AnimeCard from '@/components/AnimeCard';

const RecentlyAddedPage = () => {
  const [animes, setAnimes] = useState<Anime[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);

  useEffect(() => {
    const fetchRecentlyAdded = async () => {
      try {
        setLoading(true);
        const response = await AnimeAPI.getAnimeByCategory('recently-added', page);
        if (page === 1) {
          setAnimes(response.data?.animes || []);
        } else {
          setAnimes(prev => [...prev, ...(response.data?.animes || [])]);
        }
        setHasMore(response.data?.animes?.length === 20); // Assuming 20 per page
      } catch (error) {
        console.error('Error fetching recently added anime:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchRecentlyAdded();
  }, [page]);

  const loadMore = () => {
    if (!loading && hasMore) {
      setPage(prev => prev + 1);
    }
  };

  return (
    <div className="min-h-screen bg-background pt-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <div className="flex items-center space-x-3 mb-4">
            <div className="p-3 bg-blue-500/20 rounded-lg">
              <Clock className="w-6 h-6 text-blue-500" />
            </div>
            <h1 className="text-3xl font-bold text-foreground">Recently Added</h1>
          </div>
          <p className="text-muted-foreground">
            Stay up to date with the latest anime additions to our collection.
          </p>
        </motion.div>

        {/* Anime Grid */}
        {loading && page === 1 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 2xl:grid-cols-6 gap-6">
            {Array.from({ length: 24 }).map((_, i) => (
              <div key={i} className="aspect-[2/3] bg-muted animate-pulse rounded-lg" />
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 2xl:grid-cols-6 gap-6">
            {animes.map((anime) => (
              <AnimeCard key={anime.id} anime={anime} />
            ))}
          </div>
        )}

        {/* Load More Button */}
        {hasMore && animes.length > 0 && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="flex justify-center mt-12"
          >
            <button
              onClick={loadMore}
              disabled={loading}
              className="px-8 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors disabled:opacity-50"
            >
              {loading ? 'Loading...' : 'Load More'}
            </button>
          </motion.div>
        )}
      </div>
    </div>
  );
};

export default RecentlyAddedPage;
