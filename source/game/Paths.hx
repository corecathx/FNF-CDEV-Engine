package game;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;

import lime.graphics.Image;

import game.system.FunkinBitmap;
import game.cdev.CDevMods.ModFile;

import haxe.Json;

import meta.modding.ModPaths;

import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import flash.media.Sound;

// Used Psych Engine's mods folder framework code.
// Hi Shadow Mario :)
using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	// used on preload and cdev-mods folder
	static public var TEXTS_PATH:String = 'texts/';
	static public var CHARTS_PATH:String = 'charts/';
	static public var CHARACTERS_PATH:String = 'characters/';
	static public var ICONS_PATH:String = 'icons/';
	static public var STAGES_PATH:String = 'stages/';
	static public var WEEK_PATH:String = 'weeks/';

	static var currentLevel:String;
	static public var curModDir:Array<String> = [];
	static public var currentMod:String = '';
	public static var modsPath:String = 'cdev-mods';

	#if (haxe >= "4.0.0")
	public static var customImagesLoaded:Map<String, Bool> = new Map();
	public static var customSoundsLoaded:Map<String, Sound> = new Map();
	#else
	public static var customImagesLoaded:Map<String, Bool> = new Map<String, Bool>();
	public static var customSoundsLoaded:Map<String, Sound> = new Map<String, Sound>();
	#end

	public static function destroyLoadedImages(ignoreCheck:Bool = false)
	{
		//if (!ignoreCheck && FlxGraphic.defaultPersist)
		//	return; // If there's 20+ images loaded, do a cleanup just for preventing a crash

		for (key in customImagesLoaded.keys())
		{
			var graphic:FlxGraphic = FlxG.bitmap.get(key);
			if (graphic != null)
			{
				graphic.bitmap.dispose();
				graphic.destroy();
				FlxG.bitmap.removeByKey(key);
			}
		}

		for (key in ModPaths.modImagesLoaded.keys())
		{
			var graphic:FlxGraphic = FlxG.bitmap.get(key);
			if (graphic != null)
			{
				graphic.bitmap.dispose();
				graphic.destroy();
				FlxG.bitmap.removeByKey(key);
			}
		}
		ModPaths.modImagesLoaded.clear();
		Paths.customImagesLoaded.clear();

		openfl.utils.Assets.cache.clear();
	}

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	/*public static function getPath(file:String, type:AssetType, library:Null<String>)
		{
			if (library != null)
				return getLibraryPath(file, library);

			if (currentLevel != null)
			{
				var levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;

				levelPath = getLibraryPathForce(file, "shared");
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			return getPreloadPath(file);
	}*/
	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static public function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$TEXTS_PATH$key.txt', TEXT, library);
	}

	inline static public function dialogTxt(key:String, ?library:String)
	{
		return getPath('data/$CHARTS_PATH$key.txt', TEXT, library);
	}

	inline static public function char(key:String, ?library:String)
	{
		return getPath('data/$CHARACTERS_PATH$key.json', TEXT, library);
	}

	inline static public function week(key:String)
	{
		return getPath('data/$WEEK_PATH$key.json', TEXT, 'preload');
	}

	inline static public function stage(key:String)
	{
		return getPath('data/$STAGES_PATH$key.json', TEXT, 'preload');
	}

	inline static public function icon(key:String, ?library:String)
	{
		return getPath('images/$ICONS_PATH$key-icon.png', IMAGE, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$CHARTS_PATH$key.json', TEXT, library);
	}

	inline static public function chartPath(key:String)
	{
		return 'assets/data/$CHARTS_PATH$key';
	}

	static public function sound(key:String, ?library:String):Dynamic
	{
		#if ALLOW_MODS
		var soundToReturn:Sound = returnSongFile(modSounds(key));
		if (soundToReturn != null)
			return soundToReturn;
		#end
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		#if ALLOW_MODS
		var musicToReturn:Sound = returnSongFile(modMusic(key));
		if (musicToReturn != null)
			return musicToReturn;
		#end
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):Any
	{
		#if sys
		var file:Sound = returnSongFile(modSongs(song.toLowerCase().replace(' ', '-') + '/Voices'));
		if (file != null)
		{
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String):Any
	{
		#if sys
		var file:Sound = returnSongFile(modSongs(song.toLowerCase().replace(' ', '-') + '/Inst'));
		if (file != null)
		{
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Inst.$SOUND_EXT';
	}

	// hi :) credit: Shadow Mario#9396
	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if ALLOW_MODS
		if (FileSystem.exists(mods(currentMod + '/' + key)) || FileSystem.exists(mods(key)))
			return true;
		#end

		if (OpenFlAssets.exists(Paths.getPath(key, type)))
		{
			return true;
		}
		return false;
	}

	#if sys
	inline static private function returnSongFile(file:String):Sound
	{
		if (FileSystem.exists(file))
		{
			if (!customSoundsLoaded.exists(file))
			{
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		return null;
	}
	#end

	inline static public function image(key:String, ?library:String):Dynamic
	{
		#if ALLOW_MODS
		var imageToReturn:FlxGraphic = addCustomGraphic(key);
		if (imageToReturn != null)
			return imageToReturn;
		#end
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function strumConfig(key:String, ?library:String)
	{
		#if ALLOW_MODS
		var modjsond:String = modStrumConf(key);
		trace("conf exist: " + FileSystem.exists(modjsond));
		if (FileSystem.exists(modjsond))
			return modjsond;
		#end
		trace(getPath('images/notes/$key.json', TEXT, library));
		return getPath('images/notes/$key.json', TEXT, library);
	}

	#if USE_VIDEOS
	inline static public function video(key:String)
	{
		return "assets/videos/" + key + ".mp4";
	}
	#end

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		// trace(imageLoaded);
		var xmlExists:Bool = false;
		if (FileSystem.exists(modXml(key)))
		{
			xmlExists = true;
		}

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)),
			(xmlExists ? File.getContent(modXml(key)) : file('images/$key.xml', TEXT, library)));
		// return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		var txtExists:Bool = false;
		if (FileSystem.exists(modText(key)))
		{
			txtExists = true;
		}

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)),
			(txtExists ? File.getContent(modText(key)) : file('images/$key.txt', TEXT, library)));
		// return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	#if sys
	// hi shadow mario.
	static public function addCustomGraphic(key:String):FlxGraphic
	{
		if (FileSystem.exists(modImages(key)))
		{
			if (!customImagesLoaded.exists(key))
			{
				var data = Image.fromFile(modImages(key));
				var newBitmap:BitmapData = BitmapData.fromImage(data);

				if (CDevConfig.saveData.gpuBitmap)
				{
					newBitmap = new FunkinBitmap(0, 0, true, 0);
					@:privateAccess newBitmap.__fromImage(data);
				}

				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
				newGraphic.persist = true;
				FlxG.bitmap.addGraphic(newGraphic);
				customImagesLoaded.set(key, true);
			}
			return FlxG.bitmap.get(key);
		}
		return null;
	}

	inline static public function mods(key:String = '')
	{
		return 'cdev-mods/' + key;
	}

	inline static public function cdModsFile(key:String = ''):String
	{
		return 'cdev-mods/' + key + '/' + 'mod.json';
	}

	inline static public function createModFolder(modFolderName:String = '')
	{
		// FileSystem.createDirectory('cdev-mods/$modFolderName');
		var path:String = 'cdev-mods/$modFolderName/';
		var childrens:Array<String> = [];
		var dumbFolders:Array<String> = [
			'data', // DATA FOLDER
			'data/charts',
			'data/characters',
			'data/stages',
			'data/weeks',
			'data/fonts',
			'images', // IMAGES FOLDER
			'images/characters',
			'images/icons/',
			'images/storymenu',
			'images/storymenu/difficulty',
			'images/credits',
			'images/notes',
			'ui',
			'events',
			'notes',
			'scripts',
			'scripts/modules',
			'shaders',
			#if USE_VIDEOS 'videos', #end
			'sounds',
			'music',
			'songs'
		];

		// path, filename, data
		// might finish this later.
		var txtFiles:Array<Dynamic> = [
			[
				'',
				'credits.txt',
				'--Put your custom credits here\n--Credits should be on this format: Name::Desc::Color::Link\n--Credits title should be on this format: Name\n--"Color" should be on hex format (ex: 0xFF000000, rgba)'
			]
		];
		for (n in dumbFolders)
			childrens.push(path + n);

		for (child in childrens)
			FileSystem.createDirectory(child);

		for (content in txtFiles)
		{
			File.saveContent(path + content[0] + content[1], content[2]);
		}

		File.saveContent(path + 'songList.txt', ''); // prevents crash when installing a mod
	}

	inline static public function modData()
	{
		var p = modFolders("mod.json");
		if (FileSystem.exists(p))
		{
			var f:ModFile = cast Json.parse(File.getContent(p));
			return f;
		}
		trace("cannot find mod data in " + p);
		return null;
	}

	inline static public function modText(key:String)
	{
		return 'cdev-mods/' + key + '.txt';
	}

	inline static public function modJson(key:String)
	{
		return modFolders('data/' + CHARTS_PATH + key + '.json');
	}

	inline static public function modChartPath(key:String)
	{
		// "key" is folder
		return modFolders('data/' + CHARTS_PATH + key);
	}

	inline static public function modStage(key:String)
	{
		return modFolders('data/' + STAGES_PATH + key + '.json');
	}

	inline static public function modStageScript(key:String)
	{
		return modFolders('data/' + STAGES_PATH + key + '.hx');
	}

	inline static public function modWeek(key:String)
	{
		return modFolders('data/' + WEEK_PATH + key + '.json');
	}

	inline static public function modWeekChar(key:String)
	{
		return modFolders('data/' + 'weekcharacters/' + key + '.json');
	}

	inline static public function modImages(key:String)
	{
		return modFolders('images/' + key + '.png');
	}

	inline static public function modImage(key:String, exist:Bool):Dynamic
	{
		if (exist)
		{
			if (!customImagesLoaded.exists(key))
			{
				var newBitmap:BitmapData = BitmapData.fromFile(key);
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
				newGraphic.persist = true;
				FlxG.bitmap.addGraphic(newGraphic);
				customImagesLoaded.set(key, true);
			}
			return FlxG.bitmap.get(key);
		}
		return getPath('images/$key.png', IMAGE, 'shared');
	}

	inline static public function modBackground(mod:String, key:String, a:Bool):Dynamic
	{
		if (a)
		{
			if (!customImagesLoaded.exists(key))
			{
				var newBitmap:BitmapData = BitmapData.fromFile(Paths.modFolders(key + ".png"));
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
				newGraphic.persist = true;
				FlxG.bitmap.addGraphic(newGraphic);
				customImagesLoaded.set(key, true);
			}
			return FlxG.bitmap.get(key);
		}

		return getPath('images/$key.png', IMAGE, 'shared');
	}

	inline static public function modIcon(key:String):Dynamic
	{
		var newBitmap:BitmapData = BitmapData.fromFile(modFolders('images/' + ICONS_PATH + key + '-icon.png'));
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, modFolders('images/' + ICONS_PATH + key + '-icon.png'));
		newGraphic.persist = true;
		FlxG.bitmap.addGraphic(newGraphic);
		customImagesLoaded.set(modFolders('images/' + ICONS_PATH + key + '-icon.png'), true);

		return FlxG.bitmap.get(modFolders('images/' + ICONS_PATH + key + '-icon.png'));
		// return modFolders('images/' + ICONS_PATH + key + '-icon.png');
	}

	inline static public function modChar(key:String)
	{
		// trace(modFolders('data/$CHARACTERS_PATH$key.json'));
		return modFolders('data/$CHARACTERS_PATH$key.json');
	}

	inline static public function modXml(key:String)
	{
		return modFolders('images/' + key + '.xml');
	}

	inline static public function modStrumConf(key:String)
	{
		return modFolders('images/notes/$key.json');
	}

	inline static public function modMusic(key:String)
	{
		return modFolders("music/" + key + "." + SOUND_EXT);
	}

	inline static public function modSounds(key:String)
	{
		return modFolders("sounds/" + key + "." + SOUND_EXT);
	}

	inline static public function modSongs(key:String)
	{
		return modFolders('songs/' + key + '.' + SOUND_EXT);
	}

	static public function modFolders(key:String) // , ?thisMod:Null<String>=null)
	{
		///if (curModDir != null && curModDir.length > 0)
		// {
		//	var checkFile:String = mods(curModDir + '/' + key);
		//	if (FileSystem.exists(checkFile))
		//	{
		//		return checkFile;
		//	}
		// }
		/*if (thisMod != null && thisMod != '')
			{
				var checkFile:String = mods(thisMod + '/' + key);
				if (FileSystem.exists(checkFile))
					return checkFile;
			}
			else */
		{
			if (currentMod != null && currentMod != '')
			{
				var checkFile:String = mods(currentMod + '/' + key);
				if (FileSystem.exists(checkFile))
				{
					return checkFile;
				}
			}
		}

		return 'cdev-mods/' + key; // ok yea, welp.
	}
	#end
}
