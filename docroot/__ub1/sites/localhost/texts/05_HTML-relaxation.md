As mentioned, ub1 performs an initial execution of page logic on the server.

This means it needs to parse the original HTML at least once, and it has a chance to be relaxed about the accepted HTML syntax and fix it along the way for better browser compatibility and development comfort.

In ub1 you can auto-close any tag with `/>`, let it handle missing tag closures and, more importantly, insert unescaped newline and `<` characters inside attribute values.

This is a minor feature that actually makes for a much better experience when writing _dynamic expressions_, which can be properly indented on more lines and can include the `<` operator without having to write it as `&lt;`.

_**NOTE 1:** please space operators in expressions: not only it's good practice, it also prevents ub1 from confusing e.g. `a<b` with the malformed opening of a tag named `b`_.

_**NOTE 2:** while it's OK to use newlines inside dynamic expressions (they are parsed as scripts and never appear in source form in HTML attributes), keep in mind that native attributes containing literal newlines will have their values turned into single-line texts with all newlines escaped as HTML entities_.
