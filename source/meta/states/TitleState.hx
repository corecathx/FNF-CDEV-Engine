package meta.states;

import haxe.Timer;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import game.system.native.Windows;
import game.system.FunkinThread;
import lime.system.System;
import game.cdev.CDevMods.ModFile;
import flixel.util.FlxAxes;
import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import haxe.Http;
import flixel.math.FlxMath;
import flixel.util.FlxGradient;
#if desktop
import game.cdev.engineutils.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;
import game.cdev.engineutils.PlayerSettings;
import game.Paths;
import game.cdev.CDevConfig;
import game.objects.Alphabet;
import game.Conductor;

using StringTools;

class TitleState extends MusicBeatState
{
	// experimental
	public static var loadMod:Bool = false;

	var titleTextEffects:Array<String> = ["wavy", "bouncy"];

	public static var loadingBS:Array<String> = [
		"Checking on assets n' stuff.",
		"Ooh, cdev-mods folder.",
		"Preparing for something.",
		"CDEV Engine v"+CDevConfig.engineVersion,
		"Staring deep to your soul.",
		"Pro tip: Press the notes.",
		"Gimme some time to load GlowFilter :skull:",
		"Checking your OS.",
		"This process usually took like 5 secs to finish.",
		"Nuh uh.",
		"Hello.",
		"Don't stay in this game for more than 2 hours.",
		"Pro tip: touch grass."
	];

	static var isLoaded:Bool = false;

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxTypedGroup<Alphabet>;
	var credTextShit:game.objects.Alphabet;
	var textGroup:FlxTypedGroup<Alphabet>;
	var ngSpr:FlxSprite;
	var yOffset:Float = 0;
	
	var cameraInitialZoom:Float = 0.9;

	var curWacky:Array<String> = [];

	var checker:FlxBackdrop;
	var speed:Float = 1;

	var lol:Bool = false;

	var glow:GlowFilter;
	var glowFilter:FlxFilterFrames;
	var logoBlFrames:FlxAtlasFrames;
	var startLoading:Float = 0;

	var uDumb:FlxText;

	override public function create():Void
	{
		checkGitHubVersion();
		FlxG.camera.zoom = cameraInitialZoom;
		curWacky = FlxG.random.getObject(getIntroTextShit());

		#if debug
		CDevConfig.debug = true;
		#end

		lol = FlxG.random.bool(0.3);
		if (lol) trace("nahh :skull:");

		#if windows
		if (Paths.curModDir.length == 1)
		{
			if (!loadMod)
			{
				Paths.currentMod = Paths.curModDir[0];
				loadMod = true;
			} else{
				CDevConfig.setWindowProperty(true, "", "");
			}
		}
		else
		{
			CDevConfig.setWindowProperty(true, "", "");
		}

		if (loadMod)
		{
			var d:ModFile = Paths.modData();

			CDevConfig.setWindowProperty(false, Reflect.getProperty(d, "window_title"), Paths.modFolders("winicon.png"));
		}
		CDevConfig.utils.getStateScript("TitleState", false);
		#end

		isLoaded = false; // DIE

		if (!initialized){
			uDumb = new FlxText(0,0,-1,loadingBS[FlxG.random.int(0,loadingBS.length-1)]+"\nLoading...", 24);
			uDumb.font = FunkinFonts.CONSOLAS;
			uDumb.alignment = CENTER;
			uDumb.antialiasing = CDevConfig.saveData.antialiasing;
			uDumb.screenCenter();
			add(uDumb);
		}
		
		new FlxTimer().start(0.5, (_) -> {
			startLoading = Timer.stamp();
			trace("Loading TitleState...");
			startIntro();
		});


		super.create();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var bg:FlxSprite;

	function startIntro()
	{
		transOut = FlxTransitionableState.defaultTransOut;
		transIn = FlxTransitionableState.defaultTransIn;
		Main.fpsCounter.visible = (CDevConfig.saveData.performTxt != "hide");

		bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.BLUE], 1, 90, true);
		bg.antialiasing = CDevConfig.saveData.antialiasing;
		bg.scale.set(1.2, 1.2);
		bg.alpha = 0.4;
		add(bg);

		checker = new FlxBackdrop(Paths.image('checker', 'preload'), FlxAxes.XY);
		checker.scale.set(1.5, 1.5);
		checker.color = 0xFF006AFF;
		checker.blend = BlendMode.LAYER;
		add(checker);
		checker.scrollFactor.set(0, 0.07);
		checker.alpha = 0.4;
		checker.updateHitbox();

		logoBl = new FlxSprite(-50, 10);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = CDevConfig.saveData.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		for (i in 0...4){
			logoBl.animation.addByIndices(i+"freakyText", "funkinText", [i], "",24, true);
		}
		logoBl.animation.play('0freakyText');
		logoBl.updateHitbox();
		logoBl.visible = false;

		gfDance = new FlxSprite(FlxG.width * 0.4 + 50, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'GF Dancing Beat blue', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'GF Dancing Beat blue', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = CDevConfig.saveData.antialiasing;
		add(gfDance);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = CDevConfig.saveData.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.scale.set(0.9, 0.9);
		//titleText.screenCenter(X);
		add(titleText);

		logoY = logoBl.y + 50;
		logoX = logoBl.x;
		gfY = gfDance.y;
		tTextY = titleText.y;

		blackScreen = new FlxSprite(0, 0);//.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.frames = Paths.getSparrowAtlas("funkinVid");
		blackScreen.animation.addByPrefix("idle", "idle", 24, true);
		blackScreen.animation.play("idle", true);
		blackScreen.setGraphicSize(FlxG.width,FlxG.height);
		blackScreen.scale.x += 0.26;
		blackScreen.scale.y += 0.26;
		blackScreen.screenCenter();
		blackScreen.antialiasing = CDevConfig.saveData.antialiasing;
		blackScreen.color = 0xFF132841; //set the color to a bit darker ones
		add(blackScreen);
		add(logoBl);
		credGroup = new FlxTypedGroup<Alphabet>();
		add(credGroup);
		textGroup = new FlxTypedGroup<Alphabet>();

		if (!CDevConfig.saveData.engineWM)
		{
			ngSpr = new FlxSprite(0, FlxG.height * 0.52 + 30).loadGraphic(Paths.image('newgrounds_logo'));
			add(ngSpr);
			ngSpr.visible = false;
			ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
			ngSpr.updateHitbox();
			ngSpr.screenCenter(X);
			ngSpr.antialiasing = CDevConfig.saveData.antialiasing;
		}
		else
		{
			if (!lol)
				ngSpr = new FlxSprite(0, FlxG.height * 0.52 + 70).loadGraphic(Paths.image('core5570r'));
			else
				ngSpr = new FlxSprite(0, FlxG.height * 0.52 + 70).loadGraphic(Paths.image('normaldifficulty', "shared"));
			add(ngSpr);
			ngSpr.visible = false;
			ngSpr.setGraphicSize(Std.int(ngSpr.width * (!lol ? 0.1 : 0.5)));
			ngSpr.updateHitbox();
			ngSpr.screenCenter(X);
			ngSpr.antialiasing = CDevConfig.saveData.antialiasing;
		}

		FlxG.mouse.visible = false;

		if (!initialized){
			var last = Timer.stamp();
			trace("Loading Glow Filter...");
			glow = new GlowFilter(0x0084FF, 0.5, 50, 50, 40, 1);
			glowFilter = FlxFilterFrames.fromFrames(logoBl.frames,50,50,[glow]);
			glowFilter.applyToSprite(logoBl,true, true);
			trace("Glow Filter loaded, " + (Timer.stamp() - last) + "s elapsed.");
	
			logoBlFrames = Paths.getSparrowAtlas('logoBumpin'); // nah
		}

		
		if (initialized)
			skipIntro();
		else
			initialized = true;

		if (!isLoaded)
		{
			// used this code to avoid the song from skipping some beats
			if (!closedState)
			{
				Conductor.changeBPM(183);
				if (FlxG.sound.music == null)
					FlxG.sound.playMusic(Paths.music('funkinBeat'), 0);

				FlxG.sound.music.fadeIn((Conductor.crochet*4)/1000, 0, 0.7);
			}
			isLoaded = true;
		}

		trace("Finished loading state, " + (Timer.stamp() - startLoading) + "s elapsed.");

		destroyLoadingText();
	}

	function destroyLoadingText(){
		if (uDumb != null){
			uDumb.destroy();
			remove(uDumb);
			uDumb = null;
		}
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
			if (blackScreen != null){
				blackScreen.setGraphicSize(FlxG.width,FlxG.height);
				blackScreen.scale.x += 0.26;
				blackScreen.scale.y += 0.26;
			}
			bg.alpha = FlxMath.lerp(0.2, bg.alpha, CDevConfig.utils.bound(1 - (elapsed * 7), 0, 1));
			if (FlxG.sound.music != null)
				Conductor.songPosition = FlxG.sound.music.time;

			speed = FlxMath.lerp(intendedSpeed, speed, CDevConfig.utils.bound(1 - (elapsed * 2), 0, 1));
			checker.x -= 0.45 / (CDevConfig.saveData.fpscap / 60);
			checker.y -= (0.16 / (CDevConfig.saveData.fpscap / 60)) * speed;

			FlxG.camera.zoom = FlxMath.lerp(cameraInitialZoom, FlxG.camera.zoom, 1-(elapsed*5));

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

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					goToMain();
					closedState = true;
					if (CDevConfig.saveData.testMode && FlxG.keys.pressed.SHIFT)
					{
						FlxG.switchState(new OutdatedState());
					}
					else
					{
						if (!shouldUpdate)
							FlxG.switchState(new MainMenuState());
						else
						{
							if (CDevConfig.saveData.checkNewVersion)
								FlxG.switchState(new OutdatedState());
							else
								FlxG.switchState(new MainMenuState());
						}
					}
				});
			}

			if (pressedEnter && !skippedIntro)
				skipIntro();
		}

		super.update(elapsed);
	}

	override function destroy() {
		trace("Destroying TitleState...");
		if (gfDance != null) gfDance.destroy();
		if (blackScreen != null) blackScreen.destroy();
		if (bg != null) bg.destroy();
		if (checker != null) checker.destroy();
		if (logoBl != null) logoBl.destroy();
		if (titleText != null) titleText.destroy();
		super.destroy();
	}

	function createCoolText(textArray:Array<String>, ?effect:String = "default")
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
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
			var http = new Http("https://raw.githubusercontent.com/Core5570RYT/FNF-CDEV-Engine/master/githubVersion.txt");

			http.onData = function(data:String)
			{
				onlineVer = data.split('\n')[0].trim();
				var curVersion:String = CDevConfig.engineVersion.trim();
				// var curVersion:String = "0.01".trim();
				trace('GitHub Version: ' + onlineVer + ', Your version: ' + curVersion);
				if (onlineVer != curVersion)
				{
					trace('different versions.');
					// FlxG.switchState()
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
		var coolText:Alphabet = new Alphabet(0, 0, text, true);
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

	var progress:Int = 0;
	override function beatHit()
	{
		super.beatHit();

		if (isLoaded)
		{
			if (curBeat % 2 == 0) FlxG.camera.zoom += 0.05;
			if (skippedIntro) logoBl.animation.play('bump', true);
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');

			FlxG.log.add(curBeat);

			bg.alpha = 0.3;

			if (!skippedIntro) switch (curBeat)
			{
				case 1:
					yOffset = -30; // Y offset of these intro texts or shit
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8r']);
				case 4:
					addMoreText('present');
				case 6:
					deleteCoolText();
				case 8:
					yOffset = 10;
					if (CDevConfig.saveData.engineWM)
						createCoolText((!lol ? ['CDEV Engine', 'By'] : []));
					else
						createCoolText(['Newgrounds', 'Everything by']);
				case 12:
					if (CDevConfig.saveData.engineWM)
						addMoreText((!lol?'CoreDev' : ""));
					else
						addMoreText('Everyone');
					ngSpr.visible = true;
				case 14:
					deleteCoolText();
					ngSpr.visible = false;
				case 16:
					yOffset = 70;
					var text:String = _getText(curWacky[0], _getTextEffect(curWacky[0]));
					createCoolText([text], _getTextEffect(curWacky[0]));
				case 20:
					var text:String = _getText(curWacky[1], _getTextEffect(curWacky[1]));
					addMoreText(text, _getTextEffect(curWacky[1]));
				case 22:
					deleteCoolText();
					logoBl.screenCenter();
				case 24,26,28,30:
					FlxG.camera.zoom += 0.05;
					logoBl.visible = true;
					logoBl.animation.play('${progress}freakyText', true);
					progress++;
					switch (curBeat){
						case 24:
							logoBl.scale.set(0.5,0.5);
							FlxTween.tween(logoBl.scale,{x: 1.2,y: 1.2}, (Conductor.crochet*7.89)/1000, {ease:FlxEase.cubeIn});
						case 28:
							FlxG.camera.shake(0.005,(Conductor.crochet*4)/1000);
					}
				case 32:
					logoBl.animation.play('bump', true);
					logoBl.scale.set(1,1);
					skipIntro();
					FlxG.camera.zoom += 0.1;
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
	var logoX:Float = 0;
	var gfY:Float = 0;
	var tTextY:Float = 0;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			// FlxG.camera.y = 720;
			logoBl.visible = true;
			if (logoBlFrames != null) logoBl.setFrames(logoBlFrames, true);
			logoBl.x = logoX;
			logoBl.y = FlxG.height;
			gfDance.y = FlxG.height + 100;
			titleText.y = FlxG.height + 300;
			FlxTween.tween(logoBl, {y: logoY}, 2, {ease: FlxEase.circOut});
			FlxTween.tween(gfDance, {y: gfY}, 2, {ease: FlxEase.circOut});
			FlxTween.tween(titleText, {y: tTextY}, 2, {ease: FlxEase.circOut});

			remove(ngSpr);
			FlxG.camera.flash(FlxColor.WHITE, (Conductor.crochet*4)/1000);
			remove(credGroup);
			blackScreen.destroy();
			remove(blackScreen);
			blackScreen = null;
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
					alphab.members[alp].y += (Math.sin(((Conductor.songPosition / 1000) * (Conductor.bpm / 60)) + alp * 0.15) * Math.PI) / 6;
				}
			case "bouncy":
				alphab.scale.x += 0.3;
				alphab.scale.y -= 0.5;
				// alphab.y += 10;
				FlxTween.tween(alphab.scale, {x: 1, y: 1}, (Conductor.crochet / 1000) - 0.1, {ease: FlxEase.sineInOut});
		}
	}
}
