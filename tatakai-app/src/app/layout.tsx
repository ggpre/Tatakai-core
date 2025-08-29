import type { Metadata } from "next";
import "./globals.css";
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";

export const metadata: Metadata = {
  title: "Tatakai - Modern Anime Streaming",
  description: "Watch the latest anime episodes and discover new series with high-quality streaming. Your ultimate anime destination.",
  keywords: "anime, streaming, watch anime, latest episodes, anime series, manga",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="antialiased font-sans">
        <div className="min-h-screen bg-background text-foreground">
          <Navigation />
          <main className="pt-16">
            {children}
          </main>
          <Footer />
        </div>
      </body>
    </html>
  );
}
