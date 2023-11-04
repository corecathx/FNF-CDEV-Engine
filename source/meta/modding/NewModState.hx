package meta.modding;

import game.cdev.CDevConfig;
import game.Paths;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import lime.system.Clipboard;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxSpriteUtil;
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
import game.cdev.CDevMods.ModFile;

class NewModState extends meta.states.MusicBeatState
{
	var modFile:ModFile;
	var curSelected:Int = 0;
	var menuBG:FlxSprite;
	var box:FlxSprite;
	var exitButt:FlxSprite;

	override function create()
	{
		modFile = {
			modName: "",
			modDesc: "",
			modVer: "",
			mod_difficulties: []
		}
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];

		FlxG.mouse.visible = true;
		#if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence("About to create a cool mod.", null);
		#end

		menuBG = new FlxSprite().loadGraphic(game.Paths.image('menuDesat'));
		menuBG.color = FlxColor.CYAN;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.7;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		box = new FlxSprite().makeGraphic(800, 400, FlxColor.BLACK);
		box.alpha = 0.7;
		box.screenCenter();
		add(box);

		exitButt = new FlxSprite().makeGraphic(30, 20, FlxColor.RED);
		exitButt.alpha = 0.7;
		exitButt.x = ((box.x + box.width) - 30) - 10;
		exitButt.y = (box.y + 20) - 10;
		add(exitButt);

		createBoxUI();
		super.create();
	}

	var input_modName:FlxUIInputText;
	var input_modDesc:FlxUIInputText;
	var butt_createMod:FlxSprite;
	var txtbcm:FlxText;

    var txtMn:FlxText;

	function createBoxUI()
	{
		var header:FlxText = new FlxText(box.x, box.y + 10, 800, "Create a mod", 40);
		header.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header);

		input_modName = new FlxUIInputText(box.x + 50, box.y + 100, 500, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_modName.font = "VCR OSD Mono";
		add(input_modName);
		txtMn = new FlxText(input_modName.x, input_modName.y - 25, 500, "Mod name", 20);
		txtMn.font = "VCR OSD Mono";
		add(txtMn);

		input_modDesc = new FlxUIInputText(box.x + 50, box.y + 150, 500, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_modDesc.font = "VCR OSD Mono";
		add(input_modDesc);
		var txtMd:FlxText = new FlxText(input_modDesc.x, input_modDesc.y - 25, 500, "Mod description", 20);
		txtMd.font = "VCR OSD Mono";
		add(txtMd);

		butt_createMod = new FlxSprite(865, 510).makeGraphic(150, 32, FlxColor.fromRGB(70, 70, 70));
		add(butt_createMod);
		txtbcm = new FlxText(870, 515, 140, "Create Mod", 18);
		txtbcm.font = "VCR OSD Mono";
		txtbcm.alignment = CENTER;
		add(txtbcm);

		trace("x: " + txtbcm.x + " y: " + txtbcm.y);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var the:Array<FlxUIInputText> = [input_modDesc, input_modName];

		for (i in 0...the.length)
		{
			if (the[i].hasFocus)
			{
				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null)
				{
					the[i].text = game.cdev.CDevConfig.utils.pasteFunction(the[i].text);
					the[i].caretIndex = the[i].text.length;
				}

				if (FlxG.keys.justPressed.ENTER)
					the[i].hasFocus = false;
			}
		}

		if (the[1].hasFocus)
		{
			txtMn.color = FlxColor.WHITE;
		}

		if (FlxG.mouse.overlaps(exitButt))
		{
			exitButt.alpha = 1;
			if (FlxG.mouse.justPressed)
				exitStateShit();
		}
		else
		{
			exitButt.alpha = 0.7;
		}

		if (FlxG.keys.justPressed.ESCAPE){
			exitStateShit();
		}

		if (FlxG.mouse.overlaps(butt_createMod))
		{
			butt_createMod.alpha = 1;
			txtbcm.alpha = 1;

			if (FlxG.mouse.justPressed)
			{
				if (input_modName.text != '')
				{
					modFile = {
						modName: input_modName.text,
						modDesc: input_modDesc.text,

						modVer: CDevConfig.engineVersion,
						mod_difficulties: []
					}
                    FlxG.sound.play(game.Paths.sound('confirmMenu'));
					game.Paths.createModFolder(input_modName.text);
					Paths.curModDir = [];
                    Paths.curModDir.push(modFile.modName);

                    createModJSON();

                    FlxG.switchState(new meta.modding.ModdingScreen());
					CDevConfig.saveData.loadedMods = Paths.curModDir;
				}
				else
				{
                    txtMn.color = FlxColor.RED;
					FlxG.sound.play(game.Paths.sound('cancelMenu'));
				}
			}
		}
		else
		{
			txtbcm.alpha = 0.7;
			butt_createMod.alpha = 0.7;
		}
	}

	function exitStateShit()
	{
		FlxG.save.flush();
        FlxG.sound.play(game.Paths.sound('cancelMenu'));
		FlxG.switchState(new meta.modding.ModdingState());
	}
    
    function createModJSON()
    {
        var data:String = Json.stringify(modFile, "\t");
    
        if (data.length > 0)
        {
			File.saveContent('cdev-mods/' + modFile.modName + '/mod.json' ,data);
		}
    }
}
