package game.song;

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

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = null;

		#if ALLOW_MODS
		var modFile:String = game.Paths.modJson(folder + '/' + jsonInput);
		if (FileSystem.exists(modFile))
		{
			rawJson = File.getContent(modFile).trim();
		}
		#end

		if (rawJson == null)
		{
			#if ALLOW_MODS
			rawJson = File.getContent(game.Paths.json(folder + '/' + jsonInput)).trim();
			#else
			rawJson = Assets.getText(game.Paths.json(folder + '/' + jsonInput)).trim();
			#end
		}
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
