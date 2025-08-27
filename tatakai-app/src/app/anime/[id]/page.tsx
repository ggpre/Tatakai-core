'use client';

import React, { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { motion } from 'framer-motion';
import Image from 'next/image';
import Link from 'next/link';
import { AnimeAPI, type AnimeInfoResponse } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Play, Star, Clock, Calendar, Users, BookOpen, Heart, Share2 } from 'lucide-react';
import AnimeCarousel from '@/components/AnimeCarousel';
import { Skeleton } from '@/components/ui/skeleton';

const AnimeDetailsPage = () => {
  const params = useParams();
  const animeId = params?.id as string;
  const [animeData, setAnimeData] = useState<AnimeInfoResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchAnimeData = async () => {
      if (!animeId) return;
      
      try {
        setLoading(true);
        const data = await AnimeAPI.getAnimeInfo(animeId);
        
        if (data.success) {
          setAnimeData(data);
        } else {
          setError('Failed to load anime details');
        }
      } catch (err) {
        console.error('Error fetching anime data:', err);
        setError('Unable to load anime details');
      } finally {
        setLoading(false);
      }
    };

    fetchAnimeData();
  }, [animeId]);

  if (loading) {
    return <AnimeDetailsSkeleton />;
  }

  if (error || !animeData?.data) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold mb-4">Failed to load anime</h2>
          <p className="text-muted-foreground mb-4">{error}</p>
          <Button onClick={() => window.location.reload()}>Try Again</Button>
        </div>
      </div>
    );
  }

  const { anime, mostPopularAnimes, recommendedAnimes, relatedAnimes, seasons } = animeData.data;
  const { info, moreInfo } = anime;

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <div className="relative h-screen">
        <div className="absolute inset-0">
          <Image
            src={info.poster}
            alt={info.name}
            fill
            className="object-cover"
            priority
          />
          <div className="absolute inset-0 bg-gradient-to-r from-background via-background/90 to-background/60" />
          <div className="absolute inset-0 bg-gradient-to-t from-background via-transparent to-transparent" />
        </div>

        <div className="relative z-10 h-full flex items-center max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 w-full">
            {/* Poster */}
            <motion.div
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.6 }}
              className="flex justify-center lg:justify-start"
            >
              <div className="relative w-80 h-96 rounded-xl overflow-hidden shadow-2xl">
                <Image
                  src={info.poster}
                  alt={info.name}
                  fill
                  className="object-cover"
                />
              </div>
            </motion.div>

            {/* Info */}
            <div className="lg:col-span-2 space-y-6">
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.2 }}
              >
                <Badge variant="secondary" className="mb-4">
                  {info.stats.type}
                </Badge>
                <h1 className="text-4xl md:text-6xl font-bold text-foreground mb-4">
                  {info.name}
                </h1>
                
                <div className="flex flex-wrap items-center gap-4 mb-6">
                  <div className="flex items-center space-x-2">
                    <Star className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                    <span className="font-semibold">{info.stats.rating}</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Clock className="w-5 h-5 text-muted-foreground" />
                    <span>{info.stats.duration}</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <BookOpen className="w-5 h-5 text-muted-foreground" />
                    <span>{info.stats.episodes.sub} Episodes</span>
                  </div>
                  <Badge variant="outline" className="border-rose-500 text-rose-500">
                    {info.stats.quality}
                  </Badge>
                </div>

                <p className="text-lg text-muted-foreground mb-8 max-w-3xl leading-relaxed">
                  {info.description}
                </p>

                <div className="flex flex-wrap gap-4">
                  <Button size="lg" className="bg-rose-600 hover:bg-rose-700">
                    <Play className="w-5 h-5 mr-2" />
                    Watch Now
                  </Button>
                  <Button variant="outline" size="lg">
                    <Heart className="w-5 h-5 mr-2" />
                    Add to List
                  </Button>
                  <Button variant="outline" size="lg">
                    <Share2 className="w-5 h-5 mr-2" />
                    Share
                  </Button>
                </div>
              </motion.div>
            </div>
          </div>
        </div>
      </div>

      {/* Content Sections */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <Tabs defaultValue="overview" className="space-y-8">
          <TabsList className="grid w-full max-w-md grid-cols-3">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="episodes">Episodes</TabsTrigger>
            <TabsTrigger value="characters">Characters</TabsTrigger>
          </TabsList>

          <TabsContent value="overview" className="space-y-12">
            {/* More Info */}
            <Card>
              <CardContent className="p-6">
                <h3 className="text-2xl font-bold mb-6">Information</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  <div>
                    <h4 className="font-semibold text-muted-foreground mb-2">Status</h4>
                    <p>{moreInfo.status}</p>
                  </div>
                  <div>
                    <h4 className="font-semibold text-muted-foreground mb-2">Aired</h4>
                    <p>{moreInfo.aired}</p>
                  </div>
                  <div>
                    <h4 className="font-semibold text-muted-foreground mb-2">Studios</h4>
                    <p>{moreInfo.studios}</p>
                  </div>
                  <div>
                    <h4 className="font-semibold text-muted-foreground mb-2">Duration</h4>
                    <p>{moreInfo.duration}</p>
                  </div>
                  <div className="md:col-span-2">
                    <h4 className="font-semibold text-muted-foreground mb-2">Genres</h4>
                    <div className="flex flex-wrap gap-2">
                      {moreInfo.genres.map((genre) => (
                        <Badge key={genre} variant="secondary">
                          {genre}
                        </Badge>
                      ))}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Promotional Videos */}
            {info.promotionalVideos && info.promotionalVideos.length > 0 && (
              <Card>
                <CardContent className="p-6">
                  <h3 className="text-2xl font-bold mb-6">Videos</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {info.promotionalVideos.map((video, index) => (
                      <div key={index} className="relative group cursor-pointer">
                        <div className="aspect-video bg-muted rounded-lg overflow-hidden">
                          {video.thumbnail && (
                            <Image
                              src={video.thumbnail}
                              alt={video.title || 'Promotional Video'}
                              fill
                              className="object-cover group-hover:scale-105 transition-transform duration-300"
                            />
                          )}
                          <div className="absolute inset-0 flex items-center justify-center">
                            <Play className="w-12 h-12 text-white opacity-80 group-hover:opacity-100 transition-opacity" />
                          </div>
                        </div>
                        {video.title && (
                          <p className="mt-2 font-medium">{video.title}</p>
                        )}
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Seasons */}
            {seasons && seasons.length > 0 && (
              <div>
                <h3 className="text-2xl font-bold mb-6">Seasons</h3>
                <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                  {seasons.map((season) => (
                    <Link key={season.id} href={`/anime/${season.id}`}>
                      <Card className={`group cursor-pointer transition-all duration-300 hover:shadow-lg ${
                        season.isCurrent ? 'ring-2 ring-rose-500' : ''
                      }`}>
                        <CardContent className="p-4">
                          <div className="aspect-[3/4] relative mb-3 rounded-lg overflow-hidden">
                            <Image
                              src={season.poster}
                              alt={season.name}
                              fill
                              className="object-cover group-hover:scale-105 transition-transform duration-300"
                            />
                          </div>
                          <h4 className="font-semibold text-sm group-hover:text-rose-500 transition-colors">
                            {season.title}
                          </h4>
                        </CardContent>
                      </Card>
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </TabsContent>

          <TabsContent value="episodes">
            <Card>
              <CardContent className="p-6">
                <h3 className="text-2xl font-bold mb-6">Episodes</h3>
                <p className="text-muted-foreground">Episodes will be loaded here...</p>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="characters">
            {/* Characters */}
            {info.characterVoiceActor && info.characterVoiceActor.length > 0 && (
              <Card>
                <CardContent className="p-6">
                  <h3 className="text-2xl font-bold mb-6">Characters & Voice Actors</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {info.characterVoiceActor.slice(0, 12).map((item, index) => (
                      <div key={index} className="flex items-center space-x-4 p-4 border rounded-lg">
                        <div className="flex items-center space-x-3 flex-1">
                          <div className="relative w-16 h-16 rounded-full overflow-hidden">
                            <Image
                              src={item.character.poster}
                              alt={item.character.name}
                              fill
                              className="object-cover"
                            />
                          </div>
                          <div>
                            <h4 className="font-semibold">{item.character.name}</h4>
                            <p className="text-sm text-muted-foreground">{item.character.cast}</p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-3 flex-1 justify-end">
                          <div className="text-right">
                            <h4 className="font-semibold">{item.voiceActor.name}</h4>
                            <p className="text-sm text-muted-foreground">{item.voiceActor.cast}</p>
                          </div>
                          <div className="relative w-16 h-16 rounded-full overflow-hidden">
                            <Image
                              src={item.voiceActor.poster}
                              alt={item.voiceActor.name}
                              fill
                              className="object-cover"
                            />
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            )}
          </TabsContent>
        </Tabs>

        {/* Recommended Anime */}
        {recommendedAnimes && recommendedAnimes.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="mt-12"
          >
            <AnimeCarousel
              title="Recommended for You"
              animes={recommendedAnimes}
              size="md"
            />
          </motion.div>
        )}

        {/* Related Anime */}
        {relatedAnimes && relatedAnimes.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.6 }}
            className="mt-12"
          >
            <AnimeCarousel
              title="Related Anime"
              animes={relatedAnimes}
              size="md"
            />
          </motion.div>
        )}

        {/* Most Popular */}
        {mostPopularAnimes && mostPopularAnimes.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.8 }}
            className="mt-12"
          >
            <AnimeCarousel
              title="Most Popular"
              animes={mostPopularAnimes}
              size="md"
            />
          </motion.div>
        )}
      </div>
    </div>
  );
};

const AnimeDetailsSkeleton = () => (
  <div className="min-h-screen">
    <div className="h-screen relative">
      <Skeleton className="absolute inset-0" />
      <div className="absolute inset-0 bg-gradient-to-r from-background via-background/90 to-background/60" />
      <div className="relative z-10 h-full flex items-center max-w-7xl mx-auto px-4">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 w-full">
          <Skeleton className="w-80 h-96 rounded-xl" />
          <div className="lg:col-span-2 space-y-6">
            <Skeleton className="h-8 w-32" />
            <Skeleton className="h-16 w-full" />
            <div className="flex space-x-4">
              {[...Array(4)].map((_, i) => (
                <Skeleton key={i} className="h-6 w-20" />
              ))}
            </div>
            <Skeleton className="h-32 w-full" />
            <div className="flex space-x-4">
              <Skeleton className="h-12 w-32" />
              <Skeleton className="h-12 w-32" />
              <Skeleton className="h-12 w-32" />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
);

export default AnimeDetailsPage;
