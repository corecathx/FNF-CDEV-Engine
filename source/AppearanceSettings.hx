package;

import flixel.util.FlxTimer;
import openfl.Lib;
import Controls.Control;
import Controls.KeyboardScheme;
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

class AppearanceSettings extends MusicBeatSubstate
{
	var loaded:Bool = false;
	private var curSelected:Int = 0;

	var options:Array<String> = [
		'Show Performance Text',
		'Smooth Motions',
		'Antialiasing'
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var allowToPress:Bool = false;

	private var versionSht:FlxText;

	public function new()
	{
		super();
		if (!loaded)
		{
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

				FlxG.sound.play(Paths.sound('cancelMenu', 'shared'));
				close();
			}

			super.update(elapsed);
		}
	}

	function pressSelection()
	{
		// FlxG.save.flush();
		FlxG.sound.play(Paths.sound('confirmMenu'));

		saveOptions();
		updateOptions();

		grpOptions.clear();

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			optionText.isMenuItem = true;
			optionText.isOptionItem = true;
			optionText.targetY = i;
			grpOptions.add(optionText);
		}
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

	function saveOptions()
		{
			switch (options[curSelected])
			{
				case 'Show Performance Text' | 'Dont Show Performance Text':
					FlxG.save.data.performTxt = !FlxG.save.data.performTxt;
					Main.fps_mem.visible = FlxG.save.data.performTxt;
				case 'Antialiasing' | 'No Antialiasing':
					FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
				case 'Smooth Motions' | 'Dont Smooth Motions':
					FlxG.save.data.smoothAF = !FlxG.save.data.smoothAF;
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

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
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
		options = [
			FlxG.save.data.performTxt ? 'Show Performance Text' : 'Dont Show Performance Text',
			FlxG.save.data.smoothAF ? 'Smooth Motions' : 'Dont Smooth Motions',
			FlxG.save.data.antialiasing ? 'Antialiasing' : 'No Antialiasing'
		];
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
			case 'Antialiasing' | 'No Antialiasing':
				text = "If disabled, the game graphics will not looking as smooth\nand increases performance";
		}
		versionSht.text = text;
	}
}
