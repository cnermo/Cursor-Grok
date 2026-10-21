import { StyleSheet, Text as DefaultText, View as DefaultView } from 'react-native';

import Colors from '@/constants/Colors';
import { useColorScheme } from '@/components/useColorScheme';

export function useTheme() {
  const scheme = useColorScheme() ?? 'dark';
  return Colors[scheme];
}

export type TextProps = DefaultText['props'] & { muted?: boolean };
export type ViewProps = DefaultView['props'];

export function Text({ style, muted, ...props }: TextProps) {
  const theme = useTheme();
  return (
    <DefaultText
      style={[{ color: muted ? theme.muted : theme.text }, style]}
      {...props}
    />
  );
}

export function View({ style, ...props }: ViewProps) {
  const theme = useTheme();
  return <DefaultView style={[{ backgroundColor: theme.background }, style]} {...props} />;
}

export const shared = StyleSheet.create({
  tap: {
    minHeight: 44,
    minWidth: 44,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
