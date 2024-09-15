package cdev.backend;

import lime.media.vorbis.VorbisFile;
import lime.media.AudioBuffer;
import sys.io.File;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;

import flixel.graphics.FlxGraphic;

import sys.FileSystem;

/**
 * Helper class for accessing game assets like images, fonts, and audio.
 */
class Assets {
    /** Path to asset folders, modify only if necessary. **/
    @:noCompletion public inline static var _ASSET_PATH:String = "./assets";

    @:noCompletion inline public static var _FONT_PATH:String  = '$_ASSET_PATH/fonts';
    @:noCompletion inline public static var _IMAGE_PATH:String = '$_ASSET_PATH/images';
    @:noCompletion inline public static var _SOUND_PATH:String = '$_ASSET_PATH/sounds';

	@:noCompletion inline public static var _SONG_PATH:String  = '$_ASSET_PATH/songs';

    // Trackers for loaded assets. //
	public static var loaded_images:Map<String, FlxGraphic> = new Map();
	public static var loaded_sounds:Map<String, Sound> = new Map();

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
	public static function image(file:String):FlxGraphic {
        var path:String = '$_IMAGE_PATH/$file.png';

        if (!FileSystem.exists(path))
            return null;

        if (loaded_images.exists(file))
            return loaded_images.get(file);

        var newBitmap:BitmapData = BitmapData.fromFile(path);
        var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, file);
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
	public static function sparrowAtlas(file:String):FlxAtlasFrames {
		inline function failed(message:String) {
			trace(message);
			return null;
		}
		var graphic:FlxGraphic = image(file);
		if (graphic == null) 
			failed("Graphic is null.");

		var xmlPath:String = '$_IMAGE_PATH/$file.xml';
		if (!FileSystem.exists(xmlPath)) 
			failed("XML couldn't be found.");

		var xml:String = File.getContent('$_IMAGE_PATH/$file.xml');
		if (xml.length == 0) 
			failed("XML is invalid.");

		return FlxAtlasFrames.fromSparrow(graphic,xml);
	}

    /**
	 * Returns a sound file
	 * @param path Sound's file name (without extension)
	 * @return Sound
	 */
	inline public static function sound(name:String):Sound return _sound_file('$_SOUND_PATH/$name.ogg');

	/**
	 * [INTERNAL] Loads a sound file
	 * @param path Path to the sound file
	 * @return Sound
	 */
	public static function _sound_file(path:String):Sound {
		if (!FileSystem.exists(path))
			return null;

		if (!loaded_sounds.exists(path))
			loaded_sounds.set(path, Sound.fromAudioBuffer(AudioBuffer.fromVorbisFile(VorbisFile.fromFile(path))));

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
