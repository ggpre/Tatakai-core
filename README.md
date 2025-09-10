# Tatakai - Modern Anime Streaming Platform

<div align="center">
  <img src="logo.png" alt="Tatakai Logo" width="120" height="120" />
  
  **A Netflix-inspired anime streaming platform optimized for both web and TV experiences**
  
  [![Next.js](https://img.shields.io/badge/Next.js-15.5.2-000000?style=for-the-badge&logo=next.js&logoColor=white)](https://nextjs.org/)
  [![React](https://img.shields.io/badge/React-19.1.0-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://reactjs.org/)
  [![TypeScript](https://img.shields.io/badge/TypeScript-5.0-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
  [![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4.0-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)](https://tailwindcss.com/)
  [![WebOS](https://img.shields.io/badge/WebOS-Ready-FF6B35?style=for-the-badge&logo=lg&logoColor=white)](https://webostv.developer.lge.com/)
</div>

## Screenshots

### Main Application (Web)
![Tatakai Homepage](https://github.com/user-attachments/assets/931dd8ec-8b6e-4210-9126-175e816af93f)

### Anime Details Page
![One Piece Anime Page](https://github.com/user-attachments/assets/2baac6dc-cc85-4a07-b946-594095126f59)

### WebOS TV Application
![WebOS Tatakai Homepage](https://github.com/user-attachments/assets/9d505db6-da86-45e6-bb32-151646ef3761)

## Overview

Tatakai is a modern anime streaming platform that delivers a seamless viewing experience across web browsers and Smart TVs. Built with cutting-edge technologies, it features a Netflix-inspired interface with TV-optimized navigation and high-quality video streaming capabilities.

### Key Features

- **🎬 Advanced Video Streaming** - HLS.js adaptive streaming with quality selection and enhanced video player controls
- **📱 Cross-Platform Design** - Responsive design optimized for desktop, mobile, tablet, and TV
- **🎮 TV Remote Navigation** - Complete D-pad support with spatial navigation using Lucide React icons
- **🔍 Intelligent Search** - Real-time anime search with fuzzy matching and improved UI
- **📊 Dynamic Rankings** - Top 10 anime lists with daily, weekly, and monthly rankings
- **🎯 Hero Spotlight** - Auto-rotating featured anime with cinematic presentation
- **🎨 Modern UI/UX** - Dark theme with glassmorphism effects and smooth animations
- **⚡ Performance Optimized** - Code splitting, lazy loading, and WebOS optimization
- **🌐 Multi-Language Subtitles** - WebVTT subtitle support with language switching
- **📺 TV-First Experience** - Dedicated TV interface with enhanced focus management
- **🎪 Virtual Keyboard** - On-screen keyboard for TV search functionality
- **🔄 Auto-Continue** - Resume watching and episode auto-play features
- **📱 Device Detection** - Automatic interface switching based on device type
- **🎭 Genre Categories** - Browse by Action, Romance, Comedy, and more
- **🏠 Smart Home Page** - Personalized content recommendations and improved spacing

## 🏗️ Project Structure

```
Tatakai/
├── tatakai-app/                    # Main Next.js Application
│   ├── src/
│   │   ├── app/                    # Next.js App Router Pages
│   │   │   ├── api/
│   │   │   │   ├── anime/route.ts  # Anime API proxy
│   │   │   │   └── video-proxy/route.ts # Video streaming proxy
│   │   │   ├── anime/[id]/         # Anime details pages
│   │   │   ├── watch/[id]/         # Video player pages
│   │   │   ├── tv/                 # TV-optimized routes
│   │   │   │   ├── anime/[id]/     # TV anime details
│   │   │   │   ├── watch/[id]/     # TV video player
│   │   │   │   ├── search/         # TV search interface
│   │   │   │   └── page.tsx        # TV home page
│   │   │   ├── search/             # Web search
│   │   │   ├── category/           # Category pages
│   │   │   ├── trending/           # Trending anime
│   │   │   ├── movies/             # Movies section
│   │   │   ├── profile/            # User profile
│   │   │   └── settings/           # App settings
│   │   ├── components/             # React Components
│   │   │   ├── ui/                 # Shadcn/UI Components
│   │   │   │   ├── button.tsx      # Button variants
│   │   │   │   ├── card.tsx        # Card layouts
│   │   │   │   ├── dialog.tsx      # Modal dialogs
│   │   │   │   ├── carousel.tsx    # Carousel component
│   │   │   │   └── [18 more...]    # Complete UI library
│   │   │   ├── tv/                 # TV-Specific Components
│   │   │   │   └── TVVideoPlayer.tsx # TV video player
│   │   │   ├── VideoPlayer.tsx     # Desktop video player
│   │   │   ├── TVVideoPlayer.tsx   # Main TV video player
│   │   │   ├── AnimeCarousel.tsx   # Horizontal anime scrolling
│   │   │   ├── HeroSection.tsx     # Featured anime hero
│   │   │   ├── TVHomePage.tsx      # TV home interface
│   │   │   ├── TVAnimeCard.tsx     # TV-focused anime cards
│   │   │   ├── TVNavigation.tsx    # TV navigation system
│   │   │   ├── TVVirtualKeyboard.tsx # On-screen keyboard
│   │   │   ├── Navigation.tsx      # Web navigation
│   │   │   ├── Top10Section.tsx    # Ranking displays
│   │   │   └── [10 more...]        # Additional components
│   │   ├── contexts/               # React Context Providers
│   │   │   ├── NavigationContext.tsx # TV navigation state
│   │   │   └── TVNavigationContext.tsx # TV-specific navigation
│   │   ├── hooks/                  # Custom React Hooks
│   │   │   ├── useScreenDetection.ts # Device type detection
│   │   │   ├── useKeyboardNavigation.ts # Keyboard handling
│   │   │   ├── useRemoteControl.ts # TV remote support
│   │   │   ├── useLGTVIntegration.ts # LG TV APIs
│   │   │   └── index.ts            # Hook exports
│   │   ├── lib/                    # Core Libraries
│   │   │   ├── api.ts              # Anime API client
│   │   │   └── utils.ts            # Utility functions
│   │   ├── utils/                  # Additional Utilities
│   │   │   └── tvMode.ts           # TV mode helpers
│   │   └── styles/                 # Styling
│   │       └── tv.css              # TV-specific styles
│   ├── public/                     # Static Assets
│   │   ├── logo.png                # App logo
│   │   ├── placeholder-anime.jpg   # Fallback image
│   │   └── [SVG icons...]          # UI icons
│   ├── components.json             # Shadcn/UI config
│   ├── next.config.js/ts           # Next.js configuration
│   ├── tailwind.config.js          # Tailwind CSS config
│   ├── tsconfig.json               # TypeScript config
│   └── package.json                # Dependencies
├── Deprecated/                     # Legacy WebOS Implementation
│   ├── src/                        # React Source Code
│   │   ├── components/             # React components
│   │   │   ├── tv/                 # TV-specific components
│   │   │   └── ui/                 # Shared UI components
│   │   ├── pages/                  # Application pages
│   │   │   ├── HomePage.tsx        # Main home page
│   │   │   ├── AnimeDetailsPage.tsx # Anime details
│   │   │   ├── VideoPlayerPage.tsx # Video player
│   │   │   ├── SearchPage.tsx      # Search interface
│   │   │   └── SettingsPage.tsx    # App settings
│   │   ├── context/                # React contexts
│   │   │   └── RemoteNavigationContext.tsx # TV navigation
│   │   ├── services/               # API services
│   │   │   ├── api.ts              # Anime API client
│   │   │   └── videoProxy.ts       # Video proxy service
│   │   ├── hooks/                  # Custom hooks
│   │   ├── utils/                  # Utility functions
│   │   ├── styles/                 # CSS styles
│   │   ├── assets/                 # Static assets
│   │   ├── App.tsx                 # Root component
│   │   └── index.tsx               # Entry point
│   ├── webos_meta/                 # WebOS Metadata
│   │   └── appinfo.json            # WebOS app configuration
│   ├── webpack.config.js           # Webpack build config
│   ├── proxy-server.js             # Development proxy server
│   ├── tailwind.config.js          # Tailwind configuration
│   ├── tsconfig.json               # TypeScript configuration
│   └── package.json                # WebOS dependencies
├── docs/                           # Documentation
│   └── backend.md                  # API documentation
├── TV_FIXES_TESTING_GUIDE.md       # TV testing guide
├── todo.md                         # Development roadmap
├── webostatak.md                   # WebOS development plan
├── logo.png                        # Project logo
└── README.md                       # This documentation
```

## 🛠️ Technology Stack

### Frontend Framework
- **Next.js 15.5.2** with App Router and Turbopack
- **React 19.1.0** with TypeScript 5.0
- **Tailwind CSS 4.0** with CSS Variables
- **PostCSS** with modern plugins

### UI Components & Design
- **Shadcn/UI** - 19 complete UI components (Button, Card, Dialog, etc.)
- **Radix UI Primitives** - Accessible component foundations
- **Class Variance Authority** - Component variants system
- **Lucide React** - 500+ modern icons
- **Framer Motion 12.23.12** - Advanced animations

### Video & Media Streaming
- **HLS.js 1.6.11** - Adaptive bitrate streaming
- **Custom Video Proxy** - CORS and authentication handling
- **WebVTT Subtitles** - Multi-language subtitle support
- **Quality Selection** - Automatic and manual quality control

### TV Platform Development
- **LG WebOS SDK** - Smart TV development platform
- **Remote Control API** - Directional navigation support
- **TV Navigation Context** - Focus management system
- **Spatial Navigation** - 2D grid navigation for TV

### Development Tools
- **TypeScript 5.0** - Type safety and IntelliSense
- **ESLint 9** - Code quality and consistency
- **Prettier** - Code formatting
- **Webpack 5** - Legacy WebOS bundling

### State Management
- **React Context** - Navigation and app state
- **React Hooks** - Local component state
- **Custom Hooks** - Reusable stateful logic

### API Integration
- **HiAnime API** - Anime metadata and episodes
- **Next.js API Routes** - Server-side proxy endpoints
- **Fetch API** - HTTP client with error handling

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- npm or yarn
- (Optional) LG WebOS CLI for TV development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Snozxyx/Tatakai.git
   cd Tatakai
   ```

2. **Install dependencies for the main app**
   ```bash
   cd tatakai-app
   npm install
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```

4. **Open your browser**
   ```
   http://localhost:3000
   ```

### TV Development (WebOS)

1. **Install WebOS CLI** (if developing for TV)
   ```bash
   npm install -g @webosose/ares-cli
   ```

2. **Navigate to deprecated folder** (for WebOS build)
   ```bash
   cd Deprecated
   npm install
   ```

3. **Build for WebOS**
   ```bash
   npm run build
   npm run package
   ```

## Features Deep Dive

### Video Streaming Architecture
- **Adaptive Bitrate Streaming** using HLS.js with automatic quality detection
- **Multiple Video Sources** with fallback mechanisms for reliability
- **Subtitle Engine** supporting WebVTT with multi-language switching
- **Video Proxy System** handling CORS, authentication, and M3U8 manifest rewriting
- **TV-Optimized Playback** with remote control integration and focus management
- **Quality Selection** manual override for different connection speeds
- **Auto-Resume** functionality with progress tracking

### 🎨 User Interface & Experience
- **Hero Spotlight** with auto-rotating featured anime and smooth transitions
- **Anime Carousels** for different categories with infinite horizontal scrolling
- **Top 10 Rankings** with animated tabbed interface (Today/Week/Month)
- **Search Interface** with real-time suggestions and virtual keyboard for TV
- **Responsive Grid Layouts** adapting to screen sizes and device capabilities
- **Glassmorphism Design** with backdrop blur effects and modern aesthetics
- **Loading States** with skeleton screens and smooth transitions

### 📺 TV Experience Excellence
- **Spatial Navigation** with intelligent focus management across UI elements
- **Remote Control Integration** supporting all TV remote buttons and gestures
- **TV-Safe Areas** respecting overscan and ensuring content visibility
- **Performance Optimization** targeting 60fps on Smart TV hardware
- **Voice Control Ready** prepared for future voice command integration
- **Screen Burn-in Protection** with automatic screensavers and content rotation

### 🔧 Technical Architecture
- **API Abstraction Layer** with retry logic and error handling
- **Component Composition** using React context for state management
- **Custom Hooks** for device detection, navigation, and media control
- **TypeScript Interfaces** ensuring type safety across the entire application
- **Code Splitting** by routes and components for optimal loading
- **WebOS Integration** with platform-specific APIs and lifecycle management

### API Integration System
- **HiAnime API Client** for comprehensive anime metadata and episodes
- **Video Source Resolution** with multiple streaming server support
- **Search Engine** with fuzzy matching and category filtering
- **Proxy Middleware** for cross-origin request handling
- **Cache Management** for offline capability and performance
- **Error Boundaries** with graceful degradation and user feedback

## Usage

### Web Interface
1. **Browse Anime** - Scroll through featured and trending content
2. **Search** - Use the search bar for specific titles
3. **Watch** - Click any anime to view details and episodes
4. **Video Player** - Full-featured player with quality and subtitle controls

### TV Interface
1. **Navigate** using your TV remote's directional pad
2. **Select** content with the OK/Enter button
3. **Control Playback** using play/pause/volume controls
4. **Return** using the back button

### Keyboard Shortcuts (Web)
- `Space` - Play/Pause video
- `F` - Toggle fullscreen
- `M` - Mute/Unmute
- `←/→` - Seek backward/forward
- `↑/↓` - Volume up/down

## 🏭 API Documentation

### Core API Endpoints

#### Video Proxy Service
```typescript
GET /api/video-proxy?url={videoUrl}
```
Handles video stream proxying with CORS resolution and M3U8 manifest rewriting.

**Headers Added:**
- `User-Agent`: Modern browser identification
- `Referer`: Content source validation  
- `Origin`: Request origin handling
- `Accept`: Content type specification

#### Anime Data Proxy
```typescript
GET /api/anime?endpoint={apiPath}&{queryParams}
```
Proxies requests to HiAnime API with rate limiting and error handling.

### TypeScript Interfaces

#### Core Anime Structure
```typescript
interface Anime {
  id: string;                    // Unique anime identifier
  name: string;                  // Anime title
  poster: string;                // Cover image URL
  type?: string;                 // TV, Movie, OVA, etc.
  episodes?: {                   // Episode counts
    sub: number;                 // Subtitled episodes
    dub: number;                 // Dubbed episodes
  };
  jname?: string;                // Japanese title
  description?: string;          // Plot summary
  rank?: number;                 // Popularity ranking
  otherInfo?: string[];          // Additional metadata
  duration?: string;             // Episode duration
  rating?: string;               // Content rating
}
```

#### Video Source Interface
```typescript
interface VideoSource {
  url: string;                   // Stream URL
  isM3U8: boolean;              // HLS stream indicator
  quality?: string;             // Quality label (1080p, 720p, etc.)
}

interface Subtitle {
  lang: string;                 // Language code
  url: string;                  // Subtitle file URL
  label?: string;               // Display label
}
```

#### Episode Data Structure
```typescript
interface Episode {
  episodeId: string;            // Unique episode ID
  number: number;               // Episode number
  title?: string;               // Episode title
  isFiller?: boolean;           // Filler episode flag
}

interface StreamingData {
  sources: VideoSource[];       // Available video sources
  subtitles: Subtitle[];        // Available subtitles
  headers?: Record<string, string>; // Required headers
}
```

### API Response Formats

#### Home Page Data
```typescript
interface HomePageData {
  success: boolean;
  data: {
    genres: string[];                    // Available genres
    latestEpisodeAnimes: Anime[];       // Recently updated
    spotlightAnimes: SpotlightAnime[];  // Featured content
    top10Animes: {                      // Ranking lists
      today: Anime[];
      week: Anime[];
      month: Anime[];
    };
    topAiringAnimes: Anime[];           // Currently airing
    trendingAnimes: Anime[];            // Trending content
    mostPopularAnimes: Anime[];         // Popular series
    mostFavoriteAnimes: Anime[];        // Community favorites
  };
}
```

#### Error Response Format
```typescript
interface APIError {
  success: false;
  error: string;                // Error message
  status?: number;              // HTTP status code
  details?: any;                // Additional error info
}
```

## 🔧 Configuration

### Environment Variables
Create a `.env.local` file in the `tatakai-app` directory:
```env
# API Configuration
NEXT_PUBLIC_API_BASE_URL=https://aniwatch-api-taupe-eight.vercel.app
NEXT_PUBLIC_APP_URL=http://localhost:3000

# Video Proxy Settings
VIDEO_PROXY_USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
VIDEO_PROXY_REFERER="https://megacloud.blog/"

# Development Settings
NODE_ENV=development
NEXT_PUBLIC_DEBUG_MODE=true
```

### Next.js Configuration
Key settings in `next.config.ts`:
```typescript
const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      { hostname: 'cdn.noitatnemucod.net' },
      { hostname: 'gogocdn.net' },
      { hostname: 's4.anilist.co' },
      { hostname: 'artworks.thetvdb.com' },
      { hostname: 'image.tmdb.org' },
      { hostname: 'media.kitsu.io' }
    ]
  },
  // Turbopack for faster development
  experimental: {
    turbo: true
  }
};
```

### Shadcn/UI Configuration
Located in `components.json`:
```json
{
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "src/app/globals.css",
    "baseColor": "neutral",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui"
  }
}
```

### WebOS Configuration
Located in `Deprecated/webos_meta/appinfo.json`:
```json
{
  "id": "com.tatakai.webos",
  "version": "1.0.0",
  "title": "Tatakai - Anime Streaming",
  "main": "index.html",
  "requiredPermissions": [
    "internet",
    "audio.operation", 
    "video.operation",
    "network.operation",
    "storage.operation"
  ],
  "displayAffinity": "landscape",
  "supportGlobalSearch": true,
  "trustLevel": "trusted"
}
```

### Tailwind CSS Configuration
```javascript
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        // Custom color scheme for anime theme
        rose: { 500: '#e11d48' },
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))'
      },
      animation: {
        // Custom animations for smooth UX
        'spin': 'spin 1s linear infinite',
        'fade-in': 'fadeIn 0.5s ease-in-out'
      }
    }
  },
  plugins: []
};
```

### TypeScript Configuration
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "ES6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

## Performance & Optimization

### Performance Metrics
- **Bundle Size**: < 2MB main bundle, < 5MB total application size
- **First Load**: < 2 seconds on 3G networks
- **Time to Interactive**: < 3 seconds on average connections  
- **Video Start Time**: < 1.5 seconds for HLS streams
- **TV Navigation**: 60fps smooth transitions on Smart TVs
- **Lighthouse Score**: 95+ for Performance, Accessibility, and SEO

### Optimization Strategies

#### Code Splitting & Loading
- **Route-based Splitting** with Next.js automatic optimization
- **Component Lazy Loading** for off-screen carousels and modals
- **Dynamic Imports** for HLS.js and heavy libraries
- **Image Optimization** with Next.js Image component and WebP format
- **Tree Shaking** to eliminate unused code from bundles

#### Memory Management
- **React.memo** for expensive component re-renders
- **useCallback/useMemo** for expensive computations
- **Cleanup Functions** for event listeners and intervals
- **HLS Instance Management** proper cleanup to prevent memory leaks

#### Network Optimization
- **API Response Caching** with stale-while-revalidate strategy
- **Image CDN Integration** for optimized anime poster delivery
- **Request Deduplication** to prevent duplicate API calls
- **Compression** using gzip/brotli for static assets

#### TV-Specific Optimizations
- **Reduced Animation Complexity** for TV hardware constraints
- **Efficient Focus Management** minimizing DOM queries
- **Optimized Rendering** avoiding unnecessary re-renders during navigation
- **Memory-Conscious Carousels** with virtualization for large lists

## 🧪 Testing & Quality Assurance

### Testing Strategy

#### Component Testing
```bash
# Unit tests for components
npm run test

# Component integration tests  
npm run test:integration

# Visual regression testing
npm run test:visual
```

#### TV Navigation Testing
```bash
# Enable TV mode for testing
enableTVMode()  # Run in browser console

# Test navigation flows
1. Navigate to http://localhost:3000/tv
2. Use arrow keys for spatial navigation
3. Press Enter to select items
4. Test all carousel interactions
```

#### Manual Testing Checklist
- [ ] **Desktop Experience** - All features work on 1920x1080+ screens
- [ ] **Mobile Responsiveness** - Proper layout on 375px to 768px
- [ ] **Tablet Experience** - Optimized for 768px to 1024px  
- [ ] **TV Interface** - Remote navigation works on 4K displays
- [ ] **Video Playback** - HLS streams load and play smoothly
- [ ] **Search Functionality** - Real-time search with accurate results
- [ ] **Error Handling** - Graceful fallbacks for network issues

### TV Simulator Testing
```bash
# WebOS Simulator (requires WebOS SDK)
ares-simulator --display tv

# Chrome DevTools TV Simulation
1. Open Chrome DevTools
2. Toggle device toolbar
3. Select "Responsive" mode
4. Set to 3840x2160 (4K TV)
5. Enable TV mode: enableTVMode()
```

### Performance Testing
```bash
# Lighthouse performance audit
npx lighthouse http://localhost:3000 --view

# Bundle analysis
npm run analyze

# Memory leak detection
# Use Chrome DevTools Memory tab during navigation
```

### Accessibility Testing
- **WCAG 2.1 AA Compliance** for screen readers
- **Keyboard Navigation** support for all interactions
- **High Contrast Mode** compatibility
- **Focus Indicators** visible on all interactive elements

## 🚀 Deployment Options

### Vercel (Recommended for Web)
1. **Connect Repository** to Vercel via GitHub integration
2. **Configure Environment Variables** in Vercel dashboard
3. **Automatic Deployments** trigger on every push to main branch
4. **Edge Runtime** for optimal global performance

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy from local
vercel --prod
```

### Docker Deployment
```dockerfile
# Dockerfile for containerized deployment
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM base AS build
COPY . .
RUN npm run build

FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/package.json ./package.json
EXPOSE 3000
CMD ["npm", "start"]
```

```bash
# Build and run Docker container
docker build -t tatakai-app .
docker run -p 3000:3000 tatakai-app
```

### LG WebOS TV Deployment
```bash
# Navigate to WebOS project
cd Deprecated

# Install WebOS CLI tools
npm install -g @webosose/ares-cli

# Build for production
npm run build

# Package for WebOS
npm run package

# Install on connected TV
ares-setup-device --search  # Find your TV
ares-setup-device --add tv  # Add your TV
npm run install-device      # Install app

# Launch app on TV
npm run launch
```

### Static Hosting (Netlify/Vercel)
```bash
# Build static export
npm run build
npm run export

# Deploy static files to any CDN
```

### Self-Hosted Options
```bash
# PM2 Process Manager
npm install -g pm2
pm2 start ecosystem.config.js

# systemd Service (Linux)
sudo systemctl enable tatakai-app
sudo systemctl start tatakai-app

# Nginx Reverse Proxy
server {
    listen 80;
    server_name your-domain.com;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Code Style
- Use TypeScript for all new code
- Follow ESLint configuration
- Use Prettier for code formatting
- Write descriptive commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Next.js Team** for the amazing framework
- **Radix UI** for accessible component primitives
- **Tailwind CSS** for utility-first styling
- **HLS.js** for video streaming capabilities
- **LG WebOS** for Smart TV platform support

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Snozxyx/Tatakai/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Snozxyx/Tatakai/discussions)
- **Documentation**: [Project Wiki](https://github.com/Snozxyx/Tatakai/wiki)

---

<div align="center">
  <p>Built with ❤️ for anime enthusiasts worldwide</p>
  <p>© 2025 Tatakai. Made for educational purposes.</p>
</div>
