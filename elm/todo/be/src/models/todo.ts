import { z } from "zod";

export const todoSchema = z.object({
    id: z.string(),
    content: z.string(),
    createdAt: z.number(),
    updatedAt: z.number(),
    done: z.boolean(),
});
export type Todo = z.infer<typeof todoSchema>;

export const todoCreateSchema = todoSchema.pick({ content: true });
export type TodoCreate = z.infer<typeof todoCreateSchema>;

export const todoUpdateSchema = todoSchema.omit({ id: true }).partial();
export type TodoUpdate = z.infer<typeof todoUpdateSchema>;
