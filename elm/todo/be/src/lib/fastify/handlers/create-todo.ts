import { todoCreateSchema } from "../../../models/todo";
import { todoStorage } from "../../storage/todo.storage";
import { apiError, fastifyApp } from "../app";

export const createTodoHandler = () => {
    fastifyApp.post("/todos", async (request, reply) => {
        const parsedBody = todoCreateSchema.safeParse(request.body);
        if (!parsedBody.success) {
            return apiError("Invalid body", 400, reply, parsedBody);
        }

        await todoStorage.create(parsedBody.data);

        reply.code(201);
        return;
    });
};
