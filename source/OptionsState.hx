package;

import openfl.Lib;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
#if desktop
import Discord.DiscordClient;
#end

class OptionsState extends MusicBeatState
{
	var curSelected:Int = 0;
	var options:Array<String> = ['Gameplay', 'Appearance'];
	var grpOptions:FlxTypedGroup<Alphabet>;
	var menuBG:FlxSprite;

	override function create()
	{
		#if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence("Setting the game options", null);
		#end

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			optionText.screenCenter();
			optionText.isMenuItem = true;
			optionText.isOptionItem = true;
			optionText.targetY = i;
			// optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}
		changeSelection();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UP_P)
		{
			changeSelection(-1);
		}
		if (controls.DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.save.flush();
			CDevConfig.reInitLerp();
			Conductor.updateSettings();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			for (item in grpOptions.members)
			{
				item.alpha = 0;
			}

			switch (options[curSelected])
			{
				case 'Gameplay':
					openSubState(new GameplaySettings());
				//case 'Inputs':
				//	openSubState(new InputsSettings());
				// case 'Credits':
				//    openSubState(new CreditState());
				case 'Appearance':
					openSubState(new AppearanceSettings());
			}
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
}
