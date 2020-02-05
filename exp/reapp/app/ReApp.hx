package reapp.app;

import reapp.core.*;
import pageamp.web.DomTools;
using pageamp.web.DomTools;

class ReApp extends ReElement {
	public var doc: DomDocument;
	public var ctx: ReContext;

	public function new(doc:DomDocument,
	                    ctx:ReContext,
	                    ?cb:ReApp->ReContext->Void) {
		this.app = this;
		this.doc = doc;
		this.ctx = ctx;
		super(null, doc.domRootElement(), null, null, null);
		cb != null ? cb(this, ctx) : null;
		ctx.refresh();
	}

}
