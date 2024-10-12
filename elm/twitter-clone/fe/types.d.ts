type Ports = {
    storeToken?: PortFromElm<string>;
    removeToken?: PortFromElm<void>;
    noInteractionTokenChange?: PortToElm<string | null>;
};

declare const Elm: ElmInstance<Ports>;
