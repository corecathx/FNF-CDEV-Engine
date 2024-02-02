package meta.modding;

import meta.states.TitleState;
import flixel.tweens.FlxTween;
import game.cdev.CDevConfig;
import sys.io.File;
import haxe.Json;
import game.cdev.CDevMods.ModFile;
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
import game.*;

using StringTools;

class InstallModState extends meta.states.MusicBeatState
{
	var curSelected:Int = 0;
	var modShits:Array<ModFile> = [];
	var grpOptions:FlxTypedGroup<Alphabet>;
	var menuBG:FlxSprite;
	var modBG:FlxSprite;
	var descArray:Array<FlxText> = [];
	var noMods:Bool = false;

	var iconArray:Array<ModIcon> = [];
	var usingCustomBG:Bool = false;

	override function create()
	{
		#if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence("Installing a mod.", null);
		#end
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];

		var shit:Array<String> = FileSystem.readDirectory('cdev-mods/');

		shit.remove('readme.txt'); // excludes readme.txt from the list.
		for (i in 0...shit.length)
		{
			if (FileSystem.isDirectory('cdev-mods/' + shit[i]))
			{
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

		if (shit.length == 0)
		{
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

		menuBG = new FlxSprite().loadGraphic(Paths.image('aboutMenu'));
		menuBG.color = 0xff0088ff;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.5;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		modBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		modBG.setGraphicSize(FlxG.width, FlxG.height);
		modBG.updateHitbox();
		modBG.screenCenter();
		modBG.alpha = 0;
		modBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(modBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...modShits.length)
		{
			var optionText:Alphabet = new Alphabet(0, (70 * i) + 30, modShits[i].modName, true, false, 32);
			// optionText.screenCenter();
			optionText.isMenuItem = true;
			optionText.isFreeplay = true;
			optionText.targetY = i;
			// optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);

			Paths.currentMod = modShits[i].modName;
			var iconShit:ModIcon = new ModIcon(0, 0, modShits[i].modName);
			iconShit.sprTracker = optionText;
			add(iconShit);

			iconArray.push(iconShit);
			var description:FlxText = new FlxText(optionText.x + 10, optionText.y + optionText.height + 10, (FlxG.width / 2)+100, modShits[i].modDesc, 14);
			description.setFormat('VCR OSD Mono', 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			descArray.push(description);
			add(description);
		}
		changeSelection(0, false);

		var text = meta.states.MainMenuState.coreEngineText + ' - ';
		var versionShit:FlxText = new FlxText(20, FlxG.height - 30, 1000, text, 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//add(versionShit);
		versionShit.alpha = 0.7;

		if (Paths.curModDir.length == 1)
		{
			var lastCurMod = Paths.currentMod;
			Paths.currentMod = Paths.curModDir[0];
			var d:ModFile = Paths.modData();
			if (Reflect.hasField(d, "restart_required"))
			{
				if (d.restart_required)
				{
					lastModRequireRestart = true;
					trace("will restart");
				}
			}
			Paths.currentMod = lastCurMod;
		}

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		changeSelection();
	}

	var restartOnExit:Bool = false;

	public var lastModRequireRestart:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (i in 0...descArray.length)
		{
			var daThing:Alphabet = grpOptions.members[i];
			descArray[i].setPosition(daThing.x, daThing.y + daThing.height + 10);
		}

		for (i in 0...modShits.length)
		{
			var thing:Array<String> = Paths.curModDir.copy();
			var theObject:Alphabet = grpOptions.members[i];
			theObject.color = (thing.contains(theObject.text) ? FlxColor.CYAN : FlxColor.WHITE);
		}

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
			if (!restartOnExit)
			{
				FlxG.switchState(new ModdingState());
			}
			else
			{
				Paths.currentMod = Paths.curModDir[0];
				TitleState.loadMod = !lastModRequireRestart;
				if (FlxG.sound.music != null) FlxTween.tween(FlxG.sound.music, {volume: 0}, 1);
				FlxTween.tween(FlxG.camera, {alpha: 0}, 1, {
					onComplete: function(e:FlxTween)
					{
						CDevConfig.utils.restartGame();
					}
				});
			}
			FlxG.save.flush();
			Conductor.updateSettings();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		if (controls.RESET)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Paths.curModDir = [];
			doCheck();
		}
		if (controls.ACCEPT)
		{
			if (!noMods)
			{
				if (!Paths.curModDir.contains(modShits[curSelected].modName))
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					Paths.curModDir.push(modShits[curSelected].modName);
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					checkRestart(modShits[curSelected].modName);
					Paths.curModDir.remove(modShits[curSelected].modName);
				}
				doCheck();
			}
		}
	}

	function doCheck()
	{
		restartOnExit = false;
		CDevConfig.saveData.loadedMods = Paths.curModDir;
		CDevConfig.checkLoadedMods();
		Paths.curModDir = CDevConfig.saveData.loadedMods;
		if (Paths.curModDir.length == 1)
		{
			var lastCurMod = Paths.currentMod;
			checkRestart(Paths.curModDir[0]);
			Paths.currentMod = lastCurMod;
		} else{
			if (lastModRequireRestart){
				restartOnExit = true;
			}
		}
	}

	function checkRestart(mod)
	{
		Paths.currentMod = mod;
		var d:ModFile = Paths.modData();
		if (Reflect.hasField(d, "restart_required"))
		{
			if (d.restart_required)
			{
				restartOnExit = true;
				trace("Going to restart cuz of " + d.modName);
			}
		}
	}

	function changeSelection(change:Int = 0, noBGupdate:Bool = false)
	{
		var bullShit:Int = 0;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = modShits.length - 1;
		if (curSelected >= modShits.length)
			curSelected = 0;

		for (i in 0...descArray.length)
		{
			descArray[i].alpha = 0.6;
		}

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}
		descArray[curSelected].alpha = 1;
		iconArray[curSelected].alpha = 1;
		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;
			item.selected = false;

			if (item.targetY == 0)
			{
				item.selected = true;
				item.alpha = 1;
			}
		}

		if (!noBGupdate)
			changeBackground();
	}

	var tweenie:FlxTween;
	var uhh:FlxTween;

	function changeBackground()
	{
		var mod:String = modShits[curSelected].modName;
		Paths.currentMod = mod;
		if (FileSystem.exists(Paths.modFolders("background.png")))
		{

			// menuBG.alpha = 0;
			modBG.loadGraphic(Paths.modImage(Paths.modFolders("background.png"), true));
			modBG.screenCenter();
			modBG.setGraphicSize(FlxG.width, FlxG.height);
			modBG.color = 0xffffffff;
			if (!usingCustomBG) modBG.alpha = 0;

			if (!usingCustomBG)
			{
				if (tweenie != null)
					tweenie.cancel();

				tweenie = FlxTween.tween(modBG, {alpha: 0.9}, 0.5, {
					onComplete: function(aa:FlxTween)
					{
						tweenie = null;
					}
				});

				if (uhh != null)
					uhh.cancel();

				uhh = FlxTween.tween(menuBG, {alpha: 0}, 0.5, {
					onComplete: function(aa:FlxTween)
					{
						uhh = null;
					}
				});
			}
			usingCustomBG = true;
			return;
		}

		if (usingCustomBG)
		{
			if (tweenie != null)
				tweenie.cancel();

			tweenie = FlxTween.tween(modBG, {alpha: 0}, 0.5, {
				onComplete: function(aa:FlxTween)
				{
					tweenie = null;
				}
			});

			if (uhh != null)
				uhh.cancel();

			uhh = FlxTween.tween(menuBG, {alpha: 0.6}, 0.5, {
				onComplete: function(aa:FlxTween)
				{
					uhh = null;
				}
			});
		}

		usingCustomBG = false;
	}
}
