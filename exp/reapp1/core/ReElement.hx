package reapp1.core;

import reapp1.core.IsoSource;
import pageamp.web.DomTools;
using pageamp.web.DomTools;

class ReElement extends ReNode {
	public var e: DomElement;

	public function new(parent:ReElement, props:IsoElement, ?cb:Dynamic->Void) {
		super(parent, cb);
	}

}
