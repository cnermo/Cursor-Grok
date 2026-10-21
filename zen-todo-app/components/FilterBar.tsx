import { Pressable, StyleSheet, View } from 'react-native';

import { Text, useTheme } from '@/components/Themed';
import type { TaskFilter } from '@/lib/types';

const FILTERS: { key: TaskFilter; label: string }[] = [
  { key: 'all', label: 'All' },
  { key: 'active', label: 'Active' },
  { key: 'completed', label: 'Completed' },
];

export function FilterBar({
  value,
  onChange,
}: {
  value: TaskFilter;
  onChange: (next: TaskFilter) => void;
}) {
  const theme = useTheme();

  return (
    <View style={styles.row}>
      {FILTERS.map((filter) => {
        const selected = value === filter.key;
        return (
          <Pressable
            key={filter.key}
            accessibilityRole="tab"
            accessibilityState={{ selected }}
            onPress={() => onChange(filter.key)}
            style={[
              styles.chip,
              {
                borderColor: selected ? theme.tint : theme.border,
                backgroundColor: selected ? theme.card : 'transparent',
              },
            ]}>
            <Text style={{ color: selected ? theme.tint : theme.muted, fontWeight: '600' }}>
              {filter.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    gap: 8,
    paddingHorizontal: 16,
    paddingBottom: 12,
    backgroundColor: 'transparent',
  },
  chip: {
    minHeight: 44,
    paddingHorizontal: 14,
    borderRadius: 999,
    borderWidth: 1,
    justifyContent: 'center',
  },
});
