package states;

import flixel.util.FlxAxes;
import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import haxe.Http;
import flixel.math.FlxMath;
import flixel.util.FlxGradient;
#if desktop
import engineutils.Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import engineutils.PlayerSettings;
import game.Paths;
import cdev.CDevConfig;
import game.Alphabet;
import game.Conductor;

using StringTools;

class TitleState extends MusicBeatState
{
	// experimental
	var titleTextEffects:Array<String> = ["wavy", "bouncy"];
	var isLoaded:Bool = false;

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxTypedGroup<Alphabet>;
	var credTextShit:game.Alphabet;
	var textGroup:FlxTypedGroup<Alphabet>;
	var ngSpr:FlxSprite;
	var yOffset:Float = 0;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var debugShit:Bool = false;

	var checker:FlxBackdrop;
	var speed:Float = 1;

	override public function create():Void
	{
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end

		checkGitHubVersion();

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		// NGio.noLogin(APIStuff.API);
		FlxG.save.bind('cdev_engine', 'EngineData');

		engineutils.Highscore.load();

		CDevConfig.initializeSaves();
		#if debug
		CDevConfig.debug = true;
		#end

		/*if (FlxG.save.data.weekUnlocked != null)
			{
				// FIX LATER!!!
				// WEEK UNLOCK PROGRESSION!!
				// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

				if (StoryMenuState.weekUnlocked.length < 4)
					StoryMenuState.weekUnlocked.insert(0, true);

				// QUICK PATCH OOPS!
				if (!StoryMenuState.weekUnlocked[0])
					StoryMenuState.weekUnlocked[0] = true;
		}*/

		#if debug
		debugShit = true;
		#end
		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		#if desktop
		if (!FlxG.save.data.discordRpc)
		{
			DiscordClient.shutdown();
		}
		else
		{
			DiscordClient.initialize();
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var bg:FlxSprite;

	function startIntro()
	{
		if (!isLoaded)
		{
			if (!initialized)
			{
				var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
				diamond.persist = true;
				diamond.destroyOnNoUse = false;

				FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
				FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// HAD TO MODIFY SOME BACKEND SHIT
				// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
				// https://github.com/HaxeFlixel/flixel-addons/pull/348

				// var music:FlxSound = new FlxSound();
				// music.loadStream(Paths.music('freakyMenu'));
				// FlxG.sound.list.add(music);
				// music.play();
			}
			// persistentUpdate = true;

			bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.BLUE], 1, 90, true);
			bg.antialiasing = FlxG.save.data.antialiasing;
			bg.scale.set(1.2, 1.2);
			bg.alpha = 0.4;
			add(bg);

			checker = new FlxBackdrop(Paths.image('checker', 'preload'), FlxAxes.XY);
			checker.scale.set(1.5, 1.5);
			checker.color = FlxColor.CYAN;
			checker.blend = BlendMode.LIGHTEN;
			add(checker);
			checker.scrollFactor.set(0, 0.07);
			checker.alpha = 0.5;
			checker.updateHitbox();

			logoBl = new FlxSprite(-50, 10);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBl.antialiasing = FlxG.save.data.antialiasing;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.animation.play('bump');
			logoBl.updateHitbox();
			// logoBl.screenCenter();
			// logoBl.color = FlxColor.BLACK;

			gfDance = new FlxSprite(FlxG.width * 0.4 + 50, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'GF Dancing Beat blue', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'GF Dancing Beat blue', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			gfDance.antialiasing = FlxG.save.data.antialiasing;
			add(gfDance);
			add(logoBl);

			titleText = new FlxSprite(100, FlxG.height * 0.8);
			titleText.frames = Paths.getSparrowAtlas('titleEnter');
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
			titleText.antialiasing = FlxG.save.data.antialiasing;
			titleText.animation.play('idle');
			titleText.updateHitbox();
			// titleText.screenCenter(X);
			titleText.scale.set(0.9, 0.9);
			add(titleText);

			logoY = logoBl.y;
			gfY = gfDance.y;
			tTextY = titleText.y;

			var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
			logo.screenCenter();
			logo.antialiasing = FlxG.save.data.antialiasing;
			// add(logo);

			// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
			// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});
			blackScreen = new FlxSprite(-1000, -1000).makeGraphic(2500, 2500, FlxColor.BLACK);
			add(blackScreen);
			credGroup = new FlxTypedGroup<Alphabet>();
			add(credGroup);
			textGroup = new FlxTypedGroup<Alphabet>();

			credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
			credTextShit.screenCenter();

			// credTextShit.alignment = CENTER;

			credTextShit.visible = false;

			if (!FlxG.save.data.engineWM)
			{
				ngSpr = new FlxSprite(0, FlxG.height * 0.52 + 30).loadGraphic(Paths.image('newgrounds_logo'));
				add(ngSpr);
				ngSpr.visible = false;
				ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
				ngSpr.updateHitbox();
				ngSpr.screenCenter(X);
				ngSpr.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				ngSpr = new FlxSprite(0, FlxG.height * 0.52 + 70).loadGraphic(Paths.image('core5570r'));
				add(ngSpr);
				ngSpr.visible = false;
				ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.1));
				ngSpr.updateHitbox();
				ngSpr.screenCenter(X);
				ngSpr.antialiasing = FlxG.save.data.antialiasing;
			}

			FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

			FlxG.mouse.visible = false;

			if (initialized)
				skipIntro();
			else
				initialized = true;
		}
		if (!isLoaded)
		{
			// used this code to avoid the song from skipping some beats

			if (!closedState)
			{
				Conductor.changeBPM(102);
				if (FlxG.sound.music == null)
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
			isLoaded = true;
		}

		FlxG.camera.zoom = 0.9;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var intendedSpeed:Float = 1;

	override function update(elapsed:Float)
	{
		if (isLoaded)
		{
			bg.alpha = FlxMath.lerp(0.2, bg.alpha, CDevConfig.utils.bound(1 - (elapsed * 7), 0, 1));
			if (FlxG.sound.music != null)
				Conductor.songPosition = FlxG.sound.music.time;
			// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);
			speed = FlxMath.lerp(intendedSpeed, speed, CDevConfig.utils.bound(1 - (elapsed * 2), 0, 1));
			checker.x -= 0.45 / (FlxG.save.data.fpscap / 60);
			checker.y -= (0.16 / (FlxG.save.data.fpscap / 60)) * speed;

			for (i in 0...credGroup.members.length)
			{
				if (credGroup.members[i].effect == "wavy")
					_runTextEffect(credGroup.members[i].effect, credGroup.members[i]);
			}

			var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

			#if mobile
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed)
				{
					pressedEnter = true;
				}
			}
			#end

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.START)
					pressedEnter = true;

				#if switch
				if (gamepad.justPressed.B)
					pressedEnter = true;
				#end
			}

			if (pressedEnter && !transitioning && skippedIntro)
			{
				titleText.animation.play('press');
				intendedSpeed += 100;

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					// Check if version is outdated

					goToMain();
					closedState = true;
					if (debugShit && FlxG.keys.pressed.SHIFT)
					{
						FlxG.switchState(new OutdatedState());
					}
					else
					{
						if (!shouldUpdate)
							FlxG.switchState(new MainMenuState());
						else
						{
							if (FlxG.save.data.checkNewVersion)
								FlxG.switchState(new OutdatedState());
							else
								FlxG.switchState(new MainMenuState());
						}
					}
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}

			if (pressedEnter && !skippedIntro)
			{
				skipIntro();
			}
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?effect:String = "default")
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + yOffset;
			money.effect = effect;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	public static var closedState:Bool = false;

	var shouldUpdate:Bool = false;

	public static var onlineVer:String = '';

	function checkGitHubVersion()
	{
		if (!closedState)
		{
			trace('we do som update checking!1!!1');
			var http = new Http("https://raw.githubusercontent.com/Core5570RYT/FNF-CoreDEV-Engine/master/githubVersion.txt");

			http.onData = function(data:String)
			{
				onlineVer = data.split('\n')[0].trim();
				var curVersion:String = CDevConfig.engineVersion.trim();
				trace('GitHub Version: ' + onlineVer + ', Your version: ' + curVersion);
				if (onlineVer != curVersion)
				{
					trace('different versions.');
					shouldUpdate = true;
				}
			}

			http.onError = function(error)
			{
				trace('error: $error');
			}

			http.request();
		}
	}

	function addMoreText(text:String, ?effect:String = "default")
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.effect = effect;
		coolText.y += (textGroup.length * 60) + 200 + yOffset;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (isLoaded)
		{
			logoBl.animation.play('bump', true);
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');

			FlxG.log.add(curBeat);

			bg.alpha = 0.3;

			switch (curBeat)
			{
				case 1:
					yOffset = -30; // Y offset of these intro texts or shit
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8r']);
				// credTextShit.visible = true;
				case 3:
					addMoreText('present');
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					yOffset = 10;
					if (FlxG.save.data.engineWM)
						createCoolText(['CDEV Engine', 'By']);
					else
						createCoolText(['Not Associated', 'With']);
				case 7:
					if (FlxG.save.data.engineWM)
						addMoreText('CoreDev');
					else
					{
						addMoreText('Newgrounds');
					}
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 9:
					var text:String = _getText(curWacky[0], _getTextEffect(curWacky[0]));
					createCoolText([text], _getTextEffect(curWacky[0]));
				// credTextShit.visible = true;
				case 11:
					var text:String = _getText(curWacky[1], _getTextEffect(curWacky[1]));
					addMoreText(text, _getTextEffect(curWacky[1]));
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					yOffset = 10;
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 14:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 16:
					skipIntro();
			}
			for (i in 0...credGroup.members.length)
			{
				if (credGroup.members[i].effect == "bouncy")
					_runTextEffect(credGroup.members[i].effect, credGroup.members[i]);
			}
		}
	}

	var skippedIntro:Bool = false;

	var logoY:Float = 0;
	var gfY:Float = 0;
	var tTextY:Float = 0;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			// FlxG.camera.y = 720;
			logoBl.y = FlxG.height;
			gfDance.y = FlxG.height + 100;
			titleText.y = FlxG.height + 300;
			FlxTween.tween(logoBl, {y: logoY}, 2, {ease: FlxEase.circOut});
			FlxTween.tween(gfDance, {y: gfY}, 2, {ease: FlxEase.circOut});
			FlxTween.tween(titleText, {y: tTextY}, 2, {ease: FlxEase.circOut});

			remove(ngSpr);
			FlxG.camera.flash(FlxColor.WHITE, 1);
			remove(credGroup);
			remove(blackScreen);
			skippedIntro = true;
		}
	}

	function goToMain()
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.circOut});
	}

	function _getTextEffect(s:String)
	{
		for (eff in titleTextEffects)
		{
			if (s.startsWith('<$eff>'))
				return eff;
		}

		return "default";
	}

	function _getText(s:String, effect:String)
	{
		return s.replace('<$effect>', "");
	}

	function _runTextEffect(s:String, alphab:Alphabet)
	{
		switch (s)
		{
			case "wavy":
				for (alp in 0...alphab.members.length)
				{
					alphab.members[alp].y += (Math.sin(((Conductor.songPosition / 1000) * (Conductor.bpm / 60))+ alp*0.15) * Math.PI)/6;
				}
			case "bouncy":
				alphab.scale.x += 0.3;
				alphab.scale.y -= 0.5;
				// alphab.y += 10;
				FlxTween.tween(alphab.scale, {x: 1, y: 1}, (Conductor.crochet / 1000) - 0.1, {ease: FlxEase.sineInOut});
		}
	}
}
