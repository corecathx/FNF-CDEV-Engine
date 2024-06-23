
package game;

import game.cdev.song.CDevChart;
import game.song.Song.SwagSong;
import flixel.FlxG;

typedef BPMChangeEvent =
{
	var stepTime:Float;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var time_signature:Array<Int> = [4,4];

	public static var last_bpm:Float = 100;
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var rawTime:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var curBeat:Int = 0;
	public static var curStep:Int = 0;

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
		safeFrames = 15;

		safeZoneOffset = (safeFrames / 60) * 1000;
	}

	public static function checkFakeCrochet(oaoaoa:Float) {
		fakeCrochet = (60 / oaoaoa) * 1000;
	}

	public static function changeTimeSignature(beat:Int, step:Int){
		time_signature = [beat,step];
	}

	/**
	 * hurrghh apparently doesn't work
	 * @param song song
	 */
	public static function mapBPMChanges(song:CDevChart) {
		bpmChangeMap = [];

		var current_bpm:Float = song.info.bpm;
		var step_crochet:Float = ((60 / current_bpm) * 1000) / 4;
		var last_changed_time:Float = 0;
		var last_steps:Int = 0;
	
		for (event in song.events) {
			if (event[0] == "Change BPM") {
				var data = { // easier to read, i guess
					time: Std.parseFloat(event[2]),
					new_bpm: Std.parseFloat(event[3])
				};
				if (data.new_bpm == current_bpm) continue; // if it's changing to a same bpm, ignore it
				
				trace("Found BPM Change at " + data.time + " changing to " + data.new_bpm);
				// time and steps passed since last bpm change
				var delta_steps:Int = Math.round((data.time - last_changed_time) / step_crochet);
				last_steps += delta_steps;
				last_changed_time = data.time;
				
				bpmChangeMap.push({ // add it to the array
					stepTime: last_steps,
					songTime: last_changed_time,
					bpm: data.new_bpm
				});

				// update infos
				current_bpm = data.new_bpm;
				step_crochet = ((60 / current_bpm) * 1000) / 4;
			}
		}

		if (bpmChangeMap.length > 0) 
			trace("there's " + bpmChangeMap.length + " bpm changes waiting for you.");
	}
	
	public static function changeBPM(newBpm:Float) {
		bpm = newBpm;
		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	public static function getStepByTime(time:Float) {
		var bpmChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm
		};

		for(change in bpmChangeMap)
			if (change.songTime < time && change.songTime >= bpmChange.songTime)
				bpmChange = change;

		return bpmChange.stepTime + ((time - bpmChange.songTime) / ((60 / bpmChange.bpm) * (1000/4)));
	}
}