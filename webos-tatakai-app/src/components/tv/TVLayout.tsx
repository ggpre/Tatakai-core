import React, { useState } from 'react';
import TVNavigation from './TVNavigation';
import { cn } from '@/lib/utils';

interface TVLayoutProps {
  children: React.ReactNode;
  currentPath: string;
  onNavigate: (path: string) => void;
  className?: string;
}

const TVLayout: React.FC<TVLayoutProps> = ({
  children,
  currentPath,
  onNavigate,
  className
}) => {
  const [isNavCollapsed] = useState(false);

  return (
    <div className={cn('tv-layout', className)}>
      {/* Navigation Sidebar */}
      <TVNavigation
        currentPath={currentPath}
        onNavigate={onNavigate}
      />

      {/* Main Content Area */}
      <main className={cn(
        'tv-layout__main',
        isNavCollapsed && 'navbar-collapsed'
      )}>
        <div className="tv-layout__content">
          {children}
        </div>
      </main>
    </div>
  );
};

export default TVLayout;