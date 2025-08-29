'use client';

import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { User, Edit, Heart, Clock, BarChart3, Settings } from 'lucide-react';

const ProfilePage = () => {
  const [activeTab, setActiveTab] = useState('favorites');

  const tabs = [
    { id: 'favorites', label: 'Favorites', icon: Heart },
    { id: 'watching', label: 'Watching', icon: Clock },
    { id: 'stats', label: 'Statistics', icon: BarChart3 },
  ];

  return (
    <div className="min-h-screen bg-background pt-20">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Profile Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-card rounded-lg p-8 mb-8"
        >
          <div className="flex items-center space-x-6">
            <div className="w-24 h-24 bg-primary/20 rounded-full flex items-center justify-center">
              <User className="w-12 h-12 text-primary" />
            </div>
            <div className="flex-1">
              <h1 className="text-3xl font-bold text-foreground mb-2">Guest User</h1>
              <p className="text-muted-foreground mb-4">
                Anime enthusiast and otaku since 2020
              </p>
              <div className="flex items-center space-x-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-foreground">42</div>
                  <div className="text-sm text-muted-foreground">Favorites</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-foreground">12</div>
                  <div className="text-sm text-muted-foreground">Watching</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-foreground">156</div>
                  <div className="text-sm text-muted-foreground">Completed</div>
                </div>
              </div>
            </div>
            <button className="flex items-center space-x-2 px-4 py-2 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors">
              <Edit className="w-4 h-4" />
              <span>Edit Profile</span>
            </button>
          </div>
        </motion.div>

        {/* Profile Tabs */}
        <div className="bg-card rounded-lg">
          <div className="border-b border-border">
            <nav className="flex space-x-8 px-6">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center space-x-2 py-4 border-b-2 font-medium transition-colors ${
                    activeTab === tab.id
                      ? 'border-primary text-primary'
                      : 'border-transparent text-muted-foreground hover:text-foreground'
                  }`}
                >
                  <tab.icon className="w-4 h-4" />
                  <span>{tab.label}</span>
                </button>
              ))}
            </nav>
          </div>

          <div className="p-6">
            {activeTab === 'favorites' && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="text-center py-12"
              >
                <Heart className="w-16 h-16 text-muted-foreground mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-foreground mb-2">No Favorites Yet</h3>
                <p className="text-muted-foreground">
                  Start adding anime to your favorites to see them here.
                </p>
              </motion.div>
            )}

            {activeTab === 'watching' && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="text-center py-12"
              >
                <Clock className="w-16 h-16 text-muted-foreground mx-auto mb-4" />
                <h3 className="text-xl font-semibold text-foreground mb-2">Nothing Currently Watching</h3>
                <p className="text-muted-foreground">
                  Browse our collection and start watching your next favorite anime.
                </p>
              </motion.div>
            )}

            {activeTab === 'stats' && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="grid grid-cols-1 md:grid-cols-2 gap-6"
              >
                <div className="bg-muted/50 rounded-lg p-6">
                  <h4 className="font-semibold text-foreground mb-4">Watch Time</h4>
                  <div className="text-3xl font-bold text-primary mb-2">2,340</div>
                  <div className="text-sm text-muted-foreground">Hours watched</div>
                </div>
                <div className="bg-muted/50 rounded-lg p-6">
                  <h4 className="font-semibold text-foreground mb-4">Episodes</h4>
                  <div className="text-3xl font-bold text-primary mb-2">1,856</div>
                  <div className="text-sm text-muted-foreground">Episodes completed</div>
                </div>
                <div className="bg-muted/50 rounded-lg p-6">
                  <h4 className="font-semibold text-foreground mb-4">Favorite Genre</h4>
                  <div className="text-xl font-bold text-primary mb-2">Action</div>
                  <div className="text-sm text-muted-foreground">Most watched genre</div>
                </div>
                <div className="bg-muted/50 rounded-lg p-6">
                  <h4 className="font-semibold text-foreground mb-4">Rating Average</h4>
                  <div className="text-3xl font-bold text-primary mb-2">8.7</div>
                  <div className="text-sm text-muted-foreground">Your average rating</div>
                </div>
              </motion.div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;
