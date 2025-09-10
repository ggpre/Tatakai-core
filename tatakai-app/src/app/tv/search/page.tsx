'use client';

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { AnimeAPI } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Search, Gamepad2 } from 'lucide-react';
import Image from 'next/image';

interface ApiAnime {
  id?: string;
  animeId?: string;
  anilistId?: string;
  malId?: string;
  title?: string;
  name?: string;
  poster?: string;
  image?: string;
  img?: string;
  type?: string;
  status?: string;
  totalEpisodes?: number;
  episodes?: { sub?: number } | number;
  subOrDub?: string;
}

interface SearchResult {
  id: string;
  title: string;
  poster: string;
  type: string;
  status: string;
  totalEpisodes: number;
  subOrDub: string;
}

const KEYBOARD_LAYOUT = [
  ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ['SPACE', 'BACKSPACE', 'SEARCH', 'CLEAR']
];

const TVSearchPage = () => {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [focusedSection, setFocusedSection] = useState<'keyboard' | 'results'>('keyboard');
  const [focusedKey, setFocusedKey] = useState({ row: 0, col: 0 });
  const [focusedResult, setFocusedResult] = useState(0);

  const searchInputRef = useRef<HTMLInputElement>(null);
  const resultsRef = useRef<(HTMLDivElement | null)[]>([]);

  // Perform search
  const performSearch = async (query: string) => {
    if (!query.trim()) {
      setSearchResults([]);
      return;
    }

    setLoading(true);
    try {
      console.log('Searching for:', query);
      const response = await AnimeAPI.searchAnime(query);
      console.log('Full API response:', response);
      
      if (response.success && response.data) {
        // Check different possible data structures
        let animes: ApiAnime[] = [];
        
        if (response.data.animes) {
          animes = response.data.animes;
        } else if (Array.isArray(response.data)) {
          animes = response.data;
        } else if (response.data && 'results' in response.data) {
          animes = (response.data as { results: ApiAnime[] }).results;
        }
        
        console.log('📺 Found animes:', animes.length, animes);
        
        if (animes.length === 0) {
          setSearchResults([]);
          setFocusedSection('keyboard');
          return;
        }
        
        // Convert to the expected format
        const convertedResults: SearchResult[] = animes.map((anime: ApiAnime) => ({
          id: anime.id || anime.animeId || anime.anilistId || anime.malId || 'unknown',
          title: anime.title || anime.name || 'Unknown Title',
          poster: anime.poster || anime.image || anime.img || '/placeholder-anime.jpg',
          type: anime.type || 'TV',
          status: anime.status || 'Unknown',
          totalEpisodes: anime.totalEpisodes || 
            (typeof anime.episodes === 'object' ? anime.episodes?.sub || 0 : anime.episodes || 0),
          subOrDub: anime.subOrDub || 'Sub'
        }));
        
        console.log('✅ Converted results:', convertedResults);
        setSearchResults(convertedResults);
        setFocusedSection('results');
        setFocusedResult(0);
      } else {
        console.error('❌ Search failed or no success flag:', response);
        setSearchResults([]);
        setFocusedSection('keyboard');
      }
    } catch (error) {
      console.error('💥 Search error:', error);
      setSearchResults([]);
      setFocusedSection('keyboard');
    } finally {
      setLoading(false);
    }
  };

  // Handle virtual keyboard input
  const handleKeyboardInput = useCallback((key: string) => {
    let newQuery = searchQuery;

    switch (key) {
      case 'SPACE':
        newQuery = searchQuery + ' ';
        break;
      case 'BACKSPACE':
        newQuery = searchQuery.slice(0, -1);
        break;
      case 'SEARCH':
        performSearch(searchQuery);
        return;
      case 'CLEAR':
        newQuery = '';
        setSearchResults([]);
        break;
      default:
        newQuery = searchQuery + key.toLowerCase();
        break;
    }

    setSearchQuery(newQuery);
  }, [searchQuery]);

  // Navigate anime detail
  const navigateToAnime = useCallback((animeId: string) => {
    router.push(`/tv/anime/${animeId}`);
  }, [router]);

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      e.preventDefault();

      if (focusedSection === 'keyboard') {
        const maxRow = KEYBOARD_LAYOUT.length - 1;
        const maxCol = KEYBOARD_LAYOUT[focusedKey.row].length - 1;

        switch (e.key) {
          case 'ArrowUp':
            if (focusedKey.row > 0) {
              const newRow = focusedKey.row - 1;
              const newCol = Math.min(focusedKey.col, KEYBOARD_LAYOUT[newRow].length - 1);
              setFocusedKey({ row: newRow, col: newCol });
            }
            break;
          case 'ArrowDown':
            if (focusedKey.row < maxRow) {
              const newRow = focusedKey.row + 1;
              const newCol = Math.min(focusedKey.col, KEYBOARD_LAYOUT[newRow].length - 1);
              setFocusedKey({ row: newRow, col: newCol });
            } else if (searchResults.length > 0) {
              setFocusedSection('results');
              setFocusedResult(0);
            }
            break;
          case 'ArrowLeft':
            if (focusedKey.col > 0) {
              setFocusedKey(prev => ({ ...prev, col: prev.col - 1 }));
            }
            break;
          case 'ArrowRight':
            if (focusedKey.col < maxCol) {
              setFocusedKey(prev => ({ ...prev, col: prev.col + 1 }));
            }
            break;
          case 'Enter':
            const selectedKey = KEYBOARD_LAYOUT[focusedKey.row][focusedKey.col];
            handleKeyboardInput(selectedKey);
            break;
          case 'Escape':
          case 'Backspace':
            router.back();
            break;
        }
      } else if (focusedSection === 'results') {
        switch (e.key) {
          case 'ArrowUp':
            if (focusedResult > 0) {
              setFocusedResult(focusedResult - 1);
            } else {
              setFocusedSection('keyboard');
            }
            break;
          case 'ArrowDown':
            if (focusedResult < searchResults.length - 1) {
              setFocusedResult(focusedResult + 1);
            }
            break;
          case 'ArrowLeft':
            if (focusedResult >= 4) {
              setFocusedResult(focusedResult - 4);
            }
            break;
          case 'ArrowRight':
            if (focusedResult + 4 < searchResults.length) {
              setFocusedResult(focusedResult + 4);
            }
            break;
          case 'Enter':
            if (searchResults[focusedResult]) {
              navigateToAnime(searchResults[focusedResult].id);
            }
            break;
          case 'Escape':
          case 'Backspace':
            setFocusedSection('keyboard');
            break;
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [focusedSection, focusedKey, focusedResult, searchResults, router, searchQuery]);

  // Scroll focused result into view
  useEffect(() => {
    if (focusedSection === 'results' && resultsRef.current[focusedResult]) {
      resultsRef.current[focusedResult]?.scrollIntoView({
        behavior: 'smooth',
        block: 'nearest'
      });
    }
  }, [focusedSection, focusedResult]);

  return (
    <div className="min-h-screen bg-black text-white p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-4xl font-bold mb-4 flex items-center gap-3">
          <Search className="w-10 h-10" /> Search Anime
        </h1>
        <div className="text-xl text-gray-300">
          Use the virtual keyboard to search for anime
        </div>
      </div>

      {/* Search Input Display */}
      <div className="mb-8">
        <div className="bg-gray-800 rounded-lg p-4 border-2 border-gray-600">
          <div className="flex items-center space-x-4">
            <Search className="w-6 h-6" />
            <input
              ref={searchInputRef}
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="flex-1 bg-transparent text-2xl text-white placeholder-gray-400 outline-none"
              placeholder="Type to search..."
              readOnly
            />
            {searchQuery && (
              <Button
                variant="ghost"
                onClick={() => {
                  setSearchQuery('');
                  setSearchResults([]);
                }}
                className="text-xl p-2"
              >
                ❌
              </Button>
            )}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-8">
        {/* Virtual Keyboard */}
        <div className="space-y-4">
          <h2 className="text-2xl font-bold mb-4">Virtual Keyboard</h2>
          <div className="space-y-3">
            {KEYBOARD_LAYOUT.map((row, rowIndex) => (
              <div key={rowIndex} className="flex gap-2 justify-center">
                {row.map((key, colIndex) => (
                  <Button
                    key={`${rowIndex}-${colIndex}`}
                    variant={
                      focusedSection === 'keyboard' && 
                      focusedKey.row === rowIndex && 
                      focusedKey.col === colIndex 
                        ? "default" 
                        : "outline"
                    }
                    onClick={() => handleKeyboardInput(key)}
                    className={`
                      min-w-[60px] h-14 text-lg font-bold transition-all
                      ${focusedSection === 'keyboard' && 
                        focusedKey.row === rowIndex && 
                        focusedKey.col === colIndex 
                        ? 'ring-4 ring-rose-500 bg-rose-500 scale-110' 
                        : 'hover:bg-gray-700'}
                      ${key === 'SPACE' ? 'min-w-[200px]' : ''}
                      ${['BACKSPACE', 'SEARCH', 'CLEAR'].includes(key) ? 'min-w-[100px]' : ''}
                    `}
                  >
                    {key === 'SPACE' ? '⎵ SPACE' : 
                     key === 'BACKSPACE' ? '⌫' :
                     key === 'SEARCH' ? <><Search className="w-4 h-4 inline mr-1" /> SEARCH</> :
                     key === 'CLEAR' ? '🗑️ CLEAR' : key}
                  </Button>
                ))}
              </div>
            ))}
          </div>

          {/* Instructions */}
          <div className="mt-6 p-4 bg-gray-800 rounded-lg">
            <h3 className="font-bold mb-2 flex items-center">
              <Gamepad2 className="w-5 h-5 mr-2" />
              TV Remote Controls:
            </h3>
            <div className="text-sm space-y-1 text-gray-300">
              <div>• Arrow Keys: Navigate keyboard/results</div>
              <div>• Enter: Select key or anime</div>
              <div>• Escape: Go back</div>
              <div>• Down from keyboard: Go to results</div>
            </div>
          </div>
        </div>

        {/* Search Results */}
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-bold">
              Search Results {searchResults.length > 0 && `(${searchResults.length})`}
            </h2>
            {loading && (
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-rose-500"></div>
            )}
          </div>

          {searchResults.length > 0 ? (
            <div className="grid grid-cols-4 gap-4 max-h-[600px] overflow-y-auto">
              {searchResults.map((anime, index) => (
                <div
                  key={anime.id}
                  ref={(el) => { resultsRef.current[index] = el; }}
                  onClick={() => navigateToAnime(anime.id)}
                  className={`
                    bg-gray-800 rounded-lg overflow-hidden cursor-pointer transition-all duration-200
                    ${focusedSection === 'results' && focusedResult === index
                      ? 'ring-4 ring-rose-500 scale-105 z-10' 
                      : 'hover:bg-gray-700'}
                  `}
                >
                  <div className="aspect-[3/4] relative">
                    <Image
                      src={anime.poster}
                      alt={anime.title}
                      fill
                      className="object-cover"
                      onError={(e) => {
                        const target = e.target as HTMLImageElement;
                        target.src = '/placeholder-anime.jpg';
                      }}
                    />
                  </div>
                  <div className="p-3">
                    <h3 className="font-bold text-sm mb-2 line-clamp-2">
                      {anime.title}
                    </h3>
                    <div className="space-y-1">
                      <Badge variant="outline" className="text-xs">
                        {anime.type}
                      </Badge>
                      {anime.totalEpisodes && (
                        <div className="text-xs text-gray-400">
                          {anime.totalEpisodes} episodes
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : searchQuery ? (
            <div className="text-center py-12 text-gray-400">
              {loading ? (
                <div className="space-y-4">
                  <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-rose-500 mx-auto"></div>
                  <div>Searching for &quot;{searchQuery}&quot;...</div>
                </div>
              ) : (
                <div className="space-y-4">
                  <div className="text-6xl">😢</div>
                  <div>No results found for &quot;{searchQuery}&quot;</div>
                  <div className="text-sm">Try different keywords</div>
                </div>
              )}
            </div>
          ) : (
            <div className="text-center py-12 text-gray-400">
              <div className="space-y-4">
                <div className="text-6xl">
                  <Search className="w-24 h-24 mx-auto" />
                </div>
                <div>Enter a search term to find anime</div>
                <div className="text-sm">Use the virtual keyboard to type</div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default TVSearchPage;
