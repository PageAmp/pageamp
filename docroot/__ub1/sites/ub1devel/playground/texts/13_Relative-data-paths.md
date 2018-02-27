_Data contexts_ set by outer tags are inherited by nested tags, which can either use them as they are in `$data{}` expressions, or refine/replace them using their own `:datapath` attribute.

Absolute paths, starting with the name of a data set followed by `:`, replace any inherited _data context_. Relative paths, on the other hand, start from the inherited context to change it.

`$data{...}` expressions are actually just shorthands for `${dataGet('...')}`, and the `dataGet()` function can be used inside _dynamic expressions_ and _functions_, where the `$data{}` syntax is not applicable.