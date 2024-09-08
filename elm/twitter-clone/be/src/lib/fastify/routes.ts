type HandlerRegisterer = () => void;

const handlerRegisterers: Array<HandlerRegisterer> = [];

export const fastifyRoutes = {
    register: () =>
        handlerRegisterers.forEach((registerHandler) => registerHandler()),
};
