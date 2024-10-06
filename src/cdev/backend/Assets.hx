package cdev.backend;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;
import cdev.objects.play.Character.CharacterData;


typedef CharacterAssets = {
	atlas:FlxAtlasFrames,
	icon:FlxGraphic,
	data:CharacterData
}

/**
 * Helper class for accessing game assets like images, fonts, and audio.
 */
class Assets {
    /** Path to asset folders, modify only if necessary. **/
    @:noCompletion public inline static var _ASSET_PATH:String = "./assets";

	@:noCompletion inline public static var _DATA_PATH:String  = '$_ASSET_PATH/data';
	@:noCompletion inline public static var _CHARACTER_PATH:String  = '$_DATA_PATH/characters';

    @:noCompletion inline public static var _FONT_PATH:String  = '$_ASSET_PATH/fonts';
    @:noCompletion inline public static var _IMAGE_PATH:String = '$_ASSET_PATH/images';
    @:noCompletion inline public static var _SOUND_PATH:String = '$_ASSET_PATH/sounds';
    @:noCompletion inline public static var _MUSIC_PATH:String = '$_ASSET_PATH/music';

	@:noCompletion inline public static var _SONG_PATH:String  = '$_ASSET_PATH/songs';

    // Trackers for loaded assets. //
	public static var loaded_images:Map<String, FlxGraphic> = [];
	public static var loaded_sounds:Map<String, Sound> = [];

	public static var loaded_atlases:Map<String, FlxAtlasFrames> = [];

    /** Shortcut to access game fonts. **/
    public static var fonts(default, null):Fonts = new Fonts();

	/**
	 * Loads a font file.
	 * @param name Your font's file name (without .ttf extension)
	 * @return String Your font's path.
	 */
    public inline static function font(name:String) return '$_FONT_PATH/$name.ttf';

    /**
	 * Returns an image file from `./assets/images/`, Returns null if the `path` does not exist.
	 * @param file Image file name
	 * @return FlxGraphic (Warning: might return null)
	 */
	public static function image(file:String, ?customPath:Bool = false, ?gpuTexture:Bool = true):FlxGraphic {
        if (loaded_images.exists(file))
            return loaded_images.get(file);

		var path:String = (customPath ? '$file' : '$_IMAGE_PATH/$file') + ".png";

        if (!FileSystem.exists(path))
            return null;

        var bitmap:BitmapData = BitmapData.fromFile(path);
		@:privateAccess if (gpuTexture)
		{
			/*if (bitmap.__texture == null)
			{
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;*/
		}
        var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
        newGraphic.persist = true;

        var n:FlxGraphic = FlxG.bitmap.addGraphic(newGraphic);
        loaded_images.set(file, n);

        return n;
    }

	/**
	 * Returns Atlas Frames based of `file`'s sparrow atlas XML and PNG file.
	 * @param file Your sparrow atlas filename.
	 * @return FlxAtlasFrames
	 */
	public static function sparrowAtlas(file:String, ?customPath:Bool = false, ?gpuTexture:Bool = true):FlxAtlasFrames {
		inline function failed(message:String) {
			trace(message);
			return null;
		}
		if (loaded_atlases.exists(file))
			return loaded_atlases.get(file);

		trace("Loading new Atlas Frames for: " + file);
		var graphic:FlxGraphic = image(file, customPath, gpuTexture);
		if (graphic == null) 
			failed("Graphic is null.");

		var xmlPath:String = customPath?'$file.xml' : '$_IMAGE_PATH/$file.xml';
		if (!FileSystem.exists(xmlPath)) 
			failed("XML couldn't be found.");

		var xml:String = File.getContent(customPath?'$file.xml':'$_IMAGE_PATH/$file.xml');
		if (xml.length == 0) 
			failed("XML is invalid.");

		loaded_atlases.set(file, FlxAtlasFrames.fromSparrow(graphic,xml));
		return loaded_atlases.get(file);
	}

	/**
	 * Returns character asset files.
	 * @param name Character's name.
	 * @return CharacterAssets
	 */
	public static function character(name:String):CharacterAssets {
		inline function failed(message:String) {
			trace(message);
			return null;
		}
		var path:String = '${_CHARACTER_PATH}/$name';
		trace("Character Path: " + path);
		if (!FileSystem.exists(path) || !FileSystem.isDirectory(path)) 
			failed("Character path is non-existent.");

		var atlas:FlxAtlasFrames = sparrowAtlas('$path/sprites/normal', true);
		if (atlas == null)
			failed("Could not found sparrow atlas for character sprite.");

		var icon:FlxGraphic = image('$path/icon', true);
		if (icon == null)
			failed("Could not found icon.png file.");

		var data:CharacterData = cast Json.parse(File.getContent('$path/config.json'));
		if (data == null) 
			failed("Could not get character configuration data.");

		return {
			atlas: atlas,
			icon: icon,
			data: data,
		}
	}

    /**
	 * Returns a sound file
	 * @param path Sound's file name (without extension)
	 * @return Sound
	 */
	inline public static function sound(name:String):Sound return _sound_file('$_SOUND_PATH/$name.ogg');

	/**
	 * Returns your music file
	 * @param path The music's file name (without extension)
	 * @return Sound
	 */
	inline public static function music(name:String):Sound return _sound_file('$_MUSIC_PATH/$name.ogg');

	/**
	 * [INTERNAL] Loads a sound file
	 * @param path Path to the sound file
	 * @return Sound
	 */
	public static function _sound_file(path:String):Sound {
		if (!FileSystem.exists(path))
			return null;

		if (!loaded_sounds.exists(path))
			loaded_sounds.set(path, Sound.fromFile(path));

		return loaded_sounds.get(path);
	}
}

/**
 * Contains fonts used in the game.
 */
class Fonts {
    public var JETBRAINS(default, null):String = Assets.font("jbm");
    public var VCR(default, null):String = Assets.font("vcr");
    public function new() {}
}
