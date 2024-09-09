import { z } from "zod";
import { userStorage } from "../../../storage/user.storage";
import { apiError, fastifyApp } from "../../app";

const bodySchema = z.object({
    username: z.string(),
    password: z.string(),
});

export const loginHandler = () => {
    fastifyApp.post("/auth/login", async (request, reply) => {
        const parsedBody = bodySchema.safeParse(request.body);
        if (!parsedBody.success) {
            return apiError("Invalid body", 400, reply, parsedBody);
        }

        const newUser = await userStorage.login(
            parsedBody.data.username,
            parsedBody.data.password,
        );

        return newUser;
    });
};
