package reapp.core;

import reapp.core.IsoSource;
import ub1.web.DomTools;
using ub1.web.DomTools;

class ReElement extends ReNode {
	public var e: DomElement;

	public function new(parent:ReElement, props:IsoElement, ?cb:Dynamic->Void) {
		super(parent, cb);
	}

}
