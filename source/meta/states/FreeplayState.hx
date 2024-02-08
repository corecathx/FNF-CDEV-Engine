package meta.states;

import lime.media.openal.AL;
import game.cdev.CDevPopUp;
import sys.thread.Thread;
import game.cdev.CDevMods.ModFile;
import meta.modding.week_editor.WeekData;
import game.cdev.CDevConfig;
import sys.io.File;
import haxe.io.Path;
import lime.app.Application;
import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
import openfl.Assets as FLAssets;
import openfl.utils.Assets as OpenFlAssets;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
#if sys
import sys.FileSystem;
#end
import flixel.FlxBasic.FlxType;
#if desktop
import game.cdev.engineutils.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import game.objects.*;
import game.objects.Alphabet;
import game.objects.HealthIcon;
import game.*;
import game.cdev.VCRGrpText;
import game.cdev.engineutils.Highscore;
import game.cdev.MissingFileSubstate;
import meta.substates.ResetScoreSubstate;

using StringTools;

// todolist:
// rewrite this all and make it more simple.
// fix bpm not changing cuz there is no normal difficulty json file.
class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	static var curSelected:Int = 0;

	var selectedDifficulty:String = "";

	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	// var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var selectedThing:Bool = false;

	static var curPlayedSong:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	var difficultySelectors:FlxTypedGroup<FlxSprite>;
	var sprDifficulty:FlxText;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	// used for chart modifications
	var modOptions:Array<Dynamic> = [];
	var modDescs:Array<String> = [];
	var versionSht:FlxText;
	var curModSelected:Int = 0;
	var modMenuBG:FlxSprite;
	var modTitle:Alphabet;

	public static var speed:Float = 1.0;
	public static var playOnLeftSide:Bool = false;

	var modMenuOpened:Bool = false;
	private var grpModMenu:FlxTypedGroup<VCRGrpText>;

	static var selectedBPMSONG:Int = 0;

	var songBG:FlxSprite;
	var songBar:FlxBar;

	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('aboutMenu'));
	private var iconArray:Array<HealthIcon> = [];

	var songInfo:FlxText;
	var barValue:Float = 0;
	var barValueLRP:Float = 0;
	var cachingAmount:Float = 0;
	var tip:FlxText;

	var tween:FlxTween;
	var isDebug:Bool = false;

	// this is just dumb
	var yeahNormal:Bool = false;

	override function create()
	{
		Paths.destroyLoadedImages(false);
		CDevConfig.utils.getStateScript("FreeplayState");
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		var customSongList:Array<String> = [];
		var songModListIdk:Array<String> = [];

		#if ALLOW_MODS
		for (directory in 0...Paths.curModDir.length)
		{
			var songListTxt:Array<String> = [];
			var crapz:String = Paths.curModDir[directory];

			var list:Array<String> = [];

			if (FileSystem.exists(Sys.getCwd() + 'cdev-mods/' + Paths.curModDir[directory] + '/songList.txt'))
			{
				list = File.getContent('cdev-mods/' + Paths.curModDir[directory] + '/songList.txt').trim().split('\n');
			}
			for (i in 0...list.length)
				list[i] = list[i].trim();

			songListTxt = list;
			for (i in 0...songListTxt.length)
			{
				if (songListTxt.length > 0)
				{
					customSongList.push(songListTxt[i]);
					songModListIdk.push(crapz);
					// trace('\nSong: ' + songListTxt[i] + "\nMod: " + crapz);
				}
			}
		}
		#end
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

		/*if (allowDefSongs)
		{
			for (i in 0...initSonglist.length)
			{
				var data:Array<String> = initSonglist[i].split(':');
				songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1], 'BASEFNF'));
			}
		}*/

		for (i in 0...WeekData.loadedWeeks.length)
		{
			var daWeek:WeekFile = WeekData.loadedWeeks[i][0];
			var daSongs:Array<String> = [];
			var daChars:Array<String> = [];

			if (daWeek.freeplaySongs != null)
			{
				for (index in 0...daWeek.freeplaySongs.length)
				{
					daSongs.push(daWeek.freeplaySongs[index].song);
					daChars.push(daWeek.freeplaySongs[index].character);
				}

				if (!daWeek.disableFreeplay)
				{
					for (song in daWeek.freeplaySongs)
					{
						var colors:Array<Int> = song.colors;
						if (colors == null || colors.length < 3)
						{
							colors = [146, 113, 253];
						}
						songs.push(new SongMetadata(song.song, 1, song.character, WeekData.loadedWeeks[i][1], colors, true, daWeek));
						// addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
					}
				}
			}
		}

		#if desktop
		for (i in 0...customSongList.length)
		{
			var bruh:Array<String> = customSongList[i].split(':');
			songs.push(new SongMetadata(bruh[0], 1, bruh[1], songModListIdk[i]));
		}
		#end

		// modName, isClickable, currentValue, min, max.
		// the min and max value are used if isClickable is true.
		// this array were messed up cuz' i'm dumb
		// oh yeah, the numbers are must be FLOAT.

		// to do: simplify this.
		modOptions = [
			['Randomize Chart', true, CDevConfig.saveData.randomNote],
			['Sudden Death', true, CDevConfig.saveData.suddenDeath],
			['Play as the opponent', true, playOnLeftSide],
			['Scroll Speed: ', false, CDevConfig.saveData.scrollSpeed, 0.1, 10],
			#if cpp ['Song Speed: ', false, speed, 0.1, 10], #end
			['Health Gain Multi: ', false, CDevConfig.saveData.healthGainMulti, 1, 10],
			['Health Lose Multi: ', false, CDevConfig.saveData.healthLoseMulti, 1, 10],
			['Combo Multipiler: ', false, CDevConfig.saveData.comboMultipiler, 1, 10]
		];

		modDescs = [
			'Randomizes your chart each time you load a song.',
			"If you miss a single note, it will trigger an instant gameover.",
			"Whether to play on the opponent's side",
			"Change your note scroll speed.\n(If it's at 1, it will be chart dependent.)",
			"Change the speed of your song.",
			"Set how much health that you get from hitting a note.",
			"Set how much health that you lose from missing a note.",
			"Change the Multipiler of your combo."
		];

		if (curPlayedSong == '')
			Conductor.changeBPM(102);

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC
		// LOAD CHARACTERS

		bg.alpha = 0.8;
		CDevConfig.utils.setFitScale(bg, 0.1, 0.1);
		bg.antialiasing = CDevConfig.saveData.antialiasing;
		bg.screenCenter();
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true);
			songText.isMenuItem = true;
			songText.isFreeplay = true;
			songText.targetY = i;
			songText.ID = i;
			grpSongs.add(songText);

			Paths.currentMod = songs[i].fromMod;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.ID = i;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// h e l l .
			// Caching.doMusicCaching(songs[i].songName);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		var scoreBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 66, 0xFF000000);
		scoreBG.alpha = 0.8;
		add(scoreBG);

		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.8;
		add(bottomPanel);

		scoreText = new FlxText(50, bottomPanel.y + 18, FlxG.width, "", 28);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 2;

		add(scoreText);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		difficultySelectors = new FlxTypedGroup<FlxSprite>();
		add(difficultySelectors);

		leftArrow = new FlxSprite(800, 0);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.scale.set(0.9, 0.9);
		difficultySelectors.add(leftArrow);

		leftArrow.y = FlxG.height - leftArrow.height - 30;

		sprDifficulty = new FlxText(leftArrow.x + 70, leftArrow.y + 20, (308 * 0.8), "DIFF", 44);
		sprDifficulty.setFormat(Paths.font("diffic.ttf"), 44, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.scale.set(0.9, 0.9);
		difficultySelectors.add(rightArrow);

		for (i in 0...difficultySelectors.length)
			difficultySelectors.members[i].antialiasing = CDevConfig.saveData.antialiasing;

		songInfo = new FlxText(0, 15, 1000, '', 16);
		songInfo.scrollFactor.set();
		songInfo.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(songInfo);
		songInfo.x = (FlxG.width - songInfo.width) - 20;

		var bottomPanl:FlxSprite = new FlxSprite(0, FlxG.height - 120).makeGraphic(FlxG.width, 20, 0xFF000000);
		bottomPanl.alpha = 0.8;
		add(bottomPanl);

		var daTipsTxt:String = "Press [SPACE] to preview this song. // Press ["
			+ game.cdev.CDevConfig.saveData.resetBind[0]
			+ "] to reset this song's score & ratings. // Press [M] to open modifiers.";

		tip = new FlxText(50, bottomPanel.y - 16, FlxG.width, daTipsTxt, 28);
		tip.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		tip.borderSize = 2;
		tip.screenCenter(X);
		add(tip);

		// the mod menu
		createModMenu();

		changeSelection();
		changeDiff();
		// changeModSelection();

		if (CDevConfig.saveData.smoothAF)
		{
			FlxG.camera.zoom = 1.5;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.cubeOut});
		}

		FlxG.mouse.visible = true;

		super.create();
	}

	function createModMenu()
	{
		modMenuBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		modMenuBG.alpha = 0.8;
		modMenuBG.x = FlxG.width;
		modMenuBG.scrollFactor.set();
		add(modMenuBG);

		grpModMenu = new FlxTypedGroup<VCRGrpText>();
		add(grpModMenu);
		for (i in 0...modOptions.length)
		{
			var um:VCRGrpText = new VCRGrpText(FlxG.width, FlxG.height / 2, modOptions[i][0] + (modOptions[i][1] ? '' : modOptions[i][2]), 30, FlxColor.WHITE,
				LEFT);
			um.isMenu = true;
			um.targetY = i;
			um.theXPos = modMenuBG.x + 50;
			um.alpha = 0;
			um.ID = i;
			// um.theText.scrollFactor.set();
			um.scrollFactor.set();
			grpModMenu.add(um);
		}

		modTitle = new Alphabet(0, 50, 'Song Modifiers', true);
		modTitle.x = modMenuBG.x + (modMenuBG.width / 2) - (modTitle.width / 2);
		modTitle.scrollFactor.set();
		modTitle.scale.set(0.9, 0.9);
		add(modTitle);

		versionSht = new FlxText(20, FlxG.height - 100, 1000, '', 24);
		versionSht.scrollFactor.set();
		versionSht.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionSht.screenCenter(X);
		add(versionSht);
		versionSht.borderSize = 2;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, daMod:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, daMod));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, daMod:String)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], daMod);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var bgX:Float = FlxG.width;
	var vershit:Float = FlxG.height;
	var addedSmthing:Bool = false;

	override function update(elapsed:Float)
	{
		modMenuBG.x = Std.int(FlxMath.lerp(bgX, modMenuBG.x, game.cdev.CDevConfig.utils.bound(1 - (elapsed * 10), 0, 1)));
		versionSht.y = Std.int(FlxMath.lerp(vershit, versionSht.y, game.cdev.CDevConfig.utils.bound(1 - (elapsed * 7), 0, 1)));
		grpModMenu.forEachAlive(function(theThing:VCRGrpText)
		{
			theThing.theXPos = modMenuBG.x + 50;
		});
		modTitle.x = modMenuBG.x + (modMenuBG.width / 2) - (modTitle.width / 2);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!selectedThing){
			if (FlxG.sound.music!=null&&FlxG.sound.music.volume < 0.7)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		bg.alpha = FlxMath.lerp(0.7, bg.alpha, game.cdev.CDevConfig.utils.bound(1 - (elapsed * 8), 0, 1));
		
		//using bgScaleLerp so that the scaling doesn't go way too smooth
		//(preventing motion sickness or something??)
		if (CDevConfig.saveData.smoothAF){
			var BGSL:Float = FlxMath.roundDecimal(FlxMath.lerp(1.1, bg.scale.x, 1-(elapsed*5)),3);
			bg.scale.set(BGSL, BGSL);
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, 0.4);

		for (icon in iconArray)
		{
			var lerp:Float = FlxMath.lerp(1, icon.scale.x, game.cdev.CDevConfig.utils.bound(1 - (elapsed * 12), 0, 1));
			icon.scale.set(lerp, lerp);

			if (icon.ID == curSelected)
			{
				if (icon.hasWinningIcon)
				{
					icon.animation.curAnim.curFrame = 2;
				}
				else
				{
					icon.animation.curAnim.curFrame = 0;
				}
			}
			else
			{
				iconArray[icon.ID].animation.curAnim.curFrame = 0;
			}
		}

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + "\n" + game.cdev.RatingsCheck.fixFloat(lerpRating, 2) + '%' + " ("
			+ game.cdev.RatingsCheck.getRatingText(lerpRating) + ")";

		super.update(elapsed);
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = FlxG.keys.justPressed.ENTER;
		var clicked = false;

		if (selectedThing)
		{
			barValueLRP = FlxMath.lerp(barValue, barValueLRP, 1 - (elapsed*3));
			if (daText != null){
				// doing this on a update function since changing FlxText text property
				// on a new thread somehow messes with the openfl's text engine
				if (daText.text != currentText){
					daText.text = currentText;
					daText.screenCenter(X);
				}
			}
		}

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			CDevConfig.utils.setSoundPitch(FlxG.sound.music, speed);

		if (!modMenuOpened)
		{
			if (!selectedThing)
			{
				if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (FlxG.mouse.wheel > 0 || upP)
				{
					// up
					changeSelection(-1);
				}
				else if (FlxG.mouse.wheel < 0 || downP)
				{
					// down
					changeSelection(1);
				}

				if (controls.RESET)
					resetScore();

				if (FlxG.mouse.overlaps(leftArrow))
				{
					if (FlxG.mouse.pressed)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (FlxG.mouse.justPressed)
					{
						changeDiff(-1);
					}
				}

				if (FlxG.mouse.overlaps(rightArrow))
				{
					if (FlxG.mouse.pressed)
						rightArrow.animation.play('press');
					else
						rightArrow.animation.play('idle');

					if (FlxG.mouse.justPressed)
					{
						changeDiff(1);
					}
				}

				for (item in grpSongs.members)
				{
					if (FlxG.mouse.overlaps(item))
					{
						if (FlxG.mouse.justPressed)
						{
							if (curSelected != item.ID)
							{
								changeSelection(item.ID, true);
							}
							else
							{
								var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
								var daSong:String = songs[curSelected].songName.toLowerCase().replace(" ", "-");

								var sel:String = (yeahNormal ? daSong : poop);
								#if sys
								if (!FileSystem.exists(Paths.modJson(songs[curSelected].songName.toLowerCase() + '/' + sel))
									&& !FileSystem.exists(Paths.json(songs[curSelected].songName.toLowerCase() + '/' + sel)))
								{
									if (FlxG.sound.music != null) FlxG.sound.music.pause();
									openSubState(new MissingFileSubstate(sel));
								}
								else
								{
								#end
									selectedSong();
								#if sys
								}
								#end
							}
						}
					}
				}

				if (controls.UI_LEFT_P)
					changeDiff(-1);
				if (controls.UI_RIGHT_P)
					changeDiff(1);

				if (FlxG.keys.justPressed.M)
					openMods();

				if (controls.BACK)
				{
					if (CDevConfig.saveData.smoothAF)
					{
						FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.quadOut});
					}

					if (FlxG.sound.music != null && FlxG.sound.music.playing)
						CDevConfig.utils.setSoundPitch(FlxG.sound.music, speed);

					FlxG.switchState(new MainMenuState());

					readDiff(true);
				}

				if (FlxG.sound.music != null && !FlxG.sound.music.playing)
				{
					curPlayedSong = '';
				}

				if (FlxG.keys.justPressed.SPACE)
				{
					if (curPlayedSong != songs[curSelected].songName)
					{
						curPlayedSong = songs[curSelected].songName;
						Paths.currentMod = songs[curSelected].fromMod;
						#if PRELOAD_ALL
						FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
						#end

						#if desktop
						changeDaBPM();
						#end
					}
				}

				if (accepted)
				{
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					var daSong:String = songs[curSelected].songName.toLowerCase().replace(" ", "-");

					var sel:String = (yeahNormal ? daSong : poop);
					#if sys
					if (!FileSystem.exists(Paths.modJson(songs[curSelected].songName.toLowerCase() + '/' + sel))
						&& !FileSystem.exists(Paths.json(songs[curSelected].songName.toLowerCase() + '/' + sel)))
					{
						if (FlxG.sound.music != null) FlxG.sound.music.pause();
						openSubState(new MissingFileSubstate(sel));
					}
					else
					{
					#end
						selectedSong();
					#if sys
					}
					#end
				}
			}
		}
		else
		{
			// MESS, TOTAL MESS.
			if (FlxG.mouse.wheel > 0 || upP)
			{
				// up
				changeModSelection(-1);
			}
			else if (FlxG.mouse.wheel < 0 || downP)
			{
				// down
				changeModSelection(1);
			}
			if (FlxG.keys.justPressed.ENTER && modOptions[curModSelected][1])
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
				saveMods();
			}
			if (!modOptions[curModSelected][1])
			{
				var valueToAdd:Float = controls.UI_RIGHT ? 0.1 : -0.1;
				if (modOptions[curModSelected][0] == "Song Speed: ")
				{
					valueToAdd = controls.UI_RIGHT ? 0.05 : -0.05;
				}
				if (controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if (holdTime <= 0)
						FlxG.sound.play(Paths.sound('scrollMenu'));
					if (holdTime >= 0.5 || controls.UI_LEFT_P || controls.UI_RIGHT_P)
					{
						modOptions[curModSelected][2] += valueToAdd;

						if (modOptions[curModSelected][2] <= modOptions[curModSelected][3])
							modOptions[curModSelected][2] = modOptions[curModSelected][3];

						if (modOptions[curModSelected][2] >= modOptions[curModSelected][4])
							modOptions[curModSelected][2] = modOptions[curModSelected][4];

						modOptions[curModSelected][2] = FlxMath.roundDecimal(modOptions[curModSelected][2], 2);

						var theValuee:Float = FlxMath.roundDecimal(modOptions[curModSelected][2], 2);
						grpModMenu.forEach(function(a:VCRGrpText)
						{
							a.theText.text = (a.ID == curModSelected ? '> ' : '  ')
								+ modOptions[curModSelected][0] + (modOptions[curModSelected][1] ? '' : Std.string(theValuee));
						});
						saveMods();
					}
				}
				else
					holdTime = 0;
			}

			for (i in 0...modOptions.length)
			{
				if (modOptions[i][1])
					if (modOptions[i][2])
						grpModMenu.members[i].theText.color = FlxColor.YELLOW;
					else
						grpModMenu.members[i].theText.color = FlxColor.WHITE;
			}
			if (controls.BACK || FlxG.keys.justPressed.M)
				closeMods();
			if (controls.RESET)
				resetMods();

			grpModMenu.forEach(function(a:VCRGrpText)
			{
				if (a.ID == curModSelected)
				{
					if (!addedSmthing)
					{
						var bruh:String = a.theText.text;
						if (!a.theText.text.startsWith('> '))
							a.theText.text = "> " + bruh;
						addedSmthing = true;
					}
				}
				else
				{
					a.theText.text = modOptions[a.ID][0] + (modOptions[a.ID][1] ? '' : modOptions[a.ID][2]);
				}
			});
		}
	}

	function resetMods()
	{
		FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
		switch (modOptions[curModSelected][0])
		{
			case 'Randomize Chart':
				CDevConfig.saveData.randomNote = false;
			case 'Sudden Death':
				CDevConfig.saveData.suddenDeath = false;
			case 'Play as the opponent':
				playOnLeftSide = false;
			case 'Scroll Speed: ':
				CDevConfig.saveData.scrollSpeed = 1;
			case 'Song Speed: ':
				speed = 1;
				changeDaBPM();
			case 'Health Gain Multi: ':
				CDevConfig.saveData.healthGainMulti = 1;
			case 'Health Lose Multi: ':
				CDevConfig.saveData.healthLoseMulti = 1;
			case 'Combo Multipiler: ':
				CDevConfig.saveData.comboMultipiler = 1;
		}

		modOptions = [
			['Randomize Chart', true, CDevConfig.saveData.randomNote],
			['Sudden Death', true, CDevConfig.saveData.suddenDeath],
			['Play as the opponent', true, playOnLeftSide],
			['Scroll Speed: ', false, CDevConfig.saveData.scrollSpeed, 0.1, 10],
			#if cpp ['Song Speed: ', false, speed, 0.1, 10], #end
			['Health Gain Multi: ', false, CDevConfig.saveData.healthGainMulti, 1, 10],
			['Health Lose Multi: ', false, CDevConfig.saveData.healthLoseMulti, 1, 10],
			['Combo Multipiler: ', false, CDevConfig.saveData.comboMultipiler, 1, 10]
		];

		var theValuee:Float = FlxMath.roundDecimal(modOptions[curModSelected][2], 2);
		grpModMenu.forEach(function(a:VCRGrpText)
		{
			a.theText.text = (a.ID == curModSelected ? '> ' : '  ')
				+ modOptions[curModSelected][0] + (modOptions[curModSelected][1] ? '' : Std.string(theValuee));
		});
	}

	function saveMods()
	{
		switch (modOptions[curModSelected][0])
		{
			case 'Randomize Chart':
				CDevConfig.saveData.randomNote = !CDevConfig.saveData.randomNote;
			case 'Sudden Death':
				CDevConfig.saveData.suddenDeath = !CDevConfig.saveData.suddenDeath;
			case 'Play as the opponent':
				playOnLeftSide = !playOnLeftSide;
			case 'Scroll Speed: ':
				CDevConfig.saveData.scrollSpeed = modOptions[curModSelected][2];
			case 'Song Speed: ':
				speed = modOptions[curModSelected][2];
				changeDaBPM();
			case 'Health Gain Multi: ':
				CDevConfig.saveData.healthGainMulti = modOptions[curModSelected][2];
			case 'Health Lose Multi: ':
				CDevConfig.saveData.healthLoseMulti = modOptions[curModSelected][2];
			case 'Combo Multipiler: ':
				CDevConfig.saveData.comboMultipiler = modOptions[curModSelected][2];
		}
		modOptions = [
			['Randomize Chart', true, CDevConfig.saveData.randomNote],
			['Sudden Death', true, CDevConfig.saveData.suddenDeath],
			['Play as the opponent', true, playOnLeftSide],
			['Scroll Speed: ', false, CDevConfig.saveData.scrollSpeed, 0.1, 10],
			#if cpp ['Song Speed: ', false, speed, 0.1, 10], #end
			['Health Gain Multi: ', false, CDevConfig.saveData.healthGainMulti, 1, 10],
			['Health Lose Multi: ', false, CDevConfig.saveData.healthLoseMulti, 1, 10],
			['Combo Multipiler: ', false, CDevConfig.saveData.comboMultipiler, 1, 10]
		];
	}

	function openMods()
	{
		modMenuOpened = true;
		addedSmthing = true;
		bgX = 0;
		vershit = FlxG.height - 100;
		changeModSelection();
	}

	function closeMods()
	{
		addedSmthing = true;
		modMenuOpened = false;
		bgX = FlxG.width;
		vershit = FlxG.height + 200;
	}

	var holdTime:Float = 0;

	function changeModSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curModSelected += change;

		if (curModSelected < 0)
			curModSelected = modOptions.length - 1;
		if (curModSelected >= modOptions.length)
			curModSelected = 0;

		addedSmthing = false;
		var h:Int = 0;

		for (item in grpModMenu.members)
		{
			item.targetY = h - curModSelected;
			h++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		versionSht.text = modDescs[curModSelected];
	}
	var daText:FlxText;
	var currentText:String;
	function __updTxt(toThis:String){
		currentText = toThis;
	}
	var characters:Array<Character> = [];
	function doThreading(){
		trace("=== Song Loading Thread start ===");

		//Character Caching
		for (chr in [PlayState.SONG.player2,PlayState.SONG.player1,PlayState.SONG.gfVersion]){
			__updTxt("Loading: Character - "+chr+"");
			var tempChar:Character = new Character(0,0,chr);
			tempChar.alpha = 0.00001;
			add(tempChar);
			characters.push(tempChar);
			barValue++;
		}

		//Stage Caching
		__updTxt("Loading: Stage - "+PlayState.SONG.stage);
		new Stage(PlayState.SONG.stage, new PlayState(), true).createDaStage();
		barValue++;

		for (msc in [Paths.inst(PlayState.SONG.song),Paths.voices(PlayState.SONG.song)]){
			__updTxt("Loading: Song Files");
			if (msc != null) FlxG.sound.cache(msc);
			barValue++;
		}

		__updTxt("Finished! Please Wait...");
		for (i in characters){
			if (i != null) remove(i);
		}
		new FlxTimer().start(1, function(hasd:FlxTimer)
		{
			if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.2, 0);
			if (CDevConfig.saveData.smoothAF)
			{
				FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.quadOut});
			}

			playSong();
		});
	}
	function selectedSong() // look at how messy this function is
	{
		selectedBPMSONG = curSelected;
		cachingAmount = 6;
		curPlayedSong = songs[curSelected].songName;
		songBG = new FlxSprite(0, FlxG.height / 2 + 90).loadGraphic(Paths.image('healthBar', 'shared'));
		songBG.screenCenter(X);
		songBG.antialiasing = true;
		songBG.scrollFactor.set();
		add(songBG);

		songBar = new FlxBar(songBG.x + 4, songBG.y + 4, LEFT_TO_RIGHT, Std.int(songBG.width - 8), Std.int(songBG.height - 8), this, 'barValueLRP', 0, cachingAmount);
		songBar.numDivisions = 1000;
		songBar.scrollFactor.set();
		songBar.screenCenter(X);
		songBar.antialiasing = true;
		songBar.createFilledBar(FlxColor.BLACK, FlxColor.CYAN);
		add(songBar);

		daText = new FlxText(0, songBG.y + 30, "Getting ready to play the song...", 20);
		daText.setFormat("VCR OSD Mono", 20, FlxColor.CYAN, CENTER, OUTLINE, FlxColor.BLACK);
		daText.bold = true;
		daText.screenCenter(X);
		add(daText);

		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		var daSong:String = songs[curSelected].songName.toLowerCase().replace(" ", "-");

		var sel:String = (yeahNormal ? daSong : poop);
		PlayState.SONG = game.song.Song.loadFromJson(sel, songs[curSelected].songName.toLowerCase());

		if (CDevConfig.saveData.testMode && FlxG.keys.pressed.SHIFT)
			PlayState.isStoryMode = true;
		else
			PlayState.isStoryMode = false;

		if (PlayState.isStoryMode)
		{
			PlayState.storyPlaylist = [songs[curSelected].songName];
		}
		PlayState.storyDifficulty = curDifficulty;

		PlayState.storyWeek = songs[curSelected].week;
		PlayState.fromMod = songs[curSelected].fromMod;
		PlayState.difficultyName = selectedDifficulty;
		trace('CUR WEEK' + PlayState.storyWeek);

		selectedThing = true;
		if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(0.3, 0.4);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
		for (i in 0...iconArray.length)
		{
			if (i != curSelected)
			{
				FlxTween.tween(iconArray[i], {alpha: 0}, 1, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						iconArray[i].kill();
					}
				});
			}
			else
			{
				iconArray[curSelected].alpha = 1;
			}
		}
		for (item in grpSongs.members)
		{
			if (item.targetY == 0)
			{
				item.lerpOnForceX = true;
				item.alpha = 1;
				// item.screenCenter(X);
				item.xAdd -= 70;
				item.wasChoosed = true;
			}
			else
			{
				item.wasChoosed = false;
				FlxTween.tween(item, {alpha: 0}, 1, {
					ease: FlxEase.circOut,
					onComplete: function(twn:FlxTween)
					{
						item.kill();
					}
				});
			}
		}

		FlxTween.tween(scoreText, {y: scoreText.y + 200}, 1, {
			ease: FlxEase.circOut,
		});

		FlxTween.tween(tip, {y: tip.y + 150}, 1, {
			ease: FlxEase.circOut,
		});

		FlxTween.tween(songInfo, {y: songInfo.y - 100}, 1, {
			ease: FlxEase.circOut,
		});
		difficultySelectors.forEachAlive(function(hell:FlxSprite)
		{
			FlxTween.tween(hell, {y: hell.y + 100}, 1, {
				ease: FlxEase.circOut,
			});
		});

		try {
			Thread.create(doThreading);
		} catch(e){
			trace("the hell happened? " + e.toString());
			
			var text:String = "Failed loading assets for this song! Error: \n\n"+e.toString();
			var butt:Array<PopUpButton> = [
				{text: "Ok", callback: function(){
					FlxG.switchState(new MainMenuState());
				}},
			];
			openSubState(new CDevPopUp("Error", text, butt,false, true));
		}
	}

	function playSong()
	{
		LoadingState.loadAndSwitchState(new PlayState());
	}

	function songInfoUpdate()
	{
		var songName:String = songs[curSelected].songName.toUpperCase();
		var datePlayed:String = Std.string(Highscore.getSongDate(songName.toLowerCase()));

		if (datePlayed == 'null')
		{
			datePlayed = "You haven't played this song yet!";
		}
		songInfo.text = "Song: " + songName.replace('-', ' ') + "\n" + "Last played time: " + datePlayed;
		songInfo.x = (FlxG.width - songInfo.width) - 20;
	}

	function resetScore()
	{
		openSubState(new ResetScoreSubstate(songs[curSelected].songName.toLowerCase(), CoolUtil.songDifficulties[curDifficulty - 1], curDifficulty));
	}

	function readDiff(clear:Bool = false)
	{
		// currentMod = songs[curSelected].fromMod;
		var b:Bool = (songs[curSelected].fromMod != "BASEFNF");
		// trace(b);

		// var data:String = Json.parse()//Paths.modFolders()
		if (!clear)
		{
			if (b)
				CoolUtil.songDifficulties = CDevConfig.utils.readChartJsons(songs[curSelected].songName, b);
			else
				CoolUtil.songDifficulties = CoolUtil.difficultyArray;
		}
		else
			CoolUtil.songDifficulties = [];

		selectedDifficulty = CoolUtil.songDifficulties[0];
		sprDifficulty.text = CoolUtil.songDifficulties[0].toUpperCase();
		checkNormal();
	}

	function checkNormal()
	{
		if (sprDifficulty.text.endsWith("+"))
		{
			sprDifficulty.text = "NORMAL";
			yeahNormal = true;
			// trace("yes normal");
		}
		else
		{
			yeahNormal = false;
			// trace("no.");
		}
		var c = FlxColor.WHITE;
		switch (sprDifficulty.text.toLowerCase()){
			case "easy":
				c = FlxColor.LIME;
			case "normal":
				c = FlxColor.YELLOW;
			case "hard":
				c = FlxColor.RED;
		}
		sprDifficulty.color = c;
	}

	override function closeSubState()
	{
		super.closeSubState();
		changeSelection();
		if (FlxG.sound.music != null) FlxG.sound.music.play();
	}

	function changeDiff(change:Int = 0):Void
	{
		curDifficulty += change;

		if (CoolUtil.songDifficulties.length == 0) return;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.songDifficulties.length - 1;
		if (curDifficulty > CoolUtil.songDifficulties.length - 1)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		// sprDifficulty.offset.x = 0;

		sprDifficulty.text = CoolUtil.songDifficulties[curDifficulty].toUpperCase();
		selectedDifficulty = CoolUtil.songDifficulties[curDifficulty];
		/*switch (curDifficulty)
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
		}*/

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
		changeDaBPM();
		checkNormal();
	}

	var toThisColor:Int = 0;

	function changeBGColor(?fromColor:Array<Int>)
	{
		var nextColor:Int = -1;
		if (fromColor != null)
		{
			nextColor = FlxColor.fromRGB(fromColor[0], fromColor[1], fromColor[2]);
		}
		else
		{
			nextColor = game.cdev.CDevConfig.utils.getColor(iconArray[curSelected]);
		}

		if (nextColor != toThisColor)
		{
			if (tween != null)
				tween.cancel();

			toThisColor = nextColor;
			tween = FlxTween.color(bg, 1, bg.color, toThisColor, {
				onComplete: function(twn:FlxTween)
				{
					tween = null;
				}
			});
		}
	}

	function changeSelection(change:Int = 0, forceChange:Bool = false)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (songs.length == 0) return;

		if (!forceChange)
			curSelected += change;
		else
			curSelected = change;
		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		songInfoUpdate();

		#if desktop
		// Updating Discord Rich Presence
		if (Main.discordRPC)
			DiscordClient.changePresence("Freeplay Menu", "Selected: " + songs[curSelected].songName, null);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		changeBGColor(songs[curSelected].color);

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.selected = false;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.selected = true;
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		Paths.currentMod = songs[curSelected].fromMod;
		if (!songs[curSelected].weekMode)
			readDiff();
		else
			CoolUtil.songDifficulties = songs[curSelected].weekFile.weekDifficulties;
		curDifficulty = 0;
	}

	override function beatHit()
	{
		if (CDevConfig.saveData.flashing)
			bg.alpha = 1;

		if (CDevConfig.saveData.smoothAF){
			bg.scale.x += 0.02;
			bg.scale.y += 0.02;
		}

		if (iconArray[selectedBPMSONG] != null)
			iconArray[selectedBPMSONG].scale.x += 0.2;
	}

	function changeDaBPM()
	{
		if (selectedBPMSONG != curSelected)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			var daSong:String = songs[curSelected].songName.toLowerCase().replace(" ", "-");
	
			var songLowercase:String = (yeahNormal ? daSong : poop);

			if (!FileSystem.exists(songLowercase)) return;
			if (!FileSystem.exists(Paths.modJson(songs[curSelected].songName.toLowerCase() + '/' + songs[curSelected].songName.toLowerCase()))) return;
			if (!FileSystem.exists(Paths.json(songs[curSelected].songName.toLowerCase() + '/' + songs[curSelected].songName.toLowerCase()))) return;

			selectedBPMSONG = curSelected;
			var tempStoring = game.song.Song.loadFromJson(songLowercase, songs[curSelected].songName.toLowerCase());
			Conductor.changeBPM(tempStoring.bpm * speed);
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var fromMod:String = "";
	public var color:Array<Int> = [0, 0, 0];
	public var weekMode:Bool = false;
	public var weekFile:WeekFile = null;

	public function new(song:String, week:Int, songCharacter:String, fromMod:String, ?color:Array<Int>, ?weekMode:Bool = false, ?weekFile:WeekFile = null)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.fromMod = fromMod;
		this.color = color;
		this.weekMode = weekMode;
		this.weekFile = weekFile;
	}
}
