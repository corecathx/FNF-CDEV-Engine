package modding;

import openfl.utils.Assets;
import openfl.display.Bitmap;
import lime.utils.AssetType;
import flixel.graphics.FlxGraphic;
import game.Paths;
import lime.utils.Assets as LimeAssets;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;
import flixel.FlxG;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class ModPaths
{
	private var mod:String;

	#if (haxe >= "4.0.0")
	public static var modImagesLoaded:Map<String, Bool> = new Map();
	#else
	public static var modImagesLoaded:Map<String, Bool> = new Map<String, Bool>();
	#end

	public function new(mod:String)
	{
		this.mod = mod;
	}

	public function font(font:String) {
        return currentModFolder('data/fonts/$font.ttf');
    }

	public function xml(key:String):String
	{
		return currentModFolder('images/$key.xml');
	}

	public function addCustomGraphic(key:String):FlxGraphic
	{
		if (FileSystem.exists('cdev-mods/$mod/images/$key.png'))
		{
			trace('exist yes');
			var newBitmap:BitmapData = BitmapData.fromFile('cdev-mods/$mod/images/$key.png');
			trace(newBitmap);
			var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
			newGraphic.persist = true;
			FlxG.bitmap.addGraphic(newGraphic);
			modImagesLoaded.set(key, true);
			return FlxG.bitmap.get(key);
		}
		return null;
	}

	public function soundRandom(key:String, min:Int, max:Int)
	{
		var ranVal = FlxG.random.int(min, max);
		return sound('$key$ranVal');
	}

	public function sound(key:String)
	{
		return currentModFolder('sounds/$key');
	}

	public function music(key:String)
	{
		return currentModFolder('music/$key');
	}

	public function image(key:String):Dynamic
	{
		var imageToReturn:FlxGraphic = addCustomGraphic(key);
		if (imageToReturn != null){
			trace('imagetoreturn not null');
			return imageToReturn;

		}
			
		return currentModFolder('images/$key.png');
	}

	public function getFile(key:String, type:AssetType):Any
	{
		return LimeAssets.getAsset(key, type, false);
	}

	public function getSparrowAtlas(key:String):FlxAtlasFrames
	{
		//trace(File.getContent(xml(key)));
		return FlxAtlasFrames.fromSparrow(image(key), File.getContent(xml(key)));
	}

	public function currentModFolder(key:String)
	{
		var checkFile:String = 'cdev-mods/' + mod + '/' + key;
		if (FileSystem.exists(checkFile))
			return checkFile;
		return 'cdev-mods/$mod/' + key;
	}
}
