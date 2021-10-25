* wraps existing DOM w/ a tree of ReScope objects
* dynamic expressions are marked by `[[` and `]]`
* wholly dynamic attributes can be written as `attribute=[[...]]`
* unprefixed, static attributes are plain DOM attributes
* standard attributes w/ dynamic content generate `a_<name>` values
* `:`-prefixed attributes are values (save for reserved ones)
* reserved attributes:
	* `:aka`
* `:c_`-prefixed attributes are class values
* `:s_`-prefixed attributes are style values

haxe version: 4.1.x

## MISC
* [jQueryExtern](https://lib.haxe.org/p/jQueryExtern/)
* [IntersectionObserver Polyfill](https://github.com/que-etc/intersection-observer-polyfill)
	* needed for built-in value `isVisible`

## TODO
* //reactivity
* //elements
* //data binding
* //replication
* //parser
* //preprocessor
* //state transfer
