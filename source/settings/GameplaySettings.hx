package settings;

import flixel.util.FlxTimer;
import openfl.Lib;
import game.Controls.Control;
import game.Controls.KeyboardScheme;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import game.*;

class GameplaySettings extends substates.MusicBeatSubstate
{
	var loaded:Bool = false;
	private var curSelected:Int = 0;

	var options:Array<String> = [
		'Downscroll',
		'Middlescroll',
		'Ghost Tapping',
		'Show Note Delay',
		'Enable Hit Sound',
		'Enable Reset Button',
		'Botplay Mode',
		'Show Health Percent',
		'FPS Cap',
		'Enable Note Impacts',
		'Enable Song Time',
		'Flashing Lights',
		'Camera Zooming',
		'Camera Movements',
		'Note Offset',
		'Detailed Score Info',
		'Auto Pause'
	];

	var clickableOptions:Array<String> = [
		'Downscroll',
		'Middlescroll',
		'Show Note Delay',
		'Ghost Tapping',
		'Enable Hit Sound',
		'Enable Reset Button',
		'Botplay Mode',
		'Show Health Percent',
		'Enable Note Impacts',
		'Enable Song Time',
		'Flashing Lights',
		'Camera Zooming',
		'Camera Movements',
		'Note Offset',
		'Detailed Score Info',
		'Auto Pause'
	];

	private var hold:Float = 0;
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var allowToPress:Bool = false;
	var fromPause:Bool = false;

	private var versionSht:FlxText;

	public function new(fromPause:Bool = false)
	{
		super();
		if (!loaded)
			{
				this.fromPause = fromPause;
				// quick checking
				updateOptions();

				grpOptions = new FlxTypedGroup<Alphabet>();
				add(grpOptions);

				for (i in 0...options.length)
				{
					var optionText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
					// optionText.screenCenter();
					optionText.isMenuItem = true;
					optionText.isOptionItem = true;
					optionText.targetY = i;
					//optionText.ID = i;
					// optionText.y += (100 * (i - (options.length / 2))) + 50;
					grpOptions.add(optionText);
				}

				versionSht = new FlxText(20, FlxG.height - 100, 1000, '', 24);
				versionSht.scrollFactor.set();
				versionSht.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				versionSht.screenCenter(X);
				add(versionSht);
				versionSht.borderSize = 2;
				changeSelection();
				new FlxTimer().start(0.2, function(bruh:FlxTimer)
				{
					allowToPress = true;
				});

				if (fromPause)
					cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
			}

		if (!loaded)
			{
				loaded = true;
			}
	}

	override function update(elapsed:Float)
	{
		if (loaded)
			{
				if (controls.UP_P)
					{
						changeSelection(-1);
					}
					if (controls.DOWN_P)
					{
						changeSelection(1);
					}
			
					if (allowToPress)
					{
						if (controls.ACCEPT && clickableOptions.contains(options[curSelected]))
							pressSelection();
					}

					leftRight(elapsed);
					
					if (controls.RESET)
						{
							switch (options[curSelected])
							{
								case 'Note Offset':
									FlxG.save.data.offset = 0;
									changeText();
								case 'FPS Cap':
									FlxG.save.data.fpscap = 120;
									cdev.CDevConfig.setFPS(FlxG.save.data.fpscap);
									changeText();
							}
							FlxG.sound.play(Paths.sound('cancelMenu'));
						}

			
					if (controls.BACK)
					{		
						loaded = false;
						grpOptions.clear();

						for (memes in 0...options.length)
							options.remove(options[memes]);

						for (memes in 0...clickableOptions.length)
							clickableOptions.remove(clickableOptions[memes]);
						
						versionSht.kill();
						//closeSubState();
						
						//FlxG.sound.play(Paths.sound('cancelMenu', 'shared'));	
						close();
					}
			
					super.update(elapsed);
				}
	}

	override function closeSubState()
		{
			super.closeSubState();
			changeSelection();
		}
	
	function pressSelection()
	{
		// FlxG.save.flush();
		FlxG.sound.play(Paths.sound('confirmMenu'));
		switch (options[curSelected])
		{
			case 'Downscroll' | 'Upscroll':
				FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
			case 'Show Note Delay' | 'Hide Note Delay':
				FlxG.save.data.showDelay = !FlxG.save.data.showDelay;
			case 'Enable Hit Sound' | 'Disable Hit Sound':
				FlxG.save.data.hitsound = !FlxG.save.data.hitsound;
			case 'Middlescroll' | 'No Middlescroll':
				FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
			case 'Ghost Tapping' | 'No Ghost Tapping':
				FlxG.save.data.ghost = !FlxG.save.data.ghost;
			case 'Enable Reset Button' | 'Disable Reset Button':
				FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
			case 'Botplay Mode' | 'Not Botplay Mode':
				FlxG.save.data.botplay = !FlxG.save.data.botplay;
			case 'Show Health Percent' | 'Hide Health Percent':
				FlxG.save.data.healthCounter = !FlxG.save.data.healthCounter;
			case 'Enable Note Impacts' | 'Disable Note Impacts':
				FlxG.save.data.noteImpact = !FlxG.save.data.noteImpact;
			case 'Enable Song Time' | 'Disable Song Time':
				FlxG.save.data.songtime = !FlxG.save.data.songtime;
			case 'Flashing Lights' | 'No Flashing Lights':
				FlxG.save.data.flashing = !FlxG.save.data.flashing;
			case 'Camera Zooming' | 'No Camera Zooming':
				FlxG.save.data.camZoom = !FlxG.save.data.camZoom;
			case 'Camera Movements' | 'No Camera Movements':
				FlxG.save.data.camMovement = !FlxG.save.data.camMovement;
			case 'Note Offset':
				FlxG.switchState(new states.OffsetTest());
			case 'FPS Cap':
				return;
			case 'Detailed Score Info' | 'Only Song Score':
				FlxG.save.data.fullinfo = !FlxG.save.data.fullinfo;
			case 'Auto Pause' | 'Do Not Auto Pause':
				FlxG.save.data.autoPause = !FlxG.save.data.autoPause;
				FlxG.autoPause = FlxG.save.data.autoPause;
		}

		updateOptions();

		grpOptions.remove(grpOptions.members[curSelected]);

		var optionText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, options[curSelected], true, false);
		optionText.isMenuItem = true;
		optionText.isOptionItem = true;
		//optionText.ID = curSelected;
		grpOptions.add(optionText);

		changeSelection();
		grpOptions.forEach(function(spr:FlxSprite)
		{
			if (curSelected == spr.ID)
			{
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					spr.alpha = 1;
					spr.visible = true;
				});
			}
		});
	}

	function leftRight(updateElapsed:Float)
		{
			var daValueToAdd:Int = controls.RIGHT ? 1 : -1;
			if (controls.LEFT || controls.RIGHT)
			{
				hold += updateElapsed;
	
				if (hold <= 0)
					FlxG.sound.play(Paths.sound('scrollMenu'));
	
				if (hold > 0.5 || controls.LEFT_P || controls.RIGHT_P)
				{
					switch (options[curSelected])
					{
						case 'Note Offset':
							FlxG.save.data.offset += daValueToAdd;
	
							if (FlxG.save.data.offset <= -90000) // like who tf does have a 90000 ms audio delay
								FlxG.save.data.offset = -90000;
	
							if (FlxG.save.data.offset > 90000) // pfft
								FlxG.save.data.offset = 90000;

							changeText();
						case 'FPS Cap':
							FlxG.save.data.fpscap += daValueToAdd;
	
							if (FlxG.save.data.fpscap <= 60) // you cant go below 60 fps, or else your gameplay would be really shit
								FlxG.save.data.fpscap = 60;
	
							if (FlxG.save.data.fpscap > 300)
								FlxG.save.data.fpscap = 300;
	
							cdev.CDevConfig.setFPS(FlxG.save.data.fpscap);
							changeText();
					}
				}
			}
			else
			{
				hold = 0;
			}
		}

	function changeSelection(change:Int = 0)
	{
		var bullShit:Int = 0;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		changeText();

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	function updateOptions()
		{
			if (!fromPause)
				{
					options = [
						FlxG.save.data.downscroll ? 'Downscroll' : 'Upscroll',
						FlxG.save.data.middlescroll ? 'Middlescroll' : 'No Middlescroll',
						FlxG.save.data.showDelay ? 'Show Note Delay' : 'Hide Note Delay',
						FlxG.save.data.ghost ? 'Ghost Tapping' : 'No Ghost Tapping',
						FlxG.save.data.hitsound ? 'Enable Hit Sound' : 'Disable Hit Sound',
						FlxG.save.data.resetButton ? 'Enable Reset Button' : 'Disable Reset Button',
						FlxG.save.data.botplay ? 'Botplay Mode' : 'Not Botplay Mode',
						'FPS Cap',
						FlxG.save.data.healthCounter ? 'Show Health Percent' : 'Hide Health Percent',
						FlxG.save.data.noteImpact ? 'Enable Note Impacts' : 'Disable Note Impacts',
						FlxG.save.data.songtime ? 'Enable Song Time' : 'Disable Song Time',
						FlxG.save.data.flashing ? 'Flashing Lights' : 'No Flashing Lights',
						FlxG.save.data.camZoom ? 'Camera Zooming' : 'No Camera Zooming',
						FlxG.save.data.camMovement ? 'Camera Movements' : 'No Camera Movements',
						'Note Offset',
						FlxG.save.data.fullinfo ? 'Detailed Score Info' : 'Only Song Score',
						FlxG.save.data.autoPause ? 'Auto Pause' : 'Do Not Auto Pause'
					];
				} else{
					options = [
						FlxG.save.data.showDelay ? 'Show Note Delay' : 'Hide Note Delay',
						FlxG.save.data.ghost ? 'Ghost Tapping' : 'No Ghost Tapping',
						FlxG.save.data.hitsound ? 'Enable Hit Sound' : 'Disable Hit Sound',
						FlxG.save.data.resetButton ? 'Enable Reset Button' : 'Disable Reset Button',
						FlxG.save.data.botplay ? 'Botplay Mode' : 'Not Botplay Mode',
						'FPS Cap',
						FlxG.save.data.healthCounter ? 'Show Health Percent' : 'Hide Health Percent',
						FlxG.save.data.noteImpact ? 'Enable Note Impacts' : 'Disable Note Impacts',
						FlxG.save.data.songtime ? 'Enable Song Time' : 'Disable Song Time',
						FlxG.save.data.flashing ? 'Flashing Lights' : 'No Flashing Lights',
						FlxG.save.data.camZoom ? 'Camera Zooming' : 'No Camera Zooming',
						FlxG.save.data.camMovement ? 'Camera Movements' : 'No Camera Movements',
						FlxG.save.data.fullinfo ? 'Detailed Score Info' : 'Only Song Score',
						FlxG.save.data.autoPause ? 'Auto Pause' : 'Do Not Auto Pause'
					];
				}
			clickableOptions = [
				FlxG.save.data.downscroll ? 'Downscroll' : 'Upscroll',
				FlxG.save.data.showDelay ? 'Show Note Delay' : 'Hide Note Delay',
				FlxG.save.data.middlescroll ? 'Middlescroll' : 'No Middlescroll',
				FlxG.save.data.ghost ? 'Ghost Tapping' : 'No Ghost Tapping',
				FlxG.save.data.hitsound ? 'Enable Hit Sound' : 'Disable Hit Sound',
				FlxG.save.data.resetButton ? 'Enable Reset Button' : 'Disable Reset Button',
				FlxG.save.data.healthCounter ? 'Show Health Percent' : 'Hide Health Percent',
				FlxG.save.data.botplay ? 'Botplay Mode' : 'Not Botplay Mode',
				FlxG.save.data.noteImpact ? 'Enable Note Impacts' : 'Disable Note Impacts',
				FlxG.save.data.songtime ? 'Enable Song Time' : 'Disable Song Time',
				FlxG.save.data.flashing ? 'Flashing Lights' : 'No Flashing Lights',
				FlxG.save.data.camZoom ? 'Camera Zooming' : 'No Camera Zooming',
				FlxG.save.data.camMovement ? 'Camera Movements' : 'No Camera Movements',
				'Note Offset',
				FlxG.save.data.fullinfo ? 'Detailed Score Info' : 'Only Song Score',
				FlxG.save.data.autoPause ? 'Auto Pause' : 'Do Not Auto Pause'
			];
		}

	function changeText()
		{
			var text:String = '';
			switch (options[curSelected])
			{
				case 'Downscroll' | 'Upscroll':
					text = 'Downscroll = Notes spawning from top of the screen.\nUpscroll = Notes spawning from bottom of the screen.';
				case 'Middlescroll' | 'No Middlescroll':
					text = "Makes the opponent's notes disappear and centers your notes.";
				case 'Show Note Delay' | 'Hide Note Delay':
					text = 'Whether to Show or Hide the Note Delay counter above\nyour strum notes. (In Miliseconds)';
				case 'Ghost Tapping' | 'No Ghost Tapping':
					text = 'Allows you to press every direction\nwithout increasing your misses counter';
				case 'Enable Hit Sound' | 'Disable Hit Sound':
					text = 'If you pressed your note keybinds, it will\nplays a hit sound';
				case 'Enable Reset Button' | 'Disable Reset Button':
					text = 'Whether to enable or disable the reset button.\n Your current Reset Keybind: ' + FlxG.save.data.resetBind;
				case 'Botplay Mode' | 'Not Botplay Mode':
					text = 'If enabled, a bot will plays the song for you.';
				case 'Show Health Percent' | 'Hide Health Percent':
					text = 'Whether to Show or Hide the Health Percent\nat the Score Text.';
				case 'FPS Cap':
					text = 'Choose how many frames per second that this engine should run at.\n(Current Value: ' + FlxG.save.data.fpscap + ")";
				case 'Enable Note Impacts' | 'Disable Note Impacts':
					text = 'If you hit "Sick!!" Rating, it will show impact effect at your\nNote strum line!';
				case 'Enable Song Time' | 'Disable Song Time':
					text = 'Hide / Show the Song time (as a bar)';
				case 'Flashing Lights' | 'No Flashing Lights':
					text = 'Enable / Disable Flashing Lights.\n(Disable this if you sensitive to flashing lights!)';
				case 'Camera Zooming' | 'No Camera Zooming':
					text = 'Enable / Disable Camera zooming at every\n4th beats';
				case 'Camera Movements' | 'No Camera Movements':
					text = 'If disabled, the camera wont move based on\n the current character animation';
				case 'Note Offset':
					text = "Change your notes offset. Press ENTER to start offset testing\n(Current Value: " + FlxG.save.data.offset + ")";
				case 'Detailed Score Info' | 'Only Song Score':
					text = 'If enabled, it will show your Score, Misses, and Accuracy\ninstead of just showing the Song Score only.';
			    case 'Auto Pause' | 'Do Not Auto Pause':
					text = 'If enabled, the game will pauses by itself if the\ngame window become unfocused.';
			}
			versionSht.alpha = 1;
			versionSht.text = text;
		}
}
