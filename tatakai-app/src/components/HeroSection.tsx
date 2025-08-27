'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { motion, AnimatePresence } from 'framer-motion';
import { Play, Info, Star, Calendar, Clock, Plus } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card } from '@/components/ui/card';
import type { SpotlightAnime } from '@/lib/api';

interface HeroSectionProps {
  spotlightAnimes: SpotlightAnime[];
}

const HeroSection: React.FC<HeroSectionProps> = ({ spotlightAnimes }) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isAutoPlaying, setIsAutoPlaying] = useState(true);

  const currentAnime = spotlightAnimes[currentIndex];

  useEffect(() => {
    if (isAutoPlaying && spotlightAnimes.length > 1) {
      const interval = setInterval(() => {
        setCurrentIndex((prev) => (prev + 1) % spotlightAnimes.length);
      }, 8000);

      return () => clearInterval(interval);
    }
  }, [isAutoPlaying, spotlightAnimes.length]);

  if (!currentAnime) return null;

  return (
    <div className="relative h-screen overflow-hidden">
      <AnimatePresence mode="wait">
        <motion.div
          key={currentIndex}
          initial={{ opacity: 0, scale: 1.1 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.95 }}
          transition={{ duration: 1, ease: "easeInOut" }}
          className="absolute inset-0"
        >
          {/* Background Image */}
          <div 
            className="absolute inset-0 bg-cover bg-center bg-no-repeat"
            style={{ 
              backgroundImage: `url(${currentAnime.poster})`,
            }}
          >
            {/* Gradient Overlays */}
            <div className="absolute inset-0 bg-gradient-to-r from-background via-background/80 to-transparent" />
            <div className="absolute inset-0 bg-gradient-to-t from-background via-transparent to-transparent" />
            <div className="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-background" />
          </div>

          {/* Content */}
          <div className="relative z-10 h-full flex items-center">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
              <div className="max-w-2xl">
                <motion.div
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.3, duration: 0.8 }}
                >
                  {/* Rank Badge */}
                  <motion.div
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.5 }}
                    className="flex items-center space-x-2 mb-4"
                  >
                    <Badge variant="secondary" className="bg-primary/20 text-primary border-primary/30">
                      <Star className="w-3 h-3 mr-1" />
                      #{currentAnime.rank} Spotlight
                    </Badge>
                  </motion.div>

                  {/* Title */}
                  <motion.h1
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.4, duration: 0.8 }}
                    className="text-4xl md:text-6xl lg:text-7xl font-bold text-foreground mb-4 leading-tight"
                  >
                    {currentAnime.name}
                  </motion.h1>

                  {/* Japanese Name */}
                  {currentAnime.jname && (
                    <motion.p
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.5, duration: 0.8 }}
                      className="text-lg text-muted-foreground mb-4"
                    >
                      {currentAnime.jname}
                    </motion.p>
                  )}

                  {/* Info Tags */}
                  <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.6, duration: 0.8 }}
                    className="flex flex-wrap items-center gap-3 mb-6"
                  >
                    {currentAnime.otherInfo?.map((info, index) => (
                      <Badge key={index} variant="outline" className="text-sm">
                        {info}
                      </Badge>
                    ))}
                    {currentAnime.episodes && (
                      <div className="flex items-center space-x-1 text-sm text-muted-foreground">
                        <Clock className="w-4 h-4" />
                        <span>{currentAnime.episodes.sub} Episodes</span>
                      </div>
                    )}
                  </motion.div>

                  {/* Description */}
                  <motion.p
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.7, duration: 0.8 }}
                    className="text-lg text-muted-foreground mb-8 line-clamp-3 leading-relaxed"
                  >
                    {currentAnime.description}
                  </motion.p>

                  {/* Action Buttons */}
                  <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.8, duration: 0.8 }}
                    className="flex flex-col sm:flex-row gap-4"
                  >
                    <Link href={`/watch/${currentAnime.id}?ep=1`}>
                      <Button 
                        size="lg" 
                        className="bg-primary hover:bg-primary/90 text-primary-foreground group w-full sm:w-auto"
                      >
                        <Play className="w-5 h-5 mr-2 group-hover:scale-110 transition-transform" />
                        Watch Now
                      </Button>
                    </Link>
                    
                    <Link href={`/anime/${currentAnime.id}`}>
                      <Button 
                        size="lg" 
                        variant="outline"
                        className="border-border hover:bg-accent w-full sm:w-auto"
                      >
                        <Info className="w-5 h-5 mr-2" />
                        More Info
                      </Button>
                    </Link>

                    <Button 
                      size="lg" 
                      variant="ghost"
                      className="hover:bg-accent"
                    >
                      <Plus className="w-5 h-5 mr-2" />
                      Add to List
                    </Button>
                  </motion.div>
                </motion.div>
              </div>
            </div>
          </div>
        </motion.div>
      </AnimatePresence>

      {/* Navigation Dots */}
      <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 z-20">
        <div className="flex space-x-2">
          {spotlightAnimes.map((_, index) => (
            <motion.button
              key={index}
              onClick={() => {
                setCurrentIndex(index);
                setIsAutoPlaying(false);
                setTimeout(() => setIsAutoPlaying(true), 10000);
              }}
              className={`w-2 h-2 rounded-full transition-all duration-300 ${
                index === currentIndex 
                  ? 'bg-primary w-8' 
                  : 'bg-muted-foreground/50 hover:bg-muted-foreground'
              }`}
              whileHover={{ scale: 1.2 }}
              whileTap={{ scale: 0.9 }}
            />
          ))}
        </div>
      </div>

      {/* Side Navigation */}
      <div className="absolute right-8 top-1/2 transform -translate-y-1/2 z-20 hidden lg:block">
        <div className="space-y-4">
          {spotlightAnimes.map((anime, index) => (
            <motion.button
              key={anime.id}
              onClick={() => {
                setCurrentIndex(index);
                setIsAutoPlaying(false);
                setTimeout(() => setIsAutoPlaying(true), 10000);
              }}
              className={`block transition-all duration-300 ${
                index === currentIndex ? 'opacity-100' : 'opacity-50 hover:opacity-75'
              }`}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <Card className={`p-3 w-48 ${
                index === currentIndex ? 'ring-2 ring-primary' : ''
              }`}>
                <div className="flex items-center space-x-3">
                  <img
                    src={anime.poster}
                    alt={anime.name}
                    className="w-12 h-16 object-cover rounded"
                  />
                  <div className="flex-1 text-left">
                    <h4 className="font-medium text-sm line-clamp-2">{anime.name}</h4>
                    <p className="text-xs text-muted-foreground">#{anime.rank}</p>
                  </div>
                </div>
              </Card>
            </motion.button>
          ))}
        </div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 1.5, duration: 0.8 }}
        className="absolute bottom-8 left-8 z-20 hidden md:block"
      >
        <div className="flex items-center space-x-2 text-muted-foreground">
          <div className="w-px h-12 bg-muted-foreground/30" />
          <motion.div
            animate={{ y: [0, 8, 0] }}
            transition={{ repeat: Infinity, duration: 2 }}
            className="text-sm"
          >
            Scroll to explore
          </motion.div>
        </div>
      </motion.div>
    </div>
  );
};

export default HeroSection;
