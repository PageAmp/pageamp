Similar to _named class attributes_, **named style attributes** allow you to declaratively compose the content of a tag's `style` attribute.

Whenever their value evaluates to a non-null, non-empty string, their name/value couple is added to the `style` attribute, or removed otherwise. Whenever `style`'s value is empty, it's removed from the tag.

Composite names should be written in camel case in `s_` attribute names, as shown above. This is akin to how element styles are expressed in JavaScript code.

In this sample, each `<div>` will alternatively have `style="background-color:red"` or no `style` attribute at all.

