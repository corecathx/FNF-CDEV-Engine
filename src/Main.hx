package;

import lime.app.Application;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

import cdev.backend.engine.Game;
import cdev.backend.engine.StatsDisplay;

#if CRASH_HANDLER
import sys.FileSystem;
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
		new Conductor();
		Controls.init();
		addChild(new Game());
		addChild(new StatsDisplay(10,10,0xFFFFFF));
		trace("CDEV Engine is ready :3");

		postInit();
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
	}

	#if CRASH_HANDLER
	function onCrash(uncaught:UncaughtErrorEvent):Void
	{
		trace("CDEV Engine just crashed.");
		// somehow, the music crashed the crash handler
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		var textStuff:String = "";
		var filePath:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		filePath = "./crash/" + "CDEV-Engine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					textStuff += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		textStuff += "\nEngine Version: "+Config.engine.version;
		textStuff += "\nError: " + uncaught.error;
		#if desktop 
		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(filePath, textStuff + "\n");

		trace("Crash info file saved in " + Path.normalize(filePath));	
		trace("Saving current save data, and closing the game...");
		#end

		var reportClassic:String = "CDEV Engine crashed during runtime.\n\nCall Stacks:\n"
		+ textStuff
		+ "Please report this error to CDEV Engine's GitHub page: \nhttps://github.com/Core5570RYT/FNF-CDEV-Engine";
		
		var cdev_ch_path:String = "./cdev-crash_handler.exe";
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