package pageamp.lib;

import haxe.Constraints.IMap;
import haxe.ds.EnumValueMap;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;

@:multiType(@:followWithAbstracts K)
abstract Set<T>(IMap<T, Bool>) {

	public function new();

	public inline function add(key:T)
		this.set(key, true);

	public inline function remove(key:T)
		return this.remove(key);

	public inline function exists(key:T)
		return this.exists(key);

	public inline function iterator():Iterator<T>
		return this.keys();

	public inline function toString():String
		return this.toString();

	@:to static inline function toStringMap<T:String>(t:IMap<T, Bool>):StringMap<Bool>
		return new StringMap<Bool>();

	@:to static inline function toIntMap<T:Int>(t:IMap<T, Bool>):IntMap<Bool>
		return new IntMap<Bool>();

	@:to static inline function toEnumValueMapMap<T:EnumValue>(t:IMap<T, Bool>):EnumValueMap<T, Bool>
		return new EnumValueMap<T, Bool>();

	@:to static inline function toObjectMap<T:{}>(t:IMap<T, Bool>):ObjectMap<T, Bool>
		return new ObjectMap<T, Bool>();
}
