package meta.modding.week_editor;

import game.cdev.CDevMods.ModFile;
import game.Paths;
import haxe.Json;
import lime.utils.Assets;
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

class WeekData
{
	public static var loadedWeeks:Array<Dynamic> = []; // weekFile, modName

	public function new()
	{
	}

	public static function loadWeeks()
	{
        loadedWeeks = [];

		var allowDefSongs = true;
		if (CDevConfig.utils.isPriorityMod())
		{
			Paths.currentMod = CDevConfig.utils.isPriorityMod(true);
			var data:ModFile = Paths.modData();
			if (data != null)
			{
				if (Reflect.hasField(data, "disable_base_game"))
				{
					allowDefSongs = !data.disable_base_game;
				}
			}
		}
		var pathraw = "assets/data/weeks/";
		var direct:Array<String> = FileSystem.readDirectory(pathraw);

		if (allowDefSongs) for (i in 0...direct.length)
		{
			if (direct[i].endsWith(".json")){
				var pathJson:String = pathraw+direct[i];
				trace(pathraw + " - " + i);

				var crapJSON = null;
				if (FileSystem.exists(pathJson))
					crapJSON = File.getContent(pathJson);

				var json:WeekFile = null;
				if (crapJSON != null) json = cast Json.parse(crapJSON);

				if (json != null) loadedWeeks.push([json, 'BASEFNF']);
			}
		}

		for (mod in 0...Paths.curModDir.length)
		{
			var path:String = Paths.mods(Paths.curModDir[mod] + '/data/weeks/');
			trace(path);
			var weekFiles:Array<String> = [];

			if (FileSystem.isDirectory(path))
			{
				weekFiles = FileSystem.readDirectory(path);
				trace(weekFiles);
				var crapJSON = null;

				for (json in 0...weekFiles.length)
				{
					#if ALLOW_MODS
					var file:String = path + weekFiles[json];
					if (FileSystem.exists(file))
						crapJSON = File.getContent(file);
					#end

					var json:WeekFile = cast Json.parse(crapJSON);
					var gugugaga:Array<Dynamic> = [json, Paths.curModDir[mod]];
					if (crapJSON != null)
						loadedWeeks.push(gugugaga);
				}
			}
		}
	}
}
