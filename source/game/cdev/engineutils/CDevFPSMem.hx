package game.cdev.engineutils;

import game.cdev.log.GameLog;
import game.system.native.Windows;
import game.cdev.CDevConfig;
import flixel.FlxG;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * FPS and Memory Usage counter that's shown on top corner left of the game.
 */
class CDevFPSMem extends TextField
{
	/**
	 * Just like the variable's name, it returns current FPS.
	 */
	public var curFps:Int = 0;

	/**
	 * Current used Memory by the game in Bytes.
	 * (Depends on what memory setting the player used, it can be showing the garbage collector memory / the total program used memory.)
	 */
	public var curMemory:Float = 0;
	
	/**
	 * Memory Peak / Highest Memory.
	 */
	public var highestMemory:Float = 0;

	/**
	 * Static instance of this class.
	 */
	public static var current:CDevFPSMem = null;

	public var times:Array<Float>;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000, bold:Bool = false)
	{
		super();
		x = inX;
		y = inY;
		current = this;

		selectable = false;
		var mobileMulti:Float = #if mobile 1.5; #else 1; #end
		defaultTextFormat = new TextFormat(FunkinFonts.JETBRAINS, Std.int(12*mobileMulti), inCol, false);
		text = "FPS: ";
		times = [];
		autoSize = LEFT;
	}

	var updateTime:Float = 0;
	private override function __enterFrame(elapsed:Float) {
		if (updateTime > 1000){
			updateTime = 0;
			return;
		}
		var now = Timer.stamp();
		times.push(now);
	
		while (times[0] < now - 1)
			times.shift();
	
		curMemory = CDevConfig.saveData.nativeMemory ? Windows.getCurrentUsedMemory() : System.totalMemory;
		curFps = times.length > CDevConfig.saveData.fpscap ? CDevConfig.saveData.fpscap : times.length;
		
		if (curMemory > highestMemory) highestMemory = curMemory;
		if (curMemory / 1024 / 1024 >= 2048){
			openfl.Assets.cache.clear();
			FlxG.save.flush();
			CDevConfig.storeSaveData();
			game.Paths.destroyLoadedImages();
		}
		game.cdev.CDevConfig.elapsedGameTime += FlxG.elapsed * 1000;
		updateText();

		updateTime += elapsed;
	}

	public dynamic function updateText():Void {
		var ramStr:String = CDevConfig.utils.convert_size(Std.int(curMemory));
		var debugText:String = (CDevConfig.debug ? "\n- Debug -" : "");
		var lowFPS:Bool = (curFps < CDevConfig.saveData.fpscap / 2);
		if (visible)
		{
			var c = {
				fps: curFps + " FPS ("+ Std.int((1/curFps)*1000)+ "ms)" + (lowFPS?" [!]":""),
				mem: ramStr + " RAM"
			}
			var wholeText:String = "";
			switch (CDevConfig.saveData.performTxt){
				case "fps":
					wholeText = c.fps;
				case "fps-mem":
					wholeText = '${c.fps}\n${c.mem}';
				case "mem":
					wholeText = c.mem;
				default:
					wholeText = "";
			}

			var memoryPeak = (GameLog.isVisible
				&& (CDevConfig.saveData.performTxt == "fps-mem" 
				|| CDevConfig.saveData.performTxt == "mem") ? " // " + CDevConfig.utils.convert_size(Std.int(highestMemory)) + " Peak" : "");
			
			text = wholeText + memoryPeak + debugText;
			applySizes();
		}
	
		textColor = lowFPS ? 0xFF0000 : 0xFFFFFF;
	}

	function applySizes(){
		if ((CDevConfig.saveData.performTxt == "fps-mem" || CDevConfig.saveData.performTxt == "fps"))
			this.setTextFormat(new TextFormat(null, 16, 0xFFFFFF),0,Std.string(times.length).length);
	}
}