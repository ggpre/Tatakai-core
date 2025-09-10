const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3002;

// CORS configuration
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Range'],
}));

app.use(express.json());

// Serve static files from the WebOS app dist folder
app.use(express.static(path.join(__dirname, 'dist')));

// API proxy endpoints
app.use('/api', async (req, res) => {
  try {
    const { endpoint = '' } = req.query;
    const baseUrl = 'https://aniwatch-api-taupe-eight.vercel.app/api/v2/hianime';
    
    // Remove endpoint from query and build query string
    const params = new URLSearchParams(req.query);
    params.delete('endpoint');
    const queryString = params.toString();
    
    const apiUrl = `${baseUrl}${endpoint}${queryString ? '?' + queryString : ''}`;
    console.log('Proxying request to:', apiUrl);
    
    const response = await fetch(apiUrl, {
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
    });

    if (!response.ok) {
      console.error(`HTTP error! status: ${response.status}`);
      return res.status(response.status).json({
        success: false,
        error: `HTTP error! status: ${response.status}`
      });
    }

    const data = await response.json();
    
    // Transform the response to match our expected structure
    const transformedData = {
      success: data.status === 200,
      data: data.data || data,
      status: data.status
    };
    
    res.json(transformedData);
  } catch (error) {
    console.error('API Proxy Error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to proxy API request',
      details: error.message
    });
  }
});

// Video proxy endpoint
app.get('/api/video-proxy', async (req, res) => {
  try {
    const { url } = req.query;
    
    if (!url) {
      return res.status(400).json({ error: 'URL parameter is required' });
    }

    console.log('Proxying video request to:', url);

    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Referer': 'https://megacloud.blog/',
        'Origin': 'https://aniwatch.to',
        'Range': req.headers.range || '',
      },
    });

    if (!response.ok) {
      console.error(`Video proxy error! status: ${response.status}`);
      return res.status(response.status).json({
        error: `Failed to fetch video: ${response.status}`
      });
    }

    // Get the content type from the response
    const contentType = response.headers.get('content-type') || 'application/vnd.apple.mpegurl';
    
    // Set response headers
    res.set({
      'Content-Type': contentType,
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Range, Content-Type',
      'Accept-Ranges': 'bytes',
      'Cache-Control': 'public, max-age=3600',
    });

    // Handle M3U8 manifests - rewrite URLs to use our proxy
    if (contentType.includes('application/vnd.apple.mpegurl') || contentType.includes('text/plain')) {
      const text = await response.text();
      const baseUrl = new URL(url);
      const basePath = baseUrl.pathname.substring(0, baseUrl.pathname.lastIndexOf('/') + 1);
      
      // Rewrite relative URLs in the manifest to use our proxy
      const rewrittenText = text.replace(
        /^(?!#|https?:\/\/)(.+)$/gm,
        (match, filename) => {
          const trimmed = filename.trim();
          if (!trimmed || trimmed.startsWith('#')) return match;
          
          let fullUrl;
          if (trimmed.startsWith('http')) {
            fullUrl = trimmed;
          } else {
            fullUrl = `${baseUrl.protocol}//${baseUrl.host}${basePath}${trimmed}`;
          }
          
          return `http://localhost:${PORT}/api/video-proxy?url=${encodeURIComponent(fullUrl)}`;
        }
      );
      
      console.log('Rewritten M3U8 manifest for WebOS');
      res.send(rewrittenText);
    } else {
      // Pipe the response directly for video segments
      response.body.pipe(res);
    }
  } catch (error) {
    console.error('Video proxy error:', error);
    res.status(500).json({
      error: 'Failed to proxy video request'
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'WebOS Tatakai Dev Server Running', 
    port: PORT,
    timestamp: new Date().toISOString()
  });
});

// Serve the WebOS app for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

// Start server
app.listen(PORT, () => {
  console.log(`🎥 WebOS Tatakai Development Server running on http://localhost:${PORT}`);
  console.log(`📺 Ready to serve the WebOS TV app`);
  console.log(`🔗 API Proxy available at: http://localhost:${PORT}/api`);
  console.log(`🎬 Video Proxy available at: http://localhost:${PORT}/api/video-proxy`);
});

module.exports = app;