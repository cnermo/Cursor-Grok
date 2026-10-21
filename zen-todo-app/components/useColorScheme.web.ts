import { useEffect, useState } from 'react';
import { useColorScheme as useSystemColorScheme } from 'react-native';

import { useThemeStore } from '@/lib/theme-store';

/**
 * Default to dark on the first web paint to match the product and avoid
 * hydration flicker. After mount, follow the saved preference.
 */
export function useColorScheme(): 'light' | 'dark' {
  const [ready, setReady] = useState(false);
  const system = useSystemColorScheme();
  const preference = useThemeStore((state) => state.preference);

  useEffect(() => {
    setReady(true);
  }, []);

  if (!ready) {
    return 'dark';
  }

  if (preference === 'system') {
    return system === 'light' ? 'light' : 'dark';
  }

  return preference;
}
