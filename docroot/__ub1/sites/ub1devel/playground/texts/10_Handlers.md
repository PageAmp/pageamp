**Handlers** are either _dynamic expressions_ or _functions_ that are executed when the value of one or more _logical attributes_ changes.

They can be declared as **handler expressions** like this:

:on_...="${ ... }"

where after the `:on_` prefix goes the name of the _logical attribute_ whose value changes will cause its execution.

This simpler form is fine as long as the monitored _logical attribute_ is only one, and handler's code can be expressed in a single _dynamic expression_.

The alternative way is declaring **handler functions**:

    :myHandler="${(name1, name2, ...):function() { ... }}"

where `name1` etc. is the list of one or more monitored _logical attributes_, and the function's body is the code that gets executed whenever any of them changes value.