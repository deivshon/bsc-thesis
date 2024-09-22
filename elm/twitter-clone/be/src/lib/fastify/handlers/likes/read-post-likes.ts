import { z } from "zod";
import { likeStorage } from "../../../storage/like.storage";
import { postStorage } from "../../../storage/post.storage";
import { apiError, assertUserId, fastifyApp } from "../../app";

const querySchema = z.object({
    postId: z.string(),
});

export const readPostLikesHandler = () => {
    fastifyApp.get("/likes", async (request, reply) => {
        assertUserId(request);

        const parsedQuery = querySchema.safeParse(request.query);
        if (!parsedQuery.success) {
            return apiError("Invalid query", 400, reply, parsedQuery);
        }

        const post = await postStorage.readPost(
            parsedQuery.data.postId,
            request.userId,
        );
        if (!post) {
            return apiError("Post with given id does not exist", 404, reply);
        }

        const likes = await likeStorage.readPostLikes(parsedQuery.data.postId);
        return likes;
    });
};
