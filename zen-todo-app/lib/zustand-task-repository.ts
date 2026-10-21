import type { TaskRepository } from '@/lib/repository';
import { useTaskStore } from '@/lib/task-store';
import type { Subtask, SubtaskPatch, Task, TaskPatch } from '@/lib/types';

function bySortThenCreated<T extends { sort_order: number; created_at: string }>(a: T, b: T) {
  if (a.sort_order !== b.sort_order) {
    return a.sort_order - b.sort_order;
  }
  return a.created_at.localeCompare(b.created_at);
}

export const zustandTaskRepository: TaskRepository = {
  async listTasks(): Promise<Task[]> {
    return [...useTaskStore.getState().tasks].sort(bySortThenCreated);
  },

  async createTask(input: { title: string }): Promise<Task> {
    const title = input.title.trim();
    if (!title) {
      throw new Error('Task title is required');
    }
    return useTaskStore.getState().insertTask(title);
  },

  async updateTask(id: string, patch: TaskPatch): Promise<Task> {
    return useTaskStore.getState().patchTask(id, patch);
  },

  async deleteTask(id: string): Promise<void> {
    useTaskStore.getState().removeTask(id);
  },

  async listSubtasks(taskId: string): Promise<Subtask[]> {
    return useTaskStore
      .getState()
      .subtasks.filter((row) => row.task_id === taskId)
      .sort(bySortThenCreated);
  },

  async createSubtask(input: { task_id: string; title: string }): Promise<Subtask> {
    const title = input.title.trim();
    if (!title) {
      throw new Error('Subtask title is required');
    }
    return useTaskStore.getState().insertSubtask(input.task_id, title);
  },

  async updateSubtask(id: string, patch: SubtaskPatch): Promise<Subtask> {
    return useTaskStore.getState().patchSubtask(id, patch);
  },

  async deleteSubtask(id: string): Promise<void> {
    useTaskStore.getState().removeSubtask(id);
  },
};
