package meta.states;

import game.cdev.CDevConfig;
import game.CoolUtil;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import game.cdev.engineutils.Highscore;
import flixel.addons.ui.FlxUIState;
import flixel.FlxState;
import flixel.FlxG;
import game.cdev.MissingFileMessage;
import game.Paths;
import sys.FileSystem;
import meta.modding.week_editor.WeekData.WeekFile;

using StringTools;


class StoryMenuFunctions
{
    public static var storr:StoryMenuState = null;

	public static function checkSongs()
	{
		//storymenustate bugged idk why, so i made this class and this function.

        var curState:Dynamic = FlxG.state;
		storr = curState;
		var canLoadWeek:Bool = true;
		var songsThatCantBeLoaded:Array<String> = [];
		var tracks:Array<String> = storr.weekJSONs[storr.curWeek][0].tracks.copy();
		var theMod:String = storr.weekJSONs[storr.curWeek][1];
		for (a in 0...tracks.length)
		{
			trace(a);
			Paths.currentMod = theMod;

			var daSong:String = tracks[a].toLowerCase().replace(" ", '-');

			if (CoolUtil.songDifficulties[storr.curDifficulty].toLowerCase() != "normal")
				daSong += '-'+CoolUtil.songDifficulties[storr.curDifficulty];
	
			var poop:String = daSong;

			trace(tracks[a].toLowerCase().replace(" ", '-'));
			if (!FileSystem.exists(Paths.modJson(tracks[a].toLowerCase().replace(" ", "-") + '/' + poop))
			&& !FileSystem.exists(Paths.json(tracks[a].toLowerCase().replace(" ", "-") + '/' + poop)))
			{
				canLoadWeek = false;
				songsThatCantBeLoaded.push(poop);
			}
		}

		if (!canLoadWeek)
		{
			var m:String = 'Can\'t load this week due to an error.\nPlease check the songs mentioned below on\n"cdev-mods/$theMod/data/charts/" folder or\n"assets/data/charts" 
			folder and make sure if the songs are exists\n\n$songsThatCantBeLoaded';
			storr.openSubState(new MissingFileMessage(m, 'Error', function(){
				storr.stopspamming = false;
				//return;
			}));
		} else{
			startWeek();
		}

	}

	public static function startWeek(){
        var curState:Dynamic = FlxG.state;
		storr = curState;
		var tracks:Array<String> = storr.weekJSONs[storr.curWeek][0].tracks.copy();
		FlxG.sound.play(Paths.sound('confirmMenu'));

		storr.grpWeekText.members[storr.curWeek].startFlashing(FlxColor.CYAN);
		PlayState.storyPlaylist = tracks;
		PlayState.isStoryMode = true;
		PlayState.weekName = storr.weekJSONs[storr.curWeek][0].weekName;
		storr.selectedWeek = true;
		PlayState.difficultyName = CoolUtil.songDifficulties[storr.curDifficulty];

		var diffic = '-'+CoolUtil.songDifficulties[storr.curDifficulty];

		PlayState.storyDifficulty = storr.curDifficulty;

		PlayState.SONG = game.song.Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase().replace(" ", "-") + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyWeek = storr.curWeek;
		PlayState.campaignScore = 0;
		PlayState.fromMod = storr.weekJSONs[storr.curWeek][1];
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true);
		});
		// }

	}

	/*function readDiff(clear:Bool = false){
		var curState:Dynamic = FlxG.state;
		storr = curState;
		//currentMod = songs[curSelected].fromMod;
		var b:Bool = (storr.weekJSONs[storr.curWeek][1] != "BASEFNF");
		//trace(b);

		//var data:String = Json.parse()//Paths.modFolders()
		if(!clear){
			if (b)
				CoolUtil.songDifficulties = CDevConfig.utils.readChartJsons(storr.weekJSONs[storr.curWeek][0].tracks[], b);
			else
				CoolUtil.songDifficulties = CoolUtil.difficultyArray; 
		}
		else
		CoolUtil.songDifficulties = [];

		selectedDifficulty = CoolUtil.songDifficulties[0];
		sprDifficulty.text = CoolUtil.songDifficulties[0].toUpperCase();
		checkNormal();
	}

	function checkNormal(){
		if (sprDifficulty.text.endsWith("+")){
			sprDifficulty.text = "NORMAL";
			yeahNormal = true;
			trace("yes normal");
		} else{
			yeahNormal = false;
			trace("no.");
		}
	}*/
}