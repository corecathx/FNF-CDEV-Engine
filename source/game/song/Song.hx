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
	public var song:String;
	public var notes:Array<SwagSection>;
	public var songEvents:Array<SongEvent>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var offset:Float = 0;
	public var stage:String = 'stage';

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function load(jsonInput:String, ?folder:String):CDevChart
	{
		var rawJson = null;
		var curPath:String = Paths.modCdc(folder+"/"+jsonInput); // Mod Folder

		if (FileSystem.exists(curPath))
			rawJson = File.getContent(curPath).trim();
		if (rawJson != null) return parseJSONshit(rawJson);

		curPath = Paths.cdc(folder + '/' + jsonInput); // Assets Folder
		if (FileSystem.exists(curPath))
			rawJson = File.getContent(curPath).trim();

		if (rawJson != null) return parseJSONshit(rawJson);
		return null;
	}

	public static function parseJSONshit(rawJson:String):CDevChart
	{
		var swagShit:CDevChart = cast Json.parse(rawJson);
		return swagShit;
	}
}
