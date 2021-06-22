package pageamp.core;

import pageamp.core.Element;

class Body extends Element {

	public function new(parent:Element, props:ElementProps) {
		props == null ? props = {} : null;
		props.aka == null ? props.aka = 'body' : null;
		super(parent, props);
	}

}
