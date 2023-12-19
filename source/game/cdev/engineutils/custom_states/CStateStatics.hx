package game.cdev.engineutils.custom_states;

//could have just used map instead of this
class CStateStatics
{
	public static var statics:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var mod:String = "";

	public static function get(key:String)
	{
		if (!statics.exists(key))
			return null;
		return statics.get(key);
	}

	public static function set(key:String, val:Dynamic)
	{
		return statics.set(key, val);
	}

	public static function exists(key:String)
	{
		return statics.exists(key);
	}

	public static function __RESET()
	{
		statics.clear();
		mod = "";
	}
}