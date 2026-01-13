import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL || '', SUPABASE_SERVICE_ROLE_KEY || '');

export default async function handler(req: any, res: any) {
  const { id } = req.query || {};
  if (!id) return res.status(400).json({ error: 'Missing anime id' });

  // Rate limit metric endpoints
  const ip = (req.headers['x-forwarded-for'] || req.socket.remoteAddress || 'unknown').toString();
  const rl = checkRateLimit(ip, 60, 60); // stricter: 60 requests per minute
  res.setHeader('X-RateLimit-Limit', String(60));
  res.setHeader('X-RateLimit-Remaining', String(rl.remaining));
  res.setHeader('X-RateLimit-Reset', String(rl.reset));
  if (rl.limited) {
    res.setHeader('Retry-After', String(getRetryAfter(rl.reset)));
    return res.status(429).json({ error: 'Rate limit exceeded' });
  }

  try {
    // Use service role key to bypass RLS for metrics if needed
    const { data, error } = await supabase.rpc('get_anime_metrics', { p_anime_id: id });
    if (error) {
      try { const { incCounter } = await import('@/lib/metrics'); incCounter('metrics_errors_total'); } catch {}
      return res.status(500).json({ error: String(error) });
    }
    // Add caching headers for edge serving
    res.setHeader('Cache-Control', 's-maxage=300, stale-while-revalidate=600');
    try { const { incCounter, observeHistogram } = await import('@/lib/metrics'); incCounter('metrics_requests_total'); observeHistogram('metrics_request_duration_seconds', 0); } catch {}

    return res.status(200).json({ data: data?.[0] ?? null });
  } catch (e) {
    return res.status(500).json({ error: String(e) });
  }
}
