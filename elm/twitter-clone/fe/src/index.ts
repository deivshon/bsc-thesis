document.addEventListener("DOMContentLoaded", () => {
    const root = document.getElementById("app-container");
    if (!root) {
        throw new Error(
            "Something has gone terribly wrong, the root element was not found!",
        );
    }

    Elm.Main.init({
        node: root,
    });
});
