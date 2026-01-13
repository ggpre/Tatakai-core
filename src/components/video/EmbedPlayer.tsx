import { useEffect, useRef, useState } from "react";
import { Loader2, AlertCircle, RefreshCw } from "lucide-react";

interface EmbedPlayerProps {
  url: string;
  poster?: string;
  language?: string;
  onError?: () => void;
}

export function EmbedPlayer({ url, poster, language, onError }: EmbedPlayerProps) {
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(false);
  const [reloadKey, setReloadKey] = useState(0);
  const [shieldArmed, setShieldArmed] = useState(true);
  const [shieldClicks, setShieldClicks] = useState(0);
  const rearmTimer = useRef<number | null>(null);

  const handleLoad = () => {
    setIsLoading(false);
  };

  const handleError = () => {
    setIsLoading(false);
    setError(true);
    onError?.();
  };

  const handleRetry = () => {
    setError(false);
    setIsLoading(true);
    setReloadKey((k) => k + 1);
    setShieldArmed(true);
    setShieldClicks(0);
  };

  // Swallow first two clicks/taps to block redirect; then allow for a short window and re-arm
  const handleShieldPointer = (
    e: React.MouseEvent<HTMLDivElement> | React.TouchEvent<HTMLDivElement>
  ) => {
    e.preventDefault();
    e.stopPropagation();
    setShieldClicks((c) => {
      const next = c + 1;
      if (next < 2) {
        return next; // still block
      }
      // allow interactions for a short window
      setShieldArmed(false);
      if (rearmTimer.current) {
        window.clearTimeout(rearmTimer.current);
      }
      rearmTimer.current = window.setTimeout(() => {
        setShieldArmed(true);
        setShieldClicks(0);
      }, 4000);
      return next;
    });
  };

  useEffect(() => {
    return () => {
      if (rearmTimer.current) {
        window.clearTimeout(rearmTimer.current);
      }
    };
  }, []);

  if (error) {
    return (
      <div 
        className="w-full aspect-video bg-black flex flex-col items-center justify-center text-white"
        style={{ backgroundImage: poster ? `url(${poster})` : undefined, backgroundSize: 'cover', backgroundPosition: 'center' }}
      >
        <div className="bg-black/80 p-6 rounded-xl flex flex-col items-center gap-4">
          <AlertCircle className="w-12 h-12 text-red-500" />
          <p className="text-lg">Failed to load embed player</p>
          <button
            onClick={handleRetry}
            className="flex items-center gap-2 px-4 py-2 bg-primary hover:bg-primary/80 rounded-lg transition-colors"
          >
            <RefreshCw className="w-4 h-4" />
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="relative w-full aspect-video bg-black">
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-black z-10">
          <div className="flex flex-col items-center gap-3">
            <Loader2 className="w-12 h-12 animate-spin text-primary" />
            <p className="text-white/70 text-sm">
              Loading {language ? `${language} ` : ''}player...
            </p>
          </div>
        </div>
      )}

      {shieldArmed && !error && (
        <div
          className="absolute inset-0 z-20 cursor-pointer"
          onMouseDown={handleShieldPointer}
          onTouchStart={handleShieldPointer}
          title="Tap to enable player"
        >
          <div className="absolute bottom-3 right-3 bg-black/60 text-white text-xs px-2 py-1 rounded">
            Tap to start
          </div>
        </div>
      )}
      
      <iframe
        key={reloadKey}
        src={url}
        className="w-full h-full border-0"
        allowFullScreen
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        onLoad={handleLoad}
        onError={handleError}
        title={`Video player - ${language || "Embed"}`}
      />
    </div>
  );
}
