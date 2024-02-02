package meta.states;

import game.cdev.CDevMods.ModFile;
import game.objects.StoryDiffSprite;
import game.objects.Alphabet;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import game.CoolUtil;
import flixel.FlxState;
import flixel.FlxSubState;
import game.cdev.MissingFileMessage;
import lime.utils.Assets;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import meta.modding.week_editor.WeekData;
import game.objects.Character;
import flixel.tweens.FlxEase;
#if desktop
import game.cdev.engineutils.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.Paths;
import game.Conductor;
import game.objects.MenuItem;
import meta.states.PlayState;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public var weekJSONs:Array<Dynamic>; // weekFile, weekMod

	var scoreText:FlxText;

	var txtWeekTitle:FlxText;

	public var curWeek:Int = 0;
	public var curDifficulty:Int = 1;

	var txtTracklist:FlxText;

	public var grpWeekText:FlxTypedGroup<MenuItem>;

	var grpWeekCharacters:FlxTypedGroup<Character>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:StoryDiffSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	public var selectedDifficulty:String = "";

	override function create()
	{
		Paths.destroyLoadedImages(false);
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		CDevConfig.utils.getStateScript("StoryMenuState");

		loadWeeks();

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(102);
			}
		}
		persistentUpdate = persistentDraw = true;

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
		
		grpWeekCharacters = new FlxTypedGroup<Character>();

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

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
			Paths.currentMod = weekJSONs[i][1];
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, 0, weekJSONs[i][0].weekTxtImgPath);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = CDevConfig.saveData.antialiasing;
			weekThing.changeGraphic(weekJSONs[i][0].weekTxtImgPath);

			if (weekThing.fileMissing)
			{
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
					lock.antialiasing = CDevConfig.saveData.antialiasing;
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

		sprDifficulty = new StoryDiffSprite(leftArrow.x + 130, leftArrow.y, "normal");
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		add(yellowBG);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		add(grpWeekCharacters);
		changeCharacters();

		updateText();
		changeWeek();
		changeDifficulty();

		trace("Line 165");

		if (CDevConfig.saveData.smoothAF)
		{
			FlxG.camera.zoom = 1.5;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.cubeOut});
		}
		super.create();
	}

	function loadWeeks()
	{
		var theFiles:Array<Dynamic> = [];

		var allowDefSongs = true;
		if (CDevConfig.utils.isPriorityMod())
		{
			Paths.currentMod = CDevConfig.utils.isPriorityMod(true);
			var data:ModFile = Paths.modData();
			if (data != null)
			{
				if (Reflect.hasField(data, "disable_base_game"))
				{
					allowDefSongs = !data.disable_base_game;
				}
			}
		}

		var path = "assets/data/weeks/";
		var direct:Array<String> = FileSystem.readDirectory(path);

		if (allowDefSongs) for (i in 0...direct.length)
		{
			if (direct[i].endsWith(".json")){
				var pathJson:String = path+direct[i];
				trace(path + " - " + i);

				var crapJSON = null;
				if (FileSystem.exists(pathJson))
					crapJSON = File.getContent(pathJson);

				var json:WeekFile = null;
				if (crapJSON != null) json = cast Json.parse(crapJSON);

				if (json != null) theFiles.push([json, 'BASEFNF']);
			}
		}
		for (mod in 0...Paths.curModDir.length)
		{
			var path:String = Paths.mods(Paths.curModDir[mod] + '/data/weeks/');
			trace(path);
			var weekFiles:Array<String> = [];

			if (FileSystem.isDirectory(path))
			{
				weekFiles = FileSystem.readDirectory(path);
				trace(weekFiles);
				var crapJSON = null;

				for (json in 0...weekFiles.length)
				{
					#if ALLOW_MODS
					var file:String = path + weekFiles[json];
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
		super.update(elapsed);
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
				if (controls.UI_UP_P)
				{
					changeWeek(-1);
					changeDifficulty();
				}

				if (controls.UI_DOWN_P)
				{
					changeWeek(1);
					changeDifficulty();
				}

				if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.UI_RIGHT_P)
					changeDifficulty(1);
				if (controls.UI_LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				if (stopspamming == false)
				{
					StoryMenuFunctions.checkSongs();
					stopspamming = true;
				}
			}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			if (CDevConfig.saveData.smoothAF)
			{
				FlxG.camera.zoom = 1;
				FlxTween.tween(FlxG.camera, {zoom: 0.5}, 1, {ease: FlxEase.cubeOut});
			}
			FlxG.switchState(new MainMenuState());
		}
	}

	var movedBack:Bool = false;

	public var selectedWeek:Bool = false;
	public var stopspamming:Bool = false;

	var prevCharacters:Array<String> = [];

	function changeCharacters()
	{
		for (a in 0...grpWeekCharacters.members.length)
		{
			grpWeekCharacters.members[a].destroy();
			grpWeekCharacters.members[a] = null;
			//grpWeekCharacters.members[a].kill();
		}
		for (b in 0...3)
		{
			var no:Bool = (b == 2);
			grpWeekCharacters.add(new Character(weekJSONs[curWeek][0].charSetting[b].position[0], weekJSONs[curWeek][0].charSetting[b].position[1],
				weekJSONs[curWeek][0].weekCharacters[b], no, true));
			var char:Character = grpWeekCharacters.members[b];
			char.scale.set(weekJSONs[curWeek][0].charSetting[b].scale, weekJSONs[curWeek][0].charSetting[b].scale);
			char.flipX = weekJSONs[curWeek][0].charSetting[b].flipX;

			char.visible = !(weekJSONs[curWeek][0].weekCharacters[b] == '');
		}
	}

	var tweenDifficulty:FlxTween;
	var tweenNoDiff:FlxTween;
	var tweenNoDiffText:FlxTween;

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		trace(CoolUtil.songDifficulties);
		if (curDifficulty < 0)
			curDifficulty = CoolUtil.songDifficulties.length - 1;
		if (curDifficulty >= CoolUtil.songDifficulties.length)
			curDifficulty = 0;

		var diff:String = CoolUtil.songDifficulties[curDifficulty].toLowerCase().trim();
		trace(diff+".png");

		sprDifficulty.changeDiff(diff);
		sprDifficulty.doTween();

		sprDifficulty.x = leftArrow.x + 60;
		sprDifficulty.x += (308 - sprDifficulty.width) / 3;

		#if !switch
		intendedScore = game.cdev.engineutils.Highscore.getWeekScore(weekJSONs[curWeek][0].weekName, curDifficulty);
		#end
		selectedDifficulty = CoolUtil.songDifficulties[curDifficulty];
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
		Paths.currentMod = weekJSONs[curWeek][1];
		FlxG.sound.play(Paths.sound('scrollMenu'));

		changeCharacters();
		updateText();
		if (weekJSONs[curWeek][0].weekDifficulties != null){
			if (weekJSONs[curWeek][0].weekDifficulties.length > 0)
				CoolUtil.songDifficulties = weekJSONs[curWeek][0].weekDifficulties;
			else
				CoolUtil.songDifficulties = CoolUtil.defaultDifficulties;
		} else{
			CoolUtil.songDifficulties = CoolUtil.defaultDifficulties;
		}

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
		intendedScore = game.cdev.engineutils.Highscore.getWeekScore(weekJSONs[curWeek][0].weekName, curDifficulty);
		#end
	}

	override function beatHit()
	{
		super.beatHit();

		for (i in 0...3)
		{
			if (grpWeekCharacters.members[i] != null)
				grpWeekCharacters.members[i].dance();
		}
	}
}
