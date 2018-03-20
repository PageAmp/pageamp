package reapp.app;

import reapp.core.Re;
import ub1.util.Util;
import ub1.web.DomTools;
using ub1.web.DomTools;
using StringTools;

class ReElement extends ReNode {

	public function new(parent:ReElement,
	                    tag:Dynamic,
	                    ?plug:String,
	                    ?index:Int,
	                    ?cb:Dynamic->Void) {
		this.tag = tag;
		super(parent, plug, index, cb);
	}

	override public function add(key:String, value:Re<Dynamic>): Re<Dynamic> {
		var ret = super.add(key, value);
		if (key.startsWith('a_')) {
			// tag attribute
			value.key = makeHyphenName(key.substr('a_'.length));
			value.cb = attributeValueCB;
		} else if (key.startsWith('c_')) {
			// tag class
			value.key = makeHyphenName(key.substr('c_'.length));
			value.cb = classValueCB;
		} else if (key.startsWith('s_')) {
			// tag style
			value.key = makeHyphenName(key.substr('s_'.length));
			value.cb = styleValueCB;
		}
		return ret;
	}

	public static function makeCamelName(n:String): String {
		return ~/(\-\w)/g.map(n, function(re:EReg): String {
			return n.substr(re.matchedPos().pos + 1, 1).toUpperCase();
		});
	}

	public static function makeHyphenName(n:String): String {
		return ~/([0-9a-z][A-Z])/g.map(n, function(re:EReg): String {
			var p = re.matchedPos().pos;
			return n.substr(p, 1).toLowerCase()
			+ '-'
			+ n.substr(p + 1, 1).toLowerCase();
		});
	}

	// =========================================================================
	// private
	// =========================================================================
	var tag: Dynamic;
	var e: DomElement;

	override function init() {
		super.init();
		if (Std.is(tag, String)) {
			//TODO
		} else {
			e = cast tag;
			tag = null;
		}
	}

	// =========================================================================
	// tag attribute reflection
	// =========================================================================

	function attributeValueCB(v:Re<Dynamic>, old:Dynamic, val:Dynamic) {
		e.domSet(v.key, (val != null ? Std.string(val) : null));
	}

	// =========================================================================
	// tag class reflection
	// =========================================================================
#if !client
	var classes: Map<String, Bool>;
	var willApplyClasses = false;
#end

	function classValueCB(v:Re<Dynamic>, old:Dynamic, val:Dynamic) {
		var flag = Util.isTrue(val != null ? '$val' : '1');
#if !client
		classes == null ? classes = new Map<String, Bool>() : null;
		flag ? classes.set(key, true) : classes.remove(key);
		if (!willApplyClasses) {
			willApplyClasses = true;
			v.ctx.callbacks.push(applyClasses);
		}
#else
		if (flag) {
			e.classList.add(v.key);
		} else {
			e.classList.remove(v.key);
		}
#end
	}

#if !client
	function applyClasses() {
		willApplyClasses = false;
		var sb = new StringBuf();
		var sep = '';
		for (key in classes.keys()) {
			if (classes.get(key)) {
				sb.add(sep); sep = ' '; sb.add(key);
			}
		}
		var s = sb.toString();
		e.domSet('class', (s.length > 0 ? s : null));
	}
#end

	// =========================================================================
	// style reflection
	// =========================================================================
#if !client
	var styles: Map<String, String>;
	var willApplyStyles = false;
#end

	function styleValueCB(v:Re<Dynamic>, old:String, val:Dynamic) {
#if !client
		styles == null ? styles = new Map<String, String>() : null;
		val != null ? styles.set(v.key, Std.string(val)) : styles.remove(v.key);
		if (!willApplyStyles) {
			willApplyStyles = true;
			v.ctx.callbacks.push(applyStyles);
		}
#else
		if (val != null) {
			e.style.setProperty(v.key, Std.string(val));
		} else {
			e.style.removeProperty(v.key);
		}
#end
	}

#if !client
	function applyStyles() {
		willApplyStyles = false;
		var sb = new StringBuf();
		var sep = '';
		for (key in styles.keys()) {
			sb.add(sep); sep = ';';
			sb.add(key); sb.add(':'); sb.add(styles.get(key));
		}
		var s = sb.toString();
		e.domSet('style', (s.length > 0 ? s : null));
	}
#end

}
