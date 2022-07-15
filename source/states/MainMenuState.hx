package states;

import modding.ModPaths;
import cdev.CDevConfig;
import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import lime.system.System;
import flixel.util.FlxTimer;
#if desktop
import engineutils.Discord.DiscordClient;
#end
import openfl.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import game.Controls.KeyboardScheme;
import openfl.Assets;
import game.Paths;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'modding', 'youtube', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	public static var coreEngineText:String = "CDEV Engine v0.1.2";
	public static var fnfVersionXD:String = "Friday Night Funkin' v0.2.8";

	var lerpThing:Float = 0;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var daCFPos:FlxObject;

	var grpIcons:FlxTypedGroup<FlxSprite>;

	var randomTxt:FlxText;
	var gameTimeElasped:FlxText;

	var isTweening:Bool = false;

	var lastString:String = '';
	var engineText:FlxText;

	override function create()
	{
		Paths.destroyLoadedImages();
		FlxG.save.flush();
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS,NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS,NUMPADPLUS];
		#if desktop
		// Updating Discord Rich Presence
		if (Main.discordRPC)
			DiscordClient.changePresence("In the Menus", null);
		#end				


		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.7;
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		daCFPos = new FlxObject(0, 0, 1, 1);
		add(daCFPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = FlxG.save.data.antialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		grpIcons = new FlxTypedGroup<FlxSprite>();
		add(grpIcons);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');
		var daX:Float =(FlxG.width / 2) + 20;

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(60, 40 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.8));
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 0.8);
			menuItem.antialiasing = FlxG.save.data.antialiasing;

			var theIcon:FlxSprite = new FlxSprite(daX, 0).loadGraphic(Paths.image('menuicons/' + optionShit[i]));
			theIcon.screenCenter(Y);
			theIcon.scrollFactor.set();
			theIcon.antialiasing = FlxG.save.data.antialiasing;
			theIcon.ID = i;
			theIcon.alpha = 0;
			theIcon.setGraphicSize(Std.int(theIcon.width * 0.8));
			grpIcons.add(theIcon);
		}

		FlxG.camera.follow(daCFPos, LOCKON, 1);

		var upPanel:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 66, 0xFF000000);
		add(upPanel);

		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		add(bottomPanel);

		bottomPanel.scrollFactor.set();
		upPanel.scrollFactor.set();

		var versionShit:FlxText = new FlxText(20, FlxG.height - 35, 1000, fnfVersionXD, 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		engineText = new FlxText(0, FlxG.height - 35, 1000, coreEngineText  + (FlxG.save.data.testMode ? ' - [TESTMODE]' : ''), 16);
		engineText.scrollFactor.set();
		engineText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (FlxG.save.data.engineWM) add(engineText);
		engineText.x = (FlxG.width - engineText.width) - 20;

		randomTxt = new FlxText(20, FlxG.height - 80, 1000, "", 26);
		randomTxt.scrollFactor.set();
		randomTxt.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(randomTxt);

		gameTimeElasped = new FlxText(0, 15, 1000, "", 16);
		gameTimeElasped.scrollFactor.set();
		gameTimeElasped.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(gameTimeElasped);

		//versionShit.borderSize = 1.5;
		//versionShit.borderQuality = 1;
		//engineText.borderSize = 1.5;       the object are on a black background
		//engineText.borderQuality = 1;      so this line of codes will be useless.
		//randomTxt.borderSize = 2;

		cdev.CDevConfig.utils.cacheUISounds();

		if (FlxG.save.data.dfjk)
			engineutils.PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			engineutils.PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();
		changeText();

		if (FlxG.save.data.smoothAF)
		{
			FlxG.camera.zoom = 1.5;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.cubeOut});
		}

		super.create();
	}

	var selectedSomethin:Bool = false;
	var timer:Float = 0;

	var shitHold:Float = 0;

	var xPos:Float = 0;
	var yPos:Float = 0;
	var lerp:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.playing)
			game.Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.pressed.CONTROL
			&& FlxG.keys.pressed.SHIFT
			&& FlxG.keys.pressed.F3)
			{
				shitHold += elapsed;

				if (shitHold >= 3)
					{
						shitHold = 0;
						FlxG.save.data.testMode = !FlxG.save.data.testMode;
						engineText.text = coreEngineText  + (FlxG.save.data.testMode ? ' - [TESTMODE]' : '');

						if (FlxG.save.data.testMode)
								FlxG.sound.play(Paths.sound('confirmMenu'));
							else
								FlxG.sound.play(Paths.sound('cancelMenu'));
					}
			} else {
				shitHold = 0;
			}

		lerp = cdev.CDevConfig.utils.bound(elapsed * 6, 0, 1);
		//xPos = FlxMath.lerp(daCFPos.x, camFollow.x, lerp);
		yPos = FlxMath.lerp(daCFPos.y, camFollow.y, lerp);
		daCFPos.setPosition(xPos, yPos);

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!selectedSomethin){
			if (isTweening){
				randomTxt.screenCenter(X);
				timer = 0;
			}else{
				randomTxt.screenCenter(X);
				timer += elapsed;
				if (timer >= 3)
				{
					changeText();
				}
			}

			updateGameInfo();

			//if (FlxG.keys.justPressed.SEVEN)
			//	FlxG.switchState(new ModdingState());

			grpIcons.forEach(function(oaoa:FlxSprite){
				oaoa.angle = Math.sin((game.Conductor.songPosition / 1000) * (game.Conductor.bpm / 60) * -1.0) * 4;
			});
			
			if (controls.UP_P){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
				FlxG.switchState(new TitleState());

			if (controls.ACCEPT){
				switch(optionShit[curSelected]){
					case 'donate':
						CDevConfig.utils.openURL('https://ninja-muffin24.itch.io/funkin');
					case 'youtube':
						CDevConfig.utils.openURL('https://www.youtube.com/channel/UCQhxUlrUtrMZjeA05sbEMmA');
					default:
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
	
						if (FlxG.save.data.flashing)
							FlxFlicker.flicker(magenta, 1.1, 0.15, false);
	
						grpIcons.forEach(function(da:FlxSprite){
							FlxTween.tween(da, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(bruh:FlxTween)
								{
									da.kill();
								}
							});
						});
						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID){
								FlxTween.tween(spr, {alpha: 0}, 0.4, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}else{
								//spr.screenCenter();
								if (FlxG.save.data.flashing)
								{
									FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
									{
										openState();
									});
								}
								else
								{
									new FlxTimer().start(1, function(urmom:FlxTimer)
									{
										openState();
									});
								}
							}
						});
				}
			}
		}

		super.update(elapsed);
	}

	function updateGameInfo()
	{
		var hours:String = '' + Date.now().getHours();
		var minutes:String = '' + Date.now().getMinutes();

		if (minutes.length < 2)
			minutes = '0' + Date.now().getMinutes();
		if (hours.length < 2)
			hours = '0' + Date.now().getHours();

		var formattedTime:String = hours + ":" + minutes + '.';
			
		gameTimeElasped.text = "CDEV-Engine has been running for: "
		+ cdev.SongPosition.getCurrentDuration(cdev.CDevConfig.elapsedGameTime) + '.'
		+ '\nIt is currently '
		+ formattedTime;

		gameTimeElasped.x = (FlxG.width - gameTimeElasped.width) - 20;
	}

	function openState()
		{
			var daChoice:String = optionShit[curSelected];

			switch (daChoice)
			{
				case 'story mode':
					if (FlxG.save.data.smoothAF)
					{
						FlxTween.cancelTweensOf(FlxG.camera);
						FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.quadOut});
					}

					FlxG.switchState(new StoryMenuState());
					trace("Story Menu Selected");
				case 'freeplay':
					if (FlxG.save.data.smoothAF)
					{
						FlxTween.cancelTweensOf(FlxG.camera);
						FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.quadOut});
					}

					FlxG.switchState(new FreeplayState());

					trace("Freeplay Menu Selected");
				case 'options':
					// FlxTransitionableState.skipNextTransIn = true;
					// FlxTransitionableState.skipNextTransOut = true;
					FlxG.switchState(new OptionsState());
				case 'modding':
					FlxG.switchState(new modding.ModdingState());
			}
		}

	function changeText()
	{
		var selectedText:String = '';
		var textArray:Array<String> = game.CoolUtil.coolTextFile(Paths.txt('inGameText'));

		randomTxt.alpha = 1;
		isTweening = true;
		selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
		FlxTween.tween(randomTxt, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: function(shit:FlxTween)
			{
				if (selectedText != lastString)
				{
					randomTxt.text = selectedText;
					lastString = selectedText;
				}
				else
				{
					selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
					randomTxt.text = selectedText;
				}

				randomTxt.alpha = 0;

				FlxTween.tween(randomTxt, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: function(shit:FlxTween)
					{
						isTweening = false;
					}
				});
			}
		});
	}

	var alphaTween:FlxTween;

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		grpIcons.forEach(function(spr:FlxSprite){
			spr.alpha = 0;
			if (spr.ID == curSelected){
				if(alphaTween != null){
					alphaTween.cancel();
				}
				alphaTween = FlxTween.tween(spr,{alpha:1},0.3,{onComplete: function(aaaa:FlxTween){
					alphaTween = null;
				}});
			}
		});

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
