type Ports = ReturnType<typeof Elm.Main.init>["ports"];
type IntermediatePortsFromElm = {
    [K in keyof Ports]: Ports[K] extends PortFromElm<infer T>
        ? PortFromElm<T>
        : never;
};
type IntermediatePortsToElm = {
    [K in keyof Ports]: Ports[K] extends PortToElm<infer T>
        ? PortToElm<T>
        : never;
};

type NoNeverKeys<O extends NonNullable<object>> = {
    [K in keyof O]: O[K] extends never ? never : K;
}[keyof O];

type PortsFromElm = {
    [K in NoNeverKeys<IntermediatePortsFromElm>]: IntermediatePortsFromElm[K];
};
type PortsToElm = {
    [K in NoNeverKeys<IntermediatePortsToElm>]: IntermediatePortsToElm[K];
};

const portsToElm = (app: ElmApp<Ports>): PortsToElm => ({
    noInteractionTokenChange: app.ports.noInteractionTokenChange,
});

const registerSafePortSubscription = <K extends keyof PortsFromElm>(
    app: ElmApp<Ports>,
    portKey: K,
) => {
    if (!("ports" in app)) {
        console.error("No ports found in app");
        return;
    }

    const port = app.ports[portKey];
    if (!port) {
        console.error(`No port found with name ${portKey}`);
        return;
    }

    return {
        subscribe: (cb: Parameters<PortsFromElm[K]["subscribe"]>[0]) =>
            port.subscribe(cb),
        unsubscribe: (handler: Parameters<PortsFromElm[K]["unsubscribe"]>[0]) =>
            port.unsubscribe(handler),
    };
};

const sendToElmPort = <K extends keyof PortsToElm>(
    app: ElmApp<Ports>,
    portKey: K,
) => {
    if (!("ports" in app)) {
        console.error("No ports found in app");
        return;
    }

    const port = portsToElm(app)[portKey];
    if (!port) {
        console.error(`No port found with name ${portKey}`);
        return;
    }

    return {
        send: (data: Parameters<PortsToElm[K]["send"]>[0]) => port.send(data),
    };
};

export const safePorts = (app: ElmApp<Ports>) => ({
    storeToken: registerSafePortSubscription(app, "storeToken"),
    removeToken: registerSafePortSubscription(app, "removeToken"),
    noInteractionTokenChange: sendToElmPort(app, "noInteractionTokenChange"),
});
