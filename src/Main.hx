package;

import openfl.display.DisplayObject;
import cdev.backend.native.NativeUtils;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;

import cdev.backend.Game;
import cdev.backend.objects.StatsDisplay;

#if CRASH_HANDLER

import sys.io.File;
import sys.io.Process;

import haxe.io.Path;
import haxe.CallStack;
import haxe.CallStack.StackItem;

import openfl.events.UncaughtErrorEvent;
#end

/**
 * Program's starting point.
 */
class Main extends Sprite
{
	/** Current active instance of the Main class. **/
	public static var current:Main = null;
	
	public function new()
	{
		super();
		preInit();

		addChild(new Game());
		addChild(new StatsDisplay(10,10,0xFFFFFF));
		Log.info("CDEV Engine is ready :3");

		postInit();
	}


	function preInit() {
		Log.init();
		new Conductor();
		Controls.init();
		#if DARK_MODE_WINDOW
		NativeUtils.setWindowDarkMode(Application.current.window.title, true);
		#end
	}

	function postInit() {
		FlxG.mouse.visible = false;
		FlxG.cameras.useBufferLocking = true;
		FlxG.autoPause = false;
		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		// Linux Stuff.
		#if linux
		inline function runCmd(cmd, args) {
			var cmd = Sys.command(cmd, args);
			trace("runCmd: " + cmd + " " + (cmd != 127 ? "finished" : "failed"));
		}
		runCmd("chmod", ["+x", "./cdev-crash_handler"]);
		#end
	}

	#if CRASH_HANDLER
	function onCrash(uncaught:UncaughtErrorEvent):Void
	{
		Log.error("CDEV Engine just crashed.");
		// somehow, the music crashed the crash handler
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		var finalOutput:String = "";
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");
		var filePath:String = "./crash/" + "CDEV-Engine_" + dateNow + ".txt";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					finalOutput += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		finalOutput += "\nEngine Version: "+Engine.version;
		finalOutput += "\nError: " + uncaught.error;
		#if desktop 
		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(filePath, finalOutput + "\n");

		if (Preferences.verboseLog) {
			Log.error("Crash info file saved in " + Path.normalize(filePath));	
			Log.error("Saving current save data, and closing the game...");
		}
		#end

		var reportClassic:String = "CDEV Engine crashed during runtime.\n\nCall Stacks:\n"
		+ finalOutput
		+ "Please report this error to CDEV Engine's GitHub page: \nhttps://github.com/Core5570RYT/FNF-CDEV-Engine";
		
		var cdev_ch_path:String = "./cdev-crash_handler"#if windows + ".exe"; #elseif linux ; #end
		trace(cdev_ch_path);
		if (FileSystem.exists(cdev_ch_path))
			new Process(cdev_ch_path, ["crash", filePath]);
		else
			Application.current.window.alert(reportClassic); // fallback
		Sys.exit(1);
	}
	#end

	#if !debug
	// Get rid of hit test function because mouse memory ramp up during first move (-Bolo)
	@:noCompletion override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool return false;
	@:noCompletion override function __hitTestHitArea(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool return false;
	@:noCompletion override function __hitTestMask(x:Float, y:Float):Bool return false;
	#end
}