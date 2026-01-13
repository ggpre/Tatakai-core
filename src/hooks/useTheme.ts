import { useState, useEffect, useCallback } from 'react';

export type Theme = 
  | 'midnight' 
  | 'cherry-blossom' 
  | 'neon-tokyo' 
  | 'aurora-borealis' 
  | 'deep-ocean' 
  | 'cyberpunk'
  | 'zen-garden'
  | 'light-minimal'
  | 'light-sakura'
  | 'brutalism-dark'
  | 'obsidian'
  | 'solar'
  | 'caffeine'
  | 'brutalism-plus'
  | 'dark-matter';

interface ThemeColors {
  primary: string;
  secondary: string;
  accent: string;
  background: string;
  foreground: string;
  card: string;
  cardForeground: string;
  muted: string;
  mutedForeground: string;
  border: string;
  glass: string;
  glowPrimary: string;
  glowSecondary: string;
  surface: string;
  surfaceHover: string;
  sidebarBackground: string;
  sidebarBorder: string;
  isLight?: boolean;
  isBrutalism?: boolean;
}

export const THEME_COLORS: Record<Theme, ThemeColors> = {
  'midnight': {
    primary: '239 84% 67%',
    secondary: '270 60% 50%',
    accent: '280 70% 55%',
    background: '240 10% 4%',
    foreground: '0 0% 98%',
    card: '240 8% 7%',
    cardForeground: '0 0% 98%',
    muted: '240 6% 12%',
    mutedForeground: '240 5% 65%',
    border: '240 6% 18%',
    glass: '240 10% 8%',
    glowPrimary: '239 84% 67%',
    glowSecondary: '270 60% 50%',
    surface: '240 8% 5%',
    surfaceHover: '240 8% 10%',
    sidebarBackground: '240 10% 3%',
    sidebarBorder: '240 6% 15%',
  },
  'cherry-blossom': {
    primary: '340 82% 65%',
    secondary: '320 70% 55%',
    accent: '350 90% 70%',
    background: '340 15% 5%',
    foreground: '340 5% 95%',
    card: '340 12% 8%',
    cardForeground: '340 5% 95%',
    muted: '340 10% 15%',
    mutedForeground: '340 10% 60%',
    border: '340 10% 20%',
    glass: '340 12% 10%',
    glowPrimary: '340 82% 65%',
    glowSecondary: '320 70% 55%',
    surface: '340 12% 6%',
    surfaceHover: '340 12% 12%',
    sidebarBackground: '340 15% 4%',
    sidebarBorder: '340 10% 15%',
  },
  'neon-tokyo': {
    primary: '280 100% 60%',
    secondary: '180 100% 50%',
    accent: '320 100% 55%',
    background: '260 20% 3%',
    foreground: '0 0% 100%',
    card: '260 18% 6%',
    cardForeground: '0 0% 100%',
    muted: '260 15% 12%',
    mutedForeground: '260 10% 60%',
    border: '260 20% 18%',
    glass: '260 18% 8%',
    glowPrimary: '280 100% 60%',
    glowSecondary: '180 100% 50%',
    surface: '260 18% 4%',
    surfaceHover: '260 18% 10%',
    sidebarBackground: '260 20% 2%',
    sidebarBorder: '260 15% 15%',
  },
  'aurora-borealis': {
    primary: '160 80% 50%',
    secondary: '200 85% 55%',
    accent: '280 70% 60%',
    background: '200 25% 4%',
    foreground: '160 10% 95%',
    card: '200 20% 7%',
    cardForeground: '160 10% 95%',
    muted: '200 15% 13%',
    mutedForeground: '200 10% 60%',
    border: '200 15% 18%',
    glass: '200 18% 9%',
    glowPrimary: '160 80% 50%',
    glowSecondary: '200 85% 55%',
    surface: '200 20% 5%',
    surfaceHover: '200 20% 11%',
    sidebarBackground: '200 25% 3%',
    sidebarBorder: '200 15% 14%',
  },
  'deep-ocean': {
    primary: '200 90% 55%',
    secondary: '220 85% 50%',
    accent: '175 85% 45%',
    background: '210 35% 3%',
    foreground: '200 5% 96%',
    card: '210 30% 6%',
    cardForeground: '200 5% 96%',
    muted: '210 20% 12%',
    mutedForeground: '210 15% 55%',
    border: '210 20% 16%',
    glass: '210 25% 8%',
    glowPrimary: '200 90% 55%',
    glowSecondary: '220 85% 50%',
    surface: '210 30% 4%',
    surfaceHover: '210 30% 10%',
    sidebarBackground: '210 35% 2%',
    sidebarBorder: '210 18% 12%',
  },
  'cyberpunk': {
    primary: '55 100% 50%',
    secondary: '180 100% 40%',
    accent: '320 100% 55%',
    background: '240 15% 3%',
    foreground: '55 100% 95%',
    card: '240 12% 6%',
    cardForeground: '55 100% 95%',
    muted: '240 10% 12%',
    mutedForeground: '240 8% 55%',
    border: '240 12% 18%',
    glass: '240 12% 8%',
    glowPrimary: '55 100% 50%',
    glowSecondary: '180 100% 40%',
    surface: '240 12% 4%',
    surfaceHover: '240 12% 10%',
    sidebarBackground: '240 15% 2%',
    sidebarBorder: '240 10% 14%',
  },
  'zen-garden': {
    primary: '145 40% 50%',
    secondary: '35 60% 45%',
    accent: '160 45% 40%',
    background: '90 10% 5%',
    foreground: '90 5% 92%',
    card: '90 8% 8%',
    cardForeground: '90 5% 92%',
    muted: '90 6% 14%',
    mutedForeground: '90 5% 55%',
    border: '90 8% 18%',
    glass: '90 8% 10%',
    glowPrimary: '145 40% 50%',
    glowSecondary: '35 60% 45%',
    surface: '90 8% 6%',
    surfaceHover: '90 8% 12%',
    sidebarBackground: '90 10% 4%',
    sidebarBorder: '90 6% 14%',
  },
  // Light Themes
  'light-minimal': {
    primary: '220 90% 50%',
    secondary: '260 80% 55%',
    accent: '200 95% 45%',
    background: '0 0% 98%',
    foreground: '220 15% 10%',
    card: '0 0% 100%',
    cardForeground: '220 15% 10%',
    muted: '220 10% 92%',
    mutedForeground: '220 10% 40%',
    border: '220 10% 88%',
    glass: '0 0% 100%',
    glowPrimary: '220 90% 50%',
    glowSecondary: '260 80% 55%',
    surface: '220 10% 96%',
    surfaceHover: '220 10% 93%',
    sidebarBackground: '220 15% 97%',
    sidebarBorder: '220 10% 90%',
    isLight: true,
  },
  'light-sakura': {
    primary: '340 75% 55%',
    secondary: '320 65% 50%',
    accent: '350 85% 60%',
    background: '340 30% 97%',
    foreground: '340 30% 15%',
    card: '340 25% 100%',
    cardForeground: '340 30% 15%',
    muted: '340 15% 92%',
    mutedForeground: '340 15% 45%',
    border: '340 15% 88%',
    glass: '340 20% 98%',
    glowPrimary: '340 75% 55%',
    glowSecondary: '320 65% 50%',
    surface: '340 20% 95%',
    surfaceHover: '340 20% 92%',
    sidebarBackground: '340 25% 96%',
    sidebarBorder: '340 15% 90%',
    isLight: true,
  },
  'brutalism-dark': {
    primary: '55 100% 55%',
    secondary: '45 100% 50%',
    accent: '0 100% 55%',
    background: '0 0% 8%',
    foreground: '0 0% 98%',
    card: '0 0% 12%',
    cardForeground: '0 0% 98%',
    muted: '0 0% 18%',
    mutedForeground: '0 0% 65%',
    border: '55 100% 55%',
    glass: '0 0% 12%',
    glowPrimary: '55 100% 55%',
    glowSecondary: '0 100% 55%',
    surface: '0 0% 10%',
    surfaceHover: '0 0% 18%',
    sidebarBackground: '0 0% 5%',
    sidebarBorder: '55 100% 55%',
    isBrutalism: true,
  },
  'obsidian': {
    primary: '0 0% 70%',
    secondary: '0 0% 50%',
    accent: '0 0% 80%',
    background: '0 0% 3%',
    foreground: '0 0% 95%',
    card: '0 0% 6%',
    cardForeground: '0 0% 95%',
    muted: '0 0% 12%',
    mutedForeground: '0 0% 55%',
    border: '0 0% 18%',
    glass: '0 0% 8%',
    glowPrimary: '0 0% 70%',
    glowSecondary: '0 0% 50%',
    surface: '0 0% 4%',
    surfaceHover: '0 0% 10%',
    sidebarBackground: '0 0% 2%',
    sidebarBorder: '0 0% 14%',
  },
  'solar': {
    primary: '45 100% 55%',
    secondary: '30 95% 50%',
    accent: '60 100% 50%',
    background: '40 25% 4%',
    foreground: '45 10% 95%',
    card: '40 20% 7%',
    cardForeground: '45 10% 95%',
    muted: '40 15% 13%',
    mutedForeground: '40 10% 55%',
    border: '40 15% 18%',
    glass: '40 18% 9%',
    glowPrimary: '45 100% 55%',
    glowSecondary: '30 95% 50%',
    surface: '40 20% 5%',
    surfaceHover: '40 20% 11%',
    sidebarBackground: '40 25% 3%',
    sidebarBorder: '40 13% 14%',
  },
  'caffeine': {
    primary: '30 90% 55%',
    secondary: '20 85% 50%',
    accent: '40 95% 60%',
    background: '28 25% 5%',
    foreground: '30 10% 95%',
    card: '28 20% 8%',
    cardForeground: '30 10% 95%',
    muted: '28 15% 14%',
    mutedForeground: '28 10% 55%',
    border: '28 15% 20%',
    glass: '28 18% 10%',
    glowPrimary: '30 90% 55%',
    glowSecondary: '20 85% 50%',
    surface: '28 20% 6%',
    surfaceHover: '28 20% 12%',
    sidebarBackground: '28 25% 4%',
    sidebarBorder: '28 13% 16%',
  },
  'brutalism-plus': {
    primary: '0 0% 100%',
    secondary: '280 100% 60%',
    accent: '160 100% 50%',
    background: '0 0% 5%',
    foreground: '0 0% 100%',
    card: '0 0% 8%',
    cardForeground: '0 0% 100%',
    muted: '0 0% 15%',
    mutedForeground: '0 0% 70%',
    border: '0 0% 100%',
    glass: '0 0% 8%',
    glowPrimary: '280 100% 60%',
    glowSecondary: '160 100% 50%',
    surface: '0 0% 6%',
    surfaceHover: '0 0% 12%',
    sidebarBackground: '0 0% 3%',
    sidebarBorder: '0 0% 100%',
    isBrutalism: true,
  },
  'dark-matter': {
    primary: '270 100% 70%',
    secondary: '290 90% 65%',
    accent: '250 95% 75%',
    background: '260 30% 2%',
    foreground: '270 10% 98%',
    card: '260 25% 4%',
    cardForeground: '270 10% 98%',
    muted: '260 20% 8%',
    mutedForeground: '260 12% 60%',
    border: '260 25% 12%',
    glass: '260 22% 5%',
    glowPrimary: '270 100% 70%',
    glowSecondary: '290 90% 65%',
    surface: '260 25% 3%',
    surfaceHover: '260 25% 7%',
    sidebarBackground: '260 30% 1%',
    sidebarBorder: '260 20% 10%',
  },
};

export const THEME_INFO: Record<Theme, { name: string; gradient: string; description: string; icon: string; category: 'dark' | 'light' }> = {
  'midnight': {
    name: 'Midnight',
    gradient: 'from-indigo-600 via-purple-600 to-violet-700',
    description: 'Classic dark with indigo & violet accents',
    icon: '🌙',
    category: 'dark',
  },
  'cherry-blossom': {
    name: 'Cherry Blossom',
    gradient: 'from-pink-500 via-rose-500 to-fuchsia-600',
    description: 'Soft pink tones inspired by sakura',
    icon: '🌸',
    category: 'dark',
  },
  'neon-tokyo': {
    name: 'Neon Tokyo',
    gradient: 'from-purple-500 via-fuchsia-500 to-cyan-400',
    description: 'Electric neon cyberpunk vibes',
    icon: '🗼',
    category: 'dark',
  },
  'aurora-borealis': {
    name: 'Aurora Borealis',
    gradient: 'from-emerald-500 via-teal-500 to-violet-500',
    description: 'Northern lights dancing colors',
    icon: '✨',
    category: 'dark',
  },
  'deep-ocean': {
    name: 'Deep Ocean',
    gradient: 'from-cyan-500 via-blue-600 to-indigo-700',
    description: 'Mysterious underwater depths',
    icon: '🌊',
    category: 'dark',
  },
  'cyberpunk': {
    name: 'Cyberpunk',
    gradient: 'from-yellow-400 via-lime-500 to-cyan-500',
    description: 'Futuristic neon yellow & cyan',
    icon: '🤖',
    category: 'dark',
  },
  'zen-garden': {
    name: 'Zen Garden',
    gradient: 'from-green-600 via-emerald-600 to-teal-600',
    description: 'Calm forest tranquility',
    icon: '🌿',
    category: 'dark',
  },
  'light-minimal': {
    name: 'Light Minimal',
    gradient: 'from-blue-400 via-indigo-400 to-purple-400',
    description: 'Clean, bright, modern design',
    icon: '☀️',
    category: 'light',
  },
  'light-sakura': {
    name: 'Light Sakura',
    gradient: 'from-pink-300 via-rose-300 to-pink-400',
    description: 'Soft pink cherry blossom theme',
    icon: '🌷',
    category: 'light',
  },
  'brutalism-dark': {
    name: 'Brutalist Dark',
    gradient: 'from-gray-900 via-yellow-400 to-red-500',
    description: 'Dark brutalist aesthetic',
    icon: '⬛',
    category: 'dark',
  },
  'obsidian': {
    name: 'Obsidian',
    gradient: 'from-gray-600 via-gray-700 to-gray-800',
    description: 'Pure dark monochrome elegance',
    icon: '🖤',
    category: 'dark',
  },
  'solar': {
    name: 'Solar',
    gradient: 'from-yellow-400 via-amber-500 to-orange-500',
    description: 'Bright solar energy',
    icon: '☀️',
    category: 'dark',
  },
  'caffeine': {
    name: 'Caffeine',
    gradient: 'from-orange-500 via-amber-600 to-yellow-600',
    description: 'Energizing coffee-inspired tones',
    icon: '☕',
    category: 'dark',
  },
  'brutalism-plus': {
    name: 'Brutalist Plus',
    gradient: 'from-gray-100 via-purple-500 to-teal-400',
    description: 'Enhanced brutalist with vibrant accents',
    icon: '⬜',
    category: 'dark',
  },
  'dark-matter': {
    name: 'Dark Matter',
    gradient: 'from-purple-600 via-violet-700 to-indigo-800',
    description: 'Deep space with cosmic purple glow',
    icon: '🌌',
    category: 'dark',
  },
};

const THEME_KEY = 'anime-theme';

export function useTheme() {
  const [theme, setThemeState] = useState<Theme>(() => {
    if (typeof window !== 'undefined') {
      const stored = localStorage.getItem(THEME_KEY) as Theme | null;
      return stored && THEME_COLORS[stored] ? stored : 'cherry-blossom';
    }
    return 'cherry-blossom';
  });

  const applyTheme = useCallback((themeName: Theme) => {
    const colors = THEME_COLORS[themeName];
    if (!colors) return;
    
    const root = document.documentElement;
    
    root.style.setProperty('--primary', colors.primary);
    root.style.setProperty('--secondary', colors.secondary);
    root.style.setProperty('--accent', colors.accent);
    root.style.setProperty('--background', colors.background);
    root.style.setProperty('--foreground', colors.foreground);
    root.style.setProperty('--card', colors.card);
    root.style.setProperty('--card-foreground', colors.cardForeground);
    root.style.setProperty('--muted', colors.muted);
    root.style.setProperty('--muted-foreground', colors.mutedForeground);
    root.style.setProperty('--border', colors.border);
    root.style.setProperty('--input', colors.border);
    root.style.setProperty('--ring', colors.primary);
    root.style.setProperty('--glass', colors.glass);
    root.style.setProperty('--glow-primary', colors.glowPrimary);
    root.style.setProperty('--glow-secondary', colors.glowSecondary);
    root.style.setProperty('--surface', colors.surface);
    root.style.setProperty('--surface-hover', colors.surfaceHover);
    root.style.setProperty('--sidebar-background', colors.sidebarBackground);
    root.style.setProperty('--sidebar-foreground', colors.foreground);
    root.style.setProperty('--sidebar-primary', colors.primary);
    root.style.setProperty('--sidebar-primary-foreground', colors.foreground);
    root.style.setProperty('--sidebar-accent', colors.muted);
    root.style.setProperty('--sidebar-accent-foreground', colors.foreground);
    root.style.setProperty('--sidebar-border', colors.sidebarBorder);
    root.style.setProperty('--sidebar-ring', colors.primary);
    root.style.setProperty('--popover', colors.card);
    root.style.setProperty('--popover-foreground', colors.cardForeground);

    // Add light theme class for special styling
    if (colors.isLight) {
      document.body.classList.add('light-theme');
      document.body.classList.remove('dark-theme');
    } else {
      document.body.classList.add('dark-theme');
      document.body.classList.remove('light-theme');
    }
    
    // Add brutalism class for special styling
    if ((colors as any).isBrutalism) {
      document.body.classList.add('brutalism-theme');
    } else {
      document.body.classList.remove('brutalism-theme');
    }
    
    // Set data-theme attribute for theme-specific CSS
    document.body.setAttribute('data-theme', themeName);
  }, []);

  useEffect(() => {
    applyTheme(theme);
  }, [theme, applyTheme]);

  const setTheme = useCallback((newTheme: Theme) => {
    setThemeState(newTheme);
    localStorage.setItem(THEME_KEY, newTheme);
  }, []);

  const isLightTheme = THEME_COLORS[theme]?.isLight ?? false;

  return { 
    theme, 
    setTheme, 
    themes: Object.keys(THEME_COLORS) as Theme[],
    themeInfo: THEME_INFO,
    isLightTheme,
  };
}
