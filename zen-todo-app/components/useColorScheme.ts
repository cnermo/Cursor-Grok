import { useColorScheme as useSystemColorScheme } from 'react-native';

import { useThemeStore } from '@/lib/theme-store';

export function useColorScheme(): 'light' | 'dark' {
  const system = useSystemColorScheme();
  const preference = useThemeStore((state) => state.preference);

  if (preference === 'system') {
    return system === 'light' ? 'light' : 'dark';
  }

  return preference;
}
