import { z } from "zod";
import { likeStorage } from "../../../storage/like.storage";
import { apiError, assertUserId, fastifyApp } from "../../app";

const bodySchema = z.object({
    postId: z.string(),
});

export const createLikeHandler = () => {
    fastifyApp.post("/likes", async (request, reply) => {
        assertUserId(request);

        const parsedBody = bodySchema.safeParse(request.body);
        if (!parsedBody.success) {
            return apiError("Invalid body", 400, reply, parsedBody);
        }

        await likeStorage.createLike(parsedBody.data.postId, request.userId);
    });
};
