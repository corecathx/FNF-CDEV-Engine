package game.cdev;

import haxe.io.Path;
import haxe.Constraints.Function;
import game.cdev.engineutils.Discord.DiscordClient;
import lime.graphics.Image;
import lime.app.Application;
import haxe.io.Bytes;
import haxe.Unserializer;
import haxe.Serializer;
import haxe.Json;
import game.Paths;
import flixel.math.FlxMath;
import flixel.FlxG;
import game.Controls.KeyboardScheme;
import openfl.Lib;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

/**
 * Configuration class for CDEV Engine
 */
class CDevConfig
{
	public static var window_title:String = "Friday Night Funkin' CDEV Engine";
	public static var window_icon_custom:Bool = false;
	public static var debug:Bool = false;
	public static var elapsedGameTime:Float;
	public static var engineVersion:String = "1.6.2";
	public static var utils(default, null):CDevUtils = new CDevUtils();

	public static var DEPRECATED_STUFFS:Map<String, String>;

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
	};

	public static var saveData(default, null):Dynamic;
	public static var savePath:String = "";
	public static var saveFolder:String = "\\CDEV Engine\\";
	public static var saveFileName:String = "cdev-data.save";

	/**
	 * Initialize Saves
	 */
	public static function initSaves()
	{
		#if windows
		savePath = Sys.getEnv("AppData") + saveFolder;
		#else #if android
		savePath = Path.normalize(Sys.getCwd()+saveFolder);
		#end #end

		saveData = #if !mobile getSaveData(); #else FlxG.save.data;
		saveData = getDefaultSaves();
		#end

		for (i in Reflect.fields(getDefaultSaves())){
			checkDataField(i);
		}

		#if !mobile loadForcedMods(); #end
		updateSettingsOnSaves();

		DEPRECATED_STUFFS = new Map<String, String>();
		DEPRECATED_STUFFS["p1NoteHit"] = "1.4";
		DEPRECATED_STUFFS["p2NoteHit"] = "1.4";
	}

	public static function updateSettingsOnSaves()
	{
		trace("called!");
		FlxG.autoPause = saveData.autoPause;
		setFPS(CDevConfig.saveData.fpscap);

		#if DISCORD_RPC Main.discordRPC = saveData.discordRpc; #end

		checkLoadedMods();
		saveCurrentKeyBinds();
	}

	public static function storeSaveData()
	{
		FlxG.save.data.lastVolume = FlxG.sound.volume;

		#if windows
		var data:String = Serializer.run(Json.stringify(saveData, "\t"));
		//var conv_data:Bytes = Bytes.ofString(data); nah
		var fullPath:String = savePath + saveFileName;
		if (!FileSystem.exists(savePath)){
			FileSystem.createDirectory(savePath);
		}
		if (data.length > 0)
			File.saveContent(fullPath, data);
		#else
		trace("This is not a windows target, could not store save data.");
		#end

	}

	public static function getSaveData():Dynamic
	{
		var toReturn = getDefaultSaves();
		#if windows
		var fullPath:String = savePath + saveFileName;
		if (FileSystem.exists(fullPath))
		{
			trace("Save folder existed.");
			var data:String = File.getContent(fullPath);
			var json = null;
			
			try {
				json = Json.parse(Unserializer.run(data));
			} catch(ex){
				var text:String = 'An error occured while opening your save data\nPlease restart your CDEV Engine to see if the problem fixed.\nIf the issue persists, then delete "$saveFileName" file on your\r\n$savePath folder.';
				Application.current.window.alert(text);
		
				Sys.exit(1);
			}

			toReturn = json;
		}
		#else
		trace("This is not a windows target, could not load save data.");
		#end
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

	public static function loadForcedMods(){
		var fullText:String = File.getContent(Paths.txt('modsEnabled')).trim();
		var splitted:Array<String> = fullText.split("\n");
		var mods:Array<String> = [];
		var overrideAll:Bool = false;

		var flags:Array<{line:String, funk:Void->Void}> = [
			{
				line: "OVERRIDE_MOD_LIST",
				funk: function() {
					overrideAll = true;
				}
			}
		];
		
		for (line in splitted) {
			var gotIt:Bool = false;
		
			for (flag in flags) {
				if (line == flag.line) {
					trace("Got flag: " + flag.line);
					flag.funk();
					gotIt = true;
					break;
				}
			}
		
			if (!line.startsWith("--") && !gotIt) mods.push(line);
		}
		
		if (overrideAll) {
			saveData.loadedMods = [];
			Paths.curModDir = [];
			Paths.currentMod = null;
		}
		
		if (mods.length > 0) {
			for (mod in mods) {
				if (!saveData.loadedMods.contains(mod)) {
					trace("Forced mod, loaded: " + mod);
					saveData.loadedMods.push(mod);
				}
			}
		}
		
		Paths.curModDir = saveData.loadedMods;
		if (Paths.curModDir.length != 0) Paths.currentMod = Paths.curModDir[0];
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
		var dirs:Array<String> = #if sys FileSystem.readDirectory('cdev-mods/'); #else []; #end
		for (i in 0...saveData.loadedMods.length)
		{
			//if ()
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
		//hi
	}

	
	public static function setWindowProperty(reset:Bool, ?title:String, ?icon:String){
		var error = (title==null || icon==null);
		if (error)
			return;

		window_title = (reset ? Lib.application.meta["name"] : title);
		Application.current.window.title = window_title;

		window_icon_custom = #if sys (FileSystem.exists(icon) && !reset); #else false; #end
		var iconAsset = (window_icon_custom ? icon : "assets/shared/images/icon16.png");
		var f = File.getBytes(iconAsset);
		var i:Image = Image.fromBytes(f);
		Application.current.window.setIcon(i);
	}


	public static function setFPS(daSet:Int)
	{
		openfl.Lib.current.stage.frameRate = daSet;
	}

	// what to do before application get closed?
	public static var onExitFunction:Function = function()
	{
	};

	public static function setExitHandler(func:Function):Void
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

			autosaveChart: true,
			autosaveChart_interval: 30,

			traceLogMessage: true,

			gpuBitmap: false
		}
		return save;
	}
}
