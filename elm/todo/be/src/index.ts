import { fastifyApp } from "./lib/fastify/app";
import { fastifyRoutes } from "./lib/fastify/routes";

fastifyApp.listen({ port: 3000 }, (err, address) => {
    if (err) {
        fastifyApp.log.error(err);
        process.exit(1);
    }
});
fastifyRoutes.register();
