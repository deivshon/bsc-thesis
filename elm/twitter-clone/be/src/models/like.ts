import { z } from "zod";

export const likeDbModelSchema = z.object({
    postId: z.string(),
    userId: z.string(),
    createdAt: z.number(),
    id: z.string(),
});
export type LikeDbModel = z.infer<typeof likeDbModelSchema>;

export type Like = LikeDbModel;
