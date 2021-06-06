package ub1.core;

import ub1.core.Element;

class Body extends Element {

	public function new(parent:Element, props:ElementProps) {
		props == null ? props = {} : null;
		props.name == null ? props.name = 'body' : null;
		super(parent, props);
	}

}
