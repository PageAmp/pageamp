In ub1 you can add **logical attributes** to any tag. Their names are prefixed with `:` and they don't appear in the generated HTML.

They can be referenced in **dynamic expressions**, surrounded by the `${}` syntax, anywhere in text and tag attributes.

You can use this feature in order to effectively replace most of the functionality offered by a dedicated [CSS processor](https://htmlmag.com/article/an-introduction-to-css-preprocessors-sass-less-stylus). Ub1 provides CSS-related functionality to facilitate this, and you can add your own.

The first advantage is we can use the same syntax we use anywhere else in our ub1 applications, rather than that of [Sass](https://sass-lang.com/) or [LESS](http://lesscss.org/).

Secondly, we can share _logical attributes_ between styling and application logic, as shown above. This is important since we're now able to implement skins that don't just affect the CSS, but other aspects of content presentation as well.

For example, we can add something like `maxListItems` to our skin variables. This makes a lot of sense since it still pertains to the presentation layer, but cannot be expressed using CSS alone.

Finally, integrating the CSS side of things is key to ub1's component-orientation, as we'll see later on.