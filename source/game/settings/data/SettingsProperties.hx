package game.settings.data;

import openfl.system.System;
import openfl.utils.Assets;
import meta.substates.RatingPosition;
import meta.states.TitleState;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.FlxG;

class SettingsType
{
	public static var BOOL:Int = 0; // ENTER
	public static var INT:Int = 1; // LEFT RIGHT
	public static var FLOAT:Int = 2; // LEFT RIGHT
	public static var FUNCTION:Int = 3; // ENTER
	public static var MIXED:Int = 4; // SELF DEFINED
}

// Modable settings wip
class SettingsProperties
{
	public static var currentClass:SettingsSubState = null;
	public static var CURRENT_SETTINGS:Array<SettingsCategory> = [];
	public static var holdTime:Float = 0;
	public static var ON_PAUSE:Bool = false;

	public static function setCurrentClass(curClass:Dynamic)
	{
		currentClass = cast curClass;
	}

	public static function reset():Void
	{
		currentClass = null;
		CURRENT_SETTINGS = [];
		holdTime = 0;
	}

	public static function load_default():Void
	{
		// CONTROLS//
		create_category("Controls", [],function()
		{
			//currentClass.openSubState(new keybinds.RebindControls(false));
		});

		// GAMEPLAY//
		create_category("Gameplay", [
			new BaseSettings("Scroll Direction", ["Up", "Down"], "Set the notes Scroll Direction.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "downscroll", false),
			new BaseSettings("Middlescroll", ["Disabled", "Enabled"], "Whether to position your Note Strums in center of your screen.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "middlescroll", false),
			new BaseSettings("Ghost Tapping", ["Disabled", "Enabled"], "If enabled, you won't get any misses when there's no notes hit.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "ghost"),
			new BaseSettings("Note Hit Timing", ["Hide", "Show"], "Whether to show your note timing in miliseconds.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "showDelay"),
			new BaseSettings("Stacking Rating Sprite", ["Disabled", "Enabled"], "Whether to show or hide the \"Sick!!\" sprite stacking each other.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "multiRateSprite"),
			new BaseSettings("Hit Sound", ["Disabled", "Enabled"], "If enabled, it'll play a clicking sound when you press your note keybinds.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "hitsound"),
			new BaseSettings("Reset Button", ["Disabled", "Enabled"], "If disabled, you won't get instant killed if you press the \"R\" key.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "resetButton"),
			new BaseSettings("Botplay", ["OFF", "ON"], "If enabled, a bot will play the game for you.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "botplay"),
			new BaseSettings("Health Percentage", ["Hide", "Show"], "Whether to show or hide the Health percentage in Score Text.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "healthCounter"),
			new BaseSettings("Note Hit Effect", ["Hide", "Show"], "Whether to show or hide the hit effect when you hit a note.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "noteImpact"),	
			new BaseSettings("Time Bar", ["Hide", "Show"], "If enabled, it will show current playing song time as a bar.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "songtime"),
			new BaseSettings("Flashing Lights", ["Disabled", "Enabled"], "Enable / Disable Flashing Lights.\n(Disable this if you're sensitive to flashing lights!)", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "flashing"),	
			new BaseSettings("Camera Beat Zoom", ["OFF", "ON"], "If enabled, the camera will zoom on every 4th beat.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "camZoom"),
			new BaseSettings("Camera Movement", ["OFF", "ON"], "If disabled, the camera won't move based on the current character sing animation", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "camMovement"),
			new BaseSettings("Note Offset", ["", ""], "If you think that your audio was late / early, try to change this setting!", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (FlxG.keys.justPressed.ENTER)
				{
					FlxG.switchState(new meta.states.OffsetTest());
				}

				var daValueToAdd:Int = FlxG.keys.pressed.RIGHT ? 1 : -1;
				if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
					holdTime += elapsed;
				else
					holdTime = 0;
	
				var e = [FlxG.keys.pressed.LEFT, FlxG.keys.pressed.RIGHT];
				if (holdTime <= 0 && e.contains(true))
					FlxG.sound.play(Paths.sound('scrollMenu'));
	
				if (holdTime > 0.5 || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
				{
					CDevConfig.setData("offset", CDevConfig.getData("offset")+daValueToAdd);
	
					if (CDevConfig.getData("offset") <= -90000) // like who tf does have a 90000 ms audio delay
						CDevConfig.setData("offset",-90000);

					if (CDevConfig.getData("offset") > 90000) // pfft
						CDevConfig.setData("offset",90000);
				}
				bs.value_name[0] = CDevConfig.getData("offset") + "ms";
			}, function(){}, "", false),
			new BaseSettings("Detailed Score Text", ["OFF", "ON"], "If enabled, the game will show your misses and accuracy in the score text.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "fullinfo")
		], null);

		create_category("Graphics", [
			new BaseSettings("Shaders", ["Disabled", "Enabled"], "Whether to enable / disable shaders in the engine.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "shaders", false),
			new BaseSettings("FPS Cap", ["", ""], "Choose how many frames per second that this game should run at.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				var daValueToAdd:Int = FlxG.keys.pressed.RIGHT ? 1 : -1;
				if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
					holdTime += elapsed;
				else
					holdTime = 0;
		
				var e = [FlxG.keys.pressed.LEFT, FlxG.keys.pressed.RIGHT];
				if (holdTime <= 0 && e.contains(true))
					FlxG.sound.play(Paths.sound('scrollMenu'));
	
				if (holdTime > 0.5 || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
				{
					CDevConfig.setData("fpscap", CDevConfig.getData("fpscap")+daValueToAdd);
		
					if (CDevConfig.getData("fpscap") <= 50)
						CDevConfig.setData("fpscap", 50);

					if (CDevConfig.getData("fpscap") > 300)
						CDevConfig.setData("fpscap", 300);

					CDevConfig.setFPS(CDevConfig.getData("fpscap"));
				}
				bs.value_name[0] = CDevConfig.getData("fpscap") + " FPS";
			}, function(){}, ""),	
			new BaseSettings("Antialiasing", ["OFF", "ON"], "If disabled, your game will run as smooth but at cost of graphics.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "antialiasing", false),
			new BaseSettings("Auto Pause", ["Disabled", "Enabled"], "If disabled, the game will no longer pauses whenever the game window is unfocused.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (FlxG.keys.justPressed.ENTER){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					CDevConfig.saveData.autoPause = !CDevConfig.saveData.autoPause;
					FlxG.autoPause = CDevConfig.saveData.autoPause;
	
					bs.value_name[0] = (CDevConfig.saveData.autoPause ? "Enabled":"Disabled");
				}
			}, function(){}, ""),
			new BaseSettings("Bitmaps on GPU", ["Disabled", "Enabled"], "Whether to store all bitmaps to your GPU, and not storing bitmaps to your RAM.\n(Warning: This option is still experimental.)", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "gpuBitmap", false),
			new BaseSettings("Clear Game Cache", ["", ""], "Press ENTER to clear memory cache.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				var usedMem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
				if (usedMem > 1024){
					bs.description = "You might need this option.\nPress ENTER to clear memory cache.";
					if (usedMem > 2048){
						bs.description = "You DEFINITELY need this option.\nPress ENTER to clear memory cache.";
					}
				} else{
					bs.description = "Press ENTER to clear memory cache.";
				}
				
				if (FlxG.keys.justPressed.ENTER){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					openfl.utils.Assets.cache.clear();
					Paths.destroyLoadedImages();
				}
			}, function(){}, "", false),
		], null);

		// APPEARANCE //
		create_category("Appearance", [
			new BaseSettings("Engine Watermark", ["Hide", "Show"], "Whether to show CDEV Engine's watermark in the game.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "engineWM"),	
			new BaseSettings("Opponent Notes in Midscroll", ["Hide", "Show"], "If enabled, opponent notes will be slightly visible.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "bgNote"),
			new BaseSettings("Strum Lane", ["Hide", "Show"], "If enabled, your strum notes playfield will have a black background.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "bgLane"),
			#if desktop new BaseSettings("Discord Rich Presence", ["", ""], "If enabled, your current game information will be shared to Discord RPC.\n(Changing this option will restart the game!)", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (FlxG.keys.justPressed.ENTER){
					CDevConfig.saveData.discordRpc = !CDevConfig.saveData.discordRpc;
					Main.discordRPC = CDevConfig.saveData.discordRpc;
					CDevConfig.utils.restartGame();
				}
				bs.value_name[0] = (CDevConfig.saveData.discordRpc ? "ON":"OFF");
			}, function(){}, "", false),#end
			new BaseSettings("Hit Effect Style", ["Splash", "Ripple"], "Choose your preferred Hit Effect Style.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "noteRipples", false),
			new BaseSettings("Set Rating Sprite Position", ["Press ENTER",""], "Set your preferred Rating sprite position.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (FlxG.keys.justPressed.ENTER){
					currentClass.hideAllOptions();
					var newState:RatingPosition = new RatingPosition(ON_PAUSE);
					currentClass.openSubState(newState);

					if (newState.leftState){
						currentClass.changeSelection();
						newState.leftState = false;
					}
				}
			}, function(){}, ""),
		], null);

		create_category("Misc", [
			new BaseSettings("Resources Info Mode", ["", ""], "Choose your preferred Resources Text Info Mode.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (FlxG.keys.justPressed.ENTER)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					var things:Array<String> = ["fps", "fps-mem", "mem", "hide"];
					var curIndex:Int = 0;

					trace("before: " + CDevConfig.saveData.performTxt);
					for (i in things){
						trace("data: " + i);
						if (CDevConfig.saveData.performTxt == i){
							curIndex = things.indexOf(i);
							trace("it similiar: " + i);
							break;
						}
					}

					curIndex += 1;
					if (curIndex >= things.length)
						curIndex = 0;
					CDevConfig.saveData.performTxt = things[curIndex];
					trace("after: " + CDevConfig.saveData.performTxt);
					Main.fpsCounter.visible = (CDevConfig.saveData.performTxt=="hide" ? false : true);
				}

				bs.value_name[0] = CDevConfig.saveData.performTxt;
			}, function(){}, ""),
			new BaseSettings("Game Log Window", ["", ""], "Whether to show / hide TGame Log Window.", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (FlxG.keys.justPressed.ENTER){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					CDevConfig.saveData.showTraceLogAt += 1;
					if (CDevConfig.saveData.showTraceLogAt < 0)
						CDevConfig.saveData.showTraceLogAt = 2;
					if (CDevConfig.saveData.showTraceLogAt >= 2)
						CDevConfig.saveData.showTraceLogAt = 0;
				}
				if (CDevConfig.saveData.showTraceLogAt==0)
					bs.value_name[0] = "Hide";
				else if (CDevConfig.saveData.showTraceLogAt==1)
					bs.value_name[0] = "Show";
				else
					bs.value_name[0] = "Undefined";
			}, function(){}, "", false),
			new BaseSettings("Game Log Main Message", ["Hide", "Show"], "Whether to show the tips text in the Game Log Window.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "traceLogMessage", false),	
			new BaseSettings("Check For Updates", ["Disable", "Enabled"], "If enabled, the game will check for updates.", SettingsType.BOOL, function(elapsed:Float, bs:BaseSettings){}, function(){}, "checkNewVersion", false),
			new BaseSettings("Autosave Chart File", ["", ""], "If enabled, the game will autosave the chart as a file. (Press SHIFT for more options)", SettingsType.MIXED, function(elapsed:Float, bs:BaseSettings){
				if (FlxG.keys.justPressed.ENTER){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					CDevConfig.saveData.autosaveChart = !CDevConfig.saveData.autosaveChart;
					if (CDevConfig.saveData.autosaveChart){
						bs.description = "If enabled, the game will autosave the chart as a file. (Press SHIFT for more options)";
					} else{
						bs.description = "If enabled, the game will autosave the chart as a file.";
					}
				}
				if (FlxG.keys.justPressed.SHIFT){
					currentClass.openSubState(new game.settings.misc.AutosaveSettings());
				}
				bs.value_name[0] = (CDevConfig.saveData.autosaveChart?"Enabled":"Disabled");
				
			}, function(){},"", false),
		], null);
	}

	public static function create_category(name:String, child:Array<BaseSettings>, ?onPress:Dynamic):Void
	{
		for (cat in CURRENT_SETTINGS)
		{
			if (cat.name == name)
			{
				trace("Settings category \"" + name + "\" already exists.");
				return;
			}
		}
		CURRENT_SETTINGS.push(new SettingsCategory(name, child, onPress));
	}

	public static function add_setting(catName:String, setName:String, setType:Int):Void
	{
		// Case-sensitive
		for (cat in CURRENT_SETTINGS)
		{
			if (cat.name == catName)
			{
				//var newSet:BaseSettings = new BaseSettings(setName, setType);
				//cat.settings.push(newSet);
				return;
			}
		}

		trace("Can't find settings category \"" + catName + "\".");
	}
}

class SettingsCategory
{
	public var settings:Array<BaseSettings> = [];
	public var name:String = "";
	public var onPress:Dynamic = null;

	public function new(name:String, sets:Array<BaseSettings>, ?onPress:Dynamic=null)
	{
		this.name = name;
		this.settings = sets;
		this.onPress = onPress;
	}
}

class BaseSettings
{
	public var name:String = "New Setting";
	public var value_name:Array<String> = ["Disabled", "Enabled"]; // false, true values.
	public var description:String = "No description was set.";
	public var type:Int = -1;
	public var savedata_field:String = "";

	public var selectedSetting:Bool = false;
	public var pausable:Bool = false;
	public var onUpdate:(Float, BaseSettings)->Void;
	public var updateDisplay:Void->Void;

	public function new(n:String, v:Array<String>, d:String, t:Int, oc:(Float, BaseSettings)->Void, ud:Void->Void, ?sdf:String="", ?canPause:Bool=true)
	{
		name = n;
		value_name = v;
		description = d;
		type = t;
		savedata_field = sdf;

		pausable = canPause;

		onUpdate = oc;
		updateDisplay = ud;
	}

	public function onUpdateHit(updateElapsed){
		onUpdate(updateElapsed,this);
	}

	public function updateThisDisplay(){
		updateDisplay();
	}
}