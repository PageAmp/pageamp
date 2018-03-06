The _dynamic expressions_ we've used so far are limited to single scripting expressions: they cannot include the `;` character and thus cannot contain more statements.

When you need to perform multi-step operations in your code, you can declare a `function` attribute, using the following syntax:

    :myFunction="${function(arg1, arg2 ...) { ... }}"

In the example above, the inner `<div>` must perform two distinct operations when it receives a click: toggle its selection state, and prevent the click event from propagating to the outer `<div>`.

_Dynamic expressions_ are kept simple by design so dependencies between _logical attributes_ are easier to understand. Functions, on the other hand, are a better way to express a complex behaviour, and give it an explicit name. Another fundamental difference is _dynamic expressions_ get automatically re-evaluated when the _logical attributes_ they depend upon change, whereas functions have to be explicitly called in order to perform their task.

As a side note, we can observe in this example that _event handlers_ have access to the HTML event they receive through a variable named `ev`.