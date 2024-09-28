import { z } from "zod";
import { postStorage } from "../../../storage/post.storage";
import { apiError, assertUserId, fastifyApp } from "../../app";

const querySchema = z.object({
    skip: z.number({ coerce: true }),
    limit: z.number({ coerce: true }),
    userId: z.string().optional(),
});

export const readPostsHandler = () => {
    fastifyApp.get("/posts", async (request, reply) => {
        assertUserId(request);

        const parsedQuery = querySchema.safeParse(request.query);
        if (!parsedQuery.success) {
            return apiError("Invalid query", 400, reply, parsedQuery);
        }

        return postStorage.readPaginatedPosts(
            parsedQuery.data.skip,
            parsedQuery.data.limit,
            request.userId,
            parsedQuery.data.userId,
        );
    });
};
