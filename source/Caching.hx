package;

import openfl.Assets;
import flixel.FlxG;

class Caching
{
    public static function cacheUISounds() {
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
    //sound caching
	public static function doSoundCaching(sound:String, ?library:String = null):Void {
		if(!Assets.cache.hasSound(Paths.sound(sound, library)))
            {
			    FlxG.sound.cache(Paths.sound(sound, library));
		    }
	}

    //music caching
    public static function doMusicCaching(musicPath:String) {
        if(!Assets.cache.hasSound(Paths.inst(musicPath)))
            {
			    FlxG.sound.cache(Paths.inst(musicPath));
		    }
    }


}