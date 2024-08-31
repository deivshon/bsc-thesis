import { todoStorage } from "../../storage/todo.storage";
import { fastifyApp } from "../app";

export const getTodosHandler = () => {
    fastifyApp.get("/todos", async (_, reply) => {
        const todos = await todoStorage.readAll();

        reply.status(200);
        return todos;
    });
};
