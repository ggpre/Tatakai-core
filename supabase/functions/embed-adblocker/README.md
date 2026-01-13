# Embed Ad-Blocker Function

## Overview

This Supabase Edge Function extracts clean video sources from embed URLs by parsing HTML content and blocking ad/tracking requests. It acts as a middleware layer between your app and third-party embed servers.

## How It Works

```
User Request → useCombinedSources Hook → Embed Ad-Blocker Function → Clean Video Source
                                      ↓
                               Parse Embed HTML
                                      ↓
                            Block Ad Domains/Patterns
                                      ↓
                            Extract M3U8/MP4 URLs
                                      ↓
                         Return Direct Video Sources
```

## Architecture

### 1. **Edge Function** (`index.ts`)
- Fetches embed page HTML with proper headers
- Parses content for video sources using regex patterns
- Filters out known ad/tracking domains
- Returns clean M3U8/MP4 URLs

### 2. **Frontend Integration**

#### API Helper (`src/lib/api.ts`)
```typescript
embedAdBlocker(embedUrl: string, timeout?: number)
```

#### Combined Sources Hook (`src/hooks/useCombinedSources.ts`)
- Automatically processes embed sources
- Attempts extraction before iframe fallback
- Converts successful extractions to direct sources
- Falls back to iframe player if extraction fails

#### Embed Player (`src/components/video/EmbedPlayer.tsx`)
- Hardened sandbox: removed `allow-popups`
- Detects rapid click patterns (ad redirects)
- Shows blocked redirect counter
- Improved security posture

## Ad Blocking Features

### Domain Blocklist
The function blocks requests to known ad/tracking domains:
- `doubleclick.net`, `googlesyndication.com`
- `popads.net`, `popcash.net`
- `propellerads.com`, `exoclick.com`
- `adsterra.com`, `clickadu.com`
- URLs containing: `/ads/`, `/ad/`, `banner`, `popup`, `redirect.php`

### Video Detection Patterns
Recognizes video sources by:
- **File extensions**: `.m3u8`, `.mp4`, `.mkv`, `.webm`
- **Playlist patterns**: `master.m3u8`, `playlist.m3u8`
- **Quality indicators**: `720p`, `1080p`, `hd`, `fhd`, `4k`

### HTML Parsing
Extracts URLs from:
- HTML attributes: `src`, `href`, `data-src`, `data-video`, `data-url`, `file`
- JavaScript variables: `videoSource`, `sourceUrl`, `streamUrl`, `playUrl`
- JSON objects embedded in `<script>` tags

## API Usage

### Request
```
GET /functions/v1/embed-adblocker?url={embedUrl}&timeout={ms}
Headers:
  apikey: {SUPABASE_ANON_KEY}
  Authorization: Bearer {SUPABASE_ANON_KEY}
```

### Response
```json
{
  "success": true,
  "sources": [
    {
      "url": "https://example.com/video/master.m3u8",
      "type": "hls",
      "quality": "1080p"
    }
  ],
  "debug": {
    "totalRequests": 1,
    "blockedRequests": 0,
    "detectedVideos": 1,
    "executionTime": 1234
  }
}
```

## Configuration

### Environment Variables
None required currently. Future enhancements may add:
- `AD_BLOCKER_TIMEOUT` - Default extraction timeout
- `BROWSERLESS_API_KEY` - For headless browser service
- `CUSTOM_BLOCKLIST_URL` - Remote blocklist updates

### Frontend Settings
In your `.env`:
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

## Limitations & Future Enhancements

### Current Limitations
1. **HTML Parsing Only** - Uses regex-based extraction, not full browser rendering
2. **JavaScript Execution** - Cannot handle dynamically loaded video sources
3. **Canvas Protection** - Cannot extract from Canvas-based players
4. **CAPTCHA** - No automated solving (requires manual intervention)

### Recommended Enhancements

#### 1. Full Headless Browser Integration
Use Puppeteer/Playwright for JavaScript execution:

**Option A: Browserless.io (Recommended)**
```typescript
const response = await fetch('https://chrome.browserless.io/content', {
  method: 'POST',
  headers: { 'Cache-Control': 'no-cache' },
  body: JSON.stringify({
    url: embedUrl,
    rejectRequestPattern: AD_DOMAINS,
    waitFor: 5000,
  })
});
```

**Option B: Self-hosted Microservice**
- Deploy separate Puppeteer service on Render/Railway
- Call from Edge Function
- Higher reliability, more control

#### 2. Network Request Interception
```typescript
page.on('request', (request) => {
  if (isAdRequest(request.url())) {
    request.abort();
  } else {
    request.continue();
  }
});
```

#### 3. Provider-Specific Extractors
```typescript
const extractors = {
  'filemoon.sx': extractFilemoon,
  'vidgroud.com': extractVidgroud,
  'servabyss.com': extractServabyss,
};
```

#### 4. Caching Layer
```typescript
// Cache extracted sources with TTL
const cache = new Map<string, { sources: Source[], expires: number }>();
```

#### 5. User Feedback System
- Report false positives
- Submit new ad patterns
- Community blocklist contributions

## Deployment

### Deploy to Supabase
```bash
# Link your project
supabase link --project-ref your-project-ref

# Deploy function
supabase functions deploy embed-adblocker

# Test
curl "https://your-project.supabase.co/functions/v1/embed-adblocker?url=https://example.com/embed/123"
```

### Update Frontend
Changes are already integrated. Just deploy your frontend:
```bash
npm run build
# Deploy to Vercel/Netlify
```

## Monitoring

### Edge Function Logs
```bash
supabase functions logs embed-adblocker
```

### Frontend Console
```javascript
// Check extraction results
console.log('[Ad-Blocker] Extracted sources:', sources);

// Monitor blocked redirects
// Look for ShieldAlert notifications in EmbedPlayer
```

## Legal & Ethical Considerations

⚠️ **Important**: This tool is designed to:
- Improve user experience by removing intrusive ads
- Protect users from malicious redirects
- Extract publicly accessible video sources

**You are responsible for**:
- Respecting copyright and intellectual property
- Complying with embed provider Terms of Service
- Following applicable laws in your jurisdiction
- Not bypassing legitimate paywall/DRM protections

Consider:
- Adding user consent toggle in settings
- Displaying provider attribution
- Caching responsibly (respect robots.txt)
- Rate limiting to avoid server abuse

## Support

For issues or questions:
1. Check Supabase logs for errors
2. Verify CORS headers are properly set
3. Test with `curl` to isolate frontend vs backend issues
4. Review extraction patterns for your specific providers

## Contributing

To add support for new embed providers:
1. Add provider patterns to `VIDEO_PATTERNS`
2. Add provider ad domains to `AD_DOMAINS`
3. Test with provider-specific embed URLs
4. Update this README with findings
