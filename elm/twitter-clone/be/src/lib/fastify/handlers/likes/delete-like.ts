import { z } from "zod";
import { likeStorage } from "../../../storage/like.storage";
import { apiError, assertUserId, fastifyApp } from "../../app";

const querySchema = z.object({
    postId: z.string(),
});

export const deleteLikeHandler = () => {
    fastifyApp.delete("/likes", async (request, reply) => {
        assertUserId(request);

        const parsedQuery = querySchema.safeParse(request.query);
        if (!parsedQuery.success) {
            return apiError("Invalid query", 400, reply, parsedQuery);
        }

        await likeStorage.deleteLike(parsedQuery.data.postId, request.userId);
        reply.code(204);
    });
};
