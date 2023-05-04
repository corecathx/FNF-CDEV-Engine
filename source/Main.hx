package;

import openfl.display.StageScaleMode;
#if CRASH_HANDLER
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import haxe.CallStack;
import haxe.CallStack.StackItem;
import openfl.events.UncaughtErrorEvent;
import sys.io.Process;
#end
import states.TitleState;
import flixel.system.scaleModes.StageSizeScaleMode;
import engineutils.FPS_Mem.CDevFPSMem;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import flixel.FlxG;
#if desktop
import engineutils.Discord.DiscordClient;
#end
import lime.app.Application;

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = states.TitleState; // The FlxState the game starts with.
	var zoom:Float = 1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fps_mem:CDevFPSMem;

	public static var discordRPC:Bool = false;

	var playState:Bool = false;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		//CDevConfig.initSaves();

		/*if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}*/

		#if cpp
		initialState = TitleState;
		#end
		#if desktop
		// DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			CDevConfig.onExitFunction();
			DiscordClient.shutdown();
			CDevConfig.storeSaveData();
		});
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		// addChild(new FPS(10, 10, 0xFFFFFF));
		fps_mem = new CDevFPSMem(10, 10, 0xffffff, true);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		addChild(fps_mem);
		#end
		FlxG.fixedTimestep = false;
		// FlxG.camera.antialiasing = FlxG.save.data.antialiasing;

		// FlxG.mouse.load(Paths.image('cdev-cursor','preload'),0.5);
		// Application.current.window.stage.color = null;
	}

	public function setFpsVisibility(fpsEnabled:Bool):Void
	{
		fps_mem.visible = fpsEnabled;
	}

	public function isPlayState():Bool
	{
		return playState;
	}

	public function setFPSCap(value:Float)
	{
		openfl.Lib.current.stage.frameRate = value;
	}

	public function getFPS():Float
	{
		return fps_mem.times.length;
	}
	#if CRASH_HANDLER
	function onCrash(uncaught:UncaughtErrorEvent):Void
	{
		if (FlxG.sound.music!=null&&FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		CDevConfig.storeSaveData();
		
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


		textStuff += "\nError: " + uncaught.error;
		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(filePath, textStuff + "\n");

		Sys.println("Crash info file saved in" + Path.normalize(filePath));

		var cdev_ch_path:String = "cdev-crash_handler.exe";

		/*var conv:String = '';
		for (obj in 0...toBeUsedInExe.length){
			conv += toBeUsedInExe[obj];
			if (!(obj > toBeUsedInExe.length-1))
				conv += " ";
		}*/

		DiscordClient.shutdown();

		if (FileSystem.exists(cdev_ch_path)){
			//cool python crash handler!
			new Process(cdev_ch_path, [filePath]);
		} else{
			//gotta call a simple message box thingie
			Application.current.window.alert("CDEV Engine crashed during runtime.\n\nCall Stacks:" + textStuff + "Please report this error to CDEV Engine's GitHub page: \nhttps://github.com/Core5570RYT/FNF-CoreDEV-Engine");
		}

		//Sys.command("cdev-crash_handler.exe "+conv);
		Sys.exit(1);
	}
	#end
}
