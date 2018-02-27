/*
 * Copyright (c) 2018 Ubimate.com and Ub1 contributors.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package ub1.util;

import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.EnumValueMap;
import haxe.Constraints.IMap;

@:multiType(@:followWithAbstracts K)
abstract Set<T>(IMap<T,Bool>) {

	public function new();
	public inline function add(key:T) this.set(key, true);
	public inline function remove(key:T) return this.remove(key);
	public inline function exists(key:T) return this.exists(key);
	public inline function keys():Iterator<T> return this.keys();
	public inline function toString():String return this.toString();
	@:to static inline function toStringMap<T:String>(t:IMap<T,Bool>)
	:StringMap<Bool> return new StringMap<Bool>();
	@:to static inline function toIntMap<T:Int>(t:IMap<T,Bool>)
	:IntMap<Bool> return new IntMap<Bool>();
	@:to static inline function toEnumValueMapMap<T:EnumValue>(t:IMap<T,Bool>)
	:EnumValueMap<T,Bool> return new EnumValueMap<T, Bool>();
	@:to static inline function toObjectMap<T:{ }>(t:IMap<T,Bool>)
	:ObjectMap<T,Bool> return new ObjectMap<T, Bool>();

}
