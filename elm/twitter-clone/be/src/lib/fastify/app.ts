import FastifyCors from "@fastify/cors";
import Fastify, { FastifyReply, FastifyRequest } from "fastify";
import { userStorage } from "../storage/user.storage";

const UNPROTECTED_ROUTES = [
    { path: "/auth/login", method: "POST" },
    { path: "/users", method: "POST" },
];

export const apiError = <T extends NonNullable<object>>(
    msg: string,
    code: number,
    reply: FastifyReply,
    validationError?: {
        error: T;
    },
) => {
    reply.code(code);
    const error = (() => {
        if (!validationError) {
            return msg;
        }

        return `${msg}:${validationError.error}`;
    })();

    return { error, code };
};

export const fastifyApp = Fastify({
    logger: true,
});

fastifyApp.addHook(
    "onRequest",
    async (request: FastifyRequest, reply: FastifyReply) => {
        for (const unprotectedRoute of UNPROTECTED_ROUTES) {
            if (
                request.routeOptions.url === unprotectedRoute.path &&
                request.method === unprotectedRoute.method
            ) {
                return;
            }
        }

        const userHeader = request.headers["x-user-header"];

        if (!userHeader || typeof userHeader !== "string") {
            reply.code(403).send({
                error: "Forbidden: X-User-Header missing or malformed",
            });
            return;
        }

        const exists = await userStorage.userExists(userHeader);
        if (!exists) {
            reply.code(403).send({
                error: "Forbidden: User does not exist",
            });
            return;
        }

        request.userId = userHeader;
    },
);

export function assertUserId(
    request: FastifyRequest,
): asserts request is Omit<FastifyRequest, "userId"> & { userId: string } {
    if (!request.userId) {
        throw new Error("User ID is not defined");
    }
}

fastifyApp.register(FastifyCors, {
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
});
