'use client';

import React, { useRef } from 'react';
import { motion } from 'framer-motion';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';
import AnimeCard from './AnimeCard';
import type { Anime } from '@/lib/api';

interface AnimeCarouselProps {
  title: string;
  animes: Anime[];
  showRank?: boolean;
  size?: 'sm' | 'md' | 'lg';
  viewAllLink?: string;
}

const AnimeCarousel: React.FC<AnimeCarouselProps> = ({
  title,
  animes,
  showRank = false,
  size = 'md',
  viewAllLink
}) => {
  const scrollRef = useRef<HTMLDivElement>(null);

  const scroll = (direction: 'left' | 'right') => {
    if (scrollRef.current) {
      const scrollAmount = direction === 'left' ? -400 : 400;
      scrollRef.current.scrollBy({
        left: scrollAmount,
        behavior: 'smooth'
      });
    }
  };

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2
      }
    }
  };

  const titleVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0
    }
  };

  if (!animes || animes.length === 0) return null;

  return (
    <motion.section
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className="py-8"
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <motion.div variants={titleVariants}>
          <h2 className="text-2xl md:text-3xl font-bold text-foreground">
            {title}
          </h2>
          <div className="w-12 h-1 bg-primary mt-2 rounded-full" />
        </motion.div>

        <div className="flex items-center space-x-3">
          {/* Navigation Buttons */}
          <div className="hidden md:flex items-center space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => scroll('left')}
              className="h-8 w-8 p-0"
            >
              <ChevronLeft className="w-4 h-4" />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => scroll('right')}
              className="h-8 w-8 p-0"
            >
              <ChevronRight className="w-4 h-4" />
            </Button>
          </div>

          {/* View All Link */}
          {viewAllLink && (
            <Button variant="ghost" size="sm" asChild>
              <a href={viewAllLink}>View All</a>
            </Button>
          )}
        </div>
      </div>

      {/* Carousel */}
      <div className="relative group">
        {/* Left Navigation Button - Hidden on Mobile */}
        <motion.button
          onClick={() => scroll('left')}
          className="absolute left-0 top-1/2 -translate-y-1/2 z-10 bg-background/80 backdrop-blur-sm border border-border rounded-full p-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300 hidden md:block"
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          <ChevronLeft className="w-5 h-5" />
        </motion.button>

        {/* Right Navigation Button - Hidden on Mobile */}
        <motion.button
          onClick={() => scroll('right')}
          className="absolute right-0 top-1/2 -translate-y-1/2 z-10 bg-background/80 backdrop-blur-sm border border-border rounded-full p-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300 hidden md:block"
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          <ChevronRight className="w-5 h-5" />
        </motion.button>

        {/* Scroll Container */}
        <ScrollArea className="w-full">
          <div
            ref={scrollRef}
            className="flex space-x-4 overflow-x-auto scrollbar-none pb-4"
            style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
          >
            {animes.map((anime, index) => (
              <div key={anime.id} className="flex-shrink-0">
                <AnimeCard
                  anime={anime}
                  index={index}
                  showRank={showRank}
                  size={size}
                />
              </div>
            ))}
          </div>
        </ScrollArea>

        {/* Gradient Overlays for Desktop */}
        <div className="absolute left-0 top-0 bottom-0 w-16 bg-gradient-to-r from-background to-transparent pointer-events-none hidden md:block" />
        <div className="absolute right-0 top-0 bottom-0 w-16 bg-gradient-to-l from-background to-transparent pointer-events-none hidden md:block" />
      </div>
    </motion.section>
  );
};

export default AnimeCarousel;
