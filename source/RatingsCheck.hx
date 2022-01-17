package;

import flixel.FlxG;

class RatingsCheck
{
	public static function getRating(acc:Float):String
	{
		var returnShit:String = "";

		if (acc >= 1 && acc < 4.99)
			returnShit = "Skill Issue :/";
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
			returnShit = "Lol"; // 69, funi number
		else if (acc >= 70 && acc < 79.99)
			returnShit = 'Good';
		else if (acc >= 80 && acc < 89.99)
			returnShit = "Great";
		else if (acc >= 90 && acc < 99.99)
			returnShit = "Sick!";
		else if (acc == 100)
			returnShit = "Marvelous!";
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

	public static function getRatingText(acc:Float):String
	{
		var aee:String = '';

		if (acc >= 0 && acc < 0.99)
			aee = "?";
		else if (acc >= 1 && acc < 49.99)
			aee = 'F';
		else if (acc >= 50 && acc < 59.99)
			aee = 'D';
		else if (acc >= 60 && acc < 69.99)
			aee = 'C';
		else if (acc >= 70 && acc < 79.99)
			aee = 'B';
		else if (acc >= 80 && acc < 89.99)
			aee = 'A';
		else if (acc >= 90 && acc < 94.99)
			aee = 'S';
		else if (acc >= 95 && acc < 99.99)
			aee = 'S+';
		else if (acc == 100)
			aee = 'S++';

		return aee;
	}

	public static function getNoteRating(noteDiff:Float):String
	{
		var strRet:String = '';
		if (noteDiff > 176)
			strRet = "miss";
		if (noteDiff > 145)
			strRet = "shit";
		else if (noteDiff > 100)
			strRet = "bad";
		else if (noteDiff > 55)
			strRet = "good";
		else if (noteDiff < -55)
			strRet = "good";
		else if (noteDiff < -100)
			strRet = "bad";
		else if (noteDiff < -145)
			strRet = "shit";
		else if (noteDiff < -176)
			strRet = "miss";
		else
			strRet = "sick";

		if (FlxG.save.data.botplay) //force sick on boobplay
			strRet = 'sick';

		return strRet;
	}
}
