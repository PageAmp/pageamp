package pageamp.server;

import pageamp.core.*;
import pageamp.util.PropertyTool;
import pageamp.util.SourceTools;

using StringTools;
using pageamp.util.PropertyTool;
using pageamp.util.SourceTools;

class LoaderHelper {

//	public static function loadDataProps(e:HtmlNodeElement, ?p:Props): Props {
//		for (c in e.children.slice(0)) {
//			if (c.name == 'xml') {
//				p = p.set(Dataset.XML_PROP, c.innerHTML);
//				c.remove();
//				break;
//			} else if (c.name == 'json') {
//				p = p.set(Dataset.JSON_PROP, c.innerText);
//				c.remove();
//				break;
//			}
//		}
//		return p;
//	}

	public static function loadDataProps(e:SrcElement, ?p:Props): Props {
		// 1. turn possible <xml> or <json> child elements into
		// element attributes
		var ee = new Array<SrcElement>();
		for (child in e.srcElements()) {
			if (child.srcName() == 'xml') {
				p = p.set(Dataset.XML_PROP, child.srcInnerHTML());
				ee.push(child);
			} else if (child.srcName() == 'json') {
				p = p.set(Dataset.JSON_PROP, child.srcInnerText());
				ee.push(child);
			}
		}
		// 2. remove them
		while (ee.length > 0) {
			e.srcRemoveChild(ee.pop());
		}
		return p;
	}

	public static function loadDefineProps(p:Props): Props {
		var tagname = p.getString('tag', '');
		var parts = tagname.split('->');
		var name1 = parts.length > 0 ? parts[0].trim() : '';
		var name2 = parts.length > 1 ? parts[1].trim() : '';
		~/^([a-zA-Z0-9_\-:]+)$/.match(name1) ? null : name1 = '_';
		~/^([a-zA-Z0-9_\-:]+)$/.match(name2) ? null : name2 = 'div';
		p.remove('tag');
		p.remove(Element.TAG_PROP);
		p = p.set(Define.DEFNAME_PROP, name1);
		p = p.set(Define.EXTNAME_PROP, name2);
		return p;
	}

}
