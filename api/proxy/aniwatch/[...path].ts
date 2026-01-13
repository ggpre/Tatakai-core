// Simple Vercel serverless proxy to avoid CORS issues when calling the aniwatch API.
// Deploy under the `api/` directory so Vercel will host it as a serverless function.

import { checkRateLimit, getRetryAfter } from '@/lib/rateLimiter';

export default async function handler(req: any, res: any) {
  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    return res.status(204).end();
  }

  // Basic rate limit by IP
  const ip = (req.headers['x-forwarded-for'] || req.socket.remoteAddress || 'unknown').toString();
  const rl = checkRateLimit(ip);
  res.setHeader('X-RateLimit-Limit', String(100));
  res.setHeader('X-RateLimit-Remaining', String(rl.remaining));
  res.setHeader('X-RateLimit-Reset', String(rl.reset));
  if (rl.limited) {
    res.setHeader('Retry-After', String(getRetryAfter(rl.reset)));
    return res.status(429).json({ error: 'Rate limit exceeded' });
  }

  // Reconstruct target URL by replacing /api/proxy/aniwatch with the upstream path /api/v2/hianime
  const originalUrl = req.url || '';
  const target = originalUrl.replace(/^\/api\/proxy\/aniwatch/, 'https://aniwatch-api-taupe-eight.vercel.app/api/v2/hianime');

  const start = Date.now();
  try {
    const upstreamRes = await fetch(target, {
      method: req.method,
      headers: {
        // Copy relevant headers from the client request
        'user-agent': req.headers['user-agent'] || 'tatakai-proxy',
        accept: req.headers['accept'] || '*/*',
        // Forward authorization header if present
        ...(req.headers['authorization'] ? { authorization: req.headers['authorization'] } : {}),
      },
      body: ['GET', 'HEAD'].includes(req.method) ? undefined : req.body,
    });

    const buffer = Buffer.from(await upstreamRes.arrayBuffer());

    // Mirror selected headers and ensure CORS header is set so browser can read the response
    const contentType = upstreamRes.headers.get('content-type') || 'application/json';
    res.setHeader('Content-Type', contentType);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Credentials', 'true');

    // Cache headers for edge/CDN - short caching for proxied API results
    res.setHeader('Cache-Control', 's-maxage=60, stale-while-revalidate=300');

    // Metrics
    try {
      const { incCounter, observeHistogram } = await import('@/lib/metrics');
      incCounter('proxy_requests_total');
      observeHistogram('proxy_request_duration_seconds', (Date.now() - start) / 1000);
    } catch {}

    res.status(upstreamRes.status).send(buffer);
  } catch (err) {
    try { const { incCounter } = await import('@/lib/metrics'); incCounter('proxy_errors_total'); } catch {}
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.status(502).json({ error: 'Bad gateway', details: String(err) });
  }
}
