import { useEffect } from 'react';
import { useOnline } from '@/hooks/useOnline';
import { useToast } from '@/hooks/use-toast';
import { X, WifiOff, Wifi } from 'lucide-react';

export function OfflineBanner() {
  const online = useOnline();
  const { toast } = useToast();

  useEffect(() => {
    if (!online) {
      toast({ title: 'You are offline', description: 'Some features may be limited while offline.' });
    } else {
      toast({ title: 'Back online', description: 'Network connection restored.' });
    }
  }, [online]);

  if (online) return null;

  return (
    <div className="fixed inset-x-0 top-0 z-50 flex items-center justify-center">
      <div className="max-w-3xl w-full mx-4 bg-amber/95 border border-amber/70 text-amber-900 px-4 py-2 rounded-b shadow-md flex items-center gap-4">
        <WifiOff className="w-5 h-5" />
        <div className="flex-1 text-sm">
          <div className="font-semibold">You are currently offline</div>
          <div className="text-xs opacity-90">Some features (network calls, adding to playlists, streaming) may not work until you reconnect.</div>
        </div>
        <button
          onClick={() => window.location.reload()}
          className="inline-flex items-center gap-2 px-3 py-1 rounded bg-white/10 hover:bg-white/20 text-xs"
        >
          <Wifi className="w-4 h-4" />
          Retry
        </button>
      </div>
    </div>
  );
}
