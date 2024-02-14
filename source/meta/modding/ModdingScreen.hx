package meta.modding;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import meta.modding.song_editor.SongEditor;
import meta.modding.freeplay_editor.SongListEditor;
import flixel.FlxState;
import flixel.ui.FlxButton;
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
import game.objects.Alphabet;
import game.cdev.*;
import game.*;

class ModdingScreen extends meta.states.MusicBeatState
{
	var options:Array<Dynamic> = [
		["Add Song Chart", "Add your song's .json / .ogg file to your mod."],
		["Open in Explorer", "Opens this mod's directory in Windows Explorer."],
		["Freeplay Editor", "Add a new song to / edit a song in the Freeplay Song list."],
		['Character Editor', "Create a new character / edit an existing character."], 
		['Stage Editor', "Edit the appearance of your mod's stage(s)."], 
		['Week Editor', "Create / edit Story Mode week files."]
	];
	
	var curSelected:Int = 0;
	var grpMenu:FlxTypedGroup<Alphabet>;
	var menuBG:FlxSprite;
	var descText:FlxText;
	var bgCont:FlxSprite;
	override function create()
	{
		Paths.currentMod = Paths.curModDir[0];
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
		#if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence("Creating a mod", Paths.curModDir[0]);
		#end

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		menuBG.color = 0xff0088ff;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.5;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		grpMenu = new FlxTypedGroup<Alphabet>();
		add(grpMenu);

		for (i in 0...options.length)
		{
			var size:Int = 34;
			var offset:Float = 40;
			var songText:Alphabet = new Alphabet(120, ((i - curSelected) * (size + offset)) + (FlxG.height * 0.48), options[i][0], true, false, size);
			songText.isMenuItem = true;
			songText.isFreeplay = true;
			songText.forcePositionToScreen = false;
			songText.heightOffset = offset;
			songText.targetY = i;
			grpMenu.add(songText);
		}

		bgCont = new FlxSprite().makeGraphic(20,20, FlxColor.BLACK);
		bgCont.scrollFactor.set();
		bgCont.alpha = 0.7;
		add(bgCont);
		
		descText = new FlxText(20, FlxG.height - 140, -1, '', 24);
		descText.scrollFactor.set();
		descText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.screenCenter(X);
		add(descText);
		descText.borderSize = 2;

		bgCont.setGraphicSize(descText.width, descText.height);
		bgCont.setPosition(descText.x, descText.y);
		
		changeSelection();

		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 70).makeGraphic(FlxG.width, 70, 0xFF000000);
		bottomPanel.alpha = 0.8;
		add(bottomPanel);

		var scoreText:FlxText = new FlxText(0, bottomPanel.y + 20, -1, 'Current Mod: ' + Paths.currentMod, 28);
		scoreText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 2;
		add(scoreText);
		scoreText.screenCenter(X);
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK)
		{
			FlxG.save.flush();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new ModdingState());
		}

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.ACCEPT)
		{
			switch (options[curSelected][0])
			{
				case "Open in Explorer":
					CDevConfig.utils.openFolder("./cdev-mods/"+Paths.currentMod+"/", true);
				case "Add Song Chart":
					FlxG.switchState(new SongEditor());
				case "Freeplay Editor":
					FlxG.switchState(new SongListEditor());
					//wip
				case 'Character Editor':
					var theState:meta.modding.char_editor.CharacterEditor = new meta.modding.char_editor.CharacterEditor(false,true,false);
					theState.moddingMode = true;
					FlxG.switchState(theState);
				case 'Stage Editor':
					FlxG.switchState(new meta.modding.stage_editor.Better_StageEditor());
				case 'Week Editor':
					FlxG.sound.music.stop();
					FlxG.switchState(new meta.modding.week_editor.WeekEditor(''));	
				case 'Add Event Script': // Shhh
					FlxG.switchState(new meta.modding.event_editor.EventScriptEditor()); 
			}
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
		}
	}
	var textTween:FlxTween;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		descText.text = options[curSelected][1];
		descText.screenCenter(X);
		descText.y = FlxG.height - 140;

		bgCont.setGraphicSize(descText.width+75, descText.height+40);
		bgCont.screenCenter(X);
		descText.y = FlxG.height - 140;

		if (textTween != null)
			textTween.cancel();

		descText.scale.y = 1.4;
		textTween = FlxTween.tween(descText.scale, {y:1}, 0.5, {ease:FlxEase.expoOut, onComplete:function(e){
			textTween = null;
		}});
		
		var bullShit:Int = 0;
		for (item in grpMenu.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.selected = false;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.selected = true;
				item.alpha = 1;
			}
		}
	}
}
