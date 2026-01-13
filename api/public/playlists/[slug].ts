import { createClient } from '@supabase/supabase-js';
import { checkRateLimit, getRetryAfter } from '@/lib/rateLimiter';

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL || '', SUPABASE_SERVICE_ROLE_KEY || '');

export default async function handler(req: any, res: any) {
  const { slug } = req.query || {};
  if (!slug) return res.status(400).json({ error: 'Missing slug' });

  // Basic rate limit
  const ip = (req.headers['x-forwarded-for'] || req.socket.remoteAddress || 'unknown').toString();
  const rl = checkRateLimit(ip, 60, 60);
  res.setHeader('X-RateLimit-Limit', String(60));
  res.setHeader('X-RateLimit-Remaining', String(rl.remaining));
  res.setHeader('X-RateLimit-Reset', String(rl.reset));
  if (rl.limited) {
    res.setHeader('Retry-After', String(getRetryAfter(rl.reset)));
    return res.status(429).json({ error: 'Rate limit exceeded' });
  }

  try {
    const { data, error } = await supabase
      .from('playlists')
      .select(`*, playlist_items(*), profiles:user_id(id, display_name, avatar_url)`)
      .eq('share_slug', slug)
      .eq('is_public', true)
      .limit(1)
      .single();

    if (error) {
      try { const { incCounter } = await import('@/lib/metrics'); incCounter('public_playlist_errors_total'); } catch {}
      return res.status(404).json({ error: 'Playlist not found' });
    }

    // Ensure items are ordered by position
    if (data && data.playlist_items) {
      data.playlist_items.sort((a: any, b: any) => a.position - b.position);
    }

    // Add caching and CORS headers
    res.setHeader('Cache-Control', 's-maxage=300, stale-while-revalidate=600');
    res.setHeader('Access-Control-Allow-Origin', '*');

    try { const { incCounter } = await import('@/lib/metrics'); incCounter('public_playlist_requests_total'); } catch {}

    return res.status(200).json({ data });
  } catch (e) {
    return res.status(500).json({ error: String(e) });
  }
}
