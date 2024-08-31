import { z } from "zod";
import { todoStorage } from "../../storage/todo.storage";
import { apiError, fastifyApp } from "../app";

const paramsSchema = z.object({
    id: z.string(),
});

export const getTodoHandler = () => {
    fastifyApp.get("/todos/:id", async (request, reply) => {
        const parsedParams = paramsSchema.safeParse(request.params);
        if (!parsedParams.success) {
            return apiError("Invalid params", 400, reply, parsedParams);
        }

        const { id } = parsedParams.data;

        const todo = await todoStorage.readOne(id);
        if (todo === null) {
            return apiError("Todo not found", 404, reply);
        }

        reply.status(200);
        return todo;
    });
};
