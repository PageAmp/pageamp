package reapp1.core;

#if isoclient
	import pageamp.web.DomTools;
	typedef IsoElement = DomElement;
#else
	import pageamp.util.PropertyTool;
	using StringTools;
	typedef IsoElement = Props;
#end

class IsoSource {
	public static inline var HIDDEN_PREFIX = '_';
	public static inline var TAGNAME_PROP = HIDDEN_PREFIX + 'tag_name_';

	public static function isoTagName(e:IsoElement): String {
#if isoclient
		return e.tagName;
#else
		return PropertyTool.get(e, TAGNAME_PROP);
#end
	}

	public static function isoAttributes(e:IsoElement,
	                                     cb:String->String->Void) {
#if isoclient
		DomTools.domScanAttributes(e, cb);
#else
		for (key in PropertyTool.keys(e)) {
			if (key.startsWith(HIDDEN_PREFIX)) {
				continue;
			}
			cb(key, PropertyTool.get(e, key));
		}
#end
	}

}
