'use client';

import React from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { 
  Play, 
  Github, 
  MessageCircle, 
  Mail, 
  Heart,
  ArrowUp,
  Star,
  Film,
  Tv,
  TrendingUp
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';

// Twitter icon SVG (since it's not in lucide-react)
const TwitterIcon = (props: React.SVGProps<SVGSVGElement>) => (
  <svg {...props} viewBox="0 0 24 24" fill="currentColor">
    <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
  </svg>
);

const Footer = () => {
  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const footerLinks = {
    anime: [
      { name: 'Latest Episodes', href: '/category/recently-updated' },
      { name: 'Popular Anime', href: '/category/most-popular' },
      { name: 'Top Rated', href: '/category/most-favorite' },
      { name: 'Completed Series', href: '/category/completed' },
    ],
    categories: [
      { name: 'TV Series', href: '/category/tv' },
      { name: 'Movies', href: '/category/movie' },
      { name: 'OVA', href: '/category/ova' },
      { name: 'ONA', href: '/category/ona' },
    ],
    genres: [
      { name: 'Action', href: '/genre/action' },
      { name: 'Adventure', href: '/genre/adventure' },
      { name: 'Comedy', href: '/genre/comedy' },
      { name: 'Drama', href: '/genre/drama' },
    ],
    support: [
      { name: 'About Us', href: '/about' },
      { name: 'Contact', href: '/contact' },
      { name: 'Privacy Policy', href: '/privacy' },
      { name: 'Terms of Service', href: '/terms' },
    ]
  };

  const socialLinks = [
    { name: 'GitHub', icon: Github, href: '#', color: 'hover:text-gray-400' },
    { name: 'Twitter', icon: TwitterIcon, href: '#', color: 'hover:text-blue-400' },
    { name: 'Discord', icon: MessageCircle, href: '#', color: 'hover:text-indigo-400' },
    { name: 'Email', icon: Mail, href: '#', color: 'hover:text-red-400' },
  ];

  const features = [
    { icon: Star, text: 'High Quality Streaming' },
    { icon: Film, text: 'Latest Anime Updates' },
    { icon: Tv, text: 'Multiple Seasons' },
    { icon: TrendingUp, text: 'Trending Content' },
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
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.5 }
    }
  };

  return (
    <footer className="bg-card/50 backdrop-blur-sm border-t border-border">
      {/* Main Footer Content */}
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12"
      >
        {/* Top Section */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8 mb-8">
          {/* Brand Section */}
          <motion.div variants={itemVariants} className="lg:col-span-2">
            <div className="flex items-center space-x-2 mb-4">
              <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                <Play className="w-5 h-5 text-primary-foreground" />
              </div>
              <span className="text-2xl font-bold text-foreground">Tatakai</span>
            </div>
            
            <p className="text-muted-foreground mb-6 max-w-md">
              Your ultimate destination for anime streaming. Watch the latest episodes, 
              discover new series, and enjoy high-quality content anytime, anywhere.
            </p>

            {/* Features */}
            <div className="grid grid-cols-2 gap-3">
              {features.map((feature, index) => (
                <motion.div
                  key={feature.text}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.5 + index * 0.1 }}
                  className="flex items-center space-x-2 text-sm text-muted-foreground"
                >
                  <feature.icon className="w-4 h-4 text-primary" />
                  <span>{feature.text}</span>
                </motion.div>
              ))}
            </div>
          </motion.div>

          {/* Anime Links */}
          <motion.div variants={itemVariants}>
            <h3 className="font-semibold text-foreground mb-4">Anime</h3>
            <ul className="space-y-2">
              {footerLinks.anime.map((link) => (
                <li key={link.name}>
                  <Link
                    href={link.href}
                    className="text-muted-foreground hover:text-primary transition-colors text-sm"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </motion.div>

          {/* Categories */}
          <motion.div variants={itemVariants}>
            <h3 className="font-semibold text-foreground mb-4">Categories</h3>
            <ul className="space-y-2">
              {footerLinks.categories.map((link) => (
                <li key={link.name}>
                  <Link
                    href={link.href}
                    className="text-muted-foreground hover:text-primary transition-colors text-sm"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </motion.div>

          {/* Support */}
          <motion.div variants={itemVariants}>
            <h3 className="font-semibold text-foreground mb-4">Support</h3>
            <ul className="space-y-2">
              {footerLinks.support.map((link) => (
                <li key={link.name}>
                  <Link
                    href={link.href}
                    className="text-muted-foreground hover:text-primary transition-colors text-sm"
                  >
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </motion.div>
        </div>

        <Separator className="my-8" />

        {/* Bottom Section */}
        <div className="flex flex-col md:flex-row items-center justify-between">
          <motion.div
            variants={itemVariants}
            className="flex items-center space-x-1 text-muted-foreground text-sm mb-4 md:mb-0"
          >
            <span>Made with</span>
            <Heart className="w-4 h-4 text-red-500" />
            <span>by the Tatakai team</span>
          </motion.div>

          {/* Social Links */}
          <motion.div
            variants={itemVariants}
            className="flex items-center space-x-4 mb-4 md:mb-0"
          >
            {socialLinks.map((social) => (
              <motion.a
                key={social.name}
                href={social.href}
                className={`text-muted-foreground ${social.color} transition-colors`}
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                aria-label={social.name}
              >
                <social.icon className="w-5 h-5" />
              </motion.a>
            ))}
          </motion.div>

          {/* Scroll to Top */}
          <motion.div variants={itemVariants}>
            <Button
              variant="outline"
              size="sm"
              onClick={scrollToTop}
              className="h-8"
            >
              <ArrowUp className="w-4 h-4 mr-1" />
              Top
            </Button>
          </motion.div>
        </div>

        <Separator className="my-6" />

        {/* Copyright */}
        <motion.div
          variants={itemVariants}
          className="text-center text-sm text-muted-foreground"
        >
          <p>
            © {new Date().getFullYear()} Tatakai. All rights reserved. 
            This site does not store any files on our server, we only linked to the media which is hosted on 3rd party services.
          </p>
        </motion.div>
      </motion.div>
    </footer>
  );
};

export default Footer;
