package cdev;

import lime.system.Clipboard;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import sys.FileSystem;
import flixel.math.FlxMath;
import openfl.Assets;
import flixel.FlxG;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import game.Paths;

using StringTools;

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
		return FlxMath.bound(toConvert, min, max); // ye
	}

	public function pasteFunction(prefix:String = ''):String
	{
		if (prefix.toLowerCase().endsWith('v'))
			prefix = prefix.substring(0, prefix.length - 1);

		var txt:String = prefix + Clipboard.text.replace('\n', '');
		return txt;
	}

	// hi :) credit: Shadow Mario#9396
	public function fileIsExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if ALLOW_MODS
		for (i in 0...Paths.curModDir.length)
		{
			if (FileSystem.exists(Paths.mods(Paths.curModDir[i] + '/' + key)) || FileSystem.exists(Paths.mods(key)))
				return true;
		}
		#end

		if (OpenFlAssets.exists(Paths.getPath(key, type)))
		{
			return true;
		}
		return false;
	}

	public function getColor(sprite:FlxSprite):FlxColor
	{
		var color:Map<Int, Int> = [];

		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var pixelColor:Int = sprite.pixels.getPixel32(col, row);
				if (pixelColor != 0)
				{
					if (color.exists(pixelColor))
					{
						color[pixelColor] = color[pixelColor] + 1;
					}
					else if (color[pixelColor] != 13520687 - (2 * 13520687))
					{
						color[pixelColor] = 1;
					}
				}
			}
		}

		color[FlxColor.BLACK] = 0;

		var maxCount = 0;
		var maxKey:Int = 0;

		for (key in color.keys())
			if (color[key] >= maxCount)
			{
				maxCount = color[key];
				maxKey = key;
			}

		return FlxColor.fromInt(maxKey);
	}

	public function cacheUISounds()
	{
		if (!Assets.cache.hasSound(Paths.sound('cancelMenu', 'preload')))
		{
			FlxG.sound.cache(Paths.sound('cancelMenu', 'preload'));
		}

		if (!Assets.cache.hasSound(Paths.sound('scrollMenu', 'preload')))
		{
			FlxG.sound.cache(Paths.sound('scrollMenu', 'preload'));
		}
		if (!Assets.cache.hasSound(Paths.sound('confirmMenu', 'preload')))
		{
			FlxG.sound.cache(Paths.sound('confirmMenu', 'preload'));
		}
	}

	public function openURL(url:String){
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	/**
	 * Caching sounds. just input the filename, and the library.
	 */
	public function doSoundCaching(sound:String, ?library:String = null):Void
	{
		if (!Assets.cache.hasSound(Paths.sound(sound, library)))
		{
			FlxG.sound.cache(Paths.sound(sound, library));
		}
	}

	/**
	 * Music Caching
	 */
	public function doMusicCaching(musicPath:String)
	{
		if (!Assets.cache.hasSound(Paths.inst(musicPath)))
		{
			FlxG.sound.cache(Paths.inst(musicPath));
		}
	}
}
