package game.backend;


import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OFLAssets;

import flixel.graphics.FlxGraphic;

/**
 * W.I.P Paths Rewrite.
 */
class Paths {
    /**
     * Misc Section
     */
    inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	public static var defaultLibraries:Array<String> = ["preload","default"];
    public static var currentLibrary:String = "preload";

    /**
     * Libraries Section
     */
    public static var path = {
        preload: "assets/",

    }

    /**
     * Mods Section
     */
    
    /** Current Loaded Mod / Highest Priority Mod. **/
    public static var currentMod:String = '';
    /** List of every loaded mods. **/
    public static var curModDir:Array<String> = [];

	/**
	 * Caching Section
	 */

	/** Contains every cached / loaded images in-game. **/
    public static var loadedImages:Map<String, FlxGraphic> = [];
    /** Contains every cached / loaded sounds in-game. **/
    public static var loadedSounds:Map<String, Sound> = [];
    
    /**
     * Public Functions Section
     */
    
    /**
     * Returns File.
     * @param file File Name
     * @param type File Type
     * @param library Library.
     * @return return getLibPath(file,type,library)
     */
    public static inline function file(file:String, type:AssetType = TEXT, ?library:String) 
        return getLibPath(file,type,library);

    /**
     * Returns Text File from ./assets/data/texts/ folder.
     * @param key Text filename (without extension)
     * @param library Library
     * @return return getAssetPath('data/texts/$key.txt', TEXT, library)
     */
    public static inline function txt(key:String, ?library:String)
        return getAssetPath('data/texts/$key.txt', TEXT, library); 

    public static inline function dialogTxt(key:String, ?library:String)
        return getAssetPath('data/texts/$key.txt', TEXT, library); 
    


    /**
     * Internal Section
     */

    /**
     * Returns the Asset's path to be used in game, starts on the root of the library.
     * @param file File name.
     * @param type Asset Type.
     * @param library Library.
     */
    public static function getAssetPath(file:String, type:AssetType, ?library:Null<String> = null):String {
        if (library != null) 
            return getLibPath(file, library);

        if (currentLibrary != "") {
            var libPath:String = _libraryPath(file, currentLibrary);
            if (OFLAssets.exists(libPath, type))
                return libPath;

            // Checking for shared if it exists.
			libPath = _libraryPath(file, "shared");
			if (OFLAssets.exists(libPath, type))
				return libPath;
        }

        return _preloadPath(file);
    }

    public static function getLibPath(file:String, ?library:Null<String> = null) {
        if (library == null) 
            library = defaultLibrary;

        return (defaultLibraries.contains(library) ? _preloadPath(file) : _libraryPath(file, library));
    }

    public static function _preloadPath(file:String) return 'assets/$file';

    public static function _libraryPath(file:String, library:String) return '$library:assets/$library/$file';

}