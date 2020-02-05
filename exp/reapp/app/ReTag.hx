package reapp.app;

import reapp.core.*;
import pageamp.web.DomTools;
using pageamp.web.DomTools;

class ReTag extends ReElement {

	public function new(parent:ReElement,
	                    tag:Dynamic,
	                    ?cb:ReTag->ReContext->Void) {
		super(parent, tag, null, null, null);
		cb != null ? cb(this, app.ctx) : null;
	}

}
