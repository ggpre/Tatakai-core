# Tatakai WebOS TV App

A modern anime streaming application built specifically for LG WebOS TV platform. This app provides a Netflix-style interface optimized for TV remote control navigation with a dark theme and rose accent colors.

## 🎯 Features

- **TV-Optimized Navigation**: Remote control friendly interface with directional navigation
- **Modern UI**: Dark theme with rose accent colors using shadcn/ui components
- **Real API Integration**: Connects to HiAnime API for live anime data (no mock data)
- **Video Streaming**: HLS.js powered video player with adaptive streaming
- **WebOS Compatibility**: Built specifically for LG WebOS TV version 6+
- **Responsive Design**: TV-safe areas and proper scaling for various TV screen sizes

## 🛠️ Technology Stack

- **React 18** + **TypeScript** for modern development
- **Vite** for fast build and development
- **Tailwind CSS** for styling with TV-optimized classes
- **shadcn/ui** for consistent UI components
- **HLS.js** for video streaming
- **Framer Motion** for smooth animations
- **WebOS SDK** compatible structure

## 🏗️ Project Structure

```
webos-tatakai-app/
├── src/
│   ├── components/
│   │   ├── ui/              # shadcn/ui components
│   │   └── tv/              # TV-specific components
│   ├── context/             # React contexts (Navigation)
│   ├── services/            # API services with proxy
│   ├── types/              # TypeScript definitions
│   ├── lib/                # Utility functions
│   └── styles/             # Global styles
├── webos_meta/             # WebOS app metadata
├── public/                 # Static assets
└── dist/                   # Build output
```

## 🚀 Development

### Prerequisites

- Node.js 18+
- npm or yarn
- LG WebOS SDK (for deployment)

### Setup

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Start development server**:
   ```bash
   npm run dev
   ```

3. **Build for production**:
   ```bash
   npm run build
   ```

4. **Start production server with API proxy**:
   ```bash
   npm run start
   ```

### API Configuration

The app includes a built-in API proxy server that handles:
- **Anime API**: Proxies requests to HiAnime API
- **Video Proxy**: Handles video streaming with CORS resolution
- **M3U8 Rewriting**: Processes HLS manifests for WebOS compatibility

### TV Navigation

The app uses a custom navigation system optimized for TV remote controls:

- **Arrow Keys**: Navigate between focusable elements
- **Enter/OK**: Select current element
- **Back**: Return to previous screen
- **Remote Control**: Full WebOS remote control support

## 📺 WebOS Deployment

### Package for WebOS

1. **Build the app**:
   ```bash
   npm run build
   ```

2. **Package for WebOS** (requires WebOS SDK):
   ```bash
   npm run webos-package
   ```

3. **Install on TV** (requires connected TV):
   ```bash
   npm run webos-install
   ```

4. **Launch app**:
   ```bash
   npm run webos-launch
   ```

### WebOS Configuration

The app is configured in `webos_meta/appinfo.json`:

- **App ID**: `com.tatakai.webos`
- **WebOS Version**: 6.0+
- **Permissions**: Internet, Video Playback, Media Operation
- **Resolution**: 1920x1080 with TV-safe areas

## 🎨 UI/UX Features

### Dark Theme with Rose Accent

- Primary: Rose 500 (#f43f5e)
- Background: Dark with glass morphism effects
- Typography: TV-optimized font sizes
- Animations: Smooth focus transitions

### TV-Optimized Components

- **TVNavigation**: Collapsible sidebar navigation
- **TVCard**: Anime cards with focus states
- **TVCarousel**: Horizontal scrolling lists
- **TVHero**: Featured content display
- **TVVideoPlayer**: Full-featured video player

### Focus Management

- Automatic focus handling
- Directional navigation
- Focus history for back navigation
- Visual focus indicators

## 🔗 API Integration

### Anime Data

- Home page content (trending, popular, latest)
- Anime details and metadata
- Episode listings
- Search functionality
- Genre and category browsing

### Video Streaming

- HLS manifest processing
- Multiple server support
- Subtitle support
- Adaptive quality streaming

### Proxy System

Custom proxy handles:
- CORS issues
- Video URL rewriting
- Authentication headers
- Error handling and retries

## 🔧 Configuration

### Environment Variables

Create a `.env` file for development:

```env
VITE_API_BASE_URL=http://localhost:3002/api
VITE_VIDEO_PROXY_URL=http://localhost:3002/api/video-proxy
```

### Build Configuration

Vite is configured for WebOS compatibility:
- ES2015 target for older TV browsers
- Optimized chunk splitting
- Terser minification
- Asset optimization

## 📱 Features

### Core Functionality

- ✅ Browse anime collections
- ✅ Search anime
- ✅ View anime details
- ✅ Stream episodes
- ✅ TV remote navigation
- ✅ Focus management
- ✅ Dark theme UI

### Advanced Features

- ✅ HLS video streaming
- ✅ API proxy system
- ✅ WebOS compatibility
- ✅ Responsive design
- ✅ Loading states
- ✅ Error handling

## 🐛 Troubleshooting

### Common Issues

1. **Build Errors**: Ensure all dependencies are installed
2. **API Issues**: Check proxy server is running
3. **Video Playback**: Verify HLS.js compatibility
4. **Navigation**: Ensure focus IDs are unique

### WebOS Specific

1. **App Installation**: Check WebOS SDK setup
2. **Remote Control**: Verify key event handling
3. **Performance**: Monitor memory usage on TV
4. **Safe Areas**: Check TV margin handling

## 📄 License

MIT License - See LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on WebOS simulator/device
5. Submit a pull request

## 🔗 Related Projects

- [Tatakai Main App](../tatakai-app) - Next.js web version
- [HiAnime API](https://github.com/ghoshRitesh12/aniwatch-api) - Anime data source

---

Built with ❤️ for the WebOS TV platform