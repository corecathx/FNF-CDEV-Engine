package meta.modding;

import game.cdev.CDevPopUp;
import game.cdev.CDevPopUp.PopUpButton;
import lime.app.Application;
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

using StringTools;

class NewModState extends meta.states.MusicBeatState
{
	var modFile:ModFile;
	var curSelected:Int = 0;
	var menuBG:FlxSprite;
	var box:FlxSprite;

	override function create()
	{
		modFile = {
			modName: "",
			modDesc: "",
			modVer: "",
			restart_required: false,
			disable_base_game: false,
			window_title: "Friday Night Funkin' CDEV Engine",
			window_icon: "",

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
		menuBG.color = 0xff0088ff;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.2;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		createBGUI();
		super.create();
	}

	var input_modName:FlxUIInputText;
	var txtMn:FlxText;

	var input_modDesc:FlxUIInputText;
	var txtMd:FlxText;

	var check_restart:FlxSprite;
	var label_restart:FlxText;

	var check_disable:FlxSprite;
	var label_disable:FlxText;

	var input_windowTitle:FlxUIInputText;
	var label_windowTitle:FlxText;

	var butt_createMod:FlxSprite;
	var txtbcm:FlxText;

	function createBGUI()
	{
		var header:FlxText = new FlxText(25, 50, -1, "Create a new mod", 40);
		header.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header);

		// MOD NAME
		input_modName = new FlxUIInputText(50, 120, 500, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_modName.font = "VCR OSD Mono";
		add(input_modName);
		txtMn = new FlxText(input_modName.x, input_modName.y - 25, 500, "Mod Name", 20);
		txtMn.font = "VCR OSD Mono";
		add(txtMn);

		// MOD DESC
		input_modDesc = new FlxUIInputText(50, 180, 500, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_modDesc.font = "VCR OSD Mono";
		add(input_modDesc);
		txtMd = new FlxText(input_modDesc.x, input_modDesc.y - 25, 500, "Mod Description", 20);
		txtMd.font = "VCR OSD Mono";
		add(txtMd);

		// MOD ANOTHER STUFF
		var labelanother = new FlxText(input_modDesc.x, input_modDesc.y + 35, 500, "Mod Icon & Background", 20);
		labelanother.font = "VCR OSD Mono";
		add(labelanother);
		var txt:String = ""
		+ "\nTo set the mod icon, put a .png file on root of your mod folder"
		+ "\nand rename it to \"icon.png\"."
		+ "\nSame goes to background image, just rename it to \"background.png\"";
		var wee = new FlxText(labelanother.x, labelanother.y + 15, -1, txt, 18);
		wee.font = "VCR OSD Mono";
		add(wee);


		// ...Additional...//
		var header:FlxText = new FlxText(25, 350, -1, "Additional Settings", 40);
		header.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header);

		var ea:FlxText = new FlxText(header.x+header.width + 15, header.y + 5, -1, "(Will apply if it's a first enabled mod.)", 26);
		ea.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(ea);

		// RESTART
		check_restart = new FlxSprite(50, header.y + 45).makeGraphic(25, 25, 0xFFBFBFBF);
		add(check_restart);
		label_restart = new FlxText(check_restart.x + 30, check_restart.y, -1, "Restart Required", 20);
		label_restart.font = "VCR OSD Mono";
		add(label_restart);

		// BASE GAME DISABLE
		check_disable = new FlxSprite(50, check_restart.y + 50).makeGraphic(25, 25, 0xFFBFBFBF);
		add(check_disable);
		label_disable = new FlxText(check_disable.x + 30, check_disable.y, -1, "Disable base game songs & weeks", 20);
		label_disable.font = "VCR OSD Mono";
		add(label_disable);

		// WINDOW TITLE
		input_windowTitle = new FlxUIInputText(50, check_disable.y + 70, 500, "Friday Night Funkin' CDEV Engine", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_windowTitle.font = "VCR OSD Mono";
		add(input_windowTitle);
		label_windowTitle = new FlxText(input_windowTitle.x, input_windowTitle.y - 25, 500, "Window Title", 20);
		label_windowTitle.font = "VCR OSD Mono";
		add(label_windowTitle);

		// WINDOW ICON
		var label_windowIcon = new FlxText(input_windowTitle.x, input_windowTitle.y + 35, 500, "Window Icon", 20);
		label_windowIcon.font = "VCR OSD Mono";
		add(label_windowIcon);
		var txt:String = ""
		+ "\nTo set a custom window icon, put a .png file on the root of your mod folder"
		+ "\nand rename it to \"winicon.png\".";
		var label_windowIco = new FlxText(label_windowIcon.x, label_windowIcon.y + 15, -1, txt, 18);
		label_windowIco.font = "VCR OSD Mono";
		add(label_windowIco);

		// CREATE MOD BUTTON
		butt_createMod = new FlxSprite(FlxG.width - 170, FlxG.height - 42).makeGraphic(150, 32, FlxColor.fromRGB(70, 70, 70));
		add(butt_createMod);
		txtbcm = new FlxText(butt_createMod.x + 5, butt_createMod.y + 5, 140, "Create Mod", 18);
		txtbcm.font = "VCR OSD Mono";
		txtbcm.alignment = CENTER;
		add(txtbcm);
		butt_createMod.scrollFactor.set();
		txtbcm.scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var the:Array<FlxUIInputText> = [input_modDesc, input_modName, input_windowTitle];
		var e:Array<FlxSprite> = [check_restart, check_disable];
		for (i in 0...e.length)
		{
			if (FlxG.mouse.overlaps(e[i]))
			{
				e[i].alpha = 1;

				if (FlxG.mouse.justPressed)
				{
					var cur:Bool = false;
					switch (i)
					{
						case 0:
							modFile.restart_required = !modFile.restart_required;
							cur = modFile.restart_required;
						case 1:
							modFile.disable_base_game = !modFile.disable_base_game;
							cur = modFile.disable_base_game;
					}
					e[i].color = (cur ? 0xFF00FFFF : 0xFFBFBFBF);
					FlxG.sound.play(game.Paths.sound('scrollMenu'));
				}
			}
			else
			{
				e[i].alpha = 0.7;
			}
		}

		for (i in 0...the.length)
		{
			if (the[i] != null && the[i].hasFocus)
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

		if (the[1] != null && the[1].hasFocus)
			txtMn.color = FlxColor.WHITE;

		if (input_windowTitle.hasFocus)
			label_windowTitle.color = FlxColor.WHITE;

		if (FlxG.keys.justPressed.ESCAPE)
			exitStateShit();


		if (butt_createMod != null && FlxG.mouse.overlaps(butt_createMod))
		{
			butt_createMod.alpha = 1;
			txtbcm.alpha = 1;

			if (FlxG.mouse.justPressed)
			{
				var allow = true;

				if (input_modName.text.trim() == "")
				{
					allow = false;
					txtMn.color = FlxColor.RED;
				}

				if (input_windowTitle.text.trim() == "")
				{
					allow = false;
					label_windowTitle.color = FlxColor.RED;
				}

				var path:String = Paths.modsPath + "/"+input_modName.text.trim();
				if (FileSystem.exists(path) && FileSystem.isDirectory(path)){
					allow = false;

					var butt:Array<PopUpButton> = [];
					var text:String = "Failed to create \"" + input_modName.text.trim() + "\": a mod with the same name already exists." +
					"\n\nIf you wanted to update the mod's directories, press \"Update\"; This action will reset your mod.json, songList.txt, and credits.txt.";
					butt = [
						{text: "Update", callback: createMod},
						{text: "Cancel", callback: function(){}},
					];
					openSubState(new CDevPopUp("Error", text, butt,false, true));
				}

				if (allow)
				{
					createMod();
				}
				else
				{
					FlxG.sound.play(game.Paths.sound('cancelMenu'));
				}
			}
		}
		else
		{
			if (txtbcm != null)
				txtbcm.alpha = 0.7;
			if (butt_createMod != null)
				butt_createMod.alpha = 0.7;
		}
	}

	function createMod(){
		modFile = {
						
			modName: input_modName.text.trim(),
			modDesc: input_modDesc.text.trim(),
			modVer: CDevConfig.engineVersion,
			restart_required: modFile.restart_required,
			disable_base_game: modFile.disable_base_game,
			window_title: input_windowTitle.text.trim(),
			window_icon: "",

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
			File.saveContent('cdev-mods/' + modFile.modName + '/mod.json', data);
		}
	}
}
