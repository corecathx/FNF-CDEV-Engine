package;

import flixel.util.FlxTimer;
import flixel.graphics.FlxGraphic;
#if sys
import sys.FileSystem;
#end
import flixel.FlxBasic.FlxType;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
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

using StringTools;

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

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	var difficultySelectors:FlxTypedGroup<FlxSprite>;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	static var selectedBPMSONG:Int = 0;

	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));

	private var iconArray:Array<HealthIcon> = [];
	private var arrowArray:Array<ArrowSprite> = [];

	var songInfo:FlxText;
	var bgColorTween:FlxTween;
	var arrow:FlxSprite;

	var arrowPosLerpX:Float = 0;
	var arrowPosLerpY:Float = 0;

	var songTimer:FlxTimer;

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		#if desktop
		var customSongList = CoolUtil.coolTextFile(Paths.modText('modList'));
		#end

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}

		#if desktop
		for (i in 0...customSongList.length)
		{
			var bruh:Array<String> = customSongList[i].split(':');
			songs.push(new SongMetadata(bruh[0], Std.parseInt(bruh[2]), bruh[1]));
		}
		#end
		
		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		var isDebug:Bool = false;
		Conductor.changeBPM(100);

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
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT,OUTLINE,FlxColor.BLACK);
		// scoreText.screenCenter(X);
		// scoreText.alignment = RIGHT;
		scoreText.borderSize = 2;

		add(scoreText);
		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		difficultySelectors = new FlxTypedGroup<FlxSprite>();
		add(difficultySelectors);

		leftArrow = new FlxSprite(700, 0);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		leftArrow.y = FlxG.height - leftArrow.height - 30;

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		// changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		songInfo = new FlxText(0, 15, 1000, '', 16);
		songInfo.scrollFactor.set();
		songInfo.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(songInfo);
		songInfo.x = (FlxG.width - songInfo.width) - 20;

		changeSelection();
		changeDiff();
		changeDaBPM();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */


		if (FlxG.save.data.smoothAF)
			{
				FlxG.camera.zoom = 1.5;

				FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.cubeOut});				
			}

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var bruhMoment:String = '';
	var crapBGColor:FlxColor;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		bg.alpha = FlxMath.lerp(0.6, bg.alpha, 0.95);

		//sorry for this line of codes :(
		bg.color.red = Std.int(FlxMath.lerp(iconArray[curSelected].charColorArray[0], bg.color.red, CDevConfig.utils.bound(1 - (elapsed * 4), 0, 1)));
		bg.color.green = Std.int(FlxMath.lerp(iconArray[curSelected].charColorArray[1], bg.color.green, CDevConfig.utils.bound(1 - (elapsed * 4), 0, 1)));
		bg.color.blue = Std.int(FlxMath.lerp(iconArray[curSelected].charColorArray[2], bg.color.blue, CDevConfig.utils.bound(1 - (elapsed * 4), 0, 1)));

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore,0.4));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, 0.4);

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + "\n" + RatingsCheck.fixFloat(lerpRating, 2) + '%' + " (" + RatingsCheck.getRatingText(lerpRating)+ ")"; 

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.RIGHT)
			rightArrow.animation.play('press')
		else
			rightArrow.animation.play('idle');

		if (controls.LEFT)
			leftArrow.animation.play('press');
		else
			leftArrow.animation.play('idle');

		if (controls.RESET)
			{
				resetScore();
			}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			if (FlxG.save.data.smoothAF)
				{
					FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.quadOut});
				}
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			#if sys
			if (!FileSystem.exists(Paths.modJson(songs[curSelected].songName.toLowerCase() + '/' + poop))
				&& !FileSystem.exists(Paths.json(songs[curSelected].songName.toLowerCase() + '/' + poop)))
			{
				FlxG.sound.music.pause();
				openSubState(new MissingFileSubstate(poop));
			} else{#end
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				//FlxG.switchState(new LoadingState());
				LoadingState.loadAndSwitchState(new PlayState());				
				#if sys
			}
			#end
		}

		super.update(elapsed);
	}

	function songInfoUpdate()
		{
			var songName:String = songs[curSelected].songName.toUpperCase();
			var datePlayed:String = Std.string(Highscore.getSongDate(songName.toLowerCase()));

			if (datePlayed == 'null')
				{
					datePlayed = "You have'nt played this song yet!";
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

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		songInfoUpdate();

		#if desktop
		// Updating Discord Rich Presence
		if (Main.discordRPC)
			DiscordClient.changePresence("Freeplay Menu", songs[curSelected].songName, null);
		#end

		#if desktop
		changeDaBPM();
		#end
		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end		

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

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
			bg.alpha = 0.9;
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
				PlayState.SONG = Song.loadFromJson(songLowercase, songs[curSelected].songName.toLowerCase());

				Conductor.changeBPM(PlayState.SONG.bpm);
			}

			if (FileSystem.exists(Paths.modJson(songs[curSelected].songName.toLowerCase() + '/' + songs[curSelected].songName.toLowerCase())))
			{
				PlayState.SONG = Song.loadFromJson(songLowercase, songs[curSelected].songName.toLowerCase());

				Conductor.changeBPM(PlayState.SONG.bpm);
			}

			if (FileSystem.exists(Paths.json(songs[curSelected].songName.toLowerCase() + '/' + songs[curSelected].songName.toLowerCase())))
				{
					PlayState.SONG = Song.loadFromJson(songLowercase, songs[curSelected].songName.toLowerCase());
	
					Conductor.changeBPM(PlayState.SONG.bpm);
				}
		}
		#end
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
