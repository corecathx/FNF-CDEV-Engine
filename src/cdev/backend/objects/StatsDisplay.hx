package cdev.backend.objects;

import flixel.FlxG;
import haxe.Timer;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * FPS and Memory Usage counter that's shown on top corner left of the game.
 */
class StatsDisplay extends TextField
{
	/** Active instance of the Stats Display. **/
	public static var current:StatsDisplay = null;

	/** Current FPS value. **/
	public var curFps:Float = 0;

	/** Current used GC Memory in Bytes. **/
	public var curMemory:Float = 0;
	
	/** Memory Peak / Highest Memory. **/
	public var highestMemory:Float = 0;

	/** Tracked frames in a second. **/
	public var frames:Array<Float> = [];

	public var lowFps(get,never):Bool;
	function get_lowFps():Bool {
		return (frames.length < FlxG.updateFramerate/2);
	}

	/**
	 * Creates a new Stats Display object.
	 * @param nX X Position of the object.
	 * @param nY Y Position of the object.
	 * @param nColor Text color.
	 */
	public function new(nX:Float = 10.0, nY:Float = 10.0, nColor:Int = 0x000000)
	{
		super();
		x = nX;
		y = nY;
		current = this;

		selectable = false;
		defaultTextFormat = new TextFormat(Constants.UI_FONT, 14, nColor, false);
		autoSize = LEFT;
	}

	private override function __enterFrame(elapsed:Float) {
		var now:Float = Timer.stamp();
		frames.push(now);
	
		while (frames[0] < now - 1) frames.shift();

		curMemory = MemoryUtils.usedMemory();//NativeUtils.getUsedMemory();
		curFps = FlxMath.bound(FlxMath.lerp(frames.length, curFps, 1-(FlxG.elapsed*12)), 0, null);
		
		if (curMemory > highestMemory) highestMemory = curMemory;
		Game._ACTIVE_TIME += FlxG.elapsed;
		updateText();
	}

	/**
	 * A function that updates the text of the Stats Display.
	 * You could also override this in a script and modify it to your liking.
	 */
	public dynamic function updateText():Void {
		if (!visible) return;
	
		var ramStr:String = Utils.formatBytes(curMemory);
		var rndFPS:String = '${FlxMath.roundDecimal(curFps,1)}';
		var labels = {
			fps: "!"+rndFPS + " FPS! #(" + Std.int((1/curFps)*1000) + "ms)#",
			mem: ramStr
		};
		
		var wholeText:String = '${labels.fps}\n${labels.mem}';
		var memoryPeak = " #// " + Utils.formatBytes(Std.int(highestMemory)) + "#";
		
		text = wholeText + memoryPeak + "\n#"+Engine.version+" cdev@" + Engine.gitBranch + " " + Engine.gitCommit + "#";
		
		applyFormatting();

	}
	
	var _fps_format:TextFormat = new TextFormat(null, 18, null);
	var _red_format:TextFormat = new TextFormat(null, null, null);
	var _other_format:TextFormat = new TextFormat(null, 12, 0x707070);
	function applyFormatting() {
		// The gray text thing
		_red_format.color = lowFps ? 0xFF0000 : 0xFFFFFF;
		Utils.applyTextFieldMarkup(this,text,[
			{format: _other_format, marker: "#"},
			{format: _red_format, marker:"!"}
		]);

		// The FPS value thing
		_fps_format.color = lowFps ? 0xFF0000 : 0xFFFFFF;
		this.setTextFormat(_fps_format, 0, Std.string(frames.length).length);
	}
}