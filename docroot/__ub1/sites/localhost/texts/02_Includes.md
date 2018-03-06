The simplest use of ub1 is probably just taking advantage of its preprocessor. For example, you may want to use the `<ub1-include>` tag.

Above is the previous example where the `<style>` tag was moved to an external file with this content:

    <lib note="styles for Includes.html">
        <style>
            body {
                color: red;
                font-family: sans-serif;
            }
        </style>
    </lib>

Note that the `<lib>` root tag can have any name and only its contents are included in the main source. You can use its attributes as you see fit, e.g. for documentation.

Compared to [SSI](https://en.wikipedia.org/wiki/Server_Side_Includes), `<ub1-include>` tags are handled by ub1 and don't depend on server-side configuration (other than having ub1 configured, of course).

Also, included files don't need to follow particular naming conventions. We used a `.htm` extension since these files won't be treated as pages by ub1, and, for security, will result in a `404 error` if accessed directly.
