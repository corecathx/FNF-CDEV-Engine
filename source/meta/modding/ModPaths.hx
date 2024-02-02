package meta.modding;

import game.cdev.log.GameLog;
import game.system.FunkinBitmap;
import lime.graphics.Image;
import meta.states.PlayState;
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
	public var mod:String; //my dumbass sets this to private
	var cantFind:Array<String> = [];

	#if (haxe >= "4.0.0")
	public static var modImagesLoaded:Map<String, Bool> = new Map();
	public static var modSoundsLoaded:Map<String, Sound> = new Map();
	#else
	public static var modImagesLoaded:Map<String, Bool> = new Map<String, Bool>();
	public static var modSoundsLoaded:Map<String, Sound> = new Map < String, Bool();
	#end

	public function new(mod:String)
	{
		this.mod = mod;
	}

	public function font(font:String)
	{
		return currentModFolder('data/fonts/$font.ttf');
	}

	public function xml(key:String):String
	{
		var e = currentModFolder('images/$key.xml');
		if (FileSystem.exists(e)) return e;

		e = Paths.xml(e);
		if (FileSystem.exists(e)) return e; 

		return currentModFolder('images/$key.xml');
	}

	public function addCustomGraphic(key:String):FlxGraphic
	{
		var path:String = 'cdev-mods/$mod/images/$key.png';
		if (FileSystem.exists(path))
		{
			var data:Image = Image.fromBytes(File.getBytes(path));
			var newBitmap:BitmapData = null;

			if (CDevConfig.saveData.gpuBitmap)
			{
				newBitmap = new FunkinBitmap(0, 0, true, 0);
				@:privateAccess newBitmap.__fromImage(data);
			}
			else
			{
				newBitmap = BitmapData.fromImage(data);
			}

			var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
			newGraphic.persist = true;
			FlxG.bitmap.addGraphic(newGraphic);
			modImagesLoaded.set(key, true);
			return FlxG.bitmap.get(key);
		}
		return null;
	}

	#if sys
	inline static private function returnAudioFile(file:String):Sound
	{
		if (FileSystem.exists(file))
		{
			if (!modSoundsLoaded.exists(file))
			{
				modSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return modSoundsLoaded.get(file);
		}
		return null;
	}
	#end

	public function soundRandom(key:String, min:Int, max:Int)
	{
		var ranVal = FlxG.random.int(min, max);
		return sound('$key$ranVal');
	}

	public function sound(key:String):Dynamic
	{
		var e:String = key;
		if (e.endsWith(".ogg")) e = e.replace(".ogg", "");
		var ogAssetPath:String = currentModFolder('sound/$e.ogg');

		var snd:Dynamic = returnAudioFile(ogAssetPath);
		if (snd != null) return snd; 

		snd = Paths.sound(e);
		if (snd != null) return snd;
		
		if (!cantFind.contains(ogAssetPath)){
			GameLog.warn("Can't find audio (sound) asset: " + ogAssetPath);
			cantFind.push(ogAssetPath);
		}
		return null;
	}

	public function music(key:String):Dynamic
	{
		var e:String = key;
		if (e.endsWith(".ogg")) e = e.replace(".ogg", "");
		var ogAssetPath:String = currentModFolder('music/$e.ogg');

		var snd:Dynamic = returnAudioFile(ogAssetPath);
		if (snd != null) return snd; 

		snd = Paths.music(e);
		if (snd != null) return snd;
		
		if (!cantFind.contains(ogAssetPath)){
			GameLog.warn("Can't find audio (music) asset: " + ogAssetPath);
			cantFind.push(ogAssetPath);
		}
		return null;
	}

	public function image(key:String):Dynamic
	{
		var imageToReturn:Dynamic = addCustomGraphic(key);
		if (imageToReturn != null) return imageToReturn;

		imageToReturn = Paths.image(key);
		if (imageToReturn != null) return imageToReturn;

		GameLog.warn('Error while loading "$key" image asset, returning null value.');
		return currentModFolder('images/$key.png');
	}

	public function video(key:String):String
	{
		return currentModFolder('videos/$key.mp4');
	}

	public function text(key:String):String
	{
		return File.getContent(currentModFolder(key + ".txt"));
	}

	public function frag(key:String):String
	{
		return File.getContent(currentModFolder("shaders/" + key + '.frag'));
	}

	public function vert(key:String):String
	{
		return File.getContent(currentModFolder("shaders/" + key + '.vert'));
	}

	public function getFile(key:String, type:AssetType):Any
	{
		return LimeAssets.getAsset(key, type, false);
	}

	public function getSparrowAtlas(key:String):FlxAtlasFrames
	{
		// trace(File.getContent(xml(key)));
		return FlxAtlasFrames.fromSparrow(image(key), File.getContent(xml(key)));
	}

	public function currentModFolder(key:String)
	{
		var checkFile:String = 'cdev-mods/' + mod + '/' + key;
		if (FileSystem.exists(checkFile))
			return checkFile;
		return 'cdev-mods/$mod/' + key;
	}

	/*
		WIP
	 */
	public function getFromAssets(key:String, type:String, fromPreload:Bool)
	{
		var lib:String = (fromPreload ? "preload" : "shared");
		switch (type.toLowerCase()){
			case "sound":
				return Paths.sound(key, lib);
			case "image":
				return Paths.image(key, lib);
			case "music":
				return Paths.music(key, lib);
			default:
				GameLog.warn('getFromAssets($key,$type,$fromPreload): Your "AssetType" should be "sound" / "image" / "music". $type is invalid.');
				return null;
		}
		return null;
	}
}
