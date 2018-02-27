_Custom tags_ are ub1's first step towards **HTML components**. They are fine within single projects, but they're still not reusable across projects since their styling is done outside of their definition.

In order to reuse them in another project, you'd still need to include their related CSS by hand, taking care of possible naming conflicts.

In ub1, an _HTML component_ is a _custom tag_ that:

* includes its own default styles
* uses hyphenation in its name and in its CSS classes to give them project-independent names
* represents an abstraction that's potentially useful in more than one project
* specializes either a native tag or another _HTML component_ (i.e. not a generic _custom tag_).

`<style>` tags nested into a `<ub1-define>` are special: _(**NOTE:** this is being implemented and isn't available here yet)_

* they're included in the page's `<head>` only if the defined tag is actually used
* they're included only once regardless of how many times the tag is used
* they're placed before any explicit `<style>` tag
* in case the defined component specializes another component, it makes sure the other component's `<style>` tags are included before its own.
