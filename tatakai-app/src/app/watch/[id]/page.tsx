'use client';

import React, { useEffect, useState } from 'react';
import { useParams, useSearchParams } from 'next/navigation';
import { motion } from 'framer-motion';
import { AnimeAPI, type EpisodeServersResponse, type EpisodeSourcesResponse } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Play, Download, Settings, Volume2, Maximize, SkipBack, SkipForward } from 'lucide-react';
import { Skeleton } from '@/components/ui/skeleton';

const WatchPage = () => {
  const params = useParams();
  const searchParams = useSearchParams();
  const animeId = params?.id as string;
  const episodeId = searchParams?.get('ep') || 'steinsgate-0-92?ep=2055'; // Default test episode
  
  const [servers, setServers] = useState<EpisodeServersResponse | null>(null);
  const [sources, setSources] = useState<EpisodeSourcesResponse | null>(null);
  const [selectedServer, setSelectedServer] = useState<string>('');
  const [selectedCategory, setSelectedCategory] = useState<'sub' | 'dub' | 'raw'>('sub');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchEpisodeData = async () => {
      if (!episodeId) {
        console.log('No episode ID provided');
        return;
      }
      
      console.log('Fetching episode data for:', episodeId);
      
      try {
        setLoading(true);
        
        // Fetch available servers
        console.log('Calling getEpisodeServers with:', episodeId);
        const serversData = await AnimeAPI.getEpisodeServers(episodeId);
        
        console.log('Servers response:', serversData);
        
        if (serversData.success) {
          setServers(serversData);
          
          // Auto-select first available server
          const availableServers = serversData.data.sub.length > 0 ? serversData.data.sub : 
                                 serversData.data.dub.length > 0 ? serversData.data.dub : 
                                 serversData.data.raw;
          
          if (availableServers.length > 0) {
            const defaultServer = availableServers.find(s => s.serverName === 'hd-1') || availableServers[0];
            setSelectedServer(defaultServer.serverName);
            
            // Determine category based on available servers
            if (serversData.data.sub.length > 0) setSelectedCategory('sub');
            else if (serversData.data.dub.length > 0) setSelectedCategory('dub');
            else if (serversData.data.raw.length > 0) setSelectedCategory('raw');
            
            // Fetch sources for default server
            await fetchSources(episodeId, defaultServer.serverName, selectedCategory);
          } else {
            setError('No servers available for this episode');
          }
        } else {
          setError('Failed to load episode servers');
        }
      } catch (err) {
        console.error('Error fetching episode data:', err);
        setError(`Unable to load episode: ${err instanceof Error ? err.message : 'Unknown error'}`);
      } finally {
        setLoading(false);
      }
    };

    fetchEpisodeData();
  }, [episodeId]);

  const fetchSources = async (episodeId: string, server: string, category: 'sub' | 'dub' | 'raw') => {
    try {
      const sourcesData = await AnimeAPI.getEpisodeSources(episodeId, server, category);
      
      if (sourcesData.success) {
        setSources(sourcesData);
      } else {
        setError('Failed to load video sources');
      }
    } catch (err) {
      console.error('Error fetching sources:', err);
      setError('Unable to load video sources');
    }
  };

  const handleServerChange = async (serverName: string) => {
    if (!episodeId) return;
    
    setSelectedServer(serverName);
    setLoading(true);
    
    try {
      await fetchSources(episodeId, serverName, selectedCategory);
    } finally {
      setLoading(false);
    }
  };

  const handleCategoryChange = async (category: 'sub' | 'dub' | 'raw') => {
    if (!episodeId || !selectedServer) return;
    
    setSelectedCategory(category);
    setLoading(true);
    
    try {
      await fetchSources(episodeId, selectedServer, category);
    } finally {
      setLoading(false);
    }
  };

  if (!episodeId) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold mb-4">Episode not found</h2>
          <p className="text-muted-foreground mb-4">Please select a valid episode to watch.</p>
          <p className="text-sm text-muted-foreground mb-4">
            Episode ID format should be like: anime-id?ep=episode-number
          </p>
          <Button 
            onClick={() => {
              // Test with a sample episode ID
              window.location.href = '/watch/steinsgate-3?ep=230';
            }}
          >
            Try Sample Episode
          </Button>
        </div>
      </div>
    );
  }

  if (loading && !sources) {
    return <WatchPageSkeleton />;
  }

  if (error && !sources) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold mb-4">Unable to load episode</h2>
          <p className="text-muted-foreground mb-4">{error}</p>
          <Button onClick={() => window.location.reload()}>Try Again</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-black">
      {/* Video Player */}
      <div className="relative">
        <div className="aspect-video bg-black relative">
          {sources?.data.sources && sources.data.sources.length > 0 ? (
            <VideoPlayer 
              sources={sources.data.sources}
              subtitles={sources.data.subtitles}
            />
          ) : (
            <div className="absolute inset-0 flex items-center justify-center bg-gray-900">
              <div className="text-center text-white">
                <Play className="w-16 h-16 mx-auto mb-4 opacity-50" />
                <p className="text-xl">Loading video...</p>
              </div>
            </div>
          )}
        </div>

        {/* Video Controls Overlay */}
        <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-6">
          <div className="max-w-7xl mx-auto">
            <div className="flex items-center justify-between text-white">
              <div className="flex items-center space-x-4">
                <Button variant="ghost" size="sm" className="text-white hover:text-rose-500">
                  <SkipBack className="w-5 h-5" />
                </Button>
                <Button variant="ghost" size="sm" className="text-white hover:text-rose-500">
                  <Play className="w-6 h-6" />
                </Button>
                <Button variant="ghost" size="sm" className="text-white hover:text-rose-500">
                  <SkipForward className="w-5 h-5" />
                </Button>
                <Button variant="ghost" size="sm" className="text-white hover:text-rose-500">
                  <Volume2 className="w-5 h-5" />
                </Button>
              </div>
              
              <div className="flex items-center space-x-4">
                <Button variant="ghost" size="sm" className="text-white hover:text-rose-500">
                  <Settings className="w-5 h-5" />
                </Button>
                <Button variant="ghost" size="sm" className="text-white hover:text-rose-500">
                  <Download className="w-5 h-5" />
                </Button>
                <Button variant="ghost" size="sm" className="text-white hover:text-rose-500">
                  <Maximize className="w-5 h-5" />
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Episode Info & Controls */}
      <div className="bg-background">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Episode Info */}
            <div className="lg:col-span-2 space-y-6">
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6 }}
              >
                <div className="flex items-center space-x-4 mb-4">
                  <Badge variant="secondary">
                    Episode {servers?.data.episodeNo}
                  </Badge>
                  <Badge variant="outline" className="border-rose-500 text-rose-500">
                    {selectedCategory.toUpperCase()}
                  </Badge>
                </div>
                
                <h1 className="text-3xl md:text-4xl font-bold text-foreground mb-4">
                  {animeId.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                </h1>
                
                <p className="text-muted-foreground mb-6">
                  Episode {servers?.data.episodeNo} - Now Playing
                </p>

                {/* Server & Quality Selection */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Category</label>
                    <Select value={selectedCategory} onValueChange={handleCategoryChange}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {servers?.data.sub && servers.data.sub.length > 0 && (
                          <SelectItem value="sub">Subtitled</SelectItem>
                        )}
                        {servers?.data.dub && servers.data.dub.length > 0 && (
                          <SelectItem value="dub">Dubbed</SelectItem>
                        )}
                        {servers?.data.raw && servers.data.raw.length > 0 && (
                          <SelectItem value="raw">Raw</SelectItem>
                        )}
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2">Server</label>
                    <Select value={selectedServer} onValueChange={handleServerChange}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {servers?.data[selectedCategory]?.map((server) => (
                          <SelectItem key={server.serverId} value={server.serverName}>
                            {server.serverName}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2">Quality</label>
                    <Select defaultValue="auto">
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="auto">Auto</SelectItem>
                        <SelectItem value="1080p">1080p</SelectItem>
                        <SelectItem value="720p">720p</SelectItem>
                        <SelectItem value="480p">480p</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </motion.div>
            </div>

            {/* Episode List */}
            <div className="space-y-6">
              <Card>
                <CardContent className="p-6">
                  <h3 className="text-xl font-bold mb-4">Episodes</h3>
                  <div className="space-y-2 max-h-96 overflow-y-auto">
                    {/* Placeholder episode list */}
                    {[...Array(12)].map((_, index) => (
                      <div 
                        key={index}
                        className={`p-3 rounded-lg cursor-pointer transition-colors ${
                          index + 1 === servers?.data.episodeNo 
                            ? 'bg-rose-500 text-white' 
                            : 'bg-muted hover:bg-muted/80'
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <span className="font-medium">Episode {index + 1}</span>
                          <Play className="w-4 h-4" />
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              {/* Download Options */}
              <Card>
                <CardContent className="p-6">
                  <h3 className="text-xl font-bold mb-4">Download</h3>
                  <div className="space-y-3">
                    {sources?.data.sources.map((source, index) => (
                      <Button key={index} variant="outline" className="w-full justify-between">
                        <span>{source.quality || 'Default Quality'}</span>
                        <Download className="w-4 h-4" />
                      </Button>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

// Video Player Component
const VideoPlayer = ({ sources, subtitles }: { 
  sources: any[], 
  subtitles: any[] 
}) => {
  const videoRef = React.useRef<HTMLVideoElement>(null);
  const [selectedSource, setSelectedSource] = useState(sources[0]);

  useEffect(() => {
    if (videoRef.current && selectedSource) {
      videoRef.current.src = selectedSource.url;
    }
  }, [selectedSource]);

  return (
    <div className="w-full h-full relative">
      <video
        ref={videoRef}
        className="w-full h-full"
        controls
        autoPlay
        playsInline
        crossOrigin="anonymous"
      >
        {subtitles?.map((subtitle, index) => (
          <track
            key={index}
            kind="subtitles"
            src={subtitle.url}
            srcLang={subtitle.lang.toLowerCase()}
            label={subtitle.lang}
            default={index === 0}
          />
        ))}
        Your browser does not support the video tag.
      </video>
      
      {/* Custom loading overlay */}
      <div className="absolute inset-0 flex items-center justify-center bg-black/50 opacity-0 pointer-events-none transition-opacity">
        <div className="text-white text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-white mx-auto mb-4"></div>
          <p>Loading video...</p>
        </div>
      </div>
    </div>
  );
};

const WatchPageSkeleton = () => (
  <div className="min-h-screen bg-black">
    <div className="aspect-video bg-gray-900">
      <Skeleton className="w-full h-full" />
    </div>
    <div className="bg-background">
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 space-y-6">
            <div className="space-y-4">
              <div className="flex space-x-4">
                <Skeleton className="h-6 w-20" />
                <Skeleton className="h-6 w-16" />
              </div>
              <Skeleton className="h-8 w-3/4" />
              <Skeleton className="h-4 w-1/2" />
              <div className="grid grid-cols-3 gap-4">
                <Skeleton className="h-10 w-full" />
                <Skeleton className="h-10 w-full" />
                <Skeleton className="h-10 w-full" />
              </div>
            </div>
          </div>
          <div className="space-y-6">
            <Skeleton className="h-96 w-full" />
            <Skeleton className="h-48 w-full" />
          </div>
        </div>
      </div>
    </div>
  </div>
);

export default WatchPage;
