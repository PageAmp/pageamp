package reapp.app;

import reapp.core.*;
import ub1.web.DomTools;
using ub1.web.DomTools;

class ReApp extends ReElement {
	public var doc: DomDocument;
	public var ctx: ReContext;

	public function new(doc:DomDocument,
	                    ctx:ReContext,
	                    ?cb:ReApp->ReContext->Void) {
		this.doc = doc;
		this.ctx = ctx;
		super(null, doc.domRootElement(), null, null, null);
		cb != null ? cb(this, ctx) : null;
		ctx.refresh();
	}

}
