import { z } from "zod";
import { likeStorage } from "../../../storage/like.storage";
import { apiError, assertUserId, fastifyApp } from "../../app";

const paramsSchema = z.object({
    likeId: z.string(),
});

export const readLikeHandler = () => {
    fastifyApp.get("/likes/:likeId", async (request, reply) => {
        assertUserId(request);

        const parsedParams = paramsSchema.safeParse(request.params);
        if (!parsedParams.success) {
            return apiError("Invalid params", 400, reply, parsedParams);
        }

        const like = await likeStorage.readLike(parsedParams.data.likeId);
        if (!like) {
            return apiError("No like found with given id", 404, reply);
        }

        return like;
    });
};
