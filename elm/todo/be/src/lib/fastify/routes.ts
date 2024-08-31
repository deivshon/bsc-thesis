import { createTodoHandler } from "./handlers/create-todo";
import { deleteTodoHandler } from "./handlers/delete-todo";
import { getTodoHandler } from "./handlers/get-todo";
import { getTodosHandler } from "./handlers/get-todos";
import { updateTodosHandler } from "./handlers/update-todo";

type HandlerRegisterer = () => void;

const handlerRegisterers: Array<HandlerRegisterer> = [
    createTodoHandler,
    deleteTodoHandler,
    getTodoHandler,
    getTodosHandler,
    updateTodosHandler,
];

export const fastifyRoutes = {
    register: () =>
        handlerRegisterers.forEach((registerHandler) => registerHandler()),
};
