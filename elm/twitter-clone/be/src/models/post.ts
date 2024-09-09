import { z } from "zod";

export const postSchema = z.object({
    id: z.string(),
    content: z.string(),
    userId: z.string(),
    createdAt: z.number(),
    likes: z.number(),
    likedByUser: z.boolean(),
});
export type Post = z.infer<typeof postSchema>;

export const postCreateSchema = postSchema.pick({ content: true });
export type PostCreate = z.infer<typeof postCreateSchema>;

export const postDbModelSchema = postSchema.pick({
    id: true,
    content: true,
    userId: true,
    createdAt: true,
    likes: true,
});
export type PostDbModel = z.infer<typeof postDbModelSchema>;
