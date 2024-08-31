package meta.modding;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import meta.substates.WebviewSubstate;
import openfl.Lib;
import game.Controls.Control;
#if !macro
import flash.text.TextField;
#end
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

import game.objects.*;

class ModdingState extends meta.states.MusicBeatState
{
	var curSelected:Int = 0;
	var options:Array<String> = ['Create a new mod', 'Edit a mod', 'Install a mod'];
	var grpOptions:FlxTypedGroup<Alphabet>;
	var menuBG:FlxSprite;

	override function create()
	{
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS,NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS,NUMPADPLUS];
		#if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence("About to create a cool mod.", null);
		#end

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = CDevConfig.utils.CDEV_ENGINE_BLUE;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.5;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var textSize:Int = #if desktop 34 #else 40 #end;
		var lengthy:Float = (FlxG.height * 0.5) - ((options.length * (textSize+20)) * 0.5);
		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0,0,options[i], true,false,textSize);
			optionText.screenCenter(X);
			optionText.y = lengthy + (((textSize+20)*i));
			optionText.ID = i;
			grpOptions.add(optionText);
		}
		changeSelection();
		
		var box1:FlxSprite = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width,20,FlxColor.BLACK);
		var box2:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width,20,FlxColor.BLACK);
		box1.alpha = 0.5;
		box2.alpha = 0.5;
		add(box1);
		add(box2);
		var text = meta.states.MainMenuState.coreEngineText + ' - Modding State';
		var versionShit:FlxText = new FlxText(20, FlxG.height - 30, 1000, text, 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat(FunkinFonts.VCR, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		versionShit.alpha = 0.7;

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
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new meta.states.MainMenuState());
		}

		if (controls.ACCEPT)
		{
			for (item in grpOptions.members)
			{
				item.alpha = 0;
			}

			switch (options[curSelected])
			{
				case 'Create a new mod':
					FlxG.switchState(new NewModState());
				case 'Edit a mod':
					FlxG.switchState(new OpenExistingModState());
				case 'Install a mod':
					FlxG.switchState(new InstallModState());
					//FlxG.switchState(new ());
					//FlxG.switchState(new CreateCharacterBETATEST());
				case "Read the Docs":
					openSubState(new WebviewSubstate("https://core5570ryt.github.io/FNF-CDEV-Engine/"));
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
