package meta.modding;

import game.cdev.objects.UIButton;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxButtonPlus;
import game.cdev.objects.ModList;
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
	var curSelected(default,set):Int = -1;

	function set_curSelected(val:Int):Int {
		var current:ModFile = modShits[val];
		Paths.currentMod = current.modName;
		
		msIcon.changeDaIcon(current.modName);
		msIcon.setGraphicSize(100,100);
		msIcon.updateHitbox();

		msTitle.text = current.modName;
		msDesc.text = current.modDesc;
		changeBackground(current.modName);

		butt_toggleMod.active = butt_openInExplorer.active = butt_archiveMod.active = butt_deleteMod.active =
		butt_toggleMod.visible = butt_openInExplorer.visible = butt_archiveMod.visible = butt_deleteMod.visible = true;

		butt_toggleMod.icon.animation.play((Paths.curModDir.contains(current.modName)?"ic_mod_active":"ic_mod_disabled"),true);
		butt_toggleMod.color = Paths.curModDir.contains(current.modName) ? 0xFF00673C : 0xFF672B00;

		eVer.text = "Engine Version: " + (current.modVer != null ? current.modVer : "Unknown")
		+ (current.restart_required ? "\n> Restart Required":"");
		eVer.setPosition(msBG.x + 30, msBG.y+(msBG.height-(eVer.height+30)));

		FlxG.sound.play(Paths.sound("scrollMenu"), 0.6);
		return curSelected = val;
	}

	var modShits:Array<ModFile> = [];
	var grpOptions:FlxTypedGroup<Alphabet>;
	var menuBG:FlxSprite;
	var modBG:FlxSprite;
	var descArray:Array<FlxText> = [];
	var noMods:Bool = false;

	var iconArray:Array<ModIcon> = [];
	var usingCustomBG:Bool = false;

	var listBox:ModList;

	var msBG:FlxSprite;
	var msIcon:ModIcon;
	var msTitle:FlxText;
	var msDesc:FlxText;

	override function create()
	{
		FlxG.mouse.visible = true;
		DiscordClient.changePresence("Installing a mod.", null);

		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];

		loadMods();
		loadUI();

		loadModScreen(); // the big screen thing to preview mods

		/*if (Paths.curModDir.length == 1)
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
		}*/

		super.create();
	}

	function loadMods() {
		var cdevMods:Array<String> = FileSystem.readDirectory('cdev-mods/');
		cdevMods.remove('readme.txt'); // excludes readme.txt from the list.
		for (i in 0...cdevMods.length)
		{
			if (FileSystem.isDirectory('cdev-mods/' + cdevMods[i]))
			{
				var crapJSON = null;

				var file:String = Paths.cdModsFile(cdevMods[i]);
				if (FileSystem.exists(file))
					crapJSON = File.getContent(file);

				if (crapJSON == null) continue;
				var json:ModFile = cast Json.parse(crapJSON);

				if (crapJSON != null)
					modShits.push(json);
			}
		}
		if (cdevMods.length == 0)
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
	}

	var topBox:FlxSprite;
	var botBox:FlxSprite;
	var checkerBG:FlxBackdrop;
	function loadUI() {
		menuBG = new FlxSprite().loadGraphic(Paths.image('aboutMenu'));
		menuBG.color = CDevConfig.utils.CDEV_ENGINE_BLUE;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 1;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		checkerBG = new FlxBackdrop(Paths.image('checker', 'preload'), XY);
		checkerBG.color = 0xFF006AFF;
		checkerBG.blend = ADD;
        checkerBG.alpha = 0.3;
		add(checkerBG);

		modBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		modBG.setGraphicSize(FlxG.width, FlxG.height);
		modBG.updateHitbox();
		modBG.screenCenter();
		modBG.alpha = 0;
		modBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(modBG);

		listBox = new ModList(20, 100, 340, FlxG.height-(100+140),10,modShits);
		add(listBox);

		var wawabox:FlxSprite = new FlxSprite(listBox.nX,listBox.nY+listBox.nHeight).makeGraphic(listBox.nWidth, 40, 0xFF000000);
		wawabox.alpha = 0.7;
		add(wawabox);

		var enable_all:FlxUIButton = new FlxUIButton(listBox.nX,listBox.nY+listBox.nHeight+10, "Enable All", ()->{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			Paths.curModDir = [];
			for (i in modShits)
				Paths.curModDir.push(i.modName);

			doCheck();
		},true, false, 0xff009efa);
		enable_all.resize(Std.int(listBox.nWidth/2)-5,20);
		add(enable_all);

		var disable_all:FlxUIButton = new FlxUIButton(enable_all.x+enable_all.width+15,enable_all.y, "Delete All", ()->{
			resetMods();
		},true, false, 0xffbd0000);
		disable_all.resize(Std.int(listBox.nWidth/2)-10,20);
		add(disable_all);

		enable_all.label.color = disable_all.label.color = FlxColor.WHITE;

		topBox = new FlxSprite().makeGraphic(FlxG.width,80,0xFF000000);
		topBox.alpha = 0.7;
		add(topBox);

		botBox = new FlxSprite(0,FlxG.height-80).makeGraphic(FlxG.width,80,0xFF000000);
		botBox.alpha = 0.7;
		add(botBox);
	}

	var eVer:FlxText;
	var butt_toggleMod:UIButton;
	var butt_openInExplorer:UIButton;
	var butt_archiveMod:UIButton;
	var butt_deleteMod:UIButton;
	function loadModScreen() {
		var xPos:Float = listBox.nX + listBox.nWidth + 20;

		msBG = new FlxSprite(xPos,listBox.nY).makeGraphic(Std.int(FlxG.width-xPos)-20,listBox.nHeight+40, 0xFF000000);
		msBG.alpha = 0.7;
		add(msBG);

		msIcon = new ModIcon(msBG.x + 30, msBG.y + 20, "");
		msIcon.setGraphicSize(100,100);
		msIcon.updateHitbox();
		add(msIcon);

		msTitle = new FlxText(msIcon.x + msIcon.width + 30,0,msBG.width - ((msIcon.width + 20)+(20*2)), "Select a mod");
		msTitle.setFormat(FunkinFonts.VCR, 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		msTitle.borderQuality = msTitle.borderSize = 2;
		msTitle.y = msIcon.y+(msIcon.height-msTitle.height)*0.5;
		add(msTitle);

		var div:FlxSprite = new FlxSprite(msIcon.x-10, msIcon.y + msIcon.height + 20).makeGraphic(msBG.frameWidth-(20*2), 2, FlxColor.WHITE);
		add(div);

		msDesc = new FlxText(msIcon.x,div.y + 20,msBG.width-(20*2), "Once you've selected a mod, it'll be displayed here!");
		msDesc.setFormat(FunkinFonts.VCR, 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		msDesc.borderQuality = msDesc.borderSize = 2;
		add(msDesc);

		var buttonWidth:Int = 70;
		var maxBGWidth:Int = Std.int(msBG.x + msBG.width)-20;
		var buttonY:Int = (Std.int(msBG.y + msBG.height)-20)-buttonWidth;
		butt_toggleMod = new UIButton(maxBGWidth-buttonWidth,buttonY, ["ic_mod_active","ic_mod_disabled"],()->{
			if (noMods) return;
			var current:ModFile = modShits[curSelected];
			var modName:String = current.modName;
			if (!Paths.curModDir.contains(modName))
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				Paths.curModDir.push(modName);
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				checkRestart(modName);
				Paths.curModDir.remove(modName);
			}

			butt_toggleMod.icon.animation.play((Paths.curModDir.contains(modName)?"ic_mod_active":"ic_mod_disabled"),true);
			butt_toggleMod.color = Paths.curModDir.contains(modName) ? 0xFF00673C : 0xFF672B00;
			doCheck();
		});
		add(butt_toggleMod);

		butt_openInExplorer = new UIButton(maxBGWidth-(buttonWidth+20)*2,buttonY, ["ic_open_explorer"],()->{
			var current:ModFile = modShits[curSelected];
			var modName:String = current.modName;
			CDevConfig.utils.openFolder(Paths.mods(modName),true);
		});
		add(butt_openInExplorer);

		butt_archiveMod = new UIButton(maxBGWidth-(buttonWidth+20)*3,buttonY, ["ic_archive_mod"],()->{
			// think
		});
		add(butt_archiveMod);

		butt_deleteMod = new UIButton(maxBGWidth-(buttonWidth+20)*4,buttonY, ["ic_remove_mod"],()->{
			// think
		});
		add(butt_deleteMod);

		butt_toggleMod.active = butt_openInExplorer.active = butt_archiveMod.active = butt_deleteMod.active =
		butt_toggleMod.visible = butt_openInExplorer.visible = butt_archiveMod.visible = butt_deleteMod.visible = false;

		eVer = new FlxText(msBG.x + 30,msBG.y+msBG.height,-1,"", 18);
		eVer.setFormat(FunkinFonts.VCR, 18, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		eVer.borderQuality = msDesc.borderSize = 2;
		add(eVer);
	}

	var restartOnExit:Bool = false;

	public var lastModRequireRestart:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		checkerBG.x -= elapsed * 20;
		checkerBG.y -= elapsed * 20;

		for (index=>obj in listBox.item_list) {
			var modName:String = obj.label.text;
			obj.activeMod = Paths.curModDir.contains(modName);
			if (obj.curOverlap) {
				if (FlxG.mouse.justPressed) {
					curSelected = index;
					trace(curSelected);
					/*if (!noMods)
					{
						if (!Paths.curModDir.contains(modName))
						{
							FlxG.sound.play(Paths.sound('confirmMenu'));
							Paths.curModDir.push(modName);
						}
						else
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
							checkRestart(modName);
							Paths.curModDir.remove(modName);
						}
						doCheck();
					}*/
				}
			}
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
			resetMods();
	}

	function resetMods() {
		FlxG.sound.play(Paths.sound('cancelMenu'));
		Paths.curModDir = [];
		doCheck();
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
	}

	var tweenie:FlxTween;
	var uhh:FlxTween;

	function changeBackground(thisMod:String)
	{
		var mod:String = thisMod;
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
