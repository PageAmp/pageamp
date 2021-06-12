package pageamp.core;

import pageamp.core.Element;
import pageamp.lib.ColorTools;
import pageamp.reactivity.ReConst;

class Head extends Element {

	public function new(parent:Element, props:ElementProps) {
		props == null ? props = {} : null;
		props.name == null ? props.name = 'head' : null;
		super(parent, props);

		// =========================================================================
		// CSS API
		// =========================================================================

		new ReConst(this, 'cssVendorize', function(s:String) {
			return '-moz-$s;-webkit-$s;-ms-$s;$s';
		});

		new ReConst(this, 'cssVendorize2', function(prefix:String, s:String) {
			return '$prefix-moz-$s;$prefix-webkit-$s;$prefix-ms-$s;$prefix$s';
		});

		new ReConst(this, 'cssMakeSelectable', function() {
			return '-webkit-touch-callout:text;'
			+ '-webkit-user-select:text;'
			+ '-khtml-user-select:text;'
			+ '-moz-user-select:text;'
			+ '-ms-user-select:text;'
			+ 'user-select:text;';
		});

		new ReConst(this, 'cssMakeNonSelectable', function() {
			return '-webkit-touch-callout:none;'
			+ '-webkit-user-select:none;'
			+ '-khtml-user-select:none;'
			+ '-moz-user-select:none;'
			+ '-ms-user-select:none;'
			+ 'user-select:none;';
		});

		new ReConst(this, 'cssFullRgb', ColorTools.fullRgb);
		new ReConst(this, 'cssColor2Components', ColorTools.color2Components);
		new ReConst(this, 'cssComponents2Color', ColorTools.components2Color);
		new ReConst(this, 'cssColorOffset', ColorTools.colorOffset);
		new ReConst(this, 'cssCounterColor', ColorTools.counterColor);
		new ReConst(this, 'cssColorMix', ColorTools.mix);
	}

}
