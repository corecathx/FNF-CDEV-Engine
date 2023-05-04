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
}

class CDevConfig
{
	public static var debug:Bool = false;
	public static var elapsedGameTime:Float;
	public static var engineVersion:String = "1.2";
	public static var utils(default, null):CDevUtils = new CDevUtils();

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

	/*
		oh mein gott
		public static function initializeSaves()
			{
				if (FlxG.save.data.dfjk == null)
					FlxG.save.data.dfjk = false;

				if (FlxG.save.data.downscroll == null)
					FlxG.save.data.downscroll = false;

				if (FlxG.save.data.songtime == null)
					FlxG.save.data.songtime = true;
					
				if (FlxG.save.data.flashing == null)
					FlxG.save.data.flashing = true;

				if (FlxG.save.data.camZoom == null)
					FlxG.save.data.camZoom = true;

				if (FlxG.save.data.camMovement == null)
					FlxG.save.data.camMovement = true;

				if (FlxG.save.data.fpplay == null)
					FlxG.save.data.fpplay = true;

				if (FlxG.save.data.fullinfo == null)
					FlxG.save.data.fullinfo = true;

				if (FlxG.save.data.frames == null)
					FlxG.save.data.frames = 10;

				if (FlxG.save.data.offset == null)
					FlxG.save.data.offset = 0;

				if (FlxG.save.data.ghost == null)
					FlxG.save.data.ghost = false;

				if (FlxG.save.data.fpscap == null)
					FlxG.save.data.fpscap = 120;

				if (FlxG.save.data.botplay == null)
					FlxG.save.data.botplay = false;

				if (FlxG.save.data.noteImpact == null)
					FlxG.save.data.noteImpact = true;
				
				if (FlxG.save.data.noteRipples == null)
					FlxG.save.data.noteRipples = false; //false = note splashes, true = note ripples

				if (FlxG.save.data.autoPause == null)
					FlxG.save.data.autoPause = false;

				//the keybinds
				if (FlxG.save.data.leftBind == null)
					FlxG.save.data.leftBind = 'A';

				if (FlxG.save.data.downBind == null)
					FlxG.save.data.downBind = 'S';

				if (FlxG.save.data.upBind == null)
					FlxG.save.data.upBind = 'W';

				if (FlxG.save.data.rightBind == null)
					FlxG.save.data.rightBind = 'D';

				if (FlxG.save.data.resetBind == null)
					FlxG.save.data.resetBind = 'R';

				//more flxgsave
				if (FlxG.save.data.performTxt == null) //fps, fps-engine, fps-mem, fps-mem-engine, mem, mem-engine, hide
					FlxG.save.data.performTxt = "fps-mem-engine"; 

				if (FlxG.save.data.smoothAF == null)
					FlxG.save.data.smoothAF = true;

				if (FlxG.save.data.middlescroll == null)
					FlxG.save.data.middlescroll = false;

				if (FlxG.save.data.antialiasing == null)
					FlxG.save.data.antialiasing = true;

				if (FlxG.save.data.fnfNotes == null)
					FlxG.save.data.fnfNotes = true;

				if (FlxG.save.data.hitsound == null)
					FlxG.save.data.hitsound = false;
				
				//Rating sprite position

				if (FlxG.save.data.rX == null)
					FlxG.save.data.rX = -1;

				if (FlxG.save.data.rY == null)
					FlxG.save.data.rY = -1;

				if (FlxG.save.data.rChanged == null)
					FlxG.save.data.rChanged = false;

				
				if (FlxG.save.data.cX == null)
					FlxG.save.data.cX = -1;

				if (FlxG.save.data.cY == null)
					FlxG.save.data.cY = -1;

				if (FlxG.save.data.cChanged == null)
					FlxG.save.data.cChanged = false;


				#if desktop
				if (FlxG.save.data.discordRpc == null)
					FlxG.save.data.discordRpc = true;
				#end

				if (FlxG.save.data.bgNote == null)
					FlxG.save.data.bgNote = false;

				if (FlxG.save.data.bgLane == null)
					FlxG.save.data.bgLane = false;

				if (FlxG.save.data.engineWM == null)
					FlxG.save.data.engineWM = true;

				if (FlxG.save.data.resetButton == null)
					FlxG.save.data.resetButton = false;

				if (FlxG.save.data.healthCounter == null)
					FlxG.save.data.healthCounter = false;   

				if (FlxG.save.data.showDelay == null)
					FlxG.save.data.showDelay = false;       

				if (FlxG.save.data.multiRateSprite == null)
					FlxG.save.data.multiRateSprite = true;

				//Chart Modifiers
				if (FlxG.save.data.randomNote == null)
					FlxG.save.data.randomNote = false;

				if (FlxG.save.data.suddenDeath == null)
					FlxG.save.data.suddenDeath = false;
				
				if (FlxG.save.data.scrollSpeed == null)
					FlxG.save.data.scrollSpeed = 1;

				if (FlxG.save.data.healthGainMulti == null)
					FlxG.save.data.healthGainMulti = 1;

				if (FlxG.save.data.healthLoseMulti == null)
					FlxG.save.data.healthLoseMulti = 1;

				if (FlxG.save.data.comboMultipiler == null)
					FlxG.save.data.comboMultipiler = 1;            

				if (FlxG.save.data.testMode == null)
					FlxG.save.data.testMode = false;

				if (FlxG.save.data.loadedMods == null)
					FlxG.save.data.loadedMods = [];

				if (FlxG.save.data.checkNewVersion == null)
					FlxG.save.data.checkNewVersion = true;

				//new ass settings
				if (FlxG.save.data.cameraStartFocus == null)
					FlxG.save.data.cameraStartFocus = 0; //0=dad, 1=gf, 2=bf

				//0=hide, 1=show-g, 2=show-p
				if (FlxG.save.data.showTraceLogAt == null)
					FlxG.save.data.showTraceLogAt = 0; 

				if (FlxG.save.data.quantizeNote == null)
					FlxG.save.data.quantizeNote = false;

	}*/
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
	public static var onExitFunction:openfl.utils.Function = function(){};
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
			autosaveChart_interval: 0
		}
		return save;
	}
}
