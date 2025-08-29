import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const videoUrl = searchParams.get('url');

  if (!videoUrl) {
    return NextResponse.json({ error: 'Video URL is required' }, { status: 400 });
  }

  try {
    console.log('Proxying video request for:', videoUrl);

    // Forward the request to the actual video URL
    const response = await fetch(videoUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.9',
        'Referer': 'https://aniwatch.to/',
        'Origin': 'https://aniwatch.to',
        'Range': request.headers.get('range') || '',
      },
    });

    if (!response.ok) {
      console.error(`Video proxy error! status: ${response.status}`);
      return NextResponse.json(
        { error: `Failed to fetch video: ${response.status}` },
        { status: response.status }
      );
    }

    // Get the content type from the response
    const contentType = response.headers.get('content-type') || 'application/vnd.apple.mpegurl';
    
    // Get the response body
    let data;
    if (contentType.includes('application/vnd.apple.mpegurl') || contentType.includes('text/plain')) {
      // Handle M3U8 manifests - rewrite URLs to use our proxy
      const text = await response.text();
      const baseUrl = new URL(videoUrl);
      const basePath = baseUrl.pathname.substring(0, baseUrl.pathname.lastIndexOf('/') + 1);
      
      // Rewrite relative URLs in the manifest to use our proxy
      const rewrittenText = text.replace(
        /^(?!#|https?:\/\/)(.+)$/gm,
        (match, filename) => {
          const trimmed = filename.trim();
          if (!trimmed || trimmed.startsWith('#')) return match;
          
          // Skip URI attributes in EXT-X-I-FRAME-STREAM-INF
          if (match.includes('URI=')) {
            return match.replace(/URI="([^"]+)"/g, (uriMatch, uri) => {
              const fullUrl = `${baseUrl.protocol}//${baseUrl.host}${basePath}${uri}`;
              return `URI="/api/video-proxy?url=${encodeURIComponent(fullUrl)}"`;
            });
          }
          
          let fullUrl;
          if (trimmed.startsWith('http')) {
            fullUrl = trimmed;
          } else {
            fullUrl = `${baseUrl.protocol}//${baseUrl.host}${basePath}${trimmed}`;
          }
          return `/api/video-proxy?url=${encodeURIComponent(fullUrl)}`;
        }
      );
      
      console.log('Original manifest (first 300 chars):', text.substring(0, 300));
      console.log('Rewritten manifest (first 300 chars):', rewrittenText.substring(0, 300));
      
      data = new TextEncoder().encode(rewrittenText);
    } else {
      data = await response.arrayBuffer();
    }

    // Return the video data with proper headers
    return new NextResponse(data, {
      status: 200,
      headers: {
        'Content-Type': contentType,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Range, Content-Type',
        'Accept-Ranges': 'bytes',
        'Cache-Control': 'public, max-age=3600',
        'Content-Length': data.byteLength.toString(),
      },
    });
  } catch (error) {
    console.error('Video proxy error:', error);
    return NextResponse.json(
      { error: 'Failed to proxy video request' },
      { status: 500 }
    );
  }
}

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Range, Content-Type',
    },
  });
}
