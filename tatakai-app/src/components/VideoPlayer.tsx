'use client';

import React, {
  useEffect,
  useRef,
  useState,
  useImperativeHandle,
  useCallback,
} from 'react';
import { Button } from '@/components/ui/button';
import { 
  Play, 
  Pause, 
  ClipboardList, 
  Rewind, 
  FastForward, 
  VolumeX, 
  Volume2, 
  MessageCircle, 
  Maximize, 
  Minimize 
} from 'lucide-react';
// Using minimal imports to avoid lucide-react issues
import type Hls from 'hls.js';

interface VideoSource {
  url: string;
  quality?: string;
  isM3U8: boolean;
  type?: string;
}

interface VideoSubtitle {
  url: string;
  lang: string;
  label?: string;
}

interface VideoPlayerProps {
  sources: VideoSource[];
  subtitles?: VideoSubtitle[];
  onPlay?: () => void;
  onPause?: () => void;
  onShowEpisodes?: () => void;
}

export interface VideoPlayerRef {
  play: () => Promise<void>;
  pause: () => void;
  currentTime: number;
  duration: number;
}

const VideoPlayer = React.forwardRef<VideoPlayerRef, VideoPlayerProps>(
  ({ sources, subtitles, onPlay, onPause, onShowEpisodes }, ref) => {
    const videoRef = useRef<HTMLVideoElement>(null);
    const hlsRef = useRef<Hls | null>(null);

    const [isPlaying, setIsPlaying] = useState(false);
    const [isMuted, setIsMuted] = useState(false);
    const [currentTime, setCurrentTime] = useState(0);
    const [duration, setDuration] = useState(0);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const [showControls, setShowControls] = useState(true);
    const [isFullscreen, setIsFullscreen] = useState(false);
    
    // TV subtitle control states
    const [subtitlesEnabled, setSubtitlesEnabled] = useState(true);
    const [currentSubtitleTrack, setCurrentSubtitleTrack] = useState(0);
    const [showSubtitleMenu, setShowSubtitleMenu] = useState(false);
    const [focusedControl, setFocusedControl] = useState<'rewind' | 'play' | 'forward' | 'volume' | 'subtitle' | 'episodes' | 'fullscreen'>('play');

    const [seekMessage, setSeekMessage] = useState<string | null>(null);
    const seekMessageTimer = useRef<NodeJS.Timeout | null>(null);
    const subtitleMenuRef = useRef<HTMLDivElement>(null);
    const subtitleScrollContainerRef = useRef<HTMLDivElement>(null);
    const subtitleItemsRef = useRef<(HTMLDivElement | null)[]>([]);

    const idleTimer = useRef<NodeJS.Timeout | null>(null);

    const currentSource = sources.find((s) => s.isM3U8) ?? sources[0];

    const getProxiedUrl = (url: string) =>
      url.startsWith('/api/video-proxy')
        ? url
        : url.startsWith('http')
        ? `/api/video-proxy?url=${encodeURIComponent(url)}`
        : url;

    // Load video + HLS
    useEffect(() => {
      const video = videoRef.current;
      if (!video || !currentSource) return;

      const loadVideo = async () => {
        try {
          setError(null);
          setIsLoading(true);
          const proxiedUrl = getProxiedUrl(currentSource.url);

          if (currentSource.isM3U8) {
            const Hls = (await import('hls.js')).default;
            if (Hls.isSupported()) {
              if (hlsRef.current) {
                hlsRef.current.destroy();
              }
              const hls = new Hls();
              hlsRef.current = hls;
              hls.loadSource(proxiedUrl);
              hls.attachMedia(video);
              hls.on(Hls.Events.MANIFEST_PARSED, () => {
                setIsLoading(false);
              });
              hls.on(Hls.Events.ERROR, (_evt, data) => {
                if (data.fatal) {
                  setError('HLS error: ' + data.details);
                  setIsLoading(false);
                }
              });
            } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
              video.src = proxiedUrl;
            } else {
              setError('HLS not supported');
              setIsLoading(false);
            }
          } else {
            video.src = proxiedUrl;
          }
        } catch (err) {
          console.error(err);
          setError('Failed to load video');
          setIsLoading(false);
        }
      };

      loadVideo();

      return () => {
        if (hlsRef.current) {
          hlsRef.current.destroy();
          hlsRef.current = null;
        }
      };
    }, [currentSource]);

    // Idle timer -> fake fullscreen
    useEffect(() => {
      const resetIdleTimer = () => {
        if (idleTimer.current) clearTimeout(idleTimer.current);
        idleTimer.current = setTimeout(() => {
          setIsFullscreen(true);
          setShowControls(false);
        }, 30000); // Changed from 10000 to 30000 (30 seconds instead of 10)
      };

      const activityEvents = ['keydown', 'click'];
      activityEvents.forEach((evt) =>
        window.addEventListener(evt, resetIdleTimer)
      );

      resetIdleTimer();

      return () => {
        if (idleTimer.current) clearTimeout(idleTimer.current);
        activityEvents.forEach((evt) =>
          window.removeEventListener(evt, resetIdleTimer)
        );
      };
    }, []);

    // Scroll focused subtitle into view
    useEffect(() => {
      if (showSubtitleMenu && subtitleItemsRef.current[currentSubtitleTrack] && subtitleScrollContainerRef.current) {
        const targetElement = subtitleItemsRef.current[currentSubtitleTrack];
        const container = subtitleScrollContainerRef.current;
        
        if (targetElement && container) {
          const containerRect = container.getBoundingClientRect();
          const targetRect = targetElement.getBoundingClientRect();
          
          // Check if element is out of view
          const isOutOfView = 
            targetRect.top < containerRect.top || 
            targetRect.bottom > containerRect.bottom;
          
          if (isOutOfView) {
            // Calculate the scroll position to center the element
            const containerHeight = container.clientHeight;
            const targetHeight = targetElement.offsetHeight;
            const targetOffsetTop = targetElement.offsetTop;
            
            const scrollTop = targetOffsetTop - (containerHeight / 2) + (targetHeight / 2);
            
            container.scrollTo({
              top: Math.max(0, scrollTop),
              behavior: 'smooth'
            });
          }
        }
      }
    }, [showSubtitleMenu, currentSubtitleTrack]);

    const togglePlay = useCallback(async () => {
      const video = videoRef.current;
      if (!video) return;
      if (isPlaying) {
        video.pause();
        setIsPlaying(false);
      } else {
        await video.play();
        setIsPlaying(true);
      }
    }, [isPlaying]);

    const toggleMute = () => {
      const video = videoRef.current;
      if (!video) return;
      video.muted = !video.muted;
      setIsMuted(video.muted);
    };

    const toggleFullscreen = () => {
      setIsFullscreen((prev) => !prev);
    };

    const seek = (seconds: number) => {
      const video = videoRef.current;
      if (!video) return;
      const newTime = Math.min(Math.max(video.currentTime + seconds, 0), duration);
      video.currentTime = newTime;

      if (seekMessageTimer.current) {
        clearTimeout(seekMessageTimer.current);
      }
      setSeekMessage(seconds > 0 ? `>> +${seconds}s` : `<< ${seconds}s`);
      seekMessageTimer.current = setTimeout(() => setSeekMessage(null), 1000);
    };

    const formatTime = (time: number) => {
      const minutes = Math.floor(time / 60);
      const seconds = Math.floor(time % 60);
      return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    };

    // Subtitle control functions
    const toggleSubtitles = useCallback(() => {
      if (videoRef.current) {
        const textTracks = videoRef.current.textTracks;
        if (textTracks.length > 0) {
          if (subtitlesEnabled) {
            // Disable all tracks
            for (let i = 0; i < textTracks.length; i++) {
              textTracks[i].mode = 'disabled';
            }
            setSubtitlesEnabled(false);
          } else {
            // Enable current track
            if (textTracks[currentSubtitleTrack]) {
              textTracks[currentSubtitleTrack].mode = 'showing';
            }
            setSubtitlesEnabled(true);
          }
        }
      }
    }, [subtitlesEnabled, currentSubtitleTrack]);

    const switchSubtitleTrack = useCallback((trackIndex: number) => {
      if (videoRef.current) {
        const textTracks = videoRef.current.textTracks;
        // Disable all tracks
        for (let i = 0; i < textTracks.length; i++) {
          textTracks[i].mode = 'disabled';
        }
        // Enable selected track
        if (textTracks[trackIndex]) {
          textTracks[trackIndex].mode = 'showing';
          setCurrentSubtitleTrack(trackIndex);
          setSubtitlesEnabled(true);
        }
      }
    }, []);

    // LG TV remote keys
    useEffect(() => {
      const handleKey = (e: KeyboardEvent) => {
        if (showSubtitleMenu) {
          // Subtitle menu navigation
          switch (e.key) {
            case 'ArrowUp':
              e.preventDefault();
              if (currentSubtitleTrack > 0) {
                setCurrentSubtitleTrack(currentSubtitleTrack - 1);
              }
              break;
            case 'ArrowDown':
              e.preventDefault();
              if (subtitles && currentSubtitleTrack < subtitles.length - 1) {
                setCurrentSubtitleTrack(currentSubtitleTrack + 1);
              }
              break;
            case 'Enter':
              e.preventDefault();
              switchSubtitleTrack(currentSubtitleTrack);
              setShowSubtitleMenu(false);
              break;
            case 'Escape':
            case 'Backspace':
              e.preventDefault();
              setShowSubtitleMenu(false);
              break;
          }
          return;
        }

        switch (e.key) {
          case 'Enter': // OK button
            e.preventDefault();
            if (focusedControl === 'rewind') {
              seek(-10);
            } else if (focusedControl === 'play') {
              togglePlay();
            } else if (focusedControl === 'forward') {
              seek(10);
            } else if (focusedControl === 'volume') {
              toggleMute();
            } else if (focusedControl === 'subtitle') {
              if (subtitles && subtitles.length > 0) {
                setShowSubtitleMenu(true);
              } else {
                toggleSubtitles();
              }
            } else if (focusedControl === 'episodes') {
              onShowEpisodes?.();
            } else if (focusedControl === 'fullscreen') {
              toggleFullscreen();
            }
            setShowControls(true);
            break;
          case 'ArrowLeft':
            e.preventDefault();
            // Always show controls first on arrow key press
            setShowControls(true);
            if (showControls || true) { // Force control navigation for TV
              // Navigate controls
              const controls = ['rewind', 'play', 'forward', 'volume', 'subtitle', 'episodes', 'fullscreen'] as const;
              const currentIndex = controls.indexOf(focusedControl);
              if (currentIndex > 0) {
                setFocusedControl(controls[currentIndex - 1]);
              }
            }
            break;
          case 'ArrowRight':
            e.preventDefault();
            // Always show controls first on arrow key press
            setShowControls(true);
            if (showControls || true) { // Force control navigation for TV
              // Navigate controls
              const controls = ['rewind', 'play', 'forward', 'volume', 'subtitle', 'episodes', 'fullscreen'] as const;
              const currentIndex = controls.indexOf(focusedControl);
              if (currentIndex < controls.length - 1) {
                setFocusedControl(controls[currentIndex + 1]);
              }
            }
            break;
          case 'ArrowUp':
            e.preventDefault();
            setShowControls(true);
            // You can add volume up or other functionality here
            break;
          case 'ArrowDown':
            e.preventDefault();
            setShowControls(true);
            // Show/hide controls or other functionality
            break;
          case 'F5': // F5 for rewind (10 seconds back)
          case 'KeyR': // R key for rewind
            e.preventDefault();
            seek(-10);
            setShowControls(true);
            break;
          case 'F6': // F6 for fast forward (10 seconds forward) 
          case 'KeyF': // F key for fast forward
            e.preventDefault();
            seek(10);
            setShowControls(true);
            break;
          case 'Backspace':
          case 'Escape':
            e.preventDefault();
            if (isFullscreen) {
              setIsFullscreen(false);
            } else {
              console.log('Go back from video page');
            }
            break;
          case 'F1': // Red button - Toggle subtitles
          case 'ColorF0RED':
            e.preventDefault();
            toggleSubtitles();
            setShowControls(true);
            break;
        }
      };

      window.addEventListener('keydown', handleKey);
      return () => window.removeEventListener('keydown', handleKey);
    }, [togglePlay, seek, isFullscreen, focusedControl, showControls, showSubtitleMenu, currentSubtitleTrack, subtitles, toggleSubtitles, switchSubtitleTrack, toggleMute, toggleFullscreen]);

    // Expose ref methods
    useImperativeHandle(
      ref,
      () => ({
        play: async () => {
          if (videoRef.current) await videoRef.current.play();
        },
        pause: () => {
          videoRef.current?.pause();
        },
        get currentTime() {
          return videoRef.current?.currentTime || 0;
        },
        set currentTime(t: number) {
          if (videoRef.current) videoRef.current.currentTime = t;
        },
        get duration() {
          return videoRef.current?.duration || 0;
        },
      }),
      []
    );

    if (!currentSource) {
      return (
        <div className="flex items-center justify-center h-full bg-black text-white">
          No video source available
        </div>
      );
    }

    return (
      <div
        className={`bg-black ${
          isFullscreen ? 'fixed inset-0 z-[9999]' : 'relative w-full h-full'
        }`}
      >
        <video
          ref={videoRef}
          className="w-full h-full object-contain"
          playsInline
          crossOrigin="anonymous"
          onPlay={() => {
            setIsPlaying(true);
            onPlay?.();
          }}
          onPause={() => {
            setIsPlaying(false);
            onPause?.();
          }}
          onTimeUpdate={() =>
            setCurrentTime(videoRef.current?.currentTime || 0)
          }
          onLoadedMetadata={() =>
            setDuration(videoRef.current?.duration || 0)
          }
        >
          {subtitles?.map((s, i) => (
            <track
              key={i}
              kind="subtitles"
              src={getProxiedUrl(s.url)}
              srcLang={s.lang}
              label={s.label || s.lang}
              default={i === 0}
            />
          ))}
        </video>

        {/* Loading */}
        {isLoading && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/50 text-white">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-rose-500"></div>
          </div>
        )}

        {/* Error */}
        {error && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/50 text-white">
            <div>
              <p className="mb-4">{error}</p>
              <Button onClick={() => window.location.reload()}>Retry</Button>
            </div>
          </div>
        )}

        {/* Seek overlay */}
        {seekMessage && (
          <div className="absolute inset-0 flex items-center justify-center text-white text-3xl font-bold bg-black/20">
            {seekMessage}
          </div>
        )}

        {/* Controls */}
        {showControls && (
          <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent">
            {/* Progress Bar */}
            <div className="px-4 py-2">
              <div className="w-full bg-white/20 rounded-full h-1 mb-4 cursor-pointer" 
                   onClick={(e) => {
                     const rect = e.currentTarget.getBoundingClientRect();
                     const clickX = e.clientX - rect.left;
                     const percentage = clickX / rect.width;
                     const newTime = percentage * duration;
                     if (videoRef.current) {
                       videoRef.current.currentTime = newTime;
                     }
                   }}
              >
                <div 
                  className="bg-rose-500 h-1 rounded-full transition-all duration-200" 
                  style={{ width: `${duration > 0 ? (currentTime / duration) * 100 : 0}%` }}
                ></div>
              </div>
            </div>
            
            <div className="px-4 pb-4 flex items-center justify-between text-white">
              <div className="flex items-center space-x-4">
              {/* Rewind 10s Button */}
              <Button 
                variant="ghost" 
                onClick={() => seek(-10)} 
                className={`p-2 ${focusedControl === 'rewind' ? 'ring-4 ring-rose-500 bg-rose-500/20' : ''}`}
              >
                <div className="flex items-center">
                  <Rewind className="w-5 h-5" />
                  <span className="text-xs ml-1">10s</span>
                </div>
              </Button>

              <Button 
                variant="ghost" 
                onClick={togglePlay} 
                className={`p-2 ${focusedControl === 'play' ? 'ring-4 ring-rose-500 bg-rose-500/20' : ''}`}
              >
                {isPlaying ? (
                  <Pause className="w-5 h-5" />
                ) : (
                  <Play className="w-5 h-5" />
                )}
              </Button>

              {/* Forward 10s Button */}
              <Button 
                variant="ghost" 
                onClick={() => seek(10)} 
                className={`p-2 ${focusedControl === 'forward' ? 'ring-4 ring-rose-500 bg-rose-500/20' : ''}`}
              >
                <div className="flex items-center">
                  <FastForward className="w-5 h-5" />
                  <span className="text-xs ml-1">10s</span>
                </div>
              </Button>

              <Button 
                variant="ghost" 
                onClick={toggleMute} 
                className={`p-2 ${focusedControl === 'volume' ? 'ring-4 ring-rose-500 bg-rose-500/20' : ''}`}
              >
                {isMuted ? (
                  <VolumeX className="w-5 h-5" />
                ) : (
                  <Volume2 className="w-5 h-5" />
                )}
              </Button>

              <span>
                {formatTime(currentTime)} / {formatTime(duration)}
              </span>
            </div>

              <div className="flex items-center space-x-4">
                {/* TV-friendly Subtitle Button */}
                <Button 
                  variant="ghost" 
                  onClick={() => {
                    if (subtitles && subtitles.length > 0) {
                      setShowSubtitleMenu(true);
                    } else {
                      toggleSubtitles();
                    }
                  }}
                  className={`p-2 relative ${focusedControl === 'subtitle' ? 'ring-4 ring-rose-500 bg-rose-500/20' : ''} ${subtitlesEnabled ? 'text-rose-400' : ''}`}
                >
                  <MessageCircle className="w-5 h-5" />
                  {subtitlesEnabled && (
                    <div className="absolute -top-1 -right-1 w-3 h-3 bg-rose-500 rounded-full"></div>
                  )}
                </Button>

                {/* Episodes Button */}
                <Button 
                  variant="ghost" 
                  onClick={() => onShowEpisodes?.()} 
                  className={`p-2 ${focusedControl === 'episodes' ? 'ring-4 ring-rose-500 bg-rose-500/20' : ''}`}
                >
                  <div className="flex items-center">
                    <ClipboardList className="w-5 h-5" />
                  </div>
                </Button>

                <Button 
                  variant="ghost" 
                  onClick={toggleFullscreen} 
                  className={`p-2 ${focusedControl === 'fullscreen' ? 'ring-4 ring-rose-500 bg-rose-500/20' : ''}`}
                >
                  {isFullscreen ? (
                    <Minimize className="w-5 h-5" />
                  ) : (
                    <Maximize className="w-5 h-5" />
                  )}
                </Button>
              </div>
            </div>
          </div>
        )}

        {/* TV Subtitle Menu */}
        {showSubtitleMenu && subtitles && subtitles.length > 0 && (
          <div 
            ref={subtitleMenuRef}
            className="absolute bottom-20 right-4 bg-black/90 backdrop-blur-lg rounded-lg p-4 min-w-[200px] max-w-[300px] text-white"
          >
            <h3 className="text-lg font-bold mb-3 flex items-center">
              <MessageCircle className="w-5 h-5 mr-2" />
              Subtitles
            </h3>
            <div 
              ref={subtitleScrollContainerRef}
              className="space-y-2 max-h-[300px] overflow-y-auto custom-scrollbar pr-2"
            >
              <div 
                ref={(el) => { subtitleItemsRef.current[-1] = el; }}
                className={`p-2 rounded cursor-pointer transition-all ${
                  !subtitlesEnabled 
                    ? 'bg-rose-500/30 ring-2 ring-rose-500' 
                    : 'hover:bg-gray-700'
                } ${currentSubtitleTrack === -1 ? 'ring-2 ring-blue-500' : ''}`}
                onClick={() => {
                  toggleSubtitles();
                  setShowSubtitleMenu(false);
                }}
              >
                Off
              </div>
              {subtitles.map((subtitle, index) => (
                <div
                  key={index}
                  ref={(el) => { subtitleItemsRef.current[index] = el; }}
                  className={`p-2 rounded cursor-pointer transition-all ${
                    subtitlesEnabled && currentSubtitleTrack === index 
                      ? 'bg-rose-500/30 ring-2 ring-rose-500' 
                      : 'hover:bg-gray-700'
                  } ${currentSubtitleTrack === index ? 'ring-2 ring-blue-500' : ''}`}
                  onClick={() => {
                    switchSubtitleTrack(index);
                    setShowSubtitleMenu(false);
                  }}
                >
                  {subtitle.label || subtitle.lang}
                </div>
              ))}
            </div>
            <div className="mt-3 text-xs text-gray-400 text-center">
              Use ↑↓ to navigate • Enter to select • Esc to close
            </div>
          </div>
        )}
      </div>
    );
  }
);

VideoPlayer.displayName = 'VideoPlayer';
export default VideoPlayer;
