import { taskRepository } from '@/lib/tasks';
import { useTaskStore } from '@/lib/task-store';
import type { Subtask, Task } from '@/lib/types';

export function useTaskSnapshot(): {
  tasks: Task[];
  subtasks: Subtask[];
  hydrated: boolean;
  repository: typeof taskRepository;
} {
  const tasks = useTaskStore((state) => state.tasks);
  const subtasks = useTaskStore((state) => state.subtasks);
  const hydrated = useTaskStore((state) => state.hydrated);

  return { tasks, subtasks, hydrated, repository: taskRepository };
}
