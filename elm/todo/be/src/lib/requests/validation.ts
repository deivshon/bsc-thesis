import { FastifyReply, FastifyRequest } from "fastify";
import { z } from "zod";

export const validateBody = <T>(
    schema: z.ZodType<T>,
    body: FastifyRequest["body"],
    res: FastifyReply,
): body is T => {
    const result = schema.safeParse(body);
    if (!result.success) {
        res.status(400).send(result.error.errors);
        return false;
    }

    return true;
};
