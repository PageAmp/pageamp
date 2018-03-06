Any tag in ub1 can replicate itself using the `:foreach` attribute. Like `:datapath`, it must contain an XPath expression and, if relative, it works in the inherited _data context_.

For each match of the given expression, a clone of the tag is created and the match is set as its own _data context_, populating each clone with different data.