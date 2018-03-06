Data sets can of course load external data, in either JSON, XML or text format (the latter is only selectable as a whole with the XPath expression `/text/text()`).

Static external data only needs to be loaded once. By default this is done on the server side, and the browser receives a page that's already populated with retrieved data.

Data sets automatically perform requests when their `:src` changes. Request parameters are simply added as URL parameters there, although POST requests won't actually include them in their connection URL.

This default strategy is fine for requests that, given the same URL, always return the same data. More dynamic services, e.g. those performing DB queries, can be triggered by explicitly calling `<ub1-dataset>`'s `:request` function.

_**NOTE**: Only the GET and POST methods are currently supported: more complete support will be added in future releases in order to allow the use of RESTful services._

In case of cross-domains requests made from the client side, requests will transparently be bridged by the server as clients aren't normally allowed to make them directly.