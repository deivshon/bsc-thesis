import { z } from "zod";

const userPassword = {
    password: z.string(),
};

export const userSchema = z.object({
    id: z.string(),
    username: z.string(),
    createdAt: z.number(),
});
export type User = z.infer<typeof userSchema>;

export const userCreateSchema = userSchema
    .pick({
        username: true,
    })
    .extend(userPassword);
export type UserCreate = z.infer<typeof userCreateSchema>;

export const userDbModelSchema = userSchema.extend(userPassword);
export type UserDbModel = z.infer<typeof userDbModelSchema>;
