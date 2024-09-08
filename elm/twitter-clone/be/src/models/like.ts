import { z } from "zod";

export const likeDbModelSchema = z.object({
    postId: z.string(),
    userId: z.string(),
    createdAt: z.number(),
});
export type likeDb = z.infer<typeof likeDbModelSchema>;
