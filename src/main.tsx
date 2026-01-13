import { createRoot } from "react-dom/client";
import { HelmetProvider } from "react-helmet-async";
import App from "./App.tsx";
import "./index.css";
import { ErrorBoundary } from '@/components/ErrorBoundary';
import { initConsoleProtection, logger } from '@/lib/logger';
import { initSentryClient } from '@/lib/sentry';

// Initialize Sentry (client) if configured
try {
  initSentryClient();
} catch {}

// Initialize production console protection early
initConsoleProtection();

// Global error handlers (captures window errors and unhandled promise rejections)
if (typeof window !== 'undefined') {
  window.addEventListener('error', (event) => {
    try {
      const payload = (event && (event as ErrorEvent).error) || event.message || 'window.error';
      void logger.error(payload);
    } catch {}
  });

  window.addEventListener('unhandledrejection', (ev) => {
    try {
      const reason = (ev && (ev as PromiseRejectionEvent).reason) || 'unhandledrejection';
      void logger.error(reason);
    } catch {}
  });
}

createRoot(document.getElementById("root")!).render(
  <HelmetProvider>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </HelmetProvider>
);
