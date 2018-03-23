package reapp.app;

import reapp.core.*;
import ub1.web.DomTools;
using ub1.web.DomTools;

class ReTag extends ReElement {

	public function new(parent:ReElement,
	                    tag:Dynamic,
	                    ?cb:ReTag->ReContext->Void) {
		super(parent, tag, null, null, null);
		cb != null ? cb(this, app.ctx) : null;
	}

}
