import { todoCreateSchema } from "../../../models/todo";
import { todoStorage } from "../../storage/todo.storage";
import { apiError, fastifyApp } from "../app";

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export const createTodoHandler = () => {
    fastifyApp.post("/todos", async (request, reply) => {
        await sleep(Math.random() * 500);
        const parsedBody = todoCreateSchema.safeParse(request.body);
        if (!parsedBody.success) {
            return apiError("Invalid body", 400, reply, parsedBody);
        }

        const newTodo = await todoStorage.create(parsedBody.data);

        return newTodo;
    });
};
