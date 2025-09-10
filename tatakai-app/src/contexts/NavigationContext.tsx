'use client';

import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
} from 'react';
import { usePathname } from 'next/navigation';

interface NavigationContextType {
  focusedElement: string | null;
  setFocusedElement: (id: string | null) => void;
  navigationItems: Map<string, HTMLElement>;
  registerElement: (id: string, element: HTMLElement) => void;
  unregisterElement: (id: string) => void;
  navigate: (direction: 'up' | 'down' | 'left' | 'right') => void;
  isNavigationDisabled: boolean;
}

const NavigationContext = createContext<NavigationContextType | null>(null);

export const useNavigation = () => {
  const context = useContext(NavigationContext);
  if (!context) {
    throw new Error('useNavigation must be used within a NavigationProvider');
  }
  return context;
};

export const NavigationProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const pathname = usePathname();
  const [focusedElement, setFocusedElementState] = useState<string | null>(null);
  const [navigationItems] = useState(new Map<string, HTMLElement>());

  // Disable navigation on watch pages or other full-screen experiences
  const isNavigationDisabled = pathname?.includes('/watch/') || false;

  // ✅ Centralized focus manager
  const updateFocusedElement = useCallback(
    (newFocusedElement: string | null) => {
      // remove focus from all
      document
        .querySelectorAll('.tv-focused')
        .forEach((el) => el.classList.remove('tv-focused', 'keyboard-focused'));

      if (newFocusedElement && navigationItems.has(newFocusedElement)) {
        const next = navigationItems.get(newFocusedElement);
        if (next) {
          next.classList.add('tv-focused', 'keyboard-focused');
          next.focus();
          next.scrollIntoView({
            behavior: 'smooth',
            block: 'center',
            inline: 'center',
          });
        }
      }

      setFocusedElementState(newFocusedElement);
    },
    [navigationItems]
  );

  // ✅ Register element with better initial focus handling
  const registerElement = useCallback(
    (id: string, element: HTMLElement) => {
      if (isNavigationDisabled) return; // Don't register elements when navigation is disabled
      
      navigationItems.set(id, element);
      console.log(`Registered element: ${id}`, element);

      // Auto-focus the first registered element if nothing is currently focused
      if (!focusedElement) {
        console.log(`Auto-focusing element: ${id}`);
        updateFocusedElement(id);
      }
    },
    [focusedElement, navigationItems, updateFocusedElement, isNavigationDisabled]
  );

  const unregisterElement = useCallback(
    (id: string) => {
      if (navigationItems.has(id)) {
        navigationItems.delete(id);
      }
      if (focusedElement === id) {
        updateFocusedElement(null);
      }
    },
    [focusedElement, navigationItems, updateFocusedElement]
  );

  // ✅ Directional nearest search
  const findNearestElement = useCallback(
    (
      currentElement: HTMLElement,
      direction: 'up' | 'down' | 'left' | 'right'
    ) => {
      const currentRect = currentElement.getBoundingClientRect();
      let best: [string, HTMLElement] | null = null;
      let bestDistance = Infinity;

      for (const [id, el] of navigationItems.entries()) {
        if (el === currentElement) continue;

        const rect = el.getBoundingClientRect();
        let valid = false;
        let dist = 0;

        switch (direction) {
          case 'right':
            if (rect.left >= currentRect.right) {
              dist =
                (rect.left - currentRect.right) ** 2 +
                (rect.top - currentRect.top) ** 2;
              valid = true;
            }
            break;
          case 'left':
            if (rect.right <= currentRect.left) {
              dist =
                (currentRect.left - rect.right) ** 2 +
                (rect.top - currentRect.top) ** 2;
              valid = true;
            }
            break;
          case 'down':
            if (rect.top >= currentRect.bottom) {
              dist =
                (rect.top - currentRect.bottom) ** 2 +
                (rect.left - currentRect.left) ** 2;
              valid = true;
            }
            break;
          case 'up':
            if (rect.bottom <= currentRect.top) {
              dist =
                (currentRect.top - rect.bottom) ** 2 +
                (rect.left - currentRect.left) ** 2;
              valid = true;
            }
            break;
        }

        if (valid && dist < bestDistance) {
          bestDistance = dist;
          best = [id, el];
        }
      }

      return best;
    },
    [navigationItems]
  );

  const navigate = useCallback(
    (direction: 'up' | 'down' | 'left' | 'right') => {
      setFocusedElementState((curr) => {
        if (!curr) return null;
        const currentEl = navigationItems.get(curr);
        if (!currentEl) return curr;

        const nearest = findNearestElement(currentEl, direction);
        if (nearest) {
          updateFocusedElement(nearest[0]);
          return nearest[0];
        }
        return curr;
      });
    },
    [findNearestElement, navigationItems, updateFocusedElement]
  );

  // Clear focus when navigation is disabled
  useEffect(() => {
    if (isNavigationDisabled) {
      updateFocusedElement(null);
    }
  }, [isNavigationDisabled, updateFocusedElement]);

  // ✅ LG TV Remote handler
  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => {
      // Skip if navigation is disabled (e.g., on watch pages)
      if (isNavigationDisabled) return;
      
      // Skip if focus is in an input or textarea
      const activeElement = document.activeElement;
      if (activeElement && (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA')) {
        return;
      }

      switch (e.key) {
        case 'ArrowLeft':
          e.preventDefault();
          navigate('left');
          break;
        case 'ArrowUp':
          e.preventDefault();
          navigate('up');
          break;
        case 'ArrowRight':
          e.preventDefault();
          navigate('right');
          break;
        case 'ArrowDown':
          e.preventDefault();
          navigate('down');
          break;
        case 'Enter':
          e.preventDefault();
          if (focusedElement) {
            const el = navigationItems.get(focusedElement);
            el?.click();
          }
          break;
        case 'Backspace':
        case 'Escape':
          e.preventDefault();
          console.log('🔙 Back pressed');
          // Let individual pages handle back navigation
          break;
      }
    };

    window.addEventListener('keydown', handleKey);
    return () => window.removeEventListener('keydown', handleKey);
  }, [navigate, focusedElement, navigationItems, isNavigationDisabled]);

  const value: NavigationContextType = {
    focusedElement,
    setFocusedElement: updateFocusedElement,
    navigationItems,
    registerElement,
    unregisterElement,
    navigate,
    isNavigationDisabled,
  };

  return (
    <NavigationContext.Provider value={value}>
      {children}
    </NavigationContext.Provider>
  );
};
