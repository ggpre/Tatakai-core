import React, { useState, useRef, useEffect } from 'react';
import Hls from 'hls.js';
import { 
  Play, 
  Pause, 
  Volume2, 
  VolumeX,
  SkipBack,
  SkipForward,
  RotateCcw
} from 'lucide-react';
import { VideoPlayerState } from '@/types';
import { formatTime } from '@/lib/utils';
import Focusable from './Focusable';
import { Button } from '@/components/ui/button';

interface TVVideoPlayerProps {
  src: string;
  poster?: string;
  autoPlay?: boolean;
  onTimeUpdate?: (currentTime: number) => void;
  onDurationChange?: (duration: number) => void;
  onPlay?: () => void;
  onPause?: () => void;
  onEnded?: () => void;
  onBack?: () => void;
}

const TVVideoPlayer: React.FC<TVVideoPlayerProps> = ({
  src,
  poster,
  autoPlay = false,
  onTimeUpdate,
  onDurationChange,
  onPlay,
  onPause,
  onEnded,
  onBack
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const hlsRef = useRef<Hls | null>(null);
  const controlsTimeoutRef = useRef<NodeJS.Timeout>();
  
  const [state, setState] = useState<VideoPlayerState>({
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    volume: 1,
    isMuted: false,
    isFullscreen: false,
    showControls: true,
  });

  // Initialize HLS player
  useEffect(() => {
    if (!videoRef.current || !src) return;

    const video = videoRef.current;

    if (Hls.isSupported() && src.includes('.m3u8')) {
      const hls = new Hls({
        enableWorker: true,
        lowLatencyMode: true,
      });
      
      hls.loadSource(src);
      hls.attachMedia(video);
      hlsRef.current = hls;

      hls.on(Hls.Events.MANIFEST_PARSED, () => {
        console.log('HLS manifest parsed');
        if (autoPlay) {
          video.play();
        }
      });

      hls.on(Hls.Events.ERROR, (_, data) => {
        console.error('HLS error:', data);
      });

    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
      // Native HLS support (Safari)
      video.src = src;
      if (autoPlay) {
        video.play();
      }
    } else {
      // Fallback for direct video URLs
      video.src = src;
      if (autoPlay) {
        video.play();
      }
    }

    return () => {
      if (hlsRef.current) {
        hlsRef.current.destroy();
        hlsRef.current = null;
      }
    };
  }, [src, autoPlay]);

  // Video event handlers
  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    const handleTimeUpdate = () => {
      setState(prev => ({ ...prev, currentTime: video.currentTime }));
      onTimeUpdate?.(video.currentTime);
    };

    const handleDurationChange = () => {
      setState(prev => ({ ...prev, duration: video.duration }));
      onDurationChange?.(video.duration);
    };

    const handlePlay = () => {
      setState(prev => ({ ...prev, isPlaying: true }));
      onPlay?.();
    };

    const handlePause = () => {
      setState(prev => ({ ...prev, isPlaying: false }));
      onPause?.();
    };

    const handleEnded = () => {
      setState(prev => ({ ...prev, isPlaying: false, currentTime: 0 }));
      onEnded?.();
    };

    const handleVolumeChange = () => {
      setState(prev => ({ 
        ...prev, 
        volume: video.volume,
        isMuted: video.muted 
      }));
    };

    video.addEventListener('timeupdate', handleTimeUpdate);
    video.addEventListener('durationchange', handleDurationChange);
    video.addEventListener('play', handlePlay);
    video.addEventListener('pause', handlePause);
    video.addEventListener('ended', handleEnded);
    video.addEventListener('volumechange', handleVolumeChange);

    return () => {
      video.removeEventListener('timeupdate', handleTimeUpdate);
      video.removeEventListener('durationchange', handleDurationChange);
      video.removeEventListener('play', handlePlay);
      video.removeEventListener('pause', handlePause);
      video.removeEventListener('ended', handleEnded);
      video.removeEventListener('volumechange', handleVolumeChange);
    };
  }, [onTimeUpdate, onDurationChange, onPlay, onPause, onEnded]);

  // Auto-hide controls
  useEffect(() => {
    if (state.showControls) {
      if (controlsTimeoutRef.current) {
        clearTimeout(controlsTimeoutRef.current);
      }
      controlsTimeoutRef.current = setTimeout(() => {
        setState(prev => ({ ...prev, showControls: false }));
      }, 5000);
    }

    return () => {
      if (controlsTimeoutRef.current) {
        clearTimeout(controlsTimeoutRef.current);
      }
    };
  }, [state.showControls]);

  const togglePlayPause = () => {
    if (!videoRef.current) return;
    
    if (state.isPlaying) {
      videoRef.current.pause();
    } else {
      videoRef.current.play();
    }
  };

  const toggleMute = () => {
    if (!videoRef.current) return;
    videoRef.current.muted = !videoRef.current.muted;
  };

  const changeVolume = (delta: number) => {
    if (!videoRef.current) return;
    const newVolume = Math.max(0, Math.min(1, videoRef.current.volume + delta));
    videoRef.current.volume = newVolume;
  };

  const seek = (seconds: number) => {
    if (!videoRef.current) return;
    const newTime = Math.max(0, Math.min(state.duration, videoRef.current.currentTime + seconds));
    videoRef.current.currentTime = newTime;
  };

  // const seekToPosition = (position: number) => {
  //   if (!videoRef.current) return;
  //   const newTime = (position / 100) * state.duration;
  //   videoRef.current.currentTime = newTime;
  // };

  const showControls = () => {
    setState(prev => ({ ...prev, showControls: true }));
  };

  const progressPercentage = state.duration > 0 ? (state.currentTime / state.duration) * 100 : 0;

  return (
    <div 
      className="tv-video-player"
      onMouseMove={showControls}
      onClick={showControls}
    >
      <video
        ref={videoRef}
        className="tv-video-player__video"
        poster={poster}
        playsInline
        preload="metadata"
      />

      {/* Controls Overlay */}
      {state.showControls && (
        <div className="tv-video-player__controls">
          {/* Progress Bar */}
          <div className="tv-video-player__progress">
            <div 
              className="tv-video-player__progress-bar" 
              style={{ width: `${progressPercentage}%` }}
            />
          </div>

          {/* Control Buttons */}
          <div className="tv-video-player__buttons">
            {/* Left side controls */}
            <div className="flex items-center gap-4">
              {onBack && (
                <Focusable id="video-back" onEnter={onBack}>
                  <Button variant="ghost" size="icon" className="text-white">
                    <RotateCcw size={24} />
                  </Button>
                </Focusable>
              )}

              <Focusable id="video-rewind" onEnter={() => seek(-10)}>
                <Button variant="ghost" size="icon" className="text-white">
                  <SkipBack size={24} />
                </Button>
              </Focusable>

              <Focusable id="video-play-pause" onEnter={togglePlayPause}>
                <Button variant="ghost" size="icon" className="text-white">
                  {state.isPlaying ? <Pause size={28} /> : <Play size={28} />}
                </Button>
              </Focusable>

              <Focusable id="video-forward" onEnter={() => seek(10)}>
                <Button variant="ghost" size="icon" className="text-white">
                  <SkipForward size={24} />
                </Button>
              </Focusable>

              <div className="flex items-center gap-2 text-white text-tv-sm">
                <span>{formatTime(state.currentTime)}</span>
                <span>/</span>
                <span>{formatTime(state.duration)}</span>
              </div>
            </div>

            {/* Right side controls */}
            <div className="flex items-center gap-4">
              <Focusable id="video-volume-down" onEnter={() => changeVolume(-0.1)}>
                <Button variant="ghost" size="icon" className="text-white">
                  <VolumeX size={20} />
                </Button>
              </Focusable>

              <Focusable id="video-mute" onEnter={toggleMute}>
                <Button variant="ghost" size="icon" className="text-white">
                  {state.isMuted ? <VolumeX size={24} /> : <Volume2 size={24} />}
                </Button>
              </Focusable>

              <Focusable id="video-volume-up" onEnter={() => changeVolume(0.1)}>
                <Button variant="ghost" size="icon" className="text-white">
                  <Volume2 size={20} />
                </Button>
              </Focusable>

              <div className="text-white text-tv-sm">
                {Math.round(state.volume * 100)}%
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default TVVideoPlayer;