package game.cdev;

import haxe.io.Bytes;
import haxe.Unserializer;
import haxe.Serializer;
import sys.io.File;
import haxe.Json;
import cpp.Function;
import sys.FileSystem;
import game.Paths;
import flixel.math.FlxMath;
import flixel.FlxG;
import game.Controls.KeyboardScheme;
import openfl.Lib;

using StringTools;

typedef CDevSaveData =
{
	var save_version:String;
	// basic settings
	var downscroll:Bool;
	var songtime:Bool;
	var flashing:Bool;
	var camZoom:Bool;
	var camMovement:Bool;
	var fullinfo:Bool;
	var frames:Int;
	var offset:Float;
	var ghost:Bool;
	var fpscap:Int;
	var botplay:Bool;
	var noteImpact:Bool;
	var noteRipples:Bool;
	var autoPause:Bool;

	// keybind stuff
	var leftBind:String;
	var downBind:String;
	var upBind:String;
	var rightBind:String;
	var resetBind:String;

	// appearance
	var performTxt:String;
	var smoothAF:Bool; // fps, fps-mem, mem, hide
	var middlescroll:Bool;
	var antialiasing:Bool;
	var fnfNotes:Bool; // this option is kind of useless and may be removed in the future release.
	var hitsound:Bool;
	var shaders:Bool;

	/////// more stuff ////////
	// rating sprite
	var rX:Float;
	var rY:Float;
	var rChanged:Bool;
	// combo sprite
	var cX:Float;
	var cY:Float;
	var cChanged:Bool;
	// discord RPC
	#if desktop var discordRpc:Bool; #end
	// misc settings
	var bgNote:Bool;
	var bgLane:Bool;
	var engineWM:Bool;
	var resetButton:Bool;
	var healthCounter:Bool;
	var showDelay:Bool;
	var multiRateSprite:Bool;
	// chart modifiers
	var randomNote:Bool;
	var suddenDeath:Bool;
	var scrollSpeed:Float;
	var healthGainMulti:Float;
	var healthLoseMulti:Float;
	var comboMultipiler:Float;
	// debug and testing
	var testMode:Bool;
	// more more stuff
	var loadedMods:Array<String>;
	var checkNewVersion:Bool;
	var cameraStartFocus:Int; // i wanted to set this as string soon
	var showTraceLogAt:Int; // 0=hide, 1=show-g, 2=show-p
	var autosaveChart:Bool;
	var autosaveChart_interval:Float;

	var traceLogMessage:Bool;
}

/**
 * Configuration class for CDEV Engine
 */
class CDevConfig
{
	public static var debug:Bool = false;
	public static var elapsedGameTime:Float;
	public static var engineVersion:String = "1.5";
	public static var utils(default, null):CDevUtils = new CDevUtils();

	public static var DEPRECATED_STUFFS:Map<String, String>;

	/**
	 * LEFT
	 * DOWN
	 * UP
	 * RIGHT
	 * RESET
	 */
	public static var keyBinds:Dynamic = {
		left: "A",
		down: "S",
		up: "W",
		right: "D",

		ui_left: "A",
		ui_down: "S",
		ui_up: "W",
		ui_right: "D",

		reset: "R",
		accept: "BACK"
	}; // LEFT, DOWN, UP, RIGHT, RESET

	//public static var saveData:CDevSaveData = null;
	//FlxG.save.data styled shit
	public static var saveData(default, null):Dynamic;
	public static var savePath:String = "";
	public static var saveFolder:String = "\\CDEV Engine\\";
	public static var saveFileName:String = "cdev-data.save";

	/**
	 * Initialize Saves
	 */
	public static function initSaves()
	{
		savePath = Sys.getEnv("AppData") + saveFolder;
		trace(savePath);
		saveData = getSaveData();

		for (i in Reflect.fields(getDefaultSaves())){
			checkDataField(i);
		}

		updateSettingsOnSaves();

		DEPRECATED_STUFFS = new Map<String, String>();
		DEPRECATED_STUFFS["p1NoteHit"] = "1.4";
		DEPRECATED_STUFFS["p2NoteHit"] = "1.4";
	}

	public static function updateSettingsOnSaves()
	{
		FlxG.autoPause = saveData.autoPause;
		setFPS(CDevConfig.saveData.fpscap);

		Main.discordRPC = saveData.discordRpc;

		checkLoadedMods();
		saveCurrentKeyBinds();
	}

	public static function storeSaveData()
	{
		var data:String = Serializer.run(Json.stringify(saveData, "\t"));
		//var conv_data:Bytes = Bytes.ofString(data); nah
		var fullPath:String = savePath + saveFileName;
		if (!FileSystem.exists(savePath)){
			FileSystem.createDirectory(savePath);
		}
		if (data.length > 0)
			File.saveContent(fullPath, data);
		trace("saved");
	}

	public static function getSaveData():Dynamic
	{
		var toReturn = getDefaultSaves();
		var fullPath:String = savePath + saveFileName;
		if (FileSystem.exists(fullPath))
		{
			trace("Save folder existed.");
			var data:String = File.getContent(fullPath);
			var json = Json.parse(Unserializer.run(data));

			toReturn = json;
		}
		return toReturn;
	}

	// PAIN
	public static function getData(name:String):Dynamic
	{
		if (Reflect.hasField(saveData, name))
			return Reflect.getProperty(saveData, name);

		trace("Save Data has no \""+name+"\" field.");
		return null;
	}

	public static function setData(name:String, data:Dynamic)
	{
		if (Reflect.hasField(saveData, name))
			Reflect.setProperty(saveData, name, data);
		else
			trace("Save Data has no \""+name+"\" field.");
	}

	public static function checkDataField(name:String) {
		var saves = getDefaultSaves();
		var defSave = null;
		if (!Reflect.hasField(saves, name))
			return;
		if (Reflect.hasField(saveData, name))
			return;

		defSave = Reflect.getProperty(saves, name);

		trace(name + " was null before, loaded default settings for it.");
		Reflect.setProperty(saveData, name, defSave);
			
	}

	public static function checkLoadedMods()
	{
		// is this actually working??

		Paths.curModDir = saveData.loadedMods;
		var dirs:Array<String> = FileSystem.readDirectory('cdev-mods/');
		for (i in 0...saveData.loadedMods.length)
		{
			var mod:String = saveData.loadedMods[i];
			if (!dirs.contains(mod))
			{
				trace('$mod exists on saves, but couldnt find the file in cdev-mods. removing $mod from saves.');
				saveData.loadedMods.remove(mod);
			}
		}
		Paths.curModDir = saveData.loadedMods; // bruh
	}

	public static function saveCurrentKeyBinds()
	{
		/*keyBinds.left = "A";
		keyBinds.down = "S";
		keyBinds.up = "W";
		keyBinds.right = "D";

		keyBinds.ui_left = "A";
		keyBinds.ui_down = "S";
		keyBinds.ui_up = "W";
		keyBinds.ui_right = "D";

		keyBinds.reset = "R";
		keyBinds.accept = "BACK";
		keyBinds.back = "";
		keyBinds[0] = saveData.leftBind;
		keyBinds[1] = saveData.downBind;
		keyBinds[2] = saveData.upBind;
		keyBinds[3] = saveData.rightBind;
		keyBinds[4] = saveData.resetBind;*/
	}

	public static function setFPS(daSet:Int)
	{
		openfl.Lib.current.stage.frameRate = daSet;
	}

	// what to do before application get closed?
	public static var onExitFunction:openfl.utils.Function = function()
	{
	};

	public static function setExitHandler(func:openfl.utils.Function):Void
	{
		trace("exit handler change: " + func);
		#if openfl_legacy
		openfl.Lib.current.stage.onQuit = function()
		{
			func();
			openfl.Lib.close();
		};
		#else
		openfl.Lib.current.stage.application.onExit.add(function(code)
		{
			func();
		});
		#end

		onExitFunction = func;
	}

	public static function getDefaultSaves()
	{
		var save = {
			downscroll: false,
			songtime: true,
			flashing: true,
			camZoom: true,
			camMovement: true,
			fullinfo: true,
			frames: 10,
			offset: 0,
			ghost: true,
			fpscap: 120,
			botplay: false,
			noteImpact: true,
			noteRipples: false,
			autoPause: false,

			leftBind: "A",
			downBind: "S",
			upBind: "W",
			rightBind: "D",

			// new stuff
			ui_leftBind: ["A"],
			ui_downBind: ["S"],
			ui_upBind: ["W"],
			ui_rightBind: ["D"],

			resetBind: ["R"],
			acceptBind: ["SPACE", "ENTER"],
			backBind: ["BACKSPACE", "ESCAPE"],
			pauseBind: ["ENTER", "ESCAPE"],
			// wee
			
			performTxt: "fps-mem",
			smoothAF: true,
			middlescroll: false,
			antialiasing: true,
			fnfNotes: true,
			hitsound: false,
			shaders: true,

			rX: -1,
			rY: -1,
			rChanged: false,

			cX: -1,
			cY: -1,
			cChanged: false,

			#if desktop
			discordRpc: true,
			#end

			bgNote: false,
			bgLane: false,
			engineWM: true,
			resetButton: false,
			healthCounter: false,
			showDelay: false,
			multiRateSprite: true,

			randomNote: false,
			suddenDeath: false,
			scrollSpeed: 1,
			healthGainMulti: 1,
			healthLoseMulti: 1,
			comboMultipiler: 1,

			testMode: false,

			loadedMods: [],
			checkNewVersion: true,
			cameraStartFocus: 0,
			showTraceLogAt: 0,

			autosaveChart: false,
			autosaveChart_interval: 0,

			traceLogMessage: true
		}
		return save;
	}
}
