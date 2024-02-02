package meta.modding;

import game.cdev.CDevMods.ModFile;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
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
import game.objects.*;
import game.*;

using StringTools;
 
class OpenExistingModState extends meta.states.MusicBeatState
{
	var curSelected:Int = 0;
	var modShits:Array<ModFile> = [];
	var grpOptions:FlxTypedGroup<Alphabet>;
	var menuBG:FlxSprite;
	var noMods:Bool = false;

	override function create()
	{
        #if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence("About to create a cool mod.", null);
		#end
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS,NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS,NUMPADPLUS];

        var shit:Array<String> = FileSystem.readDirectory('cdev-mods/');

		shit.remove('readme.txt'); //excludes readme.txt from the list.
        for (i in 0...shit.length){
            if (FileSystem.isDirectory('cdev-mods/' + shit[i])){
                var crapJSON = null;

                #if ALLOW_MODS
                var file:String = Paths.cdModsFile(shit[i]);
                if (FileSystem.exists(file))
                    crapJSON = File.getContent(file);
                #end
        
                var json:ModFile = cast Json.parse(crapJSON);
        
                if (crapJSON != null)
                    modShits.push(json);
            }
        }

		if (shit.length == 0){
			var sad:ModFile = {
				modName: 'No Mods Found',
				modDesc: 'Please check your cdev-mods folder.',
				modVer: CDevConfig.engineVersion,
				restart_required: false,
				disable_base_game: false,
				window_title: "Friday Night Funkin' CDEV Engine",
				window_icon: "",
				mod_difficulties: []
			};
			modShits.push(sad);
			noMods = true;
		}

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xff0088ff;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.5;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...modShits.length)
		{
			var optionText:Alphabet = new Alphabet(0, (70 * i) + 30, modShits[i].modName, true, false);
			//optionText.screenCenter();
			optionText.isMenuItem = true;
			optionText.isFreeplay = true;
			optionText.targetY = i;
			// optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}
		changeSelection();

		var text = meta.states.MainMenuState.coreEngineText + ' - Open an existing mod.';
		var versionShit:FlxText = new FlxText(20, FlxG.height - 30, 1000, text, 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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
			Conductor.updateSettings();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new ModdingState());
		}

		if (controls.ACCEPT)
		{
			if (!noMods){
				for (item in grpOptions.members)
				{
					item.alpha = 0;
				}
				FlxG.sound.play(Paths.sound('confirmMenu'));
				Paths.curModDir = [];
				Paths.curModDir.push(modShits[curSelected].modName);
				FlxG.switchState(new ModdingScreen());	
				
				CDevConfig.saveData.loadedMods = Paths.curModDir;
			}

		}
	}

	function changeSelection(change:Int = 0)
	{
		var bullShit:Int = 0;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = modShits.length - 1;
		if (curSelected >= modShits.length)
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
