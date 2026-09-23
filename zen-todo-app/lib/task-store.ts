import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

import { createId, nowIso } from '@/lib/ids';
import type { Subtask, SubtaskPatch, Task, TaskPatch } from '@/lib/types';

export type TaskTables = {
  tasks: Task[];
  subtasks: Subtask[];
};

type TaskStore = TaskTables & {
  hydrated: boolean;
  setHydrated: (value: boolean) => void;
  insertTask: (title: string) => Task;
  patchTask: (id: string, patch: TaskPatch) => Task;
  removeTask: (id: string) => void;
  insertSubtask: (taskId: string, title: string) => Subtask;
  patchSubtask: (id: string, patch: SubtaskPatch) => Subtask;
  removeSubtask: (id: string) => void;
};

export const TASK_STORAGE_KEY = 'zen-todo-db';

export const useTaskStore = create<TaskStore>()(
  persist(
    (set, get) => ({
      tasks: [],
      subtasks: [],
      hydrated: false,
      setHydrated: (value) => set({ hydrated: value }),
      insertTask: (title) => {
        const { tasks } = get();
        const nextOrder = tasks.reduce((max, row) => Math.max(max, row.sort_order), 0) + 1;
        const stamp = nowIso();
        const task: Task = {
          id: createId(),
          title: title.trim(),
          completed: false,
          created_at: stamp,
          updated_at: stamp,
          sort_order: nextOrder,
        };
        set({ tasks: [task, ...tasks] });
        return task;
      },
      patchTask: (id, patch) => {
        const current = get().tasks.find((row) => row.id === id);
        if (!current) {
          throw new Error(`Task not found: ${id}`);
        }
        const updated: Task = {
          ...current,
          ...patch,
          id: current.id,
          created_at: current.created_at,
          updated_at: nowIso(),
        };
        set({
          tasks: get().tasks.map((row) => (row.id === id ? updated : row)),
        });
        return updated;
      },
      removeTask: (id) => {
        set({
          tasks: get().tasks.filter((row) => row.id !== id),
          subtasks: get().subtasks.filter((row) => row.task_id !== id),
        });
      },
      insertSubtask: (taskId, title) => {
        const parent = get().tasks.find((row) => row.id === taskId);
        if (!parent) {
          throw new Error(`Task not found: ${taskId}`);
        }
        const siblings = get().subtasks.filter((row) => row.task_id === taskId);
        const nextOrder = siblings.reduce((max, row) => Math.max(max, row.sort_order), 0) + 1;
        const subtask: Subtask = {
          id: createId(),
          task_id: taskId,
          title: title.trim(),
          completed: false,
          created_at: nowIso(),
          sort_order: nextOrder,
        };
        set({ subtasks: [...get().subtasks, subtask] });
        return subtask;
      },
      patchSubtask: (id, patch) => {
        const current = get().subtasks.find((row) => row.id === id);
        if (!current) {
          throw new Error(`Subtask not found: ${id}`);
        }
        const updated: Subtask = {
          ...current,
          ...patch,
          id: current.id,
          task_id: current.task_id,
          created_at: current.created_at,
        };
        set({
          subtasks: get().subtasks.map((row) => (row.id === id ? updated : row)),
        });
        return updated;
      },
      removeSubtask: (id) => {
        set({
          subtasks: get().subtasks.filter((row) => row.id !== id),
        });
      },
    }),
    {
      name: TASK_STORAGE_KEY,
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        tasks: state.tasks,
        subtasks: state.subtasks,
      }),
      onRehydrateStorage: () => (state) => {
        state?.setHydrated(true);
      },
    }
  )
);
