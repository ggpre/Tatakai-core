import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";
import { componentTagger } from "lovable-tagger";
import packageJson from "./package.json";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  plugins: [react(), mode === "development" && componentTagger()].filter(Boolean),
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    // Generate sourcemaps in production to get readable stack traces in logs.
    // If you don't want to expose maps publicly, set ENABLE_SOURCEMAPS env var.
    sourcemap: mode === 'production',
  },
  server: {
    host: "::",
    port: 8080,
    proxy: {
      // Proxy all calls starting with /api/proxy/aniwatch to the third-party API (dev only)
      '/api/proxy/aniwatch': {
        target: 'https://aniwatch-api-taupe-eight.vercel.app',
        changeOrigin: true,
        secure: true,
        rewrite: (p) => p.replace(/^\/api\/proxy\/aniwatch/, '/api/v2/hianime'),
      },
    },
  },
  define: {
    __APP_VERSION__: JSON.stringify(packageJson.version),
  },
}));
