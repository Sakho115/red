export const CodeViewerHook = {
    mounted() {
        this.highlightCode();
    },
    updated() {
        this.highlightCode();
    },
    highlightCode() {
        // Import or utilize highlight.js here to map syntax formatting
        // over `this.el` mapping to a `<pre><code>` block containing code.
        console.log("Syntax highlighting triggered on element:", this.el);
        if (window.hljs) {
            window.hljs.highlightElement(this.el);
        }
    }
}
