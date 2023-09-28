package cdev;

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

class CDevConfig
{
	public static var debug:Bool = false;
	public static var elapsedGameTime:Float;
	public static var engineVersion:String = "1.4";
	public static var utils(default, null):CDevUtils = new CDevUtils();

	public static var DEPRECATED_STUFFS:Map<String, String>;

	/**
	 * LEFT
	 * DOWN
	 * UP
	 * RIGHT
	 * RESET
	 */
	public static var keyBinds:Array<String> = ['A', 'S', 'W', 'D', 'R']; // LEFT, DOWN, UP, RIGHT, RESET

	public static var saveData:CDevSaveData = null;

	/**
	 * Initialize Saves
	 */
	public static function initSaves()
	{
		saveData = getSaveData();
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
		var data:String = Json.stringify(saveData, "\t");

		if (data.length > 0)
			File.saveContent('assets/data/cdev-data.save', data);
		trace("saved");
	}

	public static function getSaveData():CDevSaveData
	{
		var toReturn:CDevSaveData = null;
		if (FileSystem.exists("assets/data/cdev-data.save"))
		{
			var data:String = File.getContent("assets/data/cdev-data.save");
			var json = Json.parse(data);

			toReturn = json;
		}
		else
		{
			toReturn = getDefaultSaves();
		}
		return toReturn;
	}

	// PAIN
	public static function getData(name:String):Dynamic
	{
		switch (name)
		{
			case "Scroll Direction":
				return saveData.downscroll;
			case "Middlescroll":
				return saveData.middlescroll;
			case "Ghost Tapping":
				return saveData.ghost;
			case "Note Hit Timing":
				return saveData.showDelay;
			case "Stacking Rating Sprite":
				return saveData.multiRateSprite;
			case "Hit Sound":
				return saveData.hitsound;
			case "Reset Button":
				return saveData.resetButton;
			case "Botplay":
				return saveData.botplay;
			case "Health Percentage":
				return saveData.healthCounter;
			case "FPS Cap":
				return saveData.fpscap;
			case "Note Hit Effect":
				return saveData.noteImpact;
			case "Time Bar":
				return saveData.songtime;
			case "Flashing Lights":
				return saveData.flashing;
			case "Camera Beat Zoom":
				return saveData.camZoom;
			case "Camera Movement":
				return saveData.camMovement;
			case "Note Offset":
				return saveData.offset;
			case "Resources Info":
				return saveData.performTxt;
			case "Engine Watermark":
				return saveData.engineWM;
			case "Opponent Notes in Midscroll":
				return saveData.bgNote;
			case "Strum Lane":
				return saveData.bgLane;
			case "Discord Rich Presence":
				return saveData.discordRpc;
			case "Antialiasing":
				return saveData.antialiasing;
			case "Hit Effect Style":
				return saveData.noteRipples;
			case "Resources Info Mode":
				return saveData.performTxt;
			case "Trace Log Window":
				return saveData.showTraceLogAt;
			case "Trace Log Main Message":
				return saveData.traceLogMessage;
			case "Check For Updates":
				return saveData.checkNewVersion;
			case "Autosave Chart File":
				return saveData.autosaveChart;
			case "Detailed Score Text":
				return saveData.fullinfo;
		}
		return null;
	}

	public static function setData(name:String, data:Dynamic)
	{
		switch (name)
		{
			case "Scroll Direction":
				saveData.downscroll = data;
			case "Middlescroll":
				saveData.middlescroll = data;
			case "Ghost Tapping":
				saveData.ghost = data;
			case "Note Hit Timing":
				saveData.showDelay = data;
			case "Stacking Rating Sprite":
				saveData.multiRateSprite = data;
			case "Hit Sound":
				saveData.hitsound = data;
			case "Reset Button":
				saveData.resetButton = data;
			case "Botplay":
				saveData.botplay = data;
			case "Health Percentage":
				saveData.healthCounter = data;
			case "FPS Cap":
				saveData.fpscap = data;
			case "Note Hit Effect":
				saveData.noteImpact = data;
			case "Time Bar":
				saveData.songtime = data;
			case "Flashing Lights":
				saveData.flashing = data;
			case "Camera Beat Zoom":
				saveData.camZoom = data;
			case "Camera Movement":
				saveData.camMovement = data;
			case "Note Offset":
				saveData.offset = data;
			case "Resources Info":
				saveData.performTxt = data;
			case "Engine Watermark":
				saveData.engineWM = data;
			case "Opponent Notes in Midscroll":
				saveData.bgNote = data;
			case "Strum Lane":
				saveData.bgLane = data;
			case "Discord Rich Presence":
				saveData.discordRpc = data;
			case "Antialiasing":
				saveData.antialiasing = data;
			case "Hit Effect Style":
				saveData.noteRipples = data;
			case "Resources Info Mode":
				saveData.performTxt = data;
			case "Trace Log Window":
				saveData.showTraceLogAt = data;
			case "Trace Log Main Message":
				saveData.traceLogMessage = data;
			case "Check For Updates":
				saveData.checkNewVersion = data;
			case "Autosave Chart File":
				saveData.autosaveChart = data;
			case "Detailed Score Text":
				saveData.fullinfo = data;
		}
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
		keyBinds[0] = saveData.leftBind;
		keyBinds[1] = saveData.downBind;
		keyBinds[2] = saveData.upBind;
		keyBinds[3] = saveData.rightBind;
		keyBinds[4] = saveData.resetBind;
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
		var save:CDevSaveData = {
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
			resetBind: "R",

			performTxt: "fps-mem",
			smoothAF: true,
			middlescroll: false,
			antialiasing: true,
			fnfNotes: true,
			hitsound: false,

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
