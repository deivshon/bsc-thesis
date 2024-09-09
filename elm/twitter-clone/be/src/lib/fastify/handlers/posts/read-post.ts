import { z } from "zod";
import { postStorage } from "../../../storage/post.storage";
import { apiError, assertUserId, fastifyApp } from "../../app";

const paramsSchema = z.object({
    postId: z.string(),
});

export const readPostHandler = () => {
    fastifyApp.get("/posts/:postId", async (request, reply) => {
        assertUserId(request);

        const parsedParams = paramsSchema.safeParse(request.params);
        if (!parsedParams.success) {
            return apiError("Invalid params", 400, reply, parsedParams);
        }

        const post = await postStorage.readPost(
            parsedParams.data.postId,
            request.userId,
        );
        if (!post) {
            return apiError("Post not found", 404, reply);
        }

        return post;
    });
};
