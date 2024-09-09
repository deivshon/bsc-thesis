import { createLikeHandler } from "./handlers/likes/create-like";
import { deleteLikeHandler } from "./handlers/likes/delete-like";
import { createPostHandler } from "./handlers/posts/create-post";
import { readPostHandler } from "./handlers/posts/read-post";
import { readPostsHandler } from "./handlers/posts/read-posts";
import { createUserHandler } from "./handlers/users/create-user";
import { loginHandler } from "./handlers/users/login";
import { readUserHandler } from "./handlers/users/read-user";
import { searchUsersHandler } from "./handlers/users/search-users";

type HandlerRegisterer = () => void;

const handlerRegisterers: Array<HandlerRegisterer> = [
    createLikeHandler,
    deleteLikeHandler,
    createPostHandler,
    readPostHandler,
    readPostsHandler,
    createUserHandler,
    loginHandler,
    readUserHandler,
    searchUsersHandler,
];

export const fastifyRoutes = {
    register: () =>
        handlerRegisterers.forEach((registerHandler) => registerHandler()),
};
