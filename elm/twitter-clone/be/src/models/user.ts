import { z } from "zod";

export const userSchema = z.object({
    id: z.string(),
    username: z.string(),
    password: z.string(),
    createdAt: z.number(),
});
export type User = z.infer<typeof userSchema>;

export const userCreateSchema = userSchema.pick({
    username: true,
    password: true,
});
export type UserCreate = z.infer<typeof userCreateSchema>;

export const userDbModelSchema = userSchema;
export type UserDbModel = z.infer<typeof userDbModelSchema>;
