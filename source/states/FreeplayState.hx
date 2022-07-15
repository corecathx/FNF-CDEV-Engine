package states;

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
import engineutils.Discord.DiscordClient;
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
import game.*;
import cdev.VCRGrpText;
import engineutils.Highscore;
import cdev.MissingFileSubstate;
import substates.ResetScoreSubstate;

using StringTools;

//todolist:
//rewrite this all and make it more simple.
class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	static var curSelected:Int = 0;

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
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	//used for chart modifications
	var modOptions:Array<Dynamic> = [];
	var modDescs:Array<String> = [];
	var versionSht:FlxText;
	var curModSelected:Int = 0;
	var modMenuBG:FlxSprite;
	var modTitle:Alphabet;

	public static var speed:Float = 1.0;

	var modMenuOpened:Bool = false;
	private var grpModMenu:FlxTypedGroup<VCRGrpText>;

	static var selectedBPMSONG:Int = 0;

	var songBG:FlxSprite;
    var songBar:FlxBar;

	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
	private var iconArray:Array<HealthIcon> = [];
	
	var songInfo:FlxText;
	var barValue:Float = 0;
	var tip:FlxText;

	var tween:FlxTween;
	var isDebug:Bool = false;
	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		var customSongList:Array<String> = [];
		var songModListIdk:Array<String> = [];
		
		#if ALLOW_MODS
		for (directory in 0...Paths.curModDir.length) {
			var songListTxt:Array<String> = [];
			var crapz:String = Paths.curModDir[directory];

			var list:Array<String> = [];

			if (FileSystem.exists('cdev-mods/' + Paths.curModDir[directory] + '/songList.txt')){
				list = File.getContent('cdev-mods/' + Paths.curModDir[directory] + '/songList.txt').trim().split('\n');
			}
			for (i in 0...list.length) 
				list[i] = list[i].trim();

			songListTxt = list;
			for (i in 0...songListTxt.length){
				if (songListTxt.length > 0){
					customSongList.push(songListTxt[i]);
					songModListIdk.push(crapz);
					trace('\nSong: ' + songListTxt[i] + "\nMod: " + crapz);
				}

			}
		}
		#end

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1], 'BASEFNF'));
		}

		#if desktop
		for (i in 0...customSongList.length)
		{
			var bruh:Array<String> = customSongList[i].split(':');
			songs.push(new SongMetadata(bruh[0], Std.parseInt(bruh[2]), bruh[1], songModListIdk[i]));
		}
		#end

		// modName, isClickable, currentValue, min, max.
		// the min and max value are used if isClickable is true.
		// this array were messed up cuz' i'm dumb
		// oh yeah, the numbers are must be FLOAT.

		// to do: simplify this.
		modOptions = [
			['Randomize Chart', true, FlxG.save.data.randomNote],
			['Sudden Death', true, FlxG.save.data.suddenDeath],
			['Scroll Speed: ', false, FlxG.save.data.scrollSpeed, 0.1, 10],
			#if cpp ['Song Speed (BETA): ', false, speed, 0.1, 10], #end
			['Health Gain Multi: ', false, FlxG.save.data.healthGainMulti, 1, 10],
			['Health Lose Multi: ', false, FlxG.save.data.healthLoseMulti, 1, 10],
			['Combo Multipiler: ', false, FlxG.save.data.comboMultipiler,1,10]
		];

		modDescs = [
			'Randomizes your chart each time you loads a song.',
			"If you missed a single note, it will triggers an instant gameover.",
			"Change your note scroll speed.\n(If it's at 1, it will be chart dependent.)",
			"Change the speed of your song\n(BETA Testing! May cause some song looping below 1x speed.)",
			"Set how much health that you'll get from hitting a note.",
			"Set how much health that you'll losing from hitting a note.",
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
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.isFreeplay = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

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

		// diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		// diffText.font = scoreText.font;
		// add(diffText);

		scoreText = new FlxText(50, bottomPanel.y + 18, FlxG.width, "", 28);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		// scoreText.screenCenter(X);
		// scoreText.alignment = RIGHT;
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
		leftArrow.scale.set(0.9,0.9);
		difficultySelectors.add(leftArrow);

		leftArrow.y = FlxG.height - leftArrow.height - 30;

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		sprDifficulty.scale.set(0.9,0.9);
		// changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 30, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.scale.set(0.9,0.9);
		difficultySelectors.add(rightArrow);

		for (i in 0...difficultySelectors.length) difficultySelectors.members[i].antialiasing = FlxG.save.data.antialiasing;

		songInfo = new FlxText(0, 15, 1000, '', 16);
		songInfo.scrollFactor.set();
		songInfo.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(songInfo);
		songInfo.x = (FlxG.width - songInfo.width) - 20;

		var bottomPanl:FlxSprite = new FlxSprite(0, FlxG.height - 120).makeGraphic(FlxG.width, 20, 0xFF000000);
		bottomPanl.alpha = 0.8;
		add(bottomPanl);

		var daTipsTxt:String = "Press [SPACE] to play this song's instrumental. // Press [" + cdev.CDevConfig.keyBinds[4] + "] to reset this song's score & ratings. // Press [M] to open mods.";

		tip = new FlxText(50, bottomPanel.y - 16, FlxG.width, daTipsTxt, 28);
		tip.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		tip.borderSize = 2;			
		tip.screenCenter(X);
		add(tip);

		// the mod menu
		createModMenu();

		changeSelection();
		changeDiff();
		//changeModSelection();

		if (FlxG.save.data.smoothAF){
			FlxG.camera.zoom = 1.5;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.cubeOut});
		}

		super.create();
	}

	function createModMenu() {
		//Std.int(FlxG.width / 2) - 50
		modMenuBG = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		modMenuBG.alpha = 0.8;
		modMenuBG.x = FlxG.width;
		modMenuBG.scrollFactor.set();
		add(modMenuBG);

		grpModMenu = new FlxTypedGroup<VCRGrpText>();
		add(grpModMenu);
		for (i in 0...modOptions.length)
		{
			var um:VCRGrpText = new VCRGrpText(FlxG.width, FlxG.height / 2, modOptions[i][0] + (modOptions[i][1] ? '' : modOptions[i][2]), 30, FlxColor.WHITE, LEFT);
			um.isMenu = true;
			um.targetY = i;
			um.theXPos = modMenuBG.x + 50;
			um.alpha = 0;
			um.ID = i;
			//um.theText.scrollFactor.set();
			um.scrollFactor.set();
			grpModMenu.add(um);
		}

		modTitle = new Alphabet(0,50,'Mods', true, false);
		modTitle.x = modMenuBG.x + (modMenuBG.width / 2) - (modTitle.width / 2);
		modTitle.scrollFactor.set();
		modTitle.scale.set(0.9,0.9);
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
		songs.push(new SongMetadata(songName, weekNum, songCharacter,daMod));
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
		modMenuBG.x = Std.int(FlxMath.lerp(bgX, modMenuBG.x, cdev.CDevConfig.utils.bound(1 - (elapsed * 10), 0, 1)));
		versionSht.y = Std.int(FlxMath.lerp(vershit, versionSht.y, cdev.CDevConfig.utils.bound(1 - (elapsed * 7), 0, 1)));
		grpModMenu.forEachAlive(function(theThing:VCRGrpText){
			theThing.theXPos = modMenuBG.x + 50;
		});
		modTitle.x = modMenuBG.x + (modMenuBG.width / 2) - (modTitle.width / 2);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!selectedThing)
			if (FlxG.sound.music.volume < 0.7)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;			

		bg.alpha = FlxMath.lerp(0.7, bg.alpha, cdev.CDevConfig.utils.bound(1 - (elapsed * 8), 0, 1));

		// sorry for this line of codes :(
		//bg.color.red = Std.int(FlxMath.lerp(iconArray[curSelected].charColorArray[0],
		//bg.color.red, cdev.CDevConfig.utils.bound(1 - (elapsed * 4), 0, 1)));
		//bg.color.green = Std.int(FlxMath.lerp(iconArray[curSelected].charColorArray[1],
		//bg.color.green, cdev.CDevConfig.utils.bound(1 - (elapsed * 4), 0, 1)));
		///bg.color.blue = Std.int(FlxMath.lerp(iconArray[curSelected].charColorArray[2],
		//bg.color.blue, cdev.CDevConfig.utils.bound(1 - (elapsed * 4), 0, 1)));

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, 0.4);

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + "\n" + cdev.RatingsCheck.fixFloat(lerpRating, 2) + '%' + " (" + cdev.RatingsCheck.getRatingText(lerpRating)
			+ ")";

		super.update(elapsed);
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = FlxG.keys.justPressed.ENTER;

		if (selectedThing) {
				barValue += elapsed;
		}

		@:privateAccess{ //hi
			#if cpp
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, speed);
			#end			
		}

		if (!modMenuOpened) {
			if (!selectedThing)
			{

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');
					
				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');
					

				if(FlxG.mouse.wheel > 0 || upP) {
					// up
					changeSelection(-1);
				}
				else if (FlxG.mouse.wheel < 0 || downP) {
					// down
					changeSelection(1);
				}
				
				if (controls.RESET)
					resetScore();
					
				if (controls.LEFT_P)
					changeDiff(-1);
				if (controls.RIGHT_P)
					changeDiff(1);

				if (FlxG.keys.justPressed.M)
					openMods();
					
				if (controls.BACK) {
					if (FlxG.save.data.smoothAF) {
						FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.quadOut});
					}
					@:privateAccess{ //hi
						#if cpp
						if (FlxG.sound.music.playing)
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, 1.0);
						#end			
					}
					
					FlxG.switchState(new MainMenuState());
				}
		
				if (FlxG.keys.justPressed.SPACE) {					
					if (curPlayedSong != songs[curSelected].songName) {
						curPlayedSong = songs[curSelected].songName;
						#if PRELOAD_ALL
						FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
						#end
		
						#if desktop
							changeDaBPM();
						#end
					}
				}
					
				if (accepted) {
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					
					#if sys
					if (!FileSystem.exists(Paths.modJson(songs[curSelected].songName.toLowerCase() + '/' + poop))
					&& !FileSystem.exists(Paths.json(songs[curSelected].songName.toLowerCase() + '/' + poop)))
					{
						FlxG.sound.music.pause();
						openSubState(new MissingFileSubstate(poop));
					}
					else
					{
						#end
						selectedSong();
						#if sys	
					} #end
				}
			}
			} else{
				//MESS, TOTAL MESS.
				if(FlxG.mouse.wheel > 0 || upP) {
					// up
					changeModSelection(-1);
				}
				else if (FlxG.mouse.wheel < 0 || downP) {
					// down
					changeModSelection(1);
				}
				if (FlxG.keys.justPressed.ENTER && modOptions[curModSelected][1]) {
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
					saveMods();
				}
				if (!modOptions[curModSelected][1])
					{
						var valueToAdd:Float = controls.RIGHT ? 0.1 : -0.1;
						if (controls.LEFT || controls.RIGHT) {
							holdTime += elapsed;
							if (holdTime <= 0)
								FlxG.sound.play(Paths.sound('scrollMenu'));
							if (holdTime >= 0.5 || controls.LEFT_P || controls.RIGHT_P)
								{
									modOptions[curModSelected][2] += valueToAdd;

									if (modOptions[curModSelected][2] <= modOptions[curModSelected][3])
										modOptions[curModSelected][2] = modOptions[curModSelected][3];
									
									if (modOptions[curModSelected][2] >= modOptions[curModSelected][4])
										modOptions[curModSelected][2] = modOptions[curModSelected][4];

									modOptions[curModSelected][2] = FlxMath.roundDecimal(modOptions[curModSelected][2],2);

									var theValuee:Float = FlxMath.roundDecimal(modOptions[curModSelected][2],2);
									grpModMenu.forEach(function(a:VCRGrpText){
										a.theText.text = (a.ID == curModSelected ? '> ' : '  ') + modOptions[curModSelected][0] + (modOptions[curModSelected][1] ? '' : Std.string(theValuee));
									});
									saveMods();
								}
						} else holdTime = 0;						
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

				grpModMenu.forEach(function(a:VCRGrpText){
					if (a.ID == curModSelected){
						if (!addedSmthing){
							var bruh:String = a.theText.text;
							if (!a.theText.text.startsWith('> '))
								a.theText.text = "> " + bruh; 
							addedSmthing = true;							
						}
					}else{
						a.theText.text = modOptions[a.ID][0] + (modOptions[a.ID][1] ? '' : modOptions[a.ID][2]);
					}
				});
		
			}
	}

	function resetMods(){
		FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
		switch (modOptions[curModSelected][0])
		{
			case 'Randomize Chart':
				FlxG.save.data.randomNote = false;
			case 'Sudden Death':
				FlxG.save.data.suddenDeath = false;
			case 'Scroll Speed: ':
				FlxG.save.data.scrollSpeed = 1;
			case 'Song Speed (BETA): ':
				speed = 1;
				changeDaBPM();
			case 'Health Gain Multi: ':
				FlxG.save.data.healthGainMulti = 1;
			case 'Health Lose Multi: ':
				FlxG.save.data.healthLoseMulti = 1;
			case 'Combo Multipiler: ':
				FlxG.save.data.comboMultipiler = 1;
		}
		
		modOptions = [
			['Randomize Chart', true, FlxG.save.data.randomNote],
			['Sudden Death', true, FlxG.save.data.suddenDeath],
			['Scroll Speed: ', false, FlxG.save.data.scrollSpeed, 0.1, 10],
			#if cpp ['Song Speed (BETA): ', false, speed, 0.1, 10], #end
			['Health Gain Multi: ', false, FlxG.save.data.healthGainMulti, 1, 10],
			['Health Lose Multi: ', false, FlxG.save.data.healthLoseMulti, 1, 10],
			['Combo Multipiler: ', false, FlxG.save.data.comboMultipiler,1,10]
		];

		var theValuee:Float = FlxMath.roundDecimal(modOptions[curModSelected][2],2);
		grpModMenu.forEach(function(a:VCRGrpText){
			a.theText.text = (a.ID == curModSelected ? '> ' : '  ') + modOptions[curModSelected][0] + (modOptions[curModSelected][1] ? '' : Std.string(theValuee));
		});
	}
	function saveMods() {
		switch (modOptions[curModSelected][0])
		{
			case 'Randomize Chart':
				FlxG.save.data.randomNote = !FlxG.save.data.randomNote;
			case 'Sudden Death':
				FlxG.save.data.suddenDeath = !FlxG.save.data.suddenDeath;
			case 'Scroll Speed: ':
				FlxG.save.data.scrollSpeed = modOptions[curModSelected][2];
			case 'Song Speed (BETA): ':
				speed = modOptions[curModSelected][2];
				changeDaBPM();
			case 'Health Gain Multi: ':
				FlxG.save.data.healthGainMulti = modOptions[curModSelected][2];
			case 'Health Lose Multi: ':
				FlxG.save.data.healthLoseMulti = modOptions[curModSelected][2];
			case 'Combo Multipiler: ':
				FlxG.save.data.comboMultipiler = modOptions[curModSelected][2];
		}
		modOptions = [
			['Randomize Chart', true, FlxG.save.data.randomNote],
			['Sudden Death', true, FlxG.save.data.suddenDeath],
			['Scroll Speed: ', false, FlxG.save.data.scrollSpeed, 0.1, 10],
			#if cpp ['Song Speed (BETA): ', false, speed, 0.1, 10], #end
			['Health Gain Multi: ', false, FlxG.save.data.healthGainMulti, 1, 10],
			['Health Lose Multi: ', false, FlxG.save.data.healthLoseMulti, 1, 10],
			['Combo Multipiler: ', false, FlxG.save.data.comboMultipiler,1,10]
		];
	}

	function openMods() {
		modMenuOpened = true;
		addedSmthing = true;
		bgX = 0;
		vershit = FlxG.height - 100;
		changeModSelection();
	}

	function closeMods() {
		addedSmthing = true;
		modMenuOpened = false;
		bgX = FlxG.width;
		vershit = FlxG.height + 200;
	}
	var holdTime:Float = 0;

	function changeModSelection(change:Int = 0) {
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

	function selectedSong() //look at how messy this function is
		{
			curPlayedSong = songs[curSelected].songName;
			songBG = new FlxSprite(0, FlxG.height / 2 + 90).loadGraphic(Paths.image('healthBar', 'shared'));
			songBG.screenCenter(X);
			songBG.antialiasing = true;
			songBG.scrollFactor.set();
			add(songBG);
	
			songBar = new FlxBar(songBG.x + 4, songBG.y + 4, LEFT_TO_RIGHT, Std.int(songBG.width - 8), Std.int(songBG.height - 8), this,'barValue', 0, 3);
			songBar.numDivisions = 1000;
			songBar.scrollFactor.set();
			songBar.screenCenter(X);
			songBar.antialiasing = true;
			songBar.createFilledBar(FlxColor.BLACK, FlxColor.CYAN);
			add(songBar);

			var daText:FlxText = new FlxText(0,songBG.y + 30, "Getting ready to play the song...", 20);
			daText.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.YELLOW,CENTER, OUTLINE,FlxColor.BLACK);
			daText.screenCenter(X);
			add(daText);

			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = song.Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			
			if (isDebug && FlxG.keys.pressed.SHIFT)
				PlayState.isStoryMode = true;
			else
				PlayState.isStoryMode = false;

			if (PlayState.isStoryMode){
				PlayState.storyPlaylist = [songs[curSelected].songName];
			}
			PlayState.storyDifficulty = curDifficulty;
	
			PlayState.storyWeek = songs[curSelected].week;
			PlayState.fromMod = songs[curSelected].fromMod;
			trace('CUR WEEK' + PlayState.storyWeek);

			/*
			if (!FLAssets.cache.hasSound(Paths.inst(PlayState.SONG.song)))
				FlxG.sound.cache(Paths.inst(PlayState.SONG.song));

			if (!FLAssets.cache.hasSound(Paths.voices(PlayState.SONG.song)))
				FlxG.sound.cache(Paths.voices(PlayState.SONG.song));*/

			selectedThing = true;
			FlxG.sound.music.fadeOut(0.3, 0.4);
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
						} else{
							iconArray[curSelected].alpha = 1;
						}
				}
			for (item in grpSongs.members)
				{		
					if (item.targetY == 0)
						{
							item.alpha = 1;
							item.wasChoosed = true;
							// item.setGraphicSize(Std.int(item.width));
						} else{
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
			difficultySelectors.forEachAlive(function(hell:FlxSprite){
				FlxTween.tween(hell, {y: hell.y + 100}, 1, {
					ease: FlxEase.circOut,
					});					
			});
			new FlxTimer().start(3, function(hasd:FlxTimer){
				FlxG.sound.music.fadeOut(0.2, 0);
				playSong();
			});
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
		var shit:String = '';
		switch (curDifficulty)
		{
			case 0:
				shit = 'easy';
			case 1:
				shit = 'normal';
			case 2:
				shit = 'hard';
		}
		openSubState(new ResetScoreSubstate(songs[curSelected].songName.toLowerCase(), shit, curDifficulty));
	}

	override function closeSubState()
	{
		super.closeSubState();
		changeSelection();
		FlxG.sound.music.play();
	}

	function changeDiff(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

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

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}
	var toThisColor:Int = 0;
	function changeBGColor() {
		var nextColor:Int = cdev.CDevConfig.utils.getColor(iconArray[curSelected]);
		if (nextColor != toThisColor)
		{
			if (tween != null)
				tween.cancel();

			toThisColor = nextColor;
			tween = FlxTween.color(bg, 1, bg.color, toThisColor, {onComplete: function(twn:FlxTween){
				tween = null;
			}});
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

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

		changeBGColor();

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
	}

	override function beatHit()
	{
		if (FlxG.save.data.flashing)
			bg.alpha = 1;
	}

	function changeDaBPM()
	{
		#if sys
		if (selectedBPMSONG != curSelected)
		{
			PlayState.SONG = null;
			selectedBPMSONG = curSelected;
			var songLowercase:String = songs[curSelected].songName.toLowerCase().replace(' ', "-");

			if (FileSystem.exists(songLowercase))
			{
				PlayState.SONG = song.Song.loadFromJson(songLowercase, songs[curSelected].songName.toLowerCase());

				Conductor.changeBPM(PlayState.SONG.bpm * speed);
			}

			if (FileSystem.exists(Paths.modJson(songs[curSelected].songName.toLowerCase() + '/' + songs[curSelected].songName.toLowerCase())))
			{
				PlayState.SONG = song.Song.loadFromJson(songLowercase, songs[curSelected].songName.toLowerCase());

				Conductor.changeBPM(PlayState.SONG.bpm * speed);
			}

			if (FileSystem.exists(Paths.json(songs[curSelected].songName.toLowerCase() + '/' + songs[curSelected].songName.toLowerCase())))
			{
				PlayState.SONG = song.Song.loadFromJson(songLowercase, songs[curSelected].songName.toLowerCase());

				Conductor.changeBPM(PlayState.SONG.bpm * speed);
			}
		}
		#end
	}
} class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var fromMod:String = "";

	public function new(song:String, week:Int, songCharacter:String, fromMod:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.fromMod = fromMod;
	}
}
