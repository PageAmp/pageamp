CSS class names are routinely added and removed from a tag's `class` attribute in order to update its visual state.

Instead of composing the content of a tag's `class` attribute yourself, ub1 lets you declare **named class attributes**, prefixed with `c_`. They will be added to the tag's `class` attribute by default, or whenever their dynamic expression, if any, evaluates to true.

Note that composite names should be written with hyphenation in CSS declarations and in camel case in `c_` attribute names, as shown above. This is akin to how element styles are expressed in JavaScript code.

In the code above, `<li>` tags will alternatively have either `"list-item"` or `"list-item selected"` in their `class` attribute.
