package engineutils;

import cdev.CDevConfig;
import flixel.util.FlxColor;
import openfl.display.Stage;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.StageSizeScaleMode;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.events.EventType;
import openfl.display.DisplayObject;
import haxe.Timer;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

class CDevFPSMem extends TextField
{
	public var times:Array<Float>;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000, bold:Bool = false)
	{
		super();
		x = inX;
		y = inY;
		selectable = false;
		defaultTextFormat = new TextFormat("VCR OSD Mono", 14, inCol, false);
		text = "FPS: ";
		times = [];
	    addEventListener(Event.ENTER_FRAME, onEnter);
		width = 170;
		height = 70;
	}

	private function onEnter(_)
	{
		var now = Timer.stamp();

		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
		var ramStr:String = '';
		if (mem >= 1024)
			ramStr = Math.round(mem / 1024) + ' GB';
		else
			ramStr = mem + ' MB';
		
		if (mem >= 2048){
			openfl.Assets.cache.clear();
			FlxG.save.flush();
			CDevConfig.storeSaveData();
			game.Paths.destroyLoadedImages();
		}

		var engineText:String = "";//(CDevConfig.saveData.engineWM ? "CDEV FNF v"+CDevConfig.engineVersion: "");
		var debugText:String = (CDevConfig.debug ? "[Debug version]" : "");

		var s:String = "";
		
		if (visible)
		{
			switch (CDevConfig.saveData.performTxt){
				case "fps":
					s = "FPS: " + times.length;
				case "fps-mem":
					s = "FPS: " + times.length + "\nRAM: " + ramStr;
				case "mem":
					s = "RAM: " + ramStr;
				default:
					s = "";
			}
			text = s + '\n$engineText\n$debugText';
		}

		if (times.length < 30){
			textColor = 0xFF0000;
		} else{
			textColor = 0xFFFFFF;
		}

		cdev.CDevConfig.elapsedGameTime += FlxG.elapsed * 1000;

		//FlxG.game.width = FlxG.width;
		//FlxG.game.height = FlxG.stage.window.height;

	 	//Lib.current.width = Lib.application.window.width;
		//Lib.current.height = Lib.application.window.height;

		//FlxG.resizeWindow(Lib.application.window.width,Lib.application.window.height);
		//Lib.application.window.resize(Lib.application.window.width,Lib.application.window.height);
	}
}
