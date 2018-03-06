Attributes starting with `:ev_` add **event handlers** to their tags, i.e. _dynamic expressions_ that are evaluated each time a given DOM event is received.

Here we're extending the previous example by changing the value of `color` at each click.

We can observe that _logical attributes_ are **reactive**: when their value changes, it propagates to all _dynamic expressions_ that depend on them, which are automatically re-evaluated and re-applied if needed.

As you can see, this applies to CSS declarations as well. Since this feature is rarely needed in the client, it will be optional in future releases to keep CSS processing on the server-side only.

It's worth noting that, being ub1 an _isomorphic_ framework, what is happening here is:

* on page request, the server performs an initial execution of its logic. In our case, this means the generated HTML markup sent to the browser will already have `${color}` replaced with `blue` in our CSS declaration
* together with the pre-rendered markup, the server stores the page's logic state, in JSON, in a script tag
* on page load, the client instantly shows the pre-rendered markup while, in the background, ub1 client code is asynchronously loaded
* as soon as the client code starts executing, it reads the JSON state descriptor and gets ready to continue the application execution _from where the server left it_.