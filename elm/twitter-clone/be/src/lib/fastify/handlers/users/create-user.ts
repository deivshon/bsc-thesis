import { userCreateSchema } from "../../../../models/user";
import { userStorage } from "../../../storage/user.storage";
import { apiError, fastifyApp } from "../../app";

export const createTodoHandler = () => {
    fastifyApp.post("/users", async (request, reply) => {
        const parsedBody = userCreateSchema.safeParse(request.body);
        if (!parsedBody.success) {
            return apiError("Invalid body", 400, reply, parsedBody);
        }

        const newUser = await userStorage.createUser(parsedBody.data);

        return newUser;
    });
};
