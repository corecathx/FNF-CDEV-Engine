package game;

import song.Song.SwagSong;
import game.Conductor.BPMChangeEvent;
import flixel.FlxG;
//typedef BPMChangeEvent =
//{
//	var stepTime:Int;
//	var songTime:Float;
//	var bpm:Float;
//}

class SongTiming
{
    public var bpmChanges:Array<BPMChangeEvent> = [];

    public var startStep:Int = 0;
    public var songTime:Float = 0;
    public var bpm:Float = 0;


    public function new()
    {

    }

    //hmm conductor
    public function loadTimingFromSong(song:SwagSong)
    {
        bpmChanges = [];

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
				bpmChanges.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
    }

    public function getBeatFromPos(songPos:Float):Int
    {
        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: 0
        }
        for (i in 0...bpmChanges.length)
        {
            if (songPos >= bpmChanges[i].songTime)
                lastChange = bpmChanges[i];
        }

        var stepCrochet:Float = ((60 / lastChange.bpm) * 1000);
        
        var curStep:Int = lastChange.stepTime + Math.floor((songPos - lastChange.songTime) / stepCrochet);		

        return (Math.floor(curStep / 4));
    }

}

/*public static function mapBPMChanges(song:SwagSong)//, addToSongTiming:Bool)
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

				//SongTiming.addTiming(songTime/(((60 / curBPM) * 1000)*(totalSteps%4)),curBPM,);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}*/