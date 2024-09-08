import FastifyCors from "@fastify/cors";
import Fastify, { FastifyReply } from "fastify";

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

fastifyApp.register(FastifyCors, {
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
});
