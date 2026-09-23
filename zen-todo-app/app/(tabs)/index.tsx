import { useMemo, useState } from 'react';
import { FlatList, KeyboardAvoidingView, Platform, Pressable, StyleSheet, TextInput } from 'react-native';

import { FilterBar } from '@/components/FilterBar';
import { TaskCard } from '@/components/TaskCard';
import { Text, View, useTheme } from '@/components/Themed';
import { useTaskSnapshot } from '@/hooks/useTaskSnapshot';
import type { TaskFilter } from '@/lib/types';

export default function TasksScreen() {
  const theme = useTheme();
  const { tasks, subtasks, hydrated, repository } = useTaskSnapshot();
  const [filter, setFilter] = useState<TaskFilter>('all');
  const [draft, setDraft] = useState('');

  const visible = useMemo(() => {
    const sorted = [...tasks].sort((a, b) => a.sort_order - b.sort_order || a.created_at.localeCompare(b.created_at));
    if (filter === 'active') return sorted.filter((task) => !task.completed);
    if (filter === 'completed') return sorted.filter((task) => task.completed);
    return sorted;
  }, [tasks, filter]);

  async function addTask() {
    const title = draft.trim();
    if (!title) return;
    await repository.createTask({ title });
    setDraft('');
  }

  if (!hydrated) {
    return (
      <View style={styles.centered}>
        <Text muted>Loading tasks…</Text>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      style={[styles.flex, { backgroundColor: theme.background }]}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <View style={styles.flex}>
        <FilterBar value={filter} onChange={setFilter} />
        <FlatList
          data={visible}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          ListEmptyComponent={
            <Text muted style={styles.empty}>
              {filter === 'all' ? 'Add a task to get started.' : `No ${filter} tasks.`}
            </Text>
          }
          renderItem={({ item }) => (
            <TaskCard
              task={item}
              subtasks={subtasks
                .filter((row) => row.task_id === item.id)
                .sort((a, b) => a.sort_order - b.sort_order || a.created_at.localeCompare(b.created_at))}
              repository={repository}
            />
          )}
        />
        <View style={[styles.composer, { borderTopColor: theme.border }]}>
          <TextInput
            accessibilityLabel="New task title"
            placeholder="What needs doing?"
            placeholderTextColor={theme.muted}
            value={draft}
            onChangeText={setDraft}
            onSubmitEditing={addTask}
            returnKeyType="done"
            style={[
              styles.input,
              { color: theme.text, borderColor: theme.border, backgroundColor: theme.input },
            ]}
          />
          <Pressable
            accessibilityRole="button"
            onPress={addTask}
            style={[styles.add, { backgroundColor: theme.tint }]}>
            <Text style={styles.addLabel}>Add</Text>
          </Pressable>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  centered: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  list: { paddingHorizontal: 16, paddingBottom: 24 },
  empty: { textAlign: 'center', marginTop: 48, fontSize: 16 },
  composer: {
    flexDirection: 'row',
    gap: 8,
    padding: 16,
    borderTopWidth: 1,
    alignItems: 'center',
  },
  input: {
    flex: 1,
    minHeight: 48,
    borderWidth: 1,
    borderRadius: 12,
    paddingHorizontal: 14,
    fontSize: 16,
  },
  add: {
    minHeight: 48,
    paddingHorizontal: 18,
    borderRadius: 12,
    justifyContent: 'center',
  },
  addLabel: {
    color: '#141415',
    fontWeight: '700',
    fontSize: 16,
  },
});
