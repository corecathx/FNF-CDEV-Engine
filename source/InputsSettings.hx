package;

import flixel.util.FlxTimer;
import openfl.Lib;
import Controls.Control;
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

class InputsSettings extends MusicBeatSubstate
{
	private var curSelected:Int = 0;

	static var options:Array<String> = ['Safe Frames', 'Note Offset', 'FPS Cap'];

	private var hold:Float = 0;
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var allowToPress:Bool = false;

	private var versionSht:FlxText;

	public function new()
	{
		super();

		options = ['Safe Frames', 'Note Offset', 'FPS Cap'];

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
		changeDatext();
		new FlxTimer().start(0.2, function(bruh:FlxTimer)
		{
			allowToPress = true;
		});
	}

	override function update(elapsed:Float)
	{
		if (controls.UP_P)
		{
			changeSelection(-1);
		}
		if (controls.DOWN_P)
		{
			changeSelection(1);
		}

		changeDatext();

		if (controls.BACK)
		{
			close();
			FlxG.sound.play(Paths.sound('cancelMenu', 'shared'));
		}

		leftRight(elapsed);

		super.update(elapsed);
	}

	function leftRight(updateElapsed:Float)
	{
		var daValueToAdd:Int = controls.RIGHT ? 1 : -1;
		if (controls.LEFT || controls.RIGHT)
		{
			hold += updateElapsed;

			if (hold <= 0)
				FlxG.sound.play(Paths.sound('scrollMenu', 'shared'));

			if (hold > 0.5 || controls.LEFT_P || controls.RIGHT_P)
			{
				switch (options[curSelected])
				{
					case 'Safe Frames':
						FlxG.save.data.frames += daValueToAdd;

						if (FlxG.save.data.frames <= 10)
							FlxG.save.data.frames = 10;

						if (FlxG.save.data.frames > 20)
							FlxG.save.data.frames = 20;

						Conductor.updateSettings();
					case 'Note Offset':
						FlxG.save.data.offset += daValueToAdd;

						if (FlxG.save.data.offset <= -90000) // like who tf does have a 90000 ms audio delay
							FlxG.save.data.offset = -90000;

						if (FlxG.save.data.offset > 90000) // pfft
							FlxG.save.data.offset = 90000;
					case 'FPS Cap':
						FlxG.save.data.fpscap += daValueToAdd;

						if (FlxG.save.data.fpscap <= 40) // you cant go below 40 fps, or else your gameplay would be really bad
							FlxG.save.data.fpscap = 40;

						if (FlxG.save.data.fpscap > 290) // better fps :swag:
							FlxG.save.data.fpscap = 290;

						CoreDevSaves.setFPS(FlxG.save.data.fpscap);
						CoreDevSaves.reInitLerp();
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

		FlxG.sound.play(Paths.sound('scrollMenu', 'shared'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

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

	function changeDatext()
	{
		var text:String = '';
		switch (options[curSelected].toLowerCase())
		{
			case 'safe frames':
				text = "Set how big is your Timing Window size.\n(Current Value: " + FlxG.save.data.frames + ")";
			case 'note offset':
				text = "Set your Notes Offset.\n(Current Value: " + FlxG.save.data.offset + ")";
			case 'fps cap':
				text = "Set the Max FPS of this engine. Default value is 120.\n(Current Value: " + FlxG.save.data.fpscap + ")";
		}

		versionSht.text = text;
	}
}
