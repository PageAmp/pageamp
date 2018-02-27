# ub1

Ub1 is a groundbreaking framework for Web developers. It augments HTML to make it:

* [isomprphic](https://en.wikipedia.org/wiki/Isomorphic_JavaScript), capable of working unmodified on both the server and the client, _without requiring a JavaScript back-end (1)_
* [reactive](https://en.wikipedia.org/wiki/Reactive_programming), as popularized by [React](https://reactjs.org/), but inspired by the simplicity of the venerable [OpenLaszlo](http://www.openlaszlo.org) framework
* [data-bound](https://en.wikipedia.org/wiki/Data_binding)
* [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)
* [component-oriented](https://en.wikipedia.org/wiki/Component-based_software_engineering)

Crucially, it adopts an HTML-first approach: it doesn't impose a model on you and it's friendly to third party JavaScript _(2)_. This means you can start using ub1 as plain old HTML and only tap into its features when and where you need them.

It strives to keep true to HTML's declarative nature, and has remarkably light client runtime of just 40KB (minified, gzipped).

It's currently in alpha stage. An online playground is available [here](http://ub1devel.net/playground/).

---
*(1) Ub1 can currently be deployed to PHP servers, with Node.js and Java coming soon.*<br>
*(2) For example the online playground is a ub1 application which uses [ace-editor](https://ace.c9.io/) and [showdown](https://github.com/showdownjs/showdown) in the client.*

## Isomorphism

> Server Side Rendering for the rest of us.

Ub1 was built from the ground up with support for [Server Side Rendering](https://medium.com/walmartlabs/the-benefits-of-server-side-rendering-over-client-side-rendering-5d07ff2cefe8) on a variety of server platforms thanks to the magic of the [Haxe language](https://haxe.org/).

Contrary to JavaScript-only technologies like [React.js](https://reactjs.org), [Vue.js](https://vuejs.org/), [Redux](https://redux.js.org/) etc., SSR is not an afterthought and your server-side options are not limited to [Node.js](https://nodejs.org/en/), which isn't a practical choice for the average web site.

In a ub1 server, HTTP requests are served through ub1.Server, configured as single entry point in `.htaccess`:

    RewriteEngine on
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php [L,QSA]

Requests of files with no extension or with extension `.html` are considered page requests, and loaded in the _same environment the client will have_, only working on a simulated browser DOM, which is then turned into a textual HTML page and sent to the client.

On the client side, the page is immediately displayed while, asynchronously, ub1's client runtime is loaded. When it's ready, the latter reads the applications state stored by the server code, and restores it in the client.

## Reactivity

Just as React.js and Vue.js, ub1 is a _reactive framework_, where changes to logical values automatically propagate.

In ub1, all tag attributes prefixed with `:` are logical attributes that don't actually appear in the page DOM, but rather are part of the page logic.

Anywhere in attributes and text you can use `${}` to inject the result of a dynamic expression. In this example:

    <html :color="blue">
    <head>
        <style>
            body {
                color: ${color};
            }
        </style>
    </head>
    <body :ev_click="${color = (color == 'red' ? 'blue' : 'red')}">
        This is ${color}.
    </body>
    </html>

clicking in the page will change the color and the text it displays. You can check it out in the [playground](http://ub1devel.local/playground/).

Keep in mind that, being also an _isomorphic framework_, what is happening here is:

* on page request, the server performs an initial execution of its logic. In our case, this means the generated HTML markup sent to the browser will already have `${color}` replaced with `blue` in our CSS declaration
* together with the pre-rendered markup, the server stores the page's logic state, in JSON, in a script tag
* on page load, the client instantly shows the pre-rendered markup while, in the background, ub1 client code is asynchronously loaded
* as soon as the client code starts executing, it reads the JSON state descriptor and gets ready to continue the application execution _from where the server left it_.

We've only used trivial expressions here, but in `${}` expression you can put actual scripting code. It's not, technically, JavaScript, but rather [hscript](https://github.com/HaxeFoundation/hscript). You'd be hard-pressed to notice the difference in most situations, though. Again, you can check it out yourself in the [playground](http://ub1devel.net/playground/).

## Data-binding

Ub1 is optimized as a _content delivery platform_, and content data are first-class citizens in ub1 pages. They are represented by `<ub1-dataset>` tags:

    <html>
    <body>
        <ub1-dataset :name="dset"
                     :src="http://ub1devel.net/playground/data/employees.json"/>

        <table :datapath="dset:/root">
            <tr :foreach="item">
                <td>$data{@name}</td>
                <td>&bull; tel: $data{@phone}</td>
            </tr>
        </table>
    </body>
    </html>

Data-binding works using `:datapath` attributes and `$data{}` expressions:

* `:datapath` sets the data context of a tag using a data path expression, expressed in a subset of XPath
* `$data{}` injects the textual result of a data path expression executed in the context set by `:datapath`.

Ub1 accepts data in both JSON and XML.

Any tag can be replicated by using `:foreach` instead of `:datapath`. For each matched data, a clone of the tag is generated and populated using the match as its own data context.

Thanks to _isomorphism_, data sets exist in both the client and the server. This allows you to implement server-side services (e.g. DB persistence) that the page will use, and to transparently use the server as a relay when accessing third-party remote data from the client in order to avoid the [Same-origin](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy) limitations.

## DRYness

Two of the most glaring limitations of plain HTML are:

* it doesn't support source code modularization
* it doesn't support code reuse.

Ub1 preprocesses your pages adding support for the `<ub1-include>` tag, e.g.:

    <html>
    <head>
        <ub1-include href="inc/style.htm"/>
    </head>
    <body>
        ...
    </body>
    </html>

Where `inc/style.html` could be:

    <lib note="sample include file">
        <style>
            body {
                color: red;
                font-family: sans-serif;
            }
        </style>
    </lib>

(the root tag is ignored and can be used for documentation).

Includes should only be used to modularize your source code, splitting it by function (e.g. style, data, different sections of your site). For avoiding replicated code, ub1 has a better tool in _custom tags_.

Let's see a classic example. The obvious duplication problem in this code above will be familiar to anybody who ever wrote an HTML page:

    <body>

        <div class="product">
            <div><span>Name:</span> Thingy</div>
            <div><span>Price:</span> 1€</div>
        </div>

        <div class="product">
            <div><span>Name:</span> Widget</div>
            <div><span>Price:</span> 2€</div>
        </div>

    </body>

In ub1, this code will produce exactly the same HTML:

    <body>

        <ub1-define tag="app-product:div" class="product">
            <div><span>Name:</span> ${name}</div>
            <div><span>Price:</span> ${price}</div>
        </ub1-define>

        <app-product :name="Thingy" :price="1€"/>
        <app-product :name="Widget" :price="2€"/>

    </body>

We simply took our duplicated block and turned it into a custom tag named `<app-product>`, which specializes a `<div>` and has dynamic content. We then used it in our code:

    <app-product :name="Thingy" :price="1€"/>
    <app-product :name="Widget" :price="2€"/>

by only specifying what it is (a product) and what changes between its instances (name and price).

## HTML component libraries

_Custom tags_ are ub1's first step towards **HTML components**. They are fine within single projects, but they're still not reusable across projects since their styling is done outside of their definition.

In order to reuse them in another project, you'd still need to include their related CSS by hand, taking care of possible naming conflicts.

In ub1, an _HTML component_ is a _custom tag_ that:

* includes its own default styles
* uses hyphenation in its name and in its CSS classes to give them project-independent names
* represents an abstraction that's potentially useful in more than one project
* specializes either a native tag or another _HTML component_ (i.e. not a generic _custom tag_).

`<style>` tags nested into a `<ub1-define>` are special: _(**NOTE:** this is being implemented and isn't available yet)_

* they're included in the page's `<head>` only if the defined tag is actually used
* they're included only once regardless of how many times the tag is used
* they're placed before any explicit `<style>` tag
* in case the defined component specializes another component, it makes sure the other component's `<style>` tags are included before its own.

Nested `<style>` tags handling is designed to allow component designers to provide baseline styling, leaving component consumers the maximum freedom to customize it either through CSS overriding (by redeclaring components' CSS classes) or by setting the skin attributes a library could provide.
