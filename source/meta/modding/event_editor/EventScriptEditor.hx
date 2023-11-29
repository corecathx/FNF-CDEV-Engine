package meta.modding.event_editor;

import sys.io.File;
import lime.system.Clipboard;
import flixel.addons.ui.FlxUIInputText;
import game.objects.Alphabet;
#if desktop import game.cdev.engineutils.Discord.DiscordClient; #end
import game.cdev.CDevConfig;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import game.CoolUtil;
import haxe.io.Path;
import game.Paths;
import sys.FileSystem;
import flixel.addons.ui.FlxButtonPlus;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import meta.states.MusicBeatState;

using StringTools;

class EventScriptEditor extends MusicBeatState
{
	var curSelected:Int = 0;
	var menuBG:FlxSprite;
	var backgroundPanel:FlxSprite;
	var panelText:FlxText;
	var newEvent:FlxButtonPlus;

	var scriptList:Array<String>;

	var grpScriptList:FlxTypedGroup<FlxText>;
	var sus:Array<Dynamic> = []; //obj, num

	public static var onSubstate:Bool = false;

	override function create()
	{
		super.create();
		FlxG.mouse.visible = true;
		#if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence("Creating Event Scripts", null);
		#end

		persistentUpdate = false;
		persistentDraw = true;
		menuBG = new FlxSprite().loadGraphic(game.Paths.image('menuDesat'));
		menuBG.color = FlxColor.CYAN;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.7;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		updateScriptList();

		backgroundPanel = new FlxSprite().makeGraphic(Std.int(FlxG.width / 3), Std.int(FlxG.height), FlxColor.BLACK);
		backgroundPanel.alpha = 0.6;
		add(backgroundPanel);

		grpScriptList = new FlxTypedGroup<FlxText>();
		add(grpScriptList);
		createTexts();

		panelText = new FlxText(0, 20, FlxG.width / 3, 'Events', 18);
		panelText.setFormat('VCR OSD Mono', 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(panelText);

		newEvent = new FlxButtonPlus(10, FlxG.height - 30, function()
		{
			
			if (!onSubstate){
				openSubState(new CreateEventScript());
				FlxG.sound.play(Paths.sound('scrollMenu'),0.6);
			}
			onSubstate = true;
		}, "Add New Event", Std.int(backgroundPanel.width) - 20, 20);
		newEvent.updateInactiveButtonColors([0xff3c0080, 0xff6200d1]);
		newEvent.updateActiveButtonColors([0xff0038a1, 0xff006cfa]);
		add(newEvent);

		var updateList:FlxButtonPlus = new FlxButtonPlus(10, FlxG.height - 60, function()
		{
			FlxG.sound.play(Paths.sound('confirmMenu'),0.6);
			updateScriptList();
			createTexts();
		}, "Update Event List", Std.int(backgroundPanel.width) - 20, 20);
		updateList.updateInactiveButtonColors([0xff510080, 0xff8f00d1]);
		updateList.updateActiveButtonColors([0xff000ba1, 0xff0025fa]);
		add(updateList);
	}

	function createTexts(){
		sus = [];
		for (i in grpScriptList.members){
			i.kill();
			remove(i);
		}

		for (i in 0...scriptList.length){
			var daText:FlxText = new FlxText(20,60 + (40 * i),0, scriptList[i]);
			daText.setFormat('VCR OSD Mono', 18, FlxColor.WHITE, LEFT);
			daText.ID = i;
			grpScriptList.add(daText);

			sus.push([daText, 0]);
		}
	}

	function updateScriptList()
	{
		scriptList = [];
		var dirs:Array<String> = [];

		dirs.push(Paths.mods(Paths.curModDir[0] + '/events/'));
		trace(Paths.mods(Paths.curModDir[0] + '/events/'));

		for (i in 0...dirs.length)
		{
			var dir:String = dirs[i];
			if (FileSystem.exists(dir))
			{
				for (i in FileSystem.readDirectory(dir))
				{
					//we'll select the event name using the json filename
					var name:String = '';
					if (i.endsWith('.hx')){
						name = i.substr(0, i.length - 3);

						trace(name);

						if (FileSystem.exists(Path.join([dir, name + '.hx'])) && !FileSystem.isDirectory(Path.join([dir, name + '.hx'])))
						{
							trace('hx is exist');
							scriptList.push(i.substr(0, i.length - 3));
						}	
					}
				}
			}
		}
		if (scriptList.length <= 0)
			scriptList.push('No Script was found!');

		// characterDropDown.selectedLabel = daAnim;
	}
	override function closeSubState()
		{
			super.closeSubState();
			updateScriptList();
			createTexts();
		}
	
	var lastCurSelected:Int = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (lastCurSelected != curSelected){
			changeSelection();
		}

		grpScriptList.forEachAlive(function(txt:FlxText){
			if (FlxG.mouse.overlaps(txt))
			{
				curSelected = txt.ID;
			}

			var reg:Int = -1;
			for (i in 0...sus.length){
				if (sus[i][0] == txt){
					reg = i;
				}
			}

			if (curSelected != txt.ID)
				txt.x = FlxMath.lerp(txt.x, 20, CDevConfig.utils.bound(elapsed * 6, 0, 1));
			else
				txt.x = FlxMath.lerp(txt.x, 40, CDevConfig.utils.bound(elapsed * 6, 0, 1));		
		});

		lastCurSelected = curSelected;

		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.switchState(new ModdingScreen());
		}
	}

	function changeSelection() {
		var bullShit:Int = 0;
		
		for (item in grpScriptList.members)
			{
				var reg:Int = -1;
				for (i in 0...sus.length){
					if (sus[i][0] == item){
						reg = i;
					}
				}
				if (!(reg <= 0)){
					sus[reg][1] = bullShit - curSelected;
				}
				
				bullShit++;
				item.alpha = 0.6;
				if (!(reg <= 0)){
					if (sus[reg][1].targetY == 0)
					{
						item.alpha = 1;
					}
				}
			}
	}
}

