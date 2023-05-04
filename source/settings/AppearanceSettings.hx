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
import game.Alphabet;
import game.Conductor;

class AppearanceSettings extends substates.MusicBeatSubstate
{
	var loaded:Bool = false;
	private var curSelected:Int = 0;

	var options:Array<String> = [
		'Show Performance Text', 
		'Smooth Motions', 
		'Show Engine Watermark',
		//'Note Quantization',
		'Show Opponent Notes',
		'Show Strum Lane',
		'Antialiasing',
		#if desktop 
		'Discord RPC',#end
		'Change Rating Position',
		'Note Ripples',
		'FNF Note Style'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var allowToPress:Bool = false;

	private var versionSht:FlxText;
	
	var fromPause:Bool = false;

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
			if (FlxG.sound.music != null && !fromPause)
			{
				Conductor.songPosition = FlxG.sound.music.time;
			}
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
				if (controls.ACCEPT)
					pressSelection();
			}

			if (controls.BACK)
			{
				loaded = false;
				grpOptions.clear();
				versionSht.kill();
				for (memes in 0...options.length)
					options.remove(options[memes]);

				//FlxG.sound.play(Paths.sound('cancelMenu', 'shared'));
				close();
			}

			super.update(elapsed);
		}
	}

	function pressSelection()
	{
		// FlxG.save.flush();
		FlxG.sound.play(game.Paths.sound('confirmMenu'));

		saveOptions();
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

		if (options[curSelected] == 'Change Rating Position')
			{
				for (item in grpOptions.members)
					{
						item.alpha = 0;
					}			
				versionSht.alpha = 0;	
			}

	}

	function saveOptions()
	{
		switch (options[curSelected])
		{
			case 'Antialiasing' | 'No Antialiasing':
				CDevConfig.saveData.antialiasing = !CDevConfig.saveData.antialiasing;
			case 'Note Ripples' | 'Note Splashes':
				CDevConfig.saveData.noteRipples = !CDevConfig.saveData.noteRipples;
			//case 'Note Quantization' | 'Note Column':
			//	CDevConfig.saveData.quantizeNote = !CDevConfig.saveData.quantizeNote;
			case 'Show Engine Watermark' | 'Hide Engine Watermark':
				CDevConfig.saveData.engineWM = !CDevConfig.saveData.engineWM;
			case 'Show Opponent Notes' | 'Hide Opponent Notes':
				CDevConfig.saveData.bgNote = !CDevConfig.saveData.bgNote;
			case 'Show Strum Lane' | 'Hide Strum Lane':
				CDevConfig.saveData.bgLane = !CDevConfig.saveData.bgLane;
			case 'Change Rating Position':
				openSubState(new substates.RatingPosition(fromPause));
			case 'Smooth Motions' | 'Dont Smooth Motions':
				CDevConfig.saveData.smoothAF = !CDevConfig.saveData.smoothAF;
		}
	}

	override function closeSubState()
	{
		super.closeSubState();
		changeSelection();
	}

	function changeSelection(change:Int = 0)
	{
		var bullShit:Int = 0;

		FlxG.sound.play(game.Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length;
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
					CDevConfig.saveData.smoothAF ? 'Smooth Motions' : 'Dont Smooth Motions',
					CDevConfig.saveData.engineWM ? 'Show Engine Watermark' : 'Hide Engine Watermark',
					//CDevConfig.saveData.quantizeNote ? "Note Quantization" : "Note Column",
					CDevConfig.saveData.bgLane ? 'Show Strum Lane' : 'Hide Strum Lane',
					CDevConfig.saveData.bgNote ? 'Show Opponent Notes' : 'Hide Opponent Notes',
					'Change Rating Position',
					CDevConfig.saveData.antialiasing ? 'Antialiasing' : 'No Antialiasing',
				];
			} else{
				options = [
					CDevConfig.saveData.smoothAF ? 'Smooth Motions' : 'Dont Smooth Motions',
					CDevConfig.saveData.bgLane ? 'Show Strum Lane' : 'Hide Strum Lane',
					CDevConfig.saveData.bgNote ? 'Show Opponent Notes' : 'Hide Opponent Notes',
					'Change Rating Position'
				];
			}

	}

	function changeText()
	{
		var text:String = '';
		switch (options[curSelected])
		{
			case 'Show Performance Text' | 'Dont Show Performance Text':
				text = "If enabled, it will show this engine's performance\non top left corner as a text";
			case 'Smooth Motions' | 'Dont Smooth Motions':
				text = "Makes this engine smooth while doing transitions!\n(Disable this if you're sensitive to motions)";
			case 'Show Opponent Notes' | 'Hide Opponent Notes':
				text = "Show / Hide the opponent's notes.\n(Requires 'Middlescroll'!)";
			case 'Show Engine Watermark' | 'Hide Engine Watermark':
				text = 'Whether to Show / Hide the watermark from this engine.';
			case 'Show Strum Lane' | 'Hide Strum Lane':
				text = "If enabled, it will show your strum lane.\n(Requires 'Middlescroll'!)";
			case 'Antialiasing' | 'No Antialiasing':
				text = "If disabled, the game graphics will not look as smooth,\nbut performance will increase.";
			case 'Change Rating Position':
				text = "Change your rating sprite position.";
			case 'Discord RPC' | 'No Discord RPC':
				text = 'Enables / Disables Discord Rich Presence.\n(This option will restart your game.)';
			case 'Note Ripples' | 'Note Splashes':
				text = 'Choose your preferred Note Impacts';
			case 'FNF Note Style' | 'CDEV Note Style':
				text = "Choose your current Note Style.";
		}
		versionSht.alpha = 1;
		versionSht.text = text;
	}
}
