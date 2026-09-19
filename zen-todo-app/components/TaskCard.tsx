import { useState } from 'react';
import { Pressable, StyleSheet, TextInput, View as RNView } from 'react-native';
import { SymbolView } from 'expo-symbols';

import { Text, shared, useTheme } from '@/components/Themed';
import type { Subtask, Task } from '@/lib/types';
import type { TaskRepository } from '@/lib/repository';

export function TaskCard({
  task,
  subtasks,
  repository,
}: {
  task: Task;
  subtasks: Subtask[];
  repository: TaskRepository;
}) {
  const theme = useTheme();
  const [expanded, setExpanded] = useState(subtasks.length > 0);
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(task.title);
  const [subDraft, setSubDraft] = useState('');

  const done = subtasks.filter((row) => row.completed).length;
  const progress = subtasks.length > 0 ? `${done}/${subtasks.length}` : null;

  async function saveTitle() {
    const title = draft.trim();
    if (title && title !== task.title) {
      await repository.updateTask(task.id, { title });
    } else {
      setDraft(task.title);
    }
    setEditing(false);
  }

  async function addSubtask() {
    const title = subDraft.trim();
    if (!title) return;
    await repository.createSubtask({ task_id: task.id, title });
    setSubDraft('');
    setExpanded(true);
  }

  return (
    <RNView style={[styles.card, { backgroundColor: theme.card, borderColor: theme.border }]}>
      <RNView style={styles.row}>
        <Pressable
          accessibilityRole="checkbox"
          accessibilityState={{ checked: task.completed }}
          accessibilityLabel={`Mark ${task.title} ${task.completed ? 'active' : 'complete'}`}
          onPress={() => repository.updateTask(task.id, { completed: !task.completed })}
          style={[
            styles.check,
            shared.tap,
            {
              borderColor: task.completed ? theme.tint : theme.border,
              backgroundColor: task.completed ? theme.tint : 'transparent',
            },
          ]}>
          {task.completed ? (
            <SymbolView name={{ ios: 'checkmark', android: 'check', web: 'check' }} size={16} tintColor="#141415" />
          ) : null}
        </Pressable>

        <RNView style={styles.body}>
          {editing ? (
            <TextInput
              value={draft}
              onChangeText={setDraft}
              onSubmitEditing={saveTitle}
              onBlur={saveTitle}
              autoFocus
              style={[styles.input, { color: theme.text, borderColor: theme.border, backgroundColor: theme.input }]}
            />
          ) : (
            <Pressable onPress={() => setEditing(true)} style={styles.titleHit}>
              <Text
                style={[
                  styles.title,
                  task.completed && { textDecorationLine: 'line-through', color: theme.muted },
                ]}>
                {task.title}
              </Text>
            </Pressable>
          )}
          {progress ? (
            <Text muted style={styles.progress}>
              Subtasks {progress}
            </Text>
          ) : null}
        </RNView>

        <Pressable
          accessibilityLabel={expanded ? 'Hide subtasks' : 'Show subtasks'}
          onPress={() => setExpanded((value) => !value)}
          style={shared.tap}>
          <SymbolView
            name={{
              ios: expanded ? 'chevron.down' : 'chevron.right',
              android: expanded ? 'expand_more' : 'chevron_right',
              web: expanded ? 'expand_more' : 'chevron_right',
            }}
            size={22}
            tintColor={theme.muted}
          />
        </Pressable>

        <Pressable
          accessibilityLabel={`Delete ${task.title}`}
          onPress={() => repository.deleteTask(task.id)}
          style={shared.tap}>
          <SymbolView
            name={{ ios: 'trash', android: 'delete', web: 'delete' }}
            size={20}
            tintColor={theme.danger}
          />
        </Pressable>
      </RNView>

      {expanded ? (
        <RNView style={styles.subs}>
          {subtasks.map((sub) => (
            <SubtaskRow key={sub.id} subtask={sub} repository={repository} />
          ))}
          <RNView style={styles.addSub}>
            <TextInput
              placeholder="Add a subtask"
              placeholderTextColor={theme.muted}
              value={subDraft}
              onChangeText={setSubDraft}
              onSubmitEditing={addSubtask}
              style={[styles.input, { color: theme.text, borderColor: theme.border, backgroundColor: theme.input, flex: 1 }]}
            />
            <Pressable onPress={addSubtask} style={[styles.addBtn, { backgroundColor: theme.tint }]}>
              <Text style={styles.addBtnText}>Add</Text>
            </Pressable>
          </RNView>
        </RNView>
      ) : null}
    </RNView>
  );
}

function SubtaskRow({
  subtask,
  repository,
}: {
  subtask: Subtask;
  repository: TaskRepository;
}) {
  const theme = useTheme();
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(subtask.title);

  async function saveTitle() {
    const title = draft.trim();
    if (title && title !== subtask.title) {
      await repository.updateSubtask(subtask.id, { title });
    } else {
      setDraft(subtask.title);
    }
    setEditing(false);
  }

  return (
    <RNView style={styles.subRow}>
      <Pressable
        accessibilityRole="checkbox"
        accessibilityState={{ checked: subtask.completed }}
        onPress={() => repository.updateSubtask(subtask.id, { completed: !subtask.completed })}
        style={[
          styles.checkSmall,
          {
            borderColor: subtask.completed ? theme.tint : theme.border,
            backgroundColor: subtask.completed ? theme.tint : 'transparent',
          },
        ]}
      />
      {editing ? (
        <TextInput
          value={draft}
          onChangeText={setDraft}
          onSubmitEditing={saveTitle}
          onBlur={saveTitle}
          autoFocus
          style={[styles.input, { color: theme.text, borderColor: theme.border, backgroundColor: theme.input, flex: 1 }]}
        />
      ) : (
        <Pressable onPress={() => setEditing(true)} style={{ flex: 1, minHeight: 44, justifyContent: 'center' }}>
          <Text style={subtask.completed ? { textDecorationLine: 'line-through', color: theme.muted } : undefined}>
            {subtask.title}
          </Text>
        </Pressable>
      )}
      <Pressable
        accessibilityLabel={`Delete ${subtask.title}`}
        onPress={() => repository.deleteSubtask(subtask.id)}
        style={shared.tap}>
        <SymbolView name={{ ios: 'xmark', android: 'close', web: 'close' }} size={18} tintColor={theme.muted} />
      </Pressable>
    </RNView>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: 14,
    padding: 12,
    marginBottom: 10,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  body: {
    flex: 1,
  },
  titleHit: {
    minHeight: 44,
    justifyContent: 'center',
  },
  title: {
    fontSize: 17,
    fontWeight: '600',
  },
  progress: {
    marginTop: 2,
    fontSize: 13,
  },
  check: {
    width: 28,
    height: 28,
    borderRadius: 14,
    borderWidth: 2,
  },
  checkSmall: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 2,
    marginRight: 8,
  },
  input: {
    minHeight: 44,
    borderWidth: 1,
    borderRadius: 10,
    paddingHorizontal: 12,
    fontSize: 16,
  },
  subs: {
    marginTop: 10,
    paddingLeft: 8,
    gap: 6,
  },
  subRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  addSub: {
    flexDirection: 'row',
    gap: 8,
    marginTop: 6,
    alignItems: 'center',
  },
  addBtn: {
    minHeight: 44,
    paddingHorizontal: 16,
    borderRadius: 10,
    justifyContent: 'center',
  },
  addBtnText: {
    color: '#141415',
    fontWeight: '700',
  },
});
