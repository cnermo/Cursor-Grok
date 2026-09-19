import { zustandTaskRepository } from '@/lib/zustand-task-repository';

/** Default v1 repository. Swap this export for a Turso adapter later. */
export const taskRepository = zustandTaskRepository;
