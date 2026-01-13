import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
};

// Ad/Tracking domain blocklist
const AD_DOMAINS = [
  'doubleclick.net',
  'googlesyndication.com',
  'googleadservices.com',
  'adserve',
  'popads.net',
  'popcash.net',
  'propellerads.com',
  'exoclick.com',
  'adsterra.com',
  'clickadu.com',
  'bidvertiser.com',
  'trafficjunky.com',
  'juicyads.com',
  'ads-',
  'adservice',
  'analytics',
  'tracker',
  '/ads/',
  '/ad/',
  'banner',
  'popup',
  'redirect.php',
  'outbound',
];

// Video source patterns to detect
const VIDEO_PATTERNS = [
  /\.m3u8(\?|$)/i,
  /\.mp4(\?|$)/i,
  /\.mkv(\?|$)/i,
  /\.webm(\?|$)/i,
  /master\.m3u8/i,
  /playlist\.m3u8/i,
  /video\.(m3u8|mp4)/i,
];

interface ExtractedSource {
  url: string;
  type: 'hls' | 'mp4' | 'unknown';
  quality?: string;
  headers?: Record<string, string>;
}

interface EmbedAdBlockerResponse {
  success: boolean;
  sources?: ExtractedSource[];
  error?: string;
  debug?: {
    totalRequests: number;
    blockedRequests: number;
    detectedVideos: number;
    executionTime: number;
  };
}

// Check if URL matches ad/tracking patterns
function isAdRequest(url: string): boolean {
  const lowerUrl = url.toLowerCase();
  return AD_DOMAINS.some(domain => lowerUrl.includes(domain));
}

// Check if URL is a video source
function isVideoSource(url: string): boolean {
  return VIDEO_PATTERNS.some(pattern => pattern.test(url));
}

// Determine video type from URL
function getVideoType(url: string): 'hls' | 'mp4' | 'unknown' {
  if (/\.m3u8/i.test(url)) return 'hls';
  if (/\.mp4/i.test(url)) return 'mp4';
  return 'unknown';
}

// Extract quality from URL if present
function extractQuality(url: string): string | undefined {
  const qualityMatch = url.match(/(\d{3,4}p|hd|sd|fhd|uhd|4k)/i);
  return qualityMatch ? qualityMatch[1] : undefined;
}

/**
 * Simulated headless browser approach using fetch + DOM parsing
 * This is a lightweight alternative that works in Deno Deploy
 * For production, consider integrating with Browserless.io or Puppeteer service
 */
async function extractVideoSourcesLightweight(
  embedUrl: string,
  timeout: number = 30000
): Promise<ExtractedSource[]> {
  const startTime = Date.now();
  const detectedSources: ExtractedSource[] = [];
  const seenUrls = new Set<string>();

  console.log(`[Embed AdBlocker] Processing: ${embedUrl}`);

  try {
    // Fetch the embed page HTML
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    const response = await fetch(embedUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Referer': new URL(embedUrl).origin,
      },
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const html = await response.text();
    console.log(`[Embed AdBlocker] Fetched HTML (${html.length} bytes)`);

    // Extract all URLs from HTML (src, href, data-src, etc.)
    const urlPatterns = [
      /(?:src|href|data-src|data-video|data-url|file)=["']([^"']+)["']/gi,
      /(?:source|video|stream):\s*["']([^"']+)["']/gi,
      /"(https?:\/\/[^"]+\.m3u8[^"]*)"/gi,
      /"(https?:\/\/[^"]+\.mp4[^"]*)"/gi,
      /['"]file['"]:\s*['"]([^'"]+)['"]/gi,
      /https?:\/\/[^\s<>"']+\.(?:m3u8|mp4)/gi,
    ];

    for (const pattern of urlPatterns) {
      let match;
      while ((match = pattern.exec(html)) !== null) {
        const url = match[1] || match[0];
        
        // Skip if already seen, is ad, or not video
        if (seenUrls.has(url)) continue;
        if (isAdRequest(url)) {
          console.log(`[Blocked Ad] ${url}`);
          continue;
        }
        
        seenUrls.add(url);

        // Check if it's a video source
        if (isVideoSource(url)) {
          const fullUrl = url.startsWith('http') ? url : new URL(url, embedUrl).href;
          
          detectedSources.push({
            url: fullUrl,
            type: getVideoType(fullUrl),
            quality: extractQuality(fullUrl),
          });

          console.log(`[Video Detected] ${fullUrl}`);
        }
      }
    }

    // Check for JavaScript variables containing video sources
    const jsVarPatterns = [
      /(?:videoSource|sourceUrl|streamUrl|playUrl|embedUrl|videoUrl|sources?|src)\s*[:=]\s*["']([^"']+\.(?:m3u8|mp4)[^"']*)["']/gi,
      /var\s+\w+\s*=\s*["'](https?:\/\/[^"']+\.(?:m3u8|mp4)[^"']*)["']/gi,
      /["']file["']\s*:\s*["']([^"']+\.(?:m3u8|mp4)[^"']*)["']/gi,
      /sources?\s*:\s*\[?\s*{[^}]*["']src["']\s*:\s*["']([^"']+\.(?:m3u8|mp4)[^"']*)["']/gi,
      /player\.source\s*=\s*{[^}]*src:\s*["']([^"']+\.(?:m3u8|mp4)[^"']*)["']/gi,
      /setup\(\s*{[^}]*file:\s*["']([^"']+\.(?:m3u8|mp4)[^"']*)["']/gi,
    ];

    for (const pattern of jsVarPatterns) {
      let match;
      while ((match = pattern.exec(html)) !== null) {
        const url = match[1];
        if (!seenUrls.has(url) && !isAdRequest(url) && isVideoSource(url)) {
          const fullUrl = url.startsWith('http') ? url : new URL(url, embedUrl).href;
          seenUrls.add(url);
          
          detectedSources.push({
            url: fullUrl,
            type: getVideoType(fullUrl),
            quality: extractQuality(fullUrl),
          });

          console.log(`[Video in JS] ${fullUrl}`);
        }
      }
    }

    // Check for base64 or obfuscated URLs
    const obfuscatedPatterns = [
      /atob\s*\(\s*["']([A-Za-z0-9+/=]+)["']\s*\)/g,
      /btoa\s*\(\s*["']([^"']+)["']\s*\)/g,
      // Player data variables (JWPlayer, VideoJS, etc.)
      /(?:const|var|let)\s+(?:datas?|playerData|videoData|config)\s*=\s*["']([A-Za-z0-9+/=]{50,})["']/g,
    ];

    for (const pattern of obfuscatedPatterns) {
      let match;
      while ((match = pattern.exec(html)) !== null) {
        try {
          const decoded = atob(match[1]);
          console.log(`[Decoded Data] ${decoded.substring(0, 200)}...`);
          
          // Check if decoded string contains video URL directly
          if (isVideoSource(decoded)) {
            const fullUrl = decoded.startsWith('http') ? decoded : new URL(decoded, embedUrl).href;
            if (!seenUrls.has(fullUrl)) {
              seenUrls.add(fullUrl);
              detectedSources.push({
                url: fullUrl,
                type: getVideoType(fullUrl),
                quality: extractQuality(fullUrl),
              });
              console.log(`[Video Decoded] ${fullUrl}`);
            }
          }
          
          // Check if it's JSON with video data
          try {
            const jsonData = JSON.parse(decoded);
            console.log(`[JSON Decoded] Keys: ${Object.keys(jsonData).join(', ')}`);
            
            // Common video source keys
            const videoKeys = ['file', 'url', 'src', 'source', 'sources', 'media', 'video', 'stream', 'playlist'];
            
            for (const key of videoKeys) {
              if (jsonData[key]) {
                let videoUrl = jsonData[key];
                
                // Handle array of sources
                if (Array.isArray(videoUrl)) {
                  for (const source of videoUrl) {
                    const url = typeof source === 'string' ? source : source.file || source.src || source.url;
                    if (url && isVideoSource(url)) {
                      const fullUrl = url.startsWith('http') ? url : new URL(url, embedUrl).href;
                      if (!seenUrls.has(fullUrl)) {
                        seenUrls.add(fullUrl);
                        detectedSources.push({
                          url: fullUrl,
                          type: getVideoType(fullUrl),
                          quality: extractQuality(fullUrl) || (source.label || source.quality),
                        });
                        console.log(`[Video from JSON Array] ${fullUrl}`);
                      }
                    }
                  }
                }
                // Handle object with nested URL
                else if (typeof videoUrl === 'object') {
                  const nestedUrl = videoUrl.file || videoUrl.src || videoUrl.url;
                  if (nestedUrl && isVideoSource(nestedUrl)) {
                    const fullUrl = nestedUrl.startsWith('http') ? nestedUrl : new URL(nestedUrl, embedUrl).href;
                    if (!seenUrls.has(fullUrl)) {
                      seenUrls.add(fullUrl);
                      detectedSources.push({
                        url: fullUrl,
                        type: getVideoType(fullUrl),
                        quality: extractQuality(fullUrl),
                      });
                      console.log(`[Video from JSON Object] ${fullUrl}`);
                    }
                  }
                }
                // Handle string URL
                else if (typeof videoUrl === 'string' && isVideoSource(videoUrl)) {
                  const fullUrl = videoUrl.startsWith('http') ? videoUrl : new URL(videoUrl, embedUrl).href;
                  if (!seenUrls.has(fullUrl)) {
                    seenUrls.add(fullUrl);
                    detectedSources.push({
                      url: fullUrl,
                      type: getVideoType(fullUrl),
                      quality: extractQuality(fullUrl),
                    });
                    console.log(`[Video from JSON String] ${fullUrl}`);
                  }
                }
              }
            }
          } catch (e) {
            // Not valid JSON, continue
          }
        } catch (e) {
          // Invalid base64, skip
        }
      }
    }

    const executionTime = Date.now() - startTime;
    console.log(`[Embed AdBlocker] Completed in ${executionTime}ms, found ${detectedSources.length} sources`);

    return detectedSources;
  } catch (error) {
    const executionTime = Date.now() - startTime;
    console.error(`[Embed AdBlocker] Error after ${executionTime}ms:`, error);
    throw error;
  }
}

/**
 * Bypass anti-adblock detection by modifying the HTML
 */
function bypassAntiAdblock(html: string, embedUrl: string): string {
  console.log('[Bypass] Removing anti-adblock code');
  
  let modified = html;
  
  // Remove common anti-adblock detection scripts
  const antiAdblockPatterns = [
    // Remove adblock detection scripts
    /<script[^>]*>[\s\S]*?(?:adblock|AdBlock|blockadblock|fuckadblock|detector)[\s\S]*?<\/script>/gi,
    // Remove sandbox detection
    /<script[^>]*>[\s\S]*?(?:sandbox|frameElement|parent\.location)[\s\S]*?<\/script>/gi,
    // Remove "please disable adblock" messages
    /<div[^>]*class=["'][^"']*(?:adblock|blocked|disable).*?["'][^>]*>[\s\S]*?<\/div>/gi,
  ];
  
  for (const pattern of antiAdblockPatterns) {
    modified = modified.replace(pattern, '<!-- Anti-adblock removed -->');
  }
  
  // Inject fake ad elements to fool detection
  const fakeAdInjection = `
    <script>
      // Fake ad presence to bypass detection
      window.canRunAds = true;
      window.isAdBlockActive = false;
      window.adsbygoogle = window.adsbygoogle || [];
      
      // Create fake ad elements
      const fakeAd = document.createElement('div');
      fakeAd.id = 'ad-banner';
      fakeAd.className = 'adsbygoogle';
      fakeAd.style.display = 'none';
      document.body.appendChild(fakeAd);
      
      // Override sandbox detection
      Object.defineProperty(document, 'sandbox', {
        get: function() { return ''; }
      });
      
      // Prevent redirect/popup attempts
      const originalOpen = window.open;
      window.open = function() {
        console.log('[Ad Blocked] Popup attempt blocked');
        return null;
      };
      
      // Block ad domain requests
      const originalFetch = window.fetch;
      window.fetch = function(url, ...args) {
        const urlStr = typeof url === 'string' ? url : url.toString();
        const adDomains = ${JSON.stringify(AD_DOMAINS)};
        
        if (adDomains.some(domain => urlStr.toLowerCase().includes(domain))) {
          console.log('[Ad Blocked] Request blocked:', urlStr);
          return Promise.reject(new Error('Ad blocked'));
        }
        
        return originalFetch(url, ...args);
      };
      
      console.log('[Bypass] Anti-adblock bypass active');
    </script>
  `;
  
  // Inject before closing body tag
  modified = modified.replace(/<\/body>/i, fakeAdInjection + '</body>');
  
  return modified;
}

/**
 * Proxy mode: Return a VM wrapper that extracts video sources from embeds
 * Creates a lightweight isolated environment to extract video URLs without redirects
 */
async function proxyEmbedPage(embedUrl: string, timeout: number): Promise<Response> {
  console.log(`[Proxy Mode] Fetching and modifying embed: ${embedUrl}`);
  
  try {
    // Fetch the actual embed page
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    const response = await fetch(embedUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Referer': new URL(embedUrl).origin,
      },
      signal: controller.signal,
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      throw new Error(`Failed to fetch embed: ${response.status}`);
    }
    
    let html = await response.text();
    console.log(`[Proxy] Fetched ${html.length} bytes, injecting extractor...`);
    
    // Injection script that will run in the embed's context
    const extractorScript = `
<script id="tatakai-extractor">
(function() {
  console.log('[Tatakai] Extractor injected');
  window.open = function() { return null; };
  
  function extract() {
    var sources = [], seen = new Set();
    
    // Method 1: Find video elements
    document.querySelectorAll('video').forEach(function(v) {
      if (v.src && !seen.has(v.src)) {
        sources.push({url: v.src, type: 'video-src', quality: 'auto'});
        seen.add(v.src);
      }
      if (v.currentSrc && !seen.has(v.currentSrc)) {
        sources.push({url: v.currentSrc, type: 'video-currentSrc', quality: 'auto'});
        seen.add(v.currentSrc);
      }
      v.querySelectorAll('source').forEach(function(s) {
        if (s.src && !seen.has(s.src)) {
          sources.push({url: s.src, type: 'source', quality: s.getAttribute('label') || 'auto'});
          seen.add(s.src);
        }
      });
    });
    
    // Method 2: Scan HTML for video URLs
    try {
      var html = document.documentElement.innerHTML;
      var m3u8 = html.match(new RegExp('https?://\\\\S+\\\\.m3u8\\\\S*', 'gi'));
      if (m3u8) {
        m3u8.forEach(function(url) {
          if (!seen.has(url)) {
            sources.push({url: url, type: 'hls', quality: 'auto'});
            seen.add(url);
          }
        });
      }
      var mp4 = html.match(new RegExp('https?://\\\\S+\\\\.mp4\\\\S*', 'gi'));
      if (mp4) {
        mp4.forEach(function(url) {
          if (!seen.has(url)) {
            sources.push({url: url, type: 'mp4', quality: 'auto'});
            seen.add(url);
          }
        });
      }
    } catch (e) {
      console.error('[Tatakai] Regex error:', e);
    }
    
    console.log('[Tatakai] Found sources:', sources);
    return sources;
  }
  
  // Extract periodically
  var attempts = 0;
  var interval = setInterval(function() {
    attempts++;
    var result = extract();
    if (result.length > 0) {
      console.log('[Tatakai] Success! Sending to parent:', result);
      window.parent.postMessage({type: 'VIDEO_EXTRACTED', sources: result}, '*');
      clearInterval(interval);
    } else if (attempts >= 50) {
      console.error('[Tatakai] Timeout - no sources found');
      window.parent.postMessage({type: 'EXTRACTION_FAILED', error: 'No sources found'}, '*');
      clearInterval(interval);
    }
  }, 300);
})();
</script>
`;
    
    // Inject before </head> or </body> or at end
    if (html.includes('</head>')) {
      html = html.replace('</head>', extractorScript + '</head>');
    } else if (html.includes('</body>')) {
      html = html.replace('</body>', extractorScript + '</body>');
    } else {
      html += extractorScript;
    }
    
    console.log('[Proxy] Injected extractor script, returning modified HTML');
    
    // Return the modified embed HTML directly
    // The React component will handle loading it and listening for messages
    return new Response(html, {
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
      },
    });
    
  } catch (error) {
    console.error('[Proxy] Error:', error);
    return new Response(
      `<!DOCTYPE html><html><body><h1>Error</h1><p>${error.message}</p></body></html>`,
      {
        status: 500,
        headers: { 'Content-Type': 'text/html' },
      }
    );
  }
}

// Fallback inline template if file not found
async function proxyEmbedPageFallback(embedUrl: string, timeout: number): Promise<Response> {
  console.log(`[VM Mode Fallback] Creating inline wrapper for: ${embedUrl}`);
  
  const wrapperHtml = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Video Player</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { 
      width: 100%; 
      height: 100%; 
      overflow: hidden; 
      background: #000; 
    }
    #player-frame { 
      width: 100%; 
      height: 100%; 
      border: none; 
      position: absolute;
      top: 0;
      left: 0;
      z-index: 1;
    }
    #initial-shield {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      z-index: 100;
      background: rgba(0,0,0,0.7);
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
    }
    #initial-shield.hidden {
      display: none;
    }
    .play-btn {
      width: 100px;
      height: 100px;
      background: rgba(255,255,255,0.95);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: transform 0.2s;
      box-shadow: 0 4px 20px rgba(0,0,0,0.5);
    }
    .play-btn:hover {
      transform: scale(1.1);
    }
    .play-btn svg {
      width: 50px;
      height: 50px;
      margin-left: 8px;
    }
    #status {
      position: fixed;
      top: 10px;
      right: 10px;
      background: rgba(0,200,0,0.9);
      color: white;
      padding: 10px 20px;
      border-radius: 25px;
      font-family: system-ui, sans-serif;
      font-size: 14px;
      font-weight: 500;
      z-index: 10001;
      display: none;
      box-shadow: 0 2px 10px rgba(0,0,0,0.3);
    }
    #tip {
      position: fixed;
      bottom: 20px;
      left: 50%;
      transform: translateX(-50%);
      background: rgba(0,0,0,0.8);
      color: white;
      padding: 12px 24px;
      border-radius: 8px;
      font-family: system-ui, sans-serif;
      font-size: 14px;
      z-index: 10001;
      display: none;
    }
  </style>
</head>
<body>
  <div id="status">🛡️ Ad Blocked</div>
  <div id="tip">💡 Click the play button on the video. If redirected, click back and try again.</div>
  
  <div id="initial-shield">
    <div class="play-btn" id="play-btn">
      <svg viewBox="0 0 24 24" fill="#000">
        <path d="M8 5v14l11-7z"/>
      </svg>
    </div>
  </div>
  
  <iframe 
    id="player-frame"
    src="${embedUrl}"
    allowfullscreen
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen"
  ></iframe>

  <script>
    (function() {
      const shield = document.getElementById('initial-shield');
      const iframe = document.getElementById('player-frame');
      const status = document.getElementById('status');
      const tip = document.getElementById('tip');
      
      let adsBlocked = 0;
      let playerActive = false;
      const currentLocation = window.location.href;
      
      // Show status message
      function showStatus(msg, duration) {
        status.textContent = msg;
        status.style.display = 'block';
        if (duration) {
          setTimeout(() => { status.style.display = 'none'; }, duration);
        }
      }
      
      // Initial click - remove shield completely
      shield.addEventListener('click', function(e) {
        shield.classList.add('hidden');
        tip.style.display = 'block';
        setTimeout(() => { tip.style.display = 'none'; }, 5000);
        playerActive = true;
        console.log('[Ad Blocker] Shield removed, player active');
      });
      
      // AGGRESSIVE REDIRECTION BLOCKING
      
      // Block window.open popups
      const originalOpen = window.open;
      window.open = function(url) {
        adsBlocked++;
        showStatus('🛡️ Popup #' + adsBlocked + ' blocked', 2000);
        console.log('[Ad Blocker] Popup blocked:', url);
        return null;
      };
      
      // Block all location changes
      const blockRedirect = function(attempt) {
        adsBlocked++;
        showStatus('🛡️ Redirect #' + adsBlocked + ' blocked', 2000);
        console.log('[Ad Blocker] Redirect blocked:', attempt);
        return currentLocation;
      };
      
      // Protect window.location
      Object.defineProperty(window, 'location', {
        get: function() { return window.location; },
        set: function(val) { 
          blockRedirect(val);
          return currentLocation;
        }
      });
      
      // Protect location.href
      const originalLocationHref = Object.getOwnPropertyDescriptor(window.location, 'href');
      Object.defineProperty(window.location, 'href', {
        get: function() { return originalLocationHref.get.call(window.location); },
        set: function(val) {
          blockRedirect(val);
          // Don't actually change location
        }
      });
      
      // Block location.replace and location.assign
      window.location.replace = function(url) { blockRedirect(url); };
      window.location.assign = function(url) { blockRedirect(url); };
      
      // Protect top and parent from iframe breakout attempts
      if (window.top !== window.self) {
        try {
          Object.defineProperty(window.top, 'location', {
            get: function() { return window.top.location; },
            set: function(val) { blockRedirect(val); }
          });
        } catch(e) { /* Cross-origin restriction */ }
      }
      
      // Monitor for navigation events
      window.addEventListener('beforeunload', function(e) {
        if (!playerActive) return; // Allow initial navigation
        e.preventDefault();
        e.returnValue = '';
        adsBlocked++;
        showStatus('🛡️ Navigation blocked', 2000);
        console.log('[Ad Blocker] Navigation attempt blocked');
        return '';
      });
      
      // Detect when we lose focus to iframe (user interacting with video)
      window.addEventListener('blur', function() {
        if (document.activeElement === iframe) {
          console.log('[Ad Blocker] User interacting with video');
        }
      });
      
      // Periodic check to ensure we haven't been redirected
      setInterval(function() {
        if (window.location.href !== currentLocation) {
          console.warn('[Ad Blocker] Redirect detected, attempting restore...');
          try {
            window.history.back();
          } catch(e) {
            console.error('[Ad Blocker] Could not restore location');
          }
        }
      }, 100);
      
      // Show persistent status
      showStatus('🛡️ Ad Protection Active', 3000);
      
      console.log('[Ad Blocker] Wrapper loaded with full protection for: ${embedUrl}');
    })();
  </script>
</body>
</html>`;

  return new Response(wrapperHtml, {
    headers: {
      ...corsHeaders,
      'Content-Type': 'text/html; charset=utf-8',
      'X-Frame-Options': 'ALLOWALL',
      'Content-Security-Policy': "frame-ancestors *; frame-src *",
    },
  });
}

/**
 * Main handler for embed ad-blocking requests
 */
serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const embedUrl = url.searchParams.get('url');
    const timeoutParam = url.searchParams.get('timeout');
    const timeout = timeoutParam ? parseInt(timeoutParam, 10) : 30000;
    const mode = url.searchParams.get('mode') || 'extract'; // 'extract' or 'proxy'

    // Validate input
    if (!embedUrl) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Missing required parameter: url',
        } as EmbedAdBlockerResponse),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Validate URL format
    try {
      new URL(embedUrl);
    } catch {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid URL format',
        } as EmbedAdBlockerResponse),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    console.log(`[Request] Mode: ${mode}, URL: ${embedUrl}`);

    // Proxy mode: Return modified HTML
    if (mode === 'proxy') {
      return await proxyEmbedPage(embedUrl, timeout);
    }

    // Extract mode: Return JSON with video sources
    const startTime = Date.now();
    const sources = await extractVideoSourcesLightweight(embedUrl, timeout);
    const executionTime = Date.now() - startTime;

    // Return results
    const response: EmbedAdBlockerResponse = {
      success: sources.length > 0,
      sources: sources.length > 0 ? sources : undefined,
      error: sources.length === 0 ? 'No video sources detected' : undefined,
      debug: {
        totalRequests: 1,
        blockedRequests: 0,
        detectedVideos: sources.length,
        executionTime,
      },
    };

    return new Response(JSON.stringify(response), {
      status: sources.length > 0 ? 200 : 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('[Embed AdBlocker] Fatal error:', error);

    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred',
      } as EmbedAdBlockerResponse),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
