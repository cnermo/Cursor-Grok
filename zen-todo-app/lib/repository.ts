import type { Subtask, SubtaskPatch, Task, TaskPatch } from '@/lib/types';

/**
 * Persistence boundary for screens. v1 uses Zustand persist.
 * Later: implement TursoTaskRepository against Vercel API + Turso/libSQL
 * without changing UI. Do not persist a .sqlite file on Vercel (ephemeral disk).
 */
export interface TaskRepository {
  listTasks(): Promise<Task[]>;
  createTask(input: { title: string }): Promise<Task>;
  updateTask(id: string, patch: TaskPatch): Promise<Task>;
  deleteTask(id: string): Promise<void>;
  listSubtasks(taskId: string): Promise<Subtask[]>;
  createSubtask(input: { task_id: string; title: string }): Promise<Subtask>;
  updateSubtask(id: string, patch: SubtaskPatch): Promise<Subtask>;
  deleteSubtask(id: string): Promise<void>;
}
