/**
 * SQLite-shaped rows. Zustand persist stores these as JSON in v1.
 * A later Turso/libSQL adapter can map them 1:1 onto tables:
 *
 *   tasks(id, title, completed, created_at, updated_at, sort_order)
 *   subtasks(id, task_id, title, completed, created_at, sort_order)
 */
export type Task = {
  id: string;
  title: string;
  completed: boolean;
  created_at: string;
  updated_at: string;
  sort_order: number;
};

export type Subtask = {
  id: string;
  task_id: string;
  title: string;
  completed: boolean;
  created_at: string;
  sort_order: number;
};

export type TaskPatch = Partial<Pick<Task, 'title' | 'completed' | 'sort_order'>>;
export type SubtaskPatch = Partial<Pick<Subtask, 'title' | 'completed' | 'sort_order'>>;

export type TaskFilter = 'all' | 'active' | 'completed';
