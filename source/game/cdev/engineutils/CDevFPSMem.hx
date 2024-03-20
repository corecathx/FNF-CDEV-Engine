package game.cdev.engineutils;

import game.cdev.log.GameLog;
import game.system.FunkinSystem;
import lime.app.Application;
import openfl.display.IBitmapDrawable;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import game.cdev.CDevConfig;
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
	public var highestMemory:Float = 0;
	public static var current:CDevFPSMem = null;
	public var showingInfo:Bool = false;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000, bold:Bool = false)
	{
		super();
		x = inX;
		y = inY;
		current = this;

		selectable = false;
		var mobileMulti:Float = #if mobile 1.5; #else 1; #end
		defaultTextFormat = new TextFormat("VCR OSD Mono", Std.int(14*mobileMulti), inCol, false);
		text = "FPS: ";
		times = [];
	    addEventListener(Event.ENTER_FRAME, onEnter);
		autoSize = LEFT;
	}

	private function onEnter(_)
	{
		var now = Timer.stamp();
		times.push(now);
	
		while (times[0] < now - 1)
			times.shift();
	
		var mem:Float = System.totalMemory;
		if (mem > highestMemory) highestMemory = mem;
		var ramStr:String = CDevConfig.utils.convert_size(Std.int(mem));
		
		if (mem / 1024 / 1024 >= 2048){
			openfl.Assets.cache.clear();
			FlxG.save.flush();
			CDevConfig.storeSaveData();
			game.Paths.destroyLoadedImages();
		}

		var debugText:String = (CDevConfig.debug ? "\n[Debug Build]" : "");

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

			var memoryPeak = (GameLog.isVisible
				&& (CDevConfig.saveData.performTxt == "fps-mem" 
				|| CDevConfig.saveData.performTxt == "mem") ? " // RAM Peak: " + CDevConfig.utils.convert_size(Std.int(highestMemory)) : "");
			
			text = s + memoryPeak + debugText;
		}
	
		textColor = (times.length < CDevConfig.saveData.fpscap / 2) ? 0xFF0000 : 0xFFFFFF;

		game.cdev.CDevConfig.elapsedGameTime += FlxG.elapsed * 1000;
	}
}