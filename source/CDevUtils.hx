package;

import flixel.math.FlxMath;

class CDevUtils
{
	public static function getLerp(toConvert:Float, min:Float, max:Float):Float
	{
		return FlxMath.bound(toConvert, min, max); //ye
	}
}
