import { Pressable, StyleSheet } from 'react-native';

import { Text, View, useTheme } from '@/components/Themed';
import type { ThemePreference } from '@/lib/theme-store';
import { useThemeStore } from '@/lib/theme-store';

const OPTIONS: { key: ThemePreference; label: string; hint: string }[] = [
  { key: 'dark', label: 'Dark', hint: 'Comfort slate (default)' },
  { key: 'light', label: 'Light', hint: 'Paper background' },
  { key: 'system', label: 'System', hint: 'Follow the device' },
];

export default function SettingsScreen() {
  const theme = useTheme();
  const preference = useThemeStore((state) => state.preference);
  const setPreference = useThemeStore((state) => state.setPreference);

  return (
    <View style={styles.screen}>
      <Text style={styles.heading}>Appearance</Text>
      <Text muted style={styles.lede}>
        Zen Todo stays local on this device. Theme is saved separately from tasks so a later SQLite
        backend can replace the task store without touching this screen.
      </Text>
      {OPTIONS.map((option) => {
        const selected = preference === option.key;
        return (
          <Pressable
            key={option.key}
            accessibilityRole="radio"
            accessibilityState={{ selected }}
            onPress={() => setPreference(option.key)}
            style={[
              styles.option,
              {
                borderColor: selected ? theme.tint : theme.border,
                backgroundColor: theme.card,
              },
            ]}>
            <Text style={[styles.optionTitle, selected && { color: theme.tint }]}>{option.label}</Text>
            <Text muted>{option.hint}</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    padding: 16,
    gap: 10,
  },
  heading: {
    fontSize: 22,
    fontWeight: '700',
  },
  lede: {
    marginBottom: 8,
    lineHeight: 22,
  },
  option: {
    minHeight: 64,
    borderWidth: 1,
    borderRadius: 14,
    paddingHorizontal: 16,
    paddingVertical: 12,
    justifyContent: 'center',
  },
  optionTitle: {
    fontSize: 17,
    fontWeight: '600',
    marginBottom: 2,
  },
});
