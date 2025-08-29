'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { motion, AnimatePresence } from 'framer-motion';
import { Play, Info, Clock, Plus, Heart } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { HoverCard, HoverCardContent, HoverCardTrigger } from '@/components/ui/hover-card';
import { AspectRatio } from '@/components/ui/aspect-ratio';
import type { Anime } from '@/lib/api';

interface AnimeCardProps {
  anime: Anime;
  index?: number;
  showRank?: boolean;
  size?: 'sm' | 'md' | 'lg';
  layout?: 'grid' | 'list';
}

const AnimeCard: React.FC<AnimeCardProps> = ({ 
  anime, 
  index = 0, 
  showRank = false, 
  size = 'md',
  layout = 'grid'
}) => {
  const [isHovered, setIsHovered] = useState(false);
  const [imageLoaded, setImageLoaded] = useState(false);

  const cardVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { 
      opacity: 1, 
      y: 0,
      transition: { 
        delay: index * 0.1,
        duration: 0.5
      }
    },
    hover: {
      y: -8,
      transition: { duration: 0.3 }
    }
  };

  const overlayVariants = {
    hidden: { opacity: 0 },
    visible: { 
      opacity: 1,
      transition: { duration: 0.3 }
    }
  };

  const sizeClasses = {
    sm: 'w-full max-w-[150px]',
    md: 'w-full max-w-[200px]',
    lg: 'w-full max-w-[250px]'
  };

  const aspectRatios = {
    sm: 3/4,
    md: 3/4,
    lg: 3/4
  };

  if (layout === 'list') {
    return (
      <motion.div
        variants={cardVariants}
        initial="hidden"
        animate="visible"
        whileHover="hover"
        className="w-full"
      >
        <Card className="overflow-hidden hover:shadow-lg transition-all duration-300 border-border/50 bg-card/50 backdrop-blur-sm">
          <CardContent className="p-0">
            <div className="flex">
              <div className="w-24 h-32 flex-shrink-0">
                <img
                  src={anime.poster}
                  alt={anime.name}
                  className="w-full h-full object-cover"
                  onLoad={() => setImageLoaded(true)}
                />
              </div>
              <div className="flex-1 p-4">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <Link href={`/anime/${anime.id}`}>
                      <h3 className="font-semibold text-foreground hover:text-primary transition-colors line-clamp-2 mb-2">
                        {anime.name}
                      </h3>
                    </Link>
                    {anime.jname && (
                      <p className="text-sm text-muted-foreground mb-2 line-clamp-1">
                        {anime.jname}
                      </p>
                    )}
                    <div className="flex flex-wrap gap-2 mb-3">
                      {anime.type && (
                        <Badge variant="secondary" className="text-xs">
                          {anime.type}
                        </Badge>
                      )}
                      {anime.rating && (
                        <Badge variant="outline" className="text-xs">
                          {anime.rating}
                        </Badge>
                      )}
                    </div>
                    {anime.episodes && (
                      <div className="flex items-center space-x-4 text-sm text-muted-foreground">
                        {anime.episodes.sub > 0 && (
                          <div className="flex items-center space-x-1">
                            <Clock className="w-3 h-3" />
                            <span>SUB: {anime.episodes.sub}</span>
                          </div>
                        )}
                        {anime.episodes.dub > 0 && (
                          <div className="flex items-center space-x-1">
                            <Clock className="w-3 h-3" />
                            <span>DUB: {anime.episodes.dub}</span>
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                  <div className="flex items-center space-x-2 ml-4">
                    {showRank && anime.rank && (
                      <Badge variant="default" className="bg-primary/20 text-primary">
                        #{anime.rank}
                      </Badge>
                    )}
                    <Button size="sm" variant="ghost">
                      <Heart className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </motion.div>
    );
  }

  return (
    <motion.div
      variants={cardVariants}
      initial="hidden"
      animate="visible"
      whileHover="hover"
      className={sizeClasses[size]}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      <HoverCard openDelay={500}>
        <HoverCardTrigger asChild>
          <Card className="overflow-hidden hover:shadow-xl transition-all duration-300 border-border/50 bg-card/80 backdrop-blur-sm group cursor-pointer">
            <CardContent className="p-0 relative">
              <AspectRatio ratio={aspectRatios[size]}>
                <div className="relative w-full h-full overflow-hidden">
                  {/* Rank Badge */}
                  {showRank && anime.rank && (
                    <motion.div
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      className="absolute top-2 left-2 z-10"
                    >
                      <Badge 
                        variant="default" 
                        className="bg-primary/90 text-primary-foreground font-bold shadow-lg"
                      >
                        #{anime.rank}
                      </Badge>
                    </motion.div>
                  )}

                  {/* Image */}
                  <img
                    src={anime.poster}
                    alt={anime.name}
                    className={`w-full h-full object-cover transition-all duration-700 ${
                      isHovered ? 'scale-110' : 'scale-100'
                    } ${imageLoaded ? 'opacity-100' : 'opacity-0'}`}
                    onLoad={() => setImageLoaded(true)}
                  />

                  {/* Loading placeholder */}
                  {!imageLoaded && (
                    <div className="absolute inset-0 bg-muted animate-pulse" />
                  )}

                  {/* Overlay */}
                  <AnimatePresence>
                    {isHovered && (
                      <motion.div
                        variants={overlayVariants}
                        initial="hidden"
                        animate="visible"
                        exit="hidden"
                        className="absolute inset-0 bg-black/60 flex items-center justify-center"
                      >
                        <div className="flex space-x-2">
                          <motion.div
                            initial={{ scale: 0, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            transition={{ delay: 0.1 }}
                          >
                            <Link href={`/anime/${anime.id}`}>
                              <Button size="sm" className="bg-primary hover:bg-primary/90">
                                <Play className="w-4 h-4" />
                              </Button>
                            </Link>
                          </motion.div>
                          <motion.div
                            initial={{ scale: 0, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            transition={{ delay: 0.2 }}
                          >
                            <Link href={`/anime/${anime.id}`}>
                              <Button size="sm" variant="secondary">
                                <Info className="w-4 h-4" />
                              </Button>
                            </Link>
                          </motion.div>
                          <motion.div
                            initial={{ scale: 0, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            transition={{ delay: 0.3 }}
                          >
                            <Button size="sm" variant="secondary">
                              <Plus className="w-4 h-4" />
                            </Button>
                          </motion.div>
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>

                  {/* Episode count overlay */}
                  {anime.episodes && (anime.episodes.sub > 0 || anime.episodes.dub > 0) && (
                    <div className="absolute bottom-2 right-2">
                      <div className="flex space-x-1">
                        {anime.episodes.sub > 0 && (
                          <Badge variant="secondary" className="text-xs bg-black/70 text-white">
                            SUB {anime.episodes.sub}
                          </Badge>
                        )}
                        {anime.episodes.dub > 0 && (
                          <Badge variant="secondary" className="text-xs bg-black/70 text-white">
                            DUB {anime.episodes.dub}
                          </Badge>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </AspectRatio>

              {/* Info Section */}
              <div className="p-3">
                <Link href={`/anime/${anime.id}`}>
                  <h3 className="font-semibold text-foreground hover:text-primary transition-colors line-clamp-2 mb-2 leading-tight">
                    {anime.name}
                  </h3>
                </Link>

                {anime.jname && size !== 'sm' && (
                  <p className="text-xs text-muted-foreground mb-2 line-clamp-1">
                    {anime.jname}
                  </p>
                )}

                <div className="flex items-center justify-between">
                  <div className="flex flex-wrap gap-1">
                    {anime.type && (
                      <Badge variant="outline" className="text-xs">
                        {anime.type}
                      </Badge>
                    )}
                    {anime.rating && size !== 'sm' && (
                      <Badge variant="secondary" className="text-xs">
                        {anime.rating}
                      </Badge>
                    )}
                  </div>
                  
                  {anime.duration && size === 'lg' && (
                    <div className="flex items-center space-x-1 text-xs text-muted-foreground">
                      <Clock className="w-3 h-3" />
                      <span>{anime.duration}</span>
                    </div>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
        </HoverCardTrigger>

        <HoverCardContent className="w-80 p-4" side="right">
          <div className="space-y-3">
            <div>
              <h4 className="font-semibold">{anime.name}</h4>
              {anime.jname && (
                <p className="text-sm text-muted-foreground">{anime.jname}</p>
              )}
            </div>
            
            {anime.description && (
              <p className="text-sm line-clamp-3">{anime.description}</p>
            )}
            
            <div className="flex flex-wrap gap-2">
              {anime.type && (
                <Badge variant="secondary">{anime.type}</Badge>
              )}
              {anime.rating && (
                <Badge variant="outline">{anime.rating}</Badge>
              )}
              {anime.duration && (
                <Badge variant="outline">{anime.duration}</Badge>
              )}
            </div>

            {anime.episodes && (
              <div className="flex items-center space-x-4 text-sm">
                {anime.episodes.sub > 0 && (
                  <div className="flex items-center space-x-1">
                    <Clock className="w-3 h-3" />
                    <span>SUB: {anime.episodes.sub}</span>
                  </div>
                )}
                {anime.episodes.dub > 0 && (
                  <div className="flex items-center space-x-1">
                    <Clock className="w-3 h-3" />
                    <span>DUB: {anime.episodes.dub}</span>
                  </div>
                )}
              </div>
            )}

            <div className="flex space-x-2 pt-2">
              <Link href={`/anime/${anime.id}`} className="flex-1">
                <Button size="sm" className="w-full">
                  <Play className="w-3 h-3 mr-1" />
                  Watch
                </Button>
              </Link>
              <Button size="sm" variant="outline">
                <Plus className="w-3 h-3" />
              </Button>
            </div>
          </div>
        </HoverCardContent>
      </HoverCard>
    </motion.div>
  );
};

export default AnimeCard;
