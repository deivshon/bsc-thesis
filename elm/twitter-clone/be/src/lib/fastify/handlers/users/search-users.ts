import { z } from "zod";
import { userStorage } from "../../../storage/user.storage";
import { apiError, fastifyApp } from "../../app";

const querySchema = z.object({
    query: z.string(),
});

export const searchUsersHandler = () => {
    fastifyApp.get("/users", async (request, reply) => {
        const parsedQuery = querySchema.safeParse(request.query);
        if (!parsedQuery.success) {
            return apiError("Invalid query", 400, reply, parsedQuery);
        }

        return userStorage.searchUsers(parsedQuery.data.query);
    });
};
