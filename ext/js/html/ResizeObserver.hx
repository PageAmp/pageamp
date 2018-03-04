package js.html;

extern interface ResizeObserver {
	public function observe(e:Element): Void;
}

extern interface ResizeObserverEntries {
	public function forEach(cb:ResizeObserverEntry->Void): Void;
}

extern interface ResizeObserverEntry {
	public var target: Element;
	public var contentRect: DOMRectReadOnly;
}
