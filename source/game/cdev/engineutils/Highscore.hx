package game.cdev.engineutils;

import game.CoolUtil;
import flixel.FlxG;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var songRating:Map<String, Float> = new Map();
	public static var songDate:Map<String, Date> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var songDate:Map<String, Date> = new Map<String, Date>();
	#end


	public static function resetSong(song:String, diff:Int = 0):Void
		{
			var theSong:String = formatSong(song, diff);

			setScore(theSong, 0);
			setRating(theSong, 0);
			setSongDate(song.toLowerCase(), null);
		}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1, ?assDate:Date = null):Void
		{
			var daSong:String = formatSong(song, diff);
	
			setSongDate(song.toLowerCase(), assDate);
			if (songScores.exists(daSong)) {
				if (songScores.get(daSong) < score) {
					setScore(daSong, score);
					if (rating >= 0)
						if (rating > getRating(daSong, diff))
							setRating(daSong, rating);
				}
			}
			else {
				setScore(daSong, score);
				if (rating >= 0)
					if (rating > getRating(daSong, diff))
						setRating(daSong, rating);
			}
		}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
		CDevConfig.storeSaveData();
	}
	static function setSongDate(song:String, date:Date):Void
		{
			songDate.set(song.toLowerCase(), date);
			FlxG.save.data.songDate = songDate;
			FlxG.save.flush();
			CDevConfig.storeSaveData();
		}

	static function setRating(song:String, rating:Float):Void
		{
			songRating.set(song, rating);
			FlxG.save.data.songRating = songRating;
			FlxG.save.flush();
			CDevConfig.storeSaveData();
		}

	public static function formatSong(song:String, diff:Int, ?dumbshit:Bool = false):String
	{
		var daSong:String = song.toLowerCase().replace(" ", "-");

		if (dumbshit)
			return daSong;
		daSong += "-"+CoolUtil.songDifficulties[diff];
		//trace(daSong);

		return daSong;
	}

	
	public static function getRating(song:String, diff:Int):Float
		{
			var daSong:String = formatSong(song, diff);
			if (!songRating.exists(daSong))
				setRating(daSong, 0);
	
			return songRating.get(daSong);
		}

	public static function getSongDate(song:String):Date
		{
			if (!songDate.exists(song.toLowerCase()))
				setSongDate(song.toLowerCase(), null);
		
			return songDate.get(song.toLowerCase());
		}

	public static function formatModSong(song:String, diff:Int):String
		{
			var daSong:String = song;
	
			if (diff == 0)
				daSong += '-easy';
			else if (diff == 2)
				daSong += '-hard';
	
			return daSong;
		}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(week, diff)))
			setScore(formatSong(week, diff), 0);

		return songScores.get(formatSong(week, diff));
	}

	public static function load():Void
		{
			if (FlxG.save.data.songScores != null)
			{
				songScores = FlxG.save.data.songScores;
			}
			if (FlxG.save.data.songRating != null)
			{
				songRating = FlxG.save.data.songRating;
			}
			if (FlxG.save.data.songDate != null)
				{
					songDate = FlxG.save.data.songDate;
				}
		}
}
