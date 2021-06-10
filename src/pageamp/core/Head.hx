package pageamp.core;

import pageamp.reactivity.ReConst;
import pageamp.core.Element;

class Head extends Element {

	public function new(parent:Element, props:ElementProps) {
		props == null ? props = {} : null;
		props.name == null ? props.name = 'head' : null;
		super(parent, props);
		//FIXME: add css-specific functions, e.g. cssVendorize()
		new ReConst(this, 'cssVendorize', function(s:String) {
			return '-moz-$s;-webkit-$s;-ms-$s;$s';
		});
		new ReConst(this, 'cssVendorize2', function(prefix:String, s:String) {
			return '$prefix-moz-$s;$prefix-webkit-$s;$prefix-ms-$s;$prefix$s';
		});
	}

}
