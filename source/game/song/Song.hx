package game.song;

import game.cdev.song.CDevChart;
import game.objects.ChartEvent.SongEvent;
import game.song.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var songEvents:Array<SongEvent>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var offset:Float;
	var stage:String;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var validScore:Bool;
}

class Song
{
	/**
	 * Loads your chart file.
	 * If there's no .cdc / CDEV Chart File found, it'll try to load the Legacy FNF Chart.
	 * (Expect few stuffs missing, as that Legacy Chart file will be converted to CDEV Chart Format.)
	 * @param json JSON file, ex: `blammed-hard`
	 * @param folder Folder inside the `./assets/data/` folder, ex: `blammed`
	 * @return CDevChart
	 */
	public static function load(json:String, ?folder:String):CDevChart
	{
		var path:String = folder+"/"+json;

		// Checking these paths for the .cdc file
		for (file in [Paths.modCdc(path), Paths.cdc(path)]){
			if (FileSystem.exists(file)){
				var strJson = File.getContent(file).trim();
				if (strJson != null) return parseCDC(strJson);
			}
		}

		// If it doesn't exists, try checking for Legacy FNF Charts (compability)
		var legacy_chart:SwagSong = loadLegacy(json, folder);
		if (legacy_chart != null) {
			Log.warn("Using Legacy FNF Chart, expect few stuffs not working.");
			return CDevConfig.utils.legacy_to_cdev(legacy_chart);
		}

		return null;
	}

	public static function loadLegacy(jsonInput:String, ?folder:String):SwagSong {
		var path:String = folder+"/"+jsonInput;
		var check_paths:Array<String> = [
			Paths.mod_legacy_json(path),
			Paths.legacy_json(path)
		];

		// Checking the paths above for the .json file
		for (file in check_paths){
			if (FileSystem.exists(file)){
				var strJson = File.getContent(file).trim();
				if (strJson != null) return parseJSON(strJson);
			}
		}
		return null;
	}

	public static function parseCDC(rawJson:String):CDevChart 
		return cast Json.parse(rawJson);

	public static function parseJSON(rawJson:String):SwagSong
		return cast Json.parse(rawJson).song;
}
