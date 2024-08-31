import { z } from "zod";
import { todoStorage } from "../../storage/todo.storage";
import { apiError, fastifyApp } from "../app";

const paramsSchema = z.object({
    id: z.string(),
});

export const deleteTodoHandler = () => {
    fastifyApp.delete("/todos/:id", async (request, reply) => {
        const parsedParams = paramsSchema.safeParse(request.params);
        if (!parsedParams.success) {
            return apiError("Invalid params", 400, reply, parsedParams);
        }

        const { id } = parsedParams.data;

        await todoStorage.delete(id);

        reply.code(204);
        return;
    });
};
