package states;

import engineutils.Highscore;
import cdev.MissingFileMessage;
import lime.utils.Assets;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import modding.WeekData;
import game.Character;
import flixel.tweens.FlxEase;
#if desktop
import engineutils.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import game.Paths;
import game.Conductor;
import game.MenuItem;
import states.PlayState;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var weekJSONs:Array<Dynamic>; //weekFile, weekMod
	var scoreText:FlxText;

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;
	var curDifficulty:Int = 1;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<Character>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		#if ALLOW_MODS
		Paths.destroyLoadedImages();
		#end
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		loadWeeks();

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(102);
			}
		}

		//persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFF000000);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<Character>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

		#if desktop
		// Updating Discord Rich Presence
		if (Main.discordRPC)
			DiscordClient.changePresence("In the Story menu", null);
		#end

		for (i in 0...weekJSONs.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, 0, weekJSONs[i][0].weekTxtImgPath);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = FlxG.save.data.antialiasing;
			weekThing.changeGraphic(weekJSONs[i][0].weekTxtImgPath);

			if (weekThing.fileMissing){
				weekThing.visible = false;
			}
			// weekThing.updateHitbox();

			// Needs an offset thingie

			// the lock week feature are removed temporarily
			/*if (!weekUnlocked[i])
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					lock.antialiasing = FlxG.save.data.antialiasing;
					grpLocks.add(lock);
			}*/
		}

		trace("Line 96");

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		add(yellowBG);
		add(grpWeekCharacters);
		changeCharacters();

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		trace("Line 165");

		if (FlxG.save.data.smoothAF)
		{
			FlxG.camera.zoom = 1.5;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.cubeOut});
		}
		super.create();
	}

	function loadWeeks()
	{
		var theFiles:Array<Dynamic> = [];

		for (i in 0...8){
			var path:String = Paths.week('week'+i);
			trace(path);
			var crapJSON = null;
			if (Assets.exists(path, TEXT))
				crapJSON = Assets.getText(path);
		
			var json:WeekFile = cast Json.parse(crapJSON);
			var gugugaga:Array<Dynamic> = [json, 'BASEFNF'];
			if (crapJSON != null)
				theFiles.push(gugugaga);
		}	
		for (mod in 0...Paths.curModDir.length)
		{
			var path:String = Paths.mods(Paths.curModDir[mod] + '/data/weeks/');
			trace(path);
			var weekFiles:Array<String> = [];

			if (FileSystem.isDirectory(path)){
				weekFiles = FileSystem.readDirectory(path);
				trace(weekFiles);
                var crapJSON = null;

				for (json in 0...weekFiles.length)
				{
					#if ALLOW_MODS
					var file:String = path+weekFiles[json];
					if (FileSystem.exists(file))
						crapJSON = File.getContent(file);
					#end
				
					var json:WeekFile = cast Json.parse(crapJSON);
					var gugugaga:Array<Dynamic> = [json, Paths.curModDir[mod]];
					if (crapJSON != null)
						theFiles.push(gugugaga);
				}
            }		
		}
		weekJSONs = theFiles;
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekJSONs[curWeek][0].weekName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = true /*weekUnlocked[curWeek]*/;

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			if (FlxG.save.data.smoothAF)
			{
				FlxG.camera.zoom = 1;
				FlxTween.tween(FlxG.camera, {zoom: 0.5}, 1, {ease: FlxEase.cubeOut});
			}
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function checkSongs(){
		//copied from FreeplayState cuz lazy
		var canLoadWeek:Bool = true;
		var songsThatCantBeLoaded:Array<String> = [];
		for (a in 0...weekJSONs[curWeek][0].tracks.length)
		{
			var poop:String = Highscore.formatSong(weekJSONs[curWeek][0].tracks[a].toLowerCase(), curDifficulty);

			if (!FileSystem.exists(Paths.modJson(weekJSONs[curWeek][0].tracks[a].toLowerCase() + '/' + poop))
			&& !FileSystem.exists(Paths.json(weekJSONs[curWeek][0].tracks[a].toLowerCase() + '/' + poop)))
			{
				canLoadWeek = false;
				songsThatCantBeLoaded.push(poop);
			}
		}

		if (!canLoadWeek){
			var m:String = 'Can\'t load this week due to an error.\nPlease check the 
			songs mentioned below on\n"cdev-mods/yourMod/data/charts/" folder or\n"assets/data/charts" 
			folder and make sure if the songs are exists\n\n$songsThatCantBeLoaded';
			openSubState(new MissingFileMessage(m, 'Error', function(){
				stopspamming = false;
				//return;
			}));
		} else{
			startWeek();
		}

	}

	function startWeek(){
		FlxG.sound.play(Paths.sound('confirmMenu'));

		grpWeekText.members[curWeek].startFlashing(FlxColor.CYAN);
		PlayState.storyPlaylist = weekJSONs[curWeek][0].tracks;
		PlayState.isStoryMode = true;
		PlayState.weekName = weekJSONs[curWeek][0].weekName;
		selectedWeek = true;

		var diffic = "";

		switch (curDifficulty)
		{
			case 0:
				diffic = '-easy';
			case 2:
				diffic = '-hard';
		}

		PlayState.storyDifficulty = curDifficulty;

		PlayState.SONG = song.Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase().replace(" ", "-") + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyWeek = curWeek;
		PlayState.campaignScore = 0;
		PlayState.fromMod = weekJSONs[curWeek][1];
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true);
		});
		// }

	}
	function selectWeek()
	{
		
		// if (weekUnlocked[curWeek])
		// {
		if (stopspamming == false)
		{
			checkSongs();
			stopspamming = true;
		}
					
	}

	var prevCharacters:Array<String> = [];

	function changeCharacters()
	{
		for (a in 0...grpWeekCharacters.members.length)
		{
			//if (prevCharacters[a] != weekJSONs[curWeek].weekCharacters[a])
			//{
				grpWeekCharacters.members[a].kill();
				grpWeekCharacters.members[a] = null;
				//remove(a);
			//}
		}
		for (b in 0...3)
		{
			//if (prevCharacters[b] != weekJSONs[curWeek].weekCharacters[b])
			//{
				var no:Bool = (b == 2);
				grpWeekCharacters.add(new Character(weekJSONs[curWeek][0].charSetting[b].position[0], weekJSONs[curWeek][0].charSetting[b].position[1],
					weekJSONs[curWeek][0].weekCharacters[b], no, true));
				var char:Character = grpWeekCharacters.members[b];
				char.scale.set(weekJSONs[curWeek][0].charSetting[b].scale, weekJSONs[curWeek][0].charSetting[b].scale);
				char.flipX = weekJSONs[curWeek][0].charSetting[b].flipX;

				if (weekJSONs[curWeek][0].weekCharacters[b] == '')
				{
					char.visible = false;
				}
				else
				{
					char.visible = true;
				}
			//}
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = engineutils.Highscore.getWeekScore(weekJSONs[curWeek][0].weekName, curDifficulty);

		#if !switch
		intendedScore = engineutils.Highscore.getWeekScore(weekJSONs[curWeek][0].weekName, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		prevCharacters = weekJSONs[curWeek][0].weekCharacters;
		curWeek += change;

		if (curWeek >= weekJSONs.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekJSONs.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) /* && weekUnlocked[curWeek]*/)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		changeCharacters();
		updateText();
	}

	function updateText()
	{
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = weekJSONs[curWeek][0].tracks;

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";
		#if !switch
		intendedScore = engineutils.Highscore.getWeekScore(weekJSONs[curWeek][0].weekName, curDifficulty);
		#end
	}

	override function beatHit()
	{
		super.beatHit();

		for (i in 0...3){
			if (grpWeekCharacters.members[i] != null)
				grpWeekCharacters.members[i].dance();
		}

	}
}
