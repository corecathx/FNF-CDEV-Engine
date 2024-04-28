package game.cdev.engineutils;

import game.system.native.Windows;
import game.cdev.CDevConfig;
import flixel.FlxG;
import haxe.Timer;
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
		defaultTextFormat = new TextFormat(FunkinFonts.VCR, Std.int(14*mobileMulti), inCol, false);
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
	
		var mem:Float = CDevConfig.saveData.nativeMemory ? Windows.getCurrentUsedMemory() : System.totalMemory;
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

		var lowFPS:Bool = (times.length < CDevConfig.saveData.fpscap / 2);

		var c = {
			fps: "FPS: " + times.length + (lowFPS?" [!]":""),
			mem: "RAM: " + ramStr
		}
		
		if (visible)
		{
			switch (CDevConfig.saveData.performTxt){
				case "fps":
					s = c.fps;
				case "fps-mem":
					s = '${c.fps}\n${c.mem}';
				case "mem":
					s = c.mem;
				default:
					s = "";
			}

			var memoryPeak = (GameLog.isVisible
				&& (CDevConfig.saveData.performTxt == "fps-mem" 
				|| CDevConfig.saveData.performTxt == "mem") ? " // RAM Peak: " + CDevConfig.utils.convert_size(Std.int(highestMemory)) : "");
			
			text = s + memoryPeak + debugText;
		}
	
		textColor = lowFPS ? 0xFF0000 : 0xFFFFFF;

		game.cdev.CDevConfig.elapsedGameTime += FlxG.elapsed * 1000;
	}
}