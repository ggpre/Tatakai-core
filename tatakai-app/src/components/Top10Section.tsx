'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Play, Star, TrendingUp, Calendar } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import type { Anime } from '@/lib/api';

interface Top10SectionProps {
  top10Animes: {
    today: Anime[];
    week: Anime[];
    month: Anime[];
  };
}

const Top10Section: React.FC<Top10SectionProps> = ({ top10Animes }) => {
  const [activeTab, setActiveTab] = useState('today');
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const tabData = [
    { value: 'today', label: 'Today', icon: Star, animes: top10Animes.today },
    { value: 'week', label: 'This Week', icon: TrendingUp, animes: top10Animes.week },
    { value: 'month', label: 'This Month', icon: Calendar, animes: top10Animes.month },
  ];

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

  const itemVariants = {
    hidden: { opacity: 0, x: -20 },
    visible: {
      opacity: 1,
      x: 0,
      transition: { duration: 0.5 }
    }
  };

  const getRankBg = (rank: number) => {
    if (rank === 1) return 'bg-gradient-to-r from-yellow-500 to-yellow-600';
    if (rank === 2) return 'bg-gradient-to-r from-gray-400 to-gray-500';
    if (rank === 3) return 'bg-gradient-to-r from-amber-600 to-amber-700';
    return 'bg-primary';
  };

  // Don't render until mounted to prevent hydration issues
  if (!mounted) {
    return (
      <section className="py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="h-8 bg-gray-200 animate-pulse rounded mb-8"></div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="space-y-4">
                <div className="h-6 bg-gray-200 animate-pulse rounded"></div>
                {[...Array(10)].map((_, j) => (
                  <div key={j} className="h-20 bg-gray-200 animate-pulse rounded"></div>
                ))}
              </div>
            ))}
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className="py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-8"
        >
          <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-4">
            Top 10 Anime
          </h2>
          <p className="text-muted-foreground max-w-2xl mx-auto">
            Discover the most popular and trending anime series
          </p>
          <div className="w-20 h-1 bg-primary mx-auto mt-4 rounded-full" />
        </motion.div>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-3 mb-8">
            {tabData.map((tab) => (
              <TabsTrigger
                key={tab.value}
                value={tab.value}
                className="flex items-center space-x-2"
              >
                <tab.icon className="w-4 h-4" />
                <span>{tab.label}</span>
              </TabsTrigger>
            ))}
          </TabsList>

          {tabData.map((tab) => (
            <TabsContent key={tab.value} value={tab.value}>
              <AnimatePresence mode="wait">
                <motion.div
                  key={tab.value}
                  variants={containerVariants}
                  initial="hidden"
                  animate="visible"
                  exit="hidden"
                  className="grid grid-cols-1 lg:grid-cols-2 gap-6"
                >
                  {/* Left Column - Top 5 */}
                  <div className="space-y-4">
                    <h3 className="text-xl font-semibold text-foreground mb-4">
                      Top 5
                    </h3>
                    {tab.animes?.slice(0, 5).map((anime, index) => (
                      <motion.div
                        key={anime.id}
                        variants={itemVariants}
                        className="group"
                      >
                        <Card className="overflow-hidden hover:shadow-lg transition-all duration-300 border-border/50 bg-card/80 backdrop-blur-sm">
                          <CardContent className="p-0">
                            <div className="flex items-center">
                              {/* Rank */}
                              <div className={`w-16 h-20 flex items-center justify-center ${getRankBg(index + 1)} text-white font-bold text-lg`}>
                                #{index + 1}
                              </div>

                              {/* Poster */}
                              <div className="w-14 h-20 flex-shrink-0">
                                <img
                                  src={anime.poster}
                                  alt={anime.name}
                                  className="w-full h-full object-cover"
                                />
                              </div>

                              {/* Info */}
                              <div className="flex-1 p-4">
                                <h4 className="font-semibold text-foreground group-hover:text-primary transition-colors line-clamp-2 mb-2">
                                  {anime.name}
                                </h4>
                                
                                <div className="flex items-center space-x-3 mb-2">
                                  {anime.type && (
                                    <Badge variant="secondary" className="text-xs">
                                      {anime.type}
                                    </Badge>
                                  )}
                                  {anime.episodes && anime.episodes.sub > 0 && (
                                    <span className="text-xs text-muted-foreground">
                                      {anime.episodes.sub} Episodes
                                    </span>
                                  )}
                                </div>

                                <div className="flex items-center space-x-2">
                                  <Button size="sm" className="h-7">
                                    <Play className="w-3 h-3 mr-1" />
                                    Watch
                                  </Button>
                                  <Button size="sm" variant="outline" className="h-7">
                                    Info
                                  </Button>
                                </div>
                              </div>
                            </div>
                          </CardContent>
                        </Card>
                      </motion.div>
                    ))}
                  </div>

                  {/* Right Column - Top 6-10 */}
                  <div className="space-y-4">
                    <h3 className="text-xl font-semibold text-foreground mb-4">
                      Top 6-10
                    </h3>
                    {tab.animes?.slice(5, 10).map((anime, index) => (
                      <motion.div
                        key={anime.id}
                        variants={itemVariants}
                        className="group"
                      >
                        <Card className="overflow-hidden hover:shadow-lg transition-all duration-300 border-border/50 bg-card/80 backdrop-blur-sm">
                          <CardContent className="p-0">
                            <div className="flex items-center">
                              {/* Rank */}
                              <div className="w-16 h-20 flex items-center justify-center bg-primary text-primary-foreground font-bold text-lg">
                                #{index + 6}
                              </div>

                              {/* Poster */}
                              <div className="w-14 h-20 flex-shrink-0">
                                <img
                                  src={anime.poster}
                                  alt={anime.name}
                                  className="w-full h-full object-cover"
                                />
                              </div>

                              {/* Info */}
                              <div className="flex-1 p-4">
                                <h4 className="font-semibold text-foreground group-hover:text-primary transition-colors line-clamp-2 mb-2">
                                  {anime.name}
                                </h4>
                                
                                <div className="flex items-center space-x-3 mb-2">
                                  {anime.type && (
                                    <Badge variant="secondary" className="text-xs">
                                      {anime.type}
                                    </Badge>
                                  )}
                                  {anime.episodes && anime.episodes.sub > 0 && (
                                    <span className="text-xs text-muted-foreground">
                                      {anime.episodes.sub} Episodes
                                    </span>
                                  )}
                                </div>

                                <div className="flex items-center space-x-2">
                                  <Button size="sm" className="h-7">
                                    <Play className="w-3 h-3 mr-1" />
                                    Watch
                                  </Button>
                                  <Button size="sm" variant="outline" className="h-7">
                                    Info
                                  </Button>
                                </div>
                              </div>
                            </div>
                          </CardContent>
                        </Card>
                      </motion.div>
                    ))}
                  </div>
                </motion.div>
              </AnimatePresence>
            </TabsContent>
          ))}
        </Tabs>
      </div>
    </section>
  );
};

export default Top10Section;
