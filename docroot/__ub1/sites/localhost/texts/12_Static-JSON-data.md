Static data sets can be expressed in JSON as well with no change in data-bound code.

Note that in order to make JSON selectable with XPath, an implicit `root` name is assumed by default for the root JSON object. For the same reason, array elements are assumed to be named `item` by default.

These default names can be overridden for each data set using the attributes `:jroot`, and `:jitem` to specify alternative names.