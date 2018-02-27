An **HTML library** is a collection of _HTML components_ in a source file that can be included to make them available to a page. It should use a common hyphenated prefix for all its components and related CSS classes.

It is common for user interface libraries to define a single common _component_ that all its other _components_ specialize. Given the rules applied to `<style>` tags nested in `<ub1-define>` tags, this common _component_'s styling will automatically be included in your page when at least one of the library's _components_ is used.

Not only can the common _component_ include library-level styling, it can define a set of _logical attributes_ that all other _components_ in the library can use in their styles, and that client code can change to easily customize its own look.

_**NOTE:** library support is currently under development and isn't available here yet_.