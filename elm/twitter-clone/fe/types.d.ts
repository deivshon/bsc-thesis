type Ports = {
    storeToken: (token: string) => void;
    removeToken: () => void;
};

declare const Elm: ElmInstance<Ports>;
