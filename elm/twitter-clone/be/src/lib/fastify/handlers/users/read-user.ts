import { z } from "zod";
import { userStorage } from "../../../storage/user.storage";
import { apiError, fastifyApp } from "../../app";

const paramsSchema = z.object({
    userId: z.string(),
});

export const readUserHandler = () => {
    fastifyApp.get("/users/:userId", async (request, reply) => {
        const parsedParams = paramsSchema.safeParse(request.params);
        if (!parsedParams.success) {
            return apiError("Invalid params", 400, reply, parsedParams);
        }

        const user = await userStorage.readUser(parsedParams.data.userId);
        if (!user) {
            return apiError("User not found", 404, reply);
        }

        return user;
    });
};
