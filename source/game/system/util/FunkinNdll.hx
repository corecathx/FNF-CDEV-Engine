package game.system.util;


class FunkinNdll {
	public static function load(path:String, name:String, args:Int, lazy:Bool){
		trace("Trying to load NDLL: " + path);
		var funk = lime.system.CFFI.load(path,name,args, lazy);
		if (funk == null) {
			trace("it's FUNKIN null.");
			funk = () -> {};
		}

		return funk;
	}
}