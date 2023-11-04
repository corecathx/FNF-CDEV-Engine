
package game;

import game.song.Song.SwagSong;
import flixel.FlxG;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var last_bpm:Float = 100;
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var rawTime:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 20;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;

	public static var fakeCrochet:Float = 0;
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static var usedSongMulti:Bool = false;

	public function new()
	{
	}

	public static function updateBPMBasedOnSongSpeed(curBPM:Float, multipiler:Float)
	{
		bpm = curBPM * multipiler;
		//bpm = Math.round(bpm); //uhm.

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
		checkFakeCrochet(bpm);

		var txt = 'BPM: ' + bpm + "\nCrochet: " + crochet + "\nStep Crochet: " + stepCrochet;
		trace(txt);
	}

	public static function updateSettings() {
		offset = CDevConfig.saveData.offset;
		safeFrames = 20;

		safeZoneOffset = (safeFrames / 60) * 1000;
	}

	public static function checkFakeCrochet(oaoaoa:Float) {
		fakeCrochet = (60 / oaoaoa) * 1000;
	}


	public static function mapBPMChanges(song:SwagSong)//, addToSongBPMTiming:Bool)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);

				//SongBPMTiming.addTiming(songTime/(((60 / curBPM) * 1000)*(totalSteps%4)),curBPM,);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float, ?alsoChangeLast:Bool=false)
	{
		if (alsoChangeLast) last_bpm = newBpm;
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}