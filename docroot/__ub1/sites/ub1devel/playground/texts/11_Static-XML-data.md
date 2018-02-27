You can declare a data source with the `<ub1-dataset>` tag:

    <ub1-dataset :name="...">

In this sample we have a static data set expressed in XML. Ub1's data-binding works using the `:datapath` attribute and the `$data{}` expression.

`:datapath` changes the **data context** of a tag using a **data path** expression. _Data paths_ are expressed in a subset of XPath.

Our `<span>` tags set their _data context_ to the `<root>` element, which is the context where the `$data{}` expressions are executed.

`:datapath` attributes must contain XPath expressions returning XML elements, whereas `$data{}` expressions must contain XPath expressions returning strings.
