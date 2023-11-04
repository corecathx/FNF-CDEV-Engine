package game.cdev;

class SongPosition
{
	public static function getSongDuration(musicTime:Float, musicLength:Float):String
	{
		var secondsMax:Int = Math.floor((musicLength - musicTime) / 1000); // 1 second = 1000 miliseconds
		var seconds:String = '' + secondsMax % 60;

		if (secondsMax < 0)
			secondsMax = 0;

		var minutes:Int = Math.floor(secondsMax / 60); // 1 minute = 60 seconds
		if (musicTime < 0)
			musicTime = 0;

		if (seconds.length < 2)
			seconds = '0' + seconds;

		var lastTextString:String = minutes + ':' + seconds;
		return lastTextString;
	}

	public static function getCurrentDuration(musicTime:Float):String
	{
		// literally copied from getSongDuration bruh.
		var theshit:Int = Math.floor(musicTime / 1000);
		var secs:String = '' + theshit % 60;
		var mins:String = "" + Math.floor(theshit / 60)%60;
		var hour:String = '' + Math.floor((theshit / 3600))%24; 
		if (theshit < 0)
			theshit = 0;
		if (musicTime < 0)
			musicTime = 0;

		if (secs.length < 2)
			secs = '0' + secs;

		var shit:String = mins + ":" + secs;
		if (hour != "0"){
			if (mins.length < 2) mins = "0"+ mins;
			shit = hour+":"+mins + ":" + secs;
		}
		return shit;
	}

	public static function getMaxDuration(musicLength:Float):String
	{
		// literally copied from getCurrentDuration bruh.
        var minutes:Int = Math.floor(musicLength / 1000);
        var seconds:String = '' + minutes % 60;

		var mins:Int = Math.floor(minutes / 60);
		if (minutes < 0)
			minutes = 0;

		if (seconds.length < 2)
			seconds = '0' + seconds;

		var shit:String = mins + ":" + seconds;
		return shit;
	}

	public static function getSongPercent(musicTime:Float, musicLength:Float):Float
	{
		return musicTime / musicLength;
	}
}
