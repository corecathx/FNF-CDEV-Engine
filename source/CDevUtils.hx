package;

import flixel.math.FlxMath;
import openfl.Assets;
import flixel.FlxG;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class CDevUtils
{
	/**
	 * boundshit
	 */
	public function new()
		{
		}
	public function bound(toConvert:Float, min:Float, max:Float):Float
	{
		return FlxMath.bound(toConvert, min, max); //ye
	}

	public function fileIsExist(key:String, type:AssetType, ?library:String)
		{
			if(OpenFlAssets.exists(Paths.getPath(key, type, library))) {
				return true;
			}
			return false;
		}

	public function cacheUISounds() {
        if(!Assets.cache.hasSound(Paths.sound('cancelMenu', 'preload')))
            {
			    FlxG.sound.cache(Paths.sound('cancelMenu', 'preload'));
		    }

        if(!Assets.cache.hasSound(Paths.sound('scrollMenu', 'preload')))
            {
                FlxG.sound.cache(Paths.sound('scrollMenu', 'preload'));
            }
        if(!Assets.cache.hasSound(Paths.sound('confirmMenu', 'preload')))
            {
                FlxG.sound.cache(Paths.sound('confirmMenu', 'preload'));
            }
    }
	/**
	 * Caching sounds. just input the filename, and the library.
	 */
	public function doSoundCaching(sound:String, ?library:String = null):Void {
		if(!Assets.cache.hasSound(Paths.sound(sound, library)))
            {
			    FlxG.sound.cache(Paths.sound(sound, library));
		    }
	}

	/**
	 * Music Caching
	 */
    public function doMusicCaching(musicPath:String) {
        if(!Assets.cache.hasSound(Paths.inst(musicPath)))
            {
			    FlxG.sound.cache(Paths.inst(musicPath));
		    }
    }

}
