package game.cdev;

import flixel.FlxG;
import meta.states.PlayState;

class RatingsCheck
{
	//shit,bad,good,sick,perfect
    public static var theTimingWindow = [166,135,90,55];
	public static function getRating(acc:Float):String
	{
		var returnShit:String = "";

		if (acc >= 1 && acc < 4.99)
			returnShit = "Skill Issue :/"; //hehe
		else if (acc >= 5 && acc < 9.99)
			returnShit = "Hell";
		else if (acc >= 10 && acc < 19.99)
			returnShit = "Wtf";
		else if (acc >= 20 && acc < 29.99)
			returnShit = "Shit";
		else if (acc >= 30 && acc < 39.99)
			returnShit = "Ugh";
		else if (acc >= 40 && acc < 49.99)
			returnShit = "Bad";
		else if (acc >= 50 && acc < 59.99)
			returnShit = "Heck";
		else if (acc >= 60 && acc < 68.99)
			returnShit = "Uhh";
		else if (acc >= 69 && acc < 69.99)
			returnShit = "Lol";
		else if (acc >= 70 && acc < 79.99)
			returnShit = 'Good';
		else if (acc >= 80 && acc < 89.99)
			returnShit = "Great";
		else if (acc >= 90 && acc < 99.99)
			returnShit = "Sick!";
		else if (acc == 100)
			returnShit = "Amazing!";
		else if (acc >= 0 && acc < 0.99)
			returnShit = "N/A";

		return returnShit;
	}

	public static function fixFloat(flt:Float, prs:Int):Float
	{
		var value = flt;
		value = value * Math.pow(10, prs);
		value = Math.round(value) / Math.pow(10, prs);
		return value;
	}

	public static function getRankText():String 
	{
		var daRank:String = '';
		if (PlayState.misses == 0 && PlayState.bad == 0 && PlayState.shit == 0 && PlayState.good == 0)
            daRank = "MFC";
        else if (PlayState.misses == 0 && PlayState.bad == 0 && PlayState.shit == 0 && PlayState.good >= 1)
            daRank = "GFC";
        else if (PlayState.misses == 0)
            daRank = "FC";
        else if (PlayState.misses < 10)
            daRank = "SDCB";
        else
			daRank = "Clear";

		return daRank;
	}

	public static function getRatingText(acc:Float):Array<Dynamic>
	{
		var aee:Array<Dynamic> = ["?", 0xFFFFFFFF];

		if (acc >= 0 && acc < 0.99)
			aee = ["?", 0xFFFFFFFF];
		else if (acc >= 1 && acc < 69.99)
			aee = ["F", 0xFFFF0000];
		else if (acc >= 70 && acc < 74.99)
			aee = ["D", 0xFFFF8800];
		else if (acc >= 75 && acc < 79.99)
			aee = ["C", 0xFFFFD900];
		else if (acc >= 80 && acc < 84.99)
			aee = ["B", 0xFFB3FF00];
		else if (acc >= 85 && acc < 89.99)
			aee = ["A", 0xFF1EFF00];
		else if (acc >= 90 && acc < 94.99)
			aee = ["S", 0xFF00CCFF];
		else if (acc >= 95 && acc < 99.99)
			aee = ["S+", 0xFF00CCFF];
		else if (acc == 100)
			aee = ["S++", 0xFF00CCFF];

		return aee;
	}

    public static function noteJudge(note:game.objects.Note):String
    {
		if (!CDevConfig.saveData.botplay) //well...
		{
			if (note.isSustainNote)
				return "sick"; //return 'perfect';

			var theDiff = Math.abs((note.strumTime - game.Conductor.songPosition));
			for (i in 0...theTimingWindow.length){
				var judgeTime = theTimingWindow[i];
				var newTime = i + 1 > theTimingWindow.length - 1 ? 0 : theTimingWindow[i + 1];
				if (theDiff < judgeTime && theDiff >= newTime)
				{
					switch(i)
					{
						case 0:
							return "shit";
						case 1:
							return "bad";
						case 2:
							return "good";
						case 3:
							return "sick";
						//case 4:
						//	return "perfect";
					}
				}
			}
				return "shit";
			
		} else{
				return "sick";
		}
    }
}
