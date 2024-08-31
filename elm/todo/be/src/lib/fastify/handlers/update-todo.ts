import { z } from "zod";
import { todoUpdateSchema } from "../../../models/todo";
import { todoStorage } from "../../storage/todo.storage";
import { apiError, fastifyApp } from "../app";

const paramsSchema = z.object({
    id: z.string(),
});

export const updateTodosHandler = () => {
    fastifyApp.patch("/todos/:id", async (request, reply) => {
        const parsedParams = paramsSchema.safeParse(request.params);
        if (!parsedParams.success) {
            return apiError("Invalid params", 400, reply, parsedParams);
        }
        const parsedBody = todoUpdateSchema.safeParse(request.body);
        if (!parsedBody.success) {
            return apiError("Invalid body", 400, reply, parsedBody);
        }

        const { id } = parsedParams.data;

        const todo = await todoStorage.readOne(id);
        if (todo === null) {
            return apiError("Todo not found", 404, reply);
        }

        await todoStorage.update(id, parsedBody.data);

        reply.status(201);
        return;
    });
};
