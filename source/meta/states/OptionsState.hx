package meta.states;

#if android
import game.system.native.Android;
#end
import game.settings.SettingsSubState;
import game.settings.data.SettingsProperties;
import game.cdev.CDevConfig;
import openfl.Lib;
import game.Controls.Control;
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
import game.cdev.engineutils.Discord.DiscordClient;
#end

class OptionsState extends MusicBeatState
{
	var currentStatus:String = "main"; // main, category
	var curSelected:Int = 0;
	// var options:Array<String> = ['Controls' , 'Gameplay', 'Appearance', 'Misc'];
	var grpOptions:FlxTypedGroup<FlxText>;
	var menuBG:FlxSprite;

	override function create()
	{
		SettingsProperties.ON_PAUSE = false;
		#if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence("Setting the game options", null);
		#end

		menuBG = new FlxSprite().loadGraphic(game.Paths.image('menuDesat'));
		menuBG.color = 0xff4da9ff;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.2;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);
		var textSize:Int = #if desktop 66 #else 72 #end;
		var lengthy:Float = (FlxG.height / 2) - (((SettingsProperties.CURRENT_SETTINGS.length) * textSize) / 2);
		for (i in 0...SettingsProperties.CURRENT_SETTINGS.length)
		{
			var text:FlxText = new FlxText(0, 0, 0, SettingsProperties.CURRENT_SETTINGS[i].name, 38);
			text.setFormat("wendy", textSize, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			text.y = lengthy + ((textSize) * i) + 5;
			text.screenCenter(X);
			text.ID = i;
			grpOptions.add(text);
		}
		changeSelection();

		var versionShit:FlxText = new FlxText(10, FlxG.height - 20, 1000, "CDEV Engine v" + CDevConfig.engineVersion, 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (CDevConfig.saveData.engineWM)
			add(versionShit);
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

		#if android
		grpOptions.forEach(function(spr:FlxText)
		{
			Android.touchJustPressed(spr, function()
			{
				if (spr.ID != curSelected)
				{
					changeSelection(spr.ID, true);
				}
				else
				{
					onSelected();
				}
			});
		});
		#end

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.save.flush();
			game.Conductor.updateSettings();
			FlxG.sound.play(game.Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			onSelected();
		}
	}

	function onSelected()
	{
		for (item in grpOptions.members)
		{
			item.alpha = 0;
		}
		switch (SettingsProperties.CURRENT_SETTINGS[curSelected].name)
		{
			case 'Controls':
				openSubState(new game.settings.keybinds.RebindControls(false));
			default:
				openSubState(new SettingsSubState(SettingsProperties.CURRENT_SETTINGS[curSelected]));
		}
	}

	function changeSelection(change:Int = 0, force:Bool = false)
	{
		FlxG.sound.play(game.Paths.sound('scrollMenu'), 0.4);
		if (force)
			curSelected = change;
		else
			curSelected += change;

		if (curSelected < 0)
			curSelected = SettingsProperties.CURRENT_SETTINGS.length - 1;
		if (curSelected >= SettingsProperties.CURRENT_SETTINGS.length)
			curSelected = 0;

		for (item in grpOptions.members)
		{
			item.alpha = 0.6;

			if (item.ID == curSelected)
			{
				item.alpha = 1;
			}
		}
	}
}
