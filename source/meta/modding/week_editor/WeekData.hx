package meta.modding.week_editor;

import game.cdev.CDevMods.ModFile;
import game.Paths;

import openfl.utils.Assets as OFLAssets;

import haxe.Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef WeekFile =
{
	var weekTxtImgPath:String;
	var weekName:String;
	var weekCharacters:Array<String>; // [dad,bf,gf]
	var tracks:Array<String>; // [1,2,3];

	// this thing is only available for
	// version 0.1.3 and above.
	var weekDifficulties:Array<String>;
	var freeplaySongs:Array<FreeplaySong>;
	// this variable is not used to hiding the freeplay selection on main menu, it's used to hide the songs in freeplay.
	var disableFreeplay:Bool;
	var charSetting:Array<WeekChar>;
}

typedef FreeplaySong =
{
	var song:String;
	var character:String;
	var bpm:Float; // incase you want a custom bpm instead of loading the bpm from the chart file.
	var colors:Array<Int>; // rgb
}

typedef WeekChar =
{
	var position:Array<Float>;
	var scale:Float;
	var flipX:Bool;
}

typedef StoryData = {
    var data:WeekFile;
    var mod:String;
}

class WeekData
{
    public static var loadedWeeks:Array<StoryData> = [];

    #if !desktop
    public static var weekCount:Int = 8;
    #end

    public static function loadWeeks():Void
    {
        loadedWeeks = [];

        var theFiles:Array<StoryData> = [];
        var allowDefSongs = true;

        if (CDevConfig.utils.isPriorityMod()) {
            Paths.currentMod = CDevConfig.utils.isPriorityMod(true);
            var data:ModFile = Paths.modData();
            if (data != null && Reflect.hasField(data, "disable_base_game")) {
                allowDefSongs = false;
            }
        }

        loadWeekFileFromPath("./assets/data/weeks/", "BASEFNF", theFiles, allowDefSongs);
        
        for (mod in Paths.curModDir) {
            var modPath = Paths.mods(mod + '/data/weeks/');
            if (FileSystem.isDirectory(modPath))
                loadWeekFileFromPath(modPath, mod, theFiles, true);
        }

        loadedWeeks = theFiles;
    }

    public static function loadWeekFileFromPath(path:String, modName:String, theFiles:Array<StoryData>, allowLoad:Bool):Void {
        if (!allowLoad) return;

        var weekFiles:Array<String> = FileSystem.readDirectory(path);
        for (file in weekFiles) {
            if (!file.endsWith(".json")) continue;
			var path:String = path + file;
			var rawJson:String = File.getContent(path);

			if (rawJson.length == 0) continue;
			var json:WeekFile = cast Json.parse(rawJson);
			if (json == null) continue;
			theFiles.push({data: json, mod: modName});
        }
    }
}

