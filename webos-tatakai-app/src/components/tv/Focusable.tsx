import React, { useRef, useEffect } from 'react';
import { useNavigation } from '@/context/NavigationProvider';
import { cn } from '@/lib/utils';

interface FocusableProps {
  id: string;
  children: React.ReactNode;
  className?: string;
  onFocus?: () => void;
  onBlur?: () => void;
  onEnter?: () => void;
  autoScroll?: boolean;
  disabled?: boolean;
}

const Focusable: React.FC<FocusableProps> = ({
  id,
  children,
  className,
  onFocus,
  onBlur,
  onEnter,
  autoScroll = true,
  disabled = false,
}) => {
  const elementRef = useRef<HTMLDivElement>(null);
  const { registerElement, unregisterElement } = useNavigation();

  useEffect(() => {
    if (elementRef.current && !disabled) {
      registerElement(id, elementRef.current, {
        onFocus,
        onBlur,
        onEnter,
        autoScroll,
      });

      return () => {
        unregisterElement(id);
      };
    }
  }, [id, registerElement, unregisterElement, onFocus, onBlur, onEnter, autoScroll, disabled]);

  return (
    <div
      ref={elementRef}
      className={cn(
        'tv-focusable',
        disabled && 'opacity-50 pointer-events-none',
        className
      )}
      tabIndex={disabled ? -1 : 0}
    >
      {children}
    </div>
  );
};

export default Focusable;