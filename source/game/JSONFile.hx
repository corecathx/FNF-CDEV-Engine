package game;

import game.song.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef JSONDefs =
{
	var song:String;
	var notes:Array<SwagSection>;
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

class JSONFile
{
	public var song:String;
	public var notes:Array<SwagSection>;
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
    public static function loadJSON(rawJson:String):JSONDefs
    {
        var swagShit:JSONDefs = cast Json.parse(rawJson).song;
        swagShit.validScore = true;
        return swagShit;
    }
}
