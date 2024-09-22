import { safePorts } from "./ports";

const authTokenKey = "authToken";
const authToken = {
    set: (token: string): void => localStorage.setItem(authTokenKey, token),
    retrieve: (): string | null => localStorage.getItem(authTokenKey),
    unset: () => localStorage.removeItem(authTokenKey),
};

document.addEventListener("DOMContentLoaded", () => {
    const root = document.getElementById("app-container");
    if (!root) {
        throw new Error(
            "Something has gone terribly wrong, the root element was not found!",
        );
    }

    const app = Elm.Main.init({
        node: root,
        flags: {
            authToken: authToken.retrieve(),
        },
    });
    const ports = safePorts(app);

    ports.storeToken?.subscribe((t) => {
        authToken.set(t);
    });

    ports.removeToken?.subscribe(() => {
        authToken.unset();
    });

    window.addEventListener("storage", (e) => {
        if (e.key !== authTokenKey) {
            return;
        }

        ports.noInteractionTokenChange?.send(e.newValue);
    });
});
