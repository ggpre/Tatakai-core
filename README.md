# 🎬 Tatakai

A modern, feature-rich anime streaming platform built with React, TypeScript, and Supabase.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.5-blue)
![React](https://img.shields.io/badge/React-18-blue)

## ✨ Features

### 🎥 Core Features
- **Anime Streaming** - Watch anime with HLS video player and AniSkip integration
- **Search & Discovery** - Advanced search with genre filtering
- **Trending Section** - Random episode previews with HLS streaming
- **Continue Watching** - Track your progress across devices
- **Watchlist & Favorites** - Save and organize your anime
- **Comments & Ratings** - Engage with the community

### 👥 User Features
- **Authentication** - Secure sign up/sign in with Supabase Auth
- **User Profiles** - Customizable profiles with avatars
- **Watch History** - Track and resume your viewing progress
- **Multiple Themes** - 7 unique themes (Neon, Sunset, Ocean, etc.)

### 🛡️ Admin Features
- **User Management** - Ban/unban users, promote to admin
- **Maintenance Mode** - System-wide maintenance with admin bypass
- **Admin Messaging** - Broadcast or individual messages to users
- **Analytics Dashboard** - View user activity and stats
- **Comment Moderation** - Delete inappropriate comments

### 🎨 Design Features
- **Responsive Design** - Desktop, tablet, and mobile optimized
- **Smart TV Support** - Optimized for LG webOS, Samsung Tizen, Android TV
- **Beautiful UI** - Glassmorphic design with smooth animations
- **Theme System** - Dynamic theme switching with unique color schemes

## 🚀 Tech Stack

### Frontend
- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Utility-first CSS
- **shadcn/ui** - UI component library
- **Framer Motion** - Animation library
- **React Query** - Server state management
- **React Router** - Client-side routing

### Backend
- **Supabase** - Backend as a Service
  - PostgreSQL database
  - Authentication
  - Row Level Security (RLS)
  - Real-time subscriptions
  
### Video
- **HLS.js** - HTTP Live Streaming playback
- **AniSkip API** - Skip intro/outro timestamps

### APIs
- **Consumet API** - Anime metadata and streaming links

## 📦 Installation

### Prerequisites
- Node.js 18+ and npm/bun
- Supabase account

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/Snozxyx/anime-haven.git
cd anime-haven
```

2. **Install dependencies**
```bash
npm install
# or
bun install
```

3. **Environment Setup**

Create a `.env` file in the root directory:

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
DATABASE_URL=your_database_url
```

4. **Database Setup**

Run the migrations in your Supabase SQL Editor:

```bash
# Run migrations in order:
# 1. supabase/migrations/20251231031018_remix_migration_from_pg_dump.sql
# 2. supabase/migrations/20250102000001_add_views_system.sql
# 3. supabase/migrations/20250115000001_add_views_system.sql
# 4. supabase/migrations/20250116000001_add_auth_trigger.sql
# 5. supabase/migrations/20260102000002_add_admin_features.sql
```

5. **Start Development Server**

```bash
npm run dev
# or
bun dev
```

Visit `http://localhost:5173`

## 🗄️ Database Schema

### Main Tables
- `profiles` - User profiles with admin/ban status
- `watch_history` - Continue watching progress
- `watchlist` - User's saved anime
- `comments` - User comments on anime
- `ratings` - User ratings for anime
- `views` - Anime view tracking
- `maintenance_mode` - System maintenance status
- `admin_messages` - Admin notification system

## 👨‍💼 Admin Setup

To make a user an admin, run this SQL in Supabase:

```sql
UPDATE public.profiles 
SET is_admin = true 
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email = 'admin@example.com'
);
```

## 🎨 Available Themes

- **Sunset** (Default) - Warm orange and pink gradients
- **Neon** - Vibrant purple and blue neon
- **Ocean** - Cool blue and teal tones
- **Forest** - Natural green shades
- **Rose** - Elegant pink and rose
- **Midnight** - Deep purple and blue
- **Brutalism Dark** - High-contrast minimalist

## 🔐 Security Features

- Row Level Security (RLS) policies
- Secure authentication via Supabase
- Admin-only routes and operations
- Banned user flow with restricted access
- CORS protection
- SQL injection prevention

## 📱 Responsive Breakpoints

- Mobile: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px
- Smart TV: Detected automatically

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Consumet API](https://github.com/consumet/consumet.ts) - Anime data provider
- [AniSkip API](https://api.aniskip.com) - Skip timestamps
- [shadcn/ui](https://ui.shadcn.com) - UI components
- [Supabase](https://supabase.com) - Backend infrastructure

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

Built with ❤️ by [Snozxyx](https://github.com/Snozxyx)
