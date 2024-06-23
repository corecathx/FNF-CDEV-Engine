package funkin.vis;

class Utils {
    public inline static function log(base:Float, x:Float):Float {
		return Math.log(x) / Math.log(base);
	}

	@:generic
	public inline static function clamp<T:Float>(val:T, min:T, max:T):T {
		return val < min ? min : (val > max ? max : val);
	}

	@:generic
	public inline static function min<T:Float>(x:T, y:T):T
	{
		return x > y ? y : x;
	}
}