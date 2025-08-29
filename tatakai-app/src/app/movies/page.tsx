'use client';

import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { AnimeAPI, type Anime } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Search, Grid, List, Star, Play } from 'lucide-react';
import { Skeleton } from '@/components/ui/skeleton';
import Image from 'next/image';
import Link from 'next/link';

const MoviesPage = () => {
  const [movies, setMovies] = useState<Anime[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedGenre, setSelectedGenre] = useState('all');
  const [sortBy, setSortBy] = useState('popular');
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [genres, setGenres] = useState<string[]>([]);

  useEffect(() => {
    fetchMovies();
    fetchGenres();
  }, []);

  const fetchMovies = async () => {
    try {
      setLoading(true);
      
      // For now, we'll use the search API to get movie results
      // In a real implementation, you'd have a dedicated movies endpoint
      const response = await AnimeAPI.searchAnime('movie', 1);
      
      if (response.success) {
        // Filter for movie-type content
        const movieData = response.data.animes.filter((anime: Anime) => 
          anime.type?.toLowerCase().includes('movie') || 
          anime.duration?.includes('hr') ||
          anime.episodes?.sub === 1 && anime.episodes?.dub === 1
        );
        setMovies(movieData);
      }
    } catch (error) {
      console.error('Error fetching movies:', error);
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

  const filteredMovies = movies.filter(movie => {
    const matchesSearch = movie.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesGenre = selectedGenre === 'all' || true; // Note: genres not available in current Anime type
    // Note: We don't have release year in the current API, so we'll skip year filtering for now
    return matchesSearch && matchesGenre;
  });

  const sortedMovies = [...filteredMovies].sort((a, b) => {
    switch (sortBy) {
      case 'name':
        return a.name.localeCompare(b.name);
      case 'rating':
        // Note: rating is string in current type, need to parse or compare as string
        return (a.rating || '').localeCompare(b.rating || '');
      case 'recent':
        // Note: no releaseDate in current Anime type
        return b.id.localeCompare(a.id); // fallback to id comparison
      default:
        return 0; // Keep original order for 'popular'
    }
  });

  if (loading) {
    return <MoviesPageSkeleton />;
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
          <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-rose-400 to-pink-600 bg-clip-text text-transparent mb-4">
            Anime Movies
          </h1>
          <p className="text-gray-300 text-lg">
            Discover amazing anime movies and feature films
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
                  placeholder="Search movies..."
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

              {/* Sort */}
              <Select value={sortBy} onValueChange={setSortBy}>
                <SelectTrigger className="bg-card/50 border-border text-foreground w-full sm:w-32">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-card border-border">
                  <SelectItem value="popular" className="text-foreground hover:bg-muted">Popular</SelectItem>
                  <SelectItem value="name" className="text-foreground hover:bg-muted">Name</SelectItem>
                  <SelectItem value="rating" className="text-foreground hover:bg-muted">Rating</SelectItem>
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
                className="text-white hover:text-rose-500"
              >
                <Grid className="w-4 h-4" />
              </Button>
              <Button
                variant={viewMode === 'list' ? 'default' : 'ghost'}
                size="sm"
                onClick={() => setViewMode('list')}
                className="text-white hover:text-rose-500"
              >
                <List className="w-4 h-4" />
              </Button>
            </div>
          </div>
        </motion.div>

        {/* Movies Grid/List */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.2 }}
        >
          {viewMode === 'grid' ? (
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-6">
              {sortedMovies.map((movie, index) => (
                <MovieCard key={movie.id} movie={movie} index={index} />
              ))}
            </div>
          ) : (
            <div className="space-y-4">
              {sortedMovies.map((movie, index) => (
                <MovieListItem key={movie.id} movie={movie} index={index} />
              ))}
            </div>
          )}
        </motion.div>

        {sortedMovies.length === 0 && !loading && (
          <div className="text-center py-16">
            <h3 className="text-2xl font-bold text-gray-400 mb-4">No movies found</h3>
            <p className="text-gray-500">Try adjusting your search or filters</p>
          </div>
        )}
      </div>
    </div>
  );
};

const MovieCard = ({ movie, index }: { movie: Anime; index: number }) => (
  <motion.div
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    transition={{ duration: 0.6, delay: index * 0.1 }}
    className="group relative"
  >
    <Link href={`/anime/${movie.id}`}>
      <Card className="bg-card/50 border-border/50 hover:border-rose-500/50 transition-all duration-300 overflow-hidden group-hover:scale-105 group-hover:shadow-2xl">
        <div className="relative aspect-[2/3]">
          <Image
            src={movie.poster}
            alt={movie.name}
            fill
            className="object-cover"
            sizes="(max-width: 640px) 50vw, (max-width: 768px) 33vw, (max-width: 1024px) 25vw, 20vw"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            <div className="absolute bottom-4 left-4 right-4">
              <div className="flex items-center justify-between text-white">
                <div className="flex items-center space-x-1">
                  <Star className="w-4 h-4 text-yellow-500" />
                  <span className="text-sm">{movie.rating || 'N/A'}</span>
                </div>
                <Play className="w-6 h-6" />
              </div>
            </div>
          </div>
        </div>
        <CardContent className="p-4">
          <h3 className="font-bold text-white group-hover:text-rose-400 transition-colors line-clamp-2 mb-2">
            {movie.name}
          </h3>
          <div className="flex items-center justify-between text-sm text-gray-400">
            <span>{movie.type || 'Movie'}</span>
            <span>{movie.duration || 'N/A'}</span>
          </div>
        </CardContent>
      </Card>
    </Link>
  </motion.div>
);

const MovieListItem = ({ movie, index }: { movie: Anime; index: number }) => (
  <motion.div
    initial={{ opacity: 0, x: -20 }}
    animate={{ opacity: 1, x: 0 }}
    transition={{ duration: 0.6, delay: index * 0.05 }}
  >
    <Link href={`/anime/${movie.id}`}>
      <Card className="bg-card/50 border-border/50 hover:border-rose-500/50 transition-all duration-300 overflow-hidden">
        <CardContent className="p-6">
          <div className="flex items-center space-x-6">
            <div className="relative w-24 h-36 flex-shrink-0">
              <Image
                src={movie.poster}
                alt={movie.name}
                fill
                className="object-cover rounded-lg"
              />
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="text-xl font-bold text-white hover:text-rose-400 transition-colors mb-2">
                {movie.name}
              </h3>
              <p className="text-gray-400 text-sm mb-4 line-clamp-3">
                {movie.description || 'No description available.'}
              </p>
              <div className="flex items-center space-x-4 text-sm text-gray-400">
                <div className="flex items-center space-x-1">
                  <Star className="w-4 h-4 text-yellow-500" />
                  <span>{movie.rating || 'N/A'}</span>
                </div>
                <span>{movie.type || 'Movie'}</span>
                <span>{movie.duration || 'N/A'}</span>
              </div>
            </div>
            <Play className="w-8 h-8 text-rose-500 flex-shrink-0" />
          </div>
        </CardContent>
      </Card>
    </Link>
  </motion.div>
);

const MoviesPageSkeleton = () => (
  <div className="min-h-screen bg-gradient-to-br from-black via-gray-900 to-black text-white">
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

export default MoviesPage;
