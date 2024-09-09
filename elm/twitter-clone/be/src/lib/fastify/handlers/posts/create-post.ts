import { postCreateSchema } from "../../../../models/post";
import { postStorage } from "../../../storage/post.storage";
import { apiError, assertUserId, fastifyApp } from "../../app";

export const createPostHandler = () => {
    fastifyApp.post("/posts", async (request, reply) => {
        assertUserId(request);

        const parsedBody = postCreateSchema.safeParse(request.body);
        if (!parsedBody.success) {
            return apiError("Invalid body", 400, reply, parsedBody);
        }

        const newPost = await postStorage.createPost(
            parsedBody.data,
            request.userId,
        );

        return newPost;
    });
};
