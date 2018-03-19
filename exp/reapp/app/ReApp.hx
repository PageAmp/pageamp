package reapp.app;

import reapp.core.*;
import ub1.web.DomTools;
using ub1.web.DomTools;

class ReApp extends ReNode {
	public var doc: DomDocument;
	public var ctx: ReContext;

	public function new(doc:DomDocument, ?cb:Dynamic->Void) {
		this.doc = doc;
		this.ctx = new ReContext();
		super(null, null, null, cb);
	}

}
