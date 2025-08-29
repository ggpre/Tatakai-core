'use client';

import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { AnimeAPI, type Anime } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Search, Grid, List, Star, Play, Clock, Tv } from 'lucide-react';
import { Skeleton } from '@/components/ui/skeleton';
import Image from 'next/image';
import Link from 'next/link';

const TVSeriesPage = () => {
  const [series, setSeries] = useState<Anime[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedGenre, setSelectedGenre] = useState('all');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [sortBy, setSortBy] = useState('popular');
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [genres, setGenres] = useState<string[]>([]);

  useEffect(() => {
    fetchSeries();
    fetchGenres();
  }, []);

  const fetchSeries = async () => {
    try {
      setLoading(true);
      
      // Get different types of series from the home page
      const homeResponse = await AnimeAPI.getHomePage();
      
      if (homeResponse.success) {
        const allSeries = [
          ...homeResponse.data.latestEpisodeAnimes,
          ...homeResponse.data.topAiringAnimes,
          ...homeResponse.data.trendingAnimes,
          ...homeResponse.data.mostPopularAnimes
        ];
        
        // Filter for TV series (more than 1 episode)
        const tvSeries = allSeries.filter((anime: Anime) => 
          anime.type?.toLowerCase().includes('tv') || 
          ((anime.episodes?.sub ?? 0) > 1 || (anime.episodes?.dub ?? 0) > 1) ||
          anime.type?.toLowerCase() === 'ona' ||
          anime.type?.toLowerCase() === 'ova'
        );
        
        // Remove duplicates based on ID
        const uniqueSeries = tvSeries.filter((series, index, self) => 
          index === self.findIndex(s => s.id === series.id)
        );
        
        setSeries(uniqueSeries);
      }
    } catch (error) {
      console.error('Error fetching TV series:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchGenres = async () => {
    try {
      const response = await AnimeAPI.getHomePage();
      if (response.success && response.data.genres) {
        setGenres(response.data.genres);
      }
    } catch (error) {
      console.error('Error fetching genres:', error);
    }
  };

  const filteredSeries = series.filter(show => {
    const matchesSearch = show.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesGenre = selectedGenre === 'all' || true; // Note: genres not available in current Anime type
    
    let matchesStatus = true;
    if (selectedStatus !== 'all') {
      // This is a simplified status check - in a real app you'd have actual status data
      if (selectedStatus === 'airing') {
        matchesStatus = show.type?.toLowerCase() === 'tv' && (show.episodes?.sub ?? 0) > 0;
      } else if (selectedStatus === 'completed') {
        matchesStatus = show.type?.toLowerCase() !== 'tv' || (show.episodes?.sub ?? 0) > 12;
      }
    }
    
    return matchesSearch && matchesGenre && matchesStatus;
  });

  const sortedSeries = [...filteredSeries].sort((a, b) => {
    switch (sortBy) {
      case 'name':
        return a.name.localeCompare(b.name);
      case 'rating':
        // Note: rating is string in current type, need to parse or compare as string
        return (a.rating || '').localeCompare(b.rating || '');
      case 'episodes':
        return (b.episodes?.sub || 0) - (a.episodes?.sub || 0);
      case 'recent':
        // Note: no releaseDate in current Anime type
        return b.id.localeCompare(a.id); // fallback to id comparison
      default:
        return 0; // Keep original order for 'popular'
    }
  });

  if (loading) {
    return <TVSeriesPageSkeleton />;
  }

  return (
    <div className="min-h-screen bg-background text-foreground">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="mb-8"
        >
          <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-blue-400 to-purple-600 bg-clip-text text-transparent mb-4">
            TV Series
          </h1>
          <p className="text-gray-300 text-lg">
            Explore ongoing and completed anime TV series
          </p>
        </motion.div>

        {/* Filters */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="bg-card/50 backdrop-blur-sm rounded-2xl p-6 border border-border/50 mb-8"
        >
          <div className="flex flex-col lg:flex-row gap-4 items-center justify-between">
            <div className="flex flex-col sm:flex-row gap-4 w-full lg:w-auto">
              {/* Search */}
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                <Input
                  placeholder="Search TV series..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-10 bg-gray-700/50 border-gray-600 text-white placeholder-gray-400 w-full sm:w-64"
                />
              </div>

              {/* Genre Filter */}
              <Select value={selectedGenre} onValueChange={setSelectedGenre}>
                <SelectTrigger className="bg-card/50 border-border text-foreground w-full sm:w-40">
                  <SelectValue placeholder="Genre" />
                </SelectTrigger>
                <SelectContent className="bg-card border-border">
                  <SelectItem value="all" className="text-foreground hover:bg-muted">All Genres</SelectItem>
                  {genres.map(genre => (
                    <SelectItem key={genre} value={genre} className="text-foreground hover:bg-muted">
                      {genre}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              {/* Status Filter */}
              <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                <SelectTrigger className="bg-card/50 border-border text-foreground w-full sm:w-40">
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent className="bg-card border-border">
                  <SelectItem value="all" className="text-foreground hover:bg-muted">All Status</SelectItem>
                  <SelectItem value="airing" className="text-foreground hover:bg-muted">Currently Airing</SelectItem>
                  <SelectItem value="completed" className="text-foreground hover:bg-muted">Completed</SelectItem>
                </SelectContent>
              </Select>

              {/* Sort */}
              <Select value={sortBy} onValueChange={setSortBy}>
                <SelectTrigger className="bg-card/50 border-border text-foreground w-full sm:w-32">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-card border-border">
                  <SelectItem value="popular" className="text-foreground hover:bg-muted">Popular</SelectItem>
                  <SelectItem value="name" className="text-foreground hover:bg-muted">Name</SelectItem>
                  <SelectItem value="rating" className="text-foreground hover:bg-muted">Rating</SelectItem>
                  <SelectItem value="episodes" className="text-foreground hover:bg-muted">Episodes</SelectItem>
                  <SelectItem value="recent" className="text-foreground hover:bg-muted">Recent</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* View Mode */}
            <div className="flex items-center space-x-2">
              <Button
                variant={viewMode === 'grid' ? 'default' : 'ghost'}
                size="sm"
                onClick={() => setViewMode('grid')}
                className="text-white hover:text-blue-500"
              >
                <Grid className="w-4 h-4" />
              </Button>
              <Button
                variant={viewMode === 'list' ? 'default' : 'ghost'}
                size="sm"
                onClick={() => setViewMode('list')}
                className="text-white hover:text-blue-500"
              >
                <List className="w-4 h-4" />
              </Button>
            </div>
          </div>
        </motion.div>

        {/* Series Grid/List */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.2 }}
        >
          {viewMode === 'grid' ? (
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6">
              {sortedSeries.map((show, index) => (
                <SeriesCard key={show.id} series={show} index={index} />
              ))}
            </div>
          ) : (
            <div className="space-y-4">
              {sortedSeries.map((show, index) => (
                <SeriesListItem key={show.id} series={show} index={index} />
              ))}
            </div>
          )}
        </motion.div>

        {sortedSeries.length === 0 && !loading && (
          <div className="text-center py-16">
            <h3 className="text-2xl font-bold text-gray-400 mb-4">No TV series found</h3>
            <p className="text-gray-500">Try adjusting your search or filters</p>
          </div>
        )}
      </div>
    </div>
  );
};

const SeriesCard = ({ series, index }: { series: Anime; index: number }) => (
  <motion.div
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    transition={{ duration: 0.6, delay: index * 0.1 }}
    className="group relative"
  >
    <Link href={`/anime/${series.id}`}>
      <Card className="bg-card/50 border-border/50 hover:border-rose-500/50 transition-all duration-300 overflow-hidden group-hover:scale-105 group-hover:shadow-2xl">
        <div className="relative aspect-[2/3]">
          <Image
            src={series.poster}
            alt={series.name}
            fill
            className="object-cover"
            sizes="(max-width: 640px) 50vw, (max-width: 768px) 33vw, (max-width: 1024px) 25vw, 20vw"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            <div className="absolute bottom-4 left-4 right-4">
              <div className="flex items-center justify-between text-white">
                <div className="flex items-center space-x-1">
                  <Star className="w-4 h-4 text-yellow-500" />
                  <span className="text-sm">{series.rating || 'N/A'}</span>
                </div>
                <Play className="w-6 h-6" />
              </div>
            </div>
          </div>
          {/* Episode count badge */}
          <div className="absolute top-2 right-2">
            <Badge className="bg-blue-500/80 text-white border-0">
              {series.episodes?.sub || series.episodes?.dub || 0} EP
            </Badge>
          </div>
        </div>
        <CardContent className="p-4">
          <h3 className="font-bold text-white group-hover:text-blue-400 transition-colors line-clamp-2 mb-2">
            {series.name}
          </h3>
          <div className="flex items-center justify-between text-sm text-gray-400">
            <span className="flex items-center space-x-1">
              <Tv className="w-3 h-3" />
              <span>{series.type || 'TV'}</span>
            </span>
            <span>{series.episodes?.sub || 0} eps</span>
          </div>
        </CardContent>
      </Card>
    </Link>
  </motion.div>
);

const SeriesListItem = ({ series, index }: { series: Anime; index: number }) => (
  <motion.div
    initial={{ opacity: 0, x: -20 }}
    animate={{ opacity: 1, x: 0 }}
    transition={{ duration: 0.6, delay: index * 0.05 }}
  >
    <Link href={`/anime/${series.id}`}>
      <Card className="bg-card/50 border-border/50 hover:border-rose-500/50 transition-all duration-300 overflow-hidden">
        <CardContent className="p-6">
          <div className="flex items-center space-x-6">
            <div className="relative w-24 h-36 flex-shrink-0">
              <Image
                src={series.poster}
                alt={series.name}
                fill
                className="object-cover rounded-lg"
              />
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="text-xl font-bold text-white hover:text-blue-400 transition-colors mb-2">
                {series.name}
              </h3>
              <p className="text-gray-400 text-sm mb-4 line-clamp-3">
                {series.description || 'No description available.'}
              </p>
              <div className="flex items-center space-x-4 text-sm text-gray-400">
                <div className="flex items-center space-x-1">
                  <Star className="w-4 h-4 text-yellow-500" />
                  <span>{series.rating || 'N/A'}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Tv className="w-4 h-4" />
                  <span>{series.type || 'TV'}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Clock className="w-4 h-4" />
                  <span>{series.episodes?.sub || 0} episodes</span>
                </div>
              </div>
            </div>
            <Play className="w-8 h-8 text-blue-500 flex-shrink-0" />
          </div>
        </CardContent>
      </Card>
    </Link>
  </motion.div>
);

const TVSeriesPageSkeleton = () => (
  <div className="min-h-screen bg-background text-foreground">
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-8">
        <Skeleton className="h-12 w-64 mb-4" />
        <Skeleton className="h-6 w-96" />
      </div>
      <div className="bg-card/50 rounded-2xl p-6 mb-8">
        <div className="flex gap-4">
          <Skeleton className="h-10 w-64" />
          <Skeleton className="h-10 w-32" />
          <Skeleton className="h-10 w-32" />
          <Skeleton className="h-10 w-32" />
        </div>
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6">
        {Array(24).fill(0).map((_, i) => (
          <div key={i} className="space-y-4">
            <Skeleton className="aspect-[2/3] w-full" />
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-3 w-3/4" />
          </div>
        ))}
      </div>
    </div>
  </div>
);

export default TVSeriesPage;
