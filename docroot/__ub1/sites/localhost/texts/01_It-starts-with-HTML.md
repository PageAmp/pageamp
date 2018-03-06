Ub1 is a groundbreaking framework for Web developers. It augments HTML to make it:

* [isomorphic](https://en.wikipedia.org/wiki/Isomorphic_JavaScript), capable of working unmodified on both the server and the client, _without requiring a JavaScript back-end (1)_
* [reactive](https://en.wikipedia.org/wiki/Reactive_programming), as popularized by [React](https://reactjs.org/), but inspired by the simplicity of the venerable [OpenLaszlo](http://www.openlaszlo.org) framework
* [data-bound](https://en.wikipedia.org/wiki/Data_binding)
* [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)
* [component-oriented](https://en.wikipedia.org/wiki/Component-based_software_engineering)

Crucially, it adopts an HTML-first approach: it doesn't impose a model on you and it's friendly to third party JavaScript _(2)_. This means you can start using ub1 as plain old HTML and only tap into its features when and where you need them.

It strives to keep true to HTML's declarative nature, and has a remarkably light client runtime of just 40KB (minified, gzipped).

You can edit any example in the editor above and refresh the preview on the right to see the result.

_**NOTE:** in its current alpha stage, ub1 doesn't provide compilation errors and simply fails silently when something is wrong in your code._

---
*(1) Ub1 can currently be deployed to PHP servers, with Node.js and Java coming soon.*<br>
*(2) This playground is a ub1 application which uses [ace-editor](https://ace.c9.io/) and [showdown](https://github.com/showdownjs/showdown) in the client.*