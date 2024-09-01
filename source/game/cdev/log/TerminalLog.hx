package game.cdev.log;

/**
 * Used for colored traces in Terminal
 * Written by Cobalt Bar - https://github.com/CobaltBar/FNF-Horizon-Engine/blob/main/source/util/Log.hx
 * Modified by CoreCat/Dev for use in CDEV Engine
 *
 * :3
 */
import sys.io.File;
import sys.FileSystem;
import haxe.Constraints.Function;
import haxe.PosInfos;

using StringTools;

class TerminalLog
{
	// https://gist.github.com/martinwells/5980517
	// https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
	private static var ogTrace:Function;
	private static var log:Array<String> = [];

	public static function init():Void
	{
		ogTrace = haxe.Log.trace;
		haxe.Log.trace = haxeTrace;
		prettyPrint("CDEV Engine v" + CDevConfig.engineVersion + "\n(Logging style written by CobaltBar!)");
		info('Logger Initialized');

		// lime.app.Application
		lime.app.Application.current.onExit.add((_) ->
		{
			if (!FileSystem.exists('log'))
				FileSystem.createDirectory('log');
			Log.info('Log Written');
			File.saveContent('log/log.txt', @:privateAccess TerminalLog.log.join('\n'));
		});
	}

	@:keep static inline function ansi(color:Int):String
		return '\033[38;5;${color}m';

	@:keep static inline function haxeTrace(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'TRACE', 75, pos);

	@:keep public static inline function error(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'ERROR', 160, pos);

	@:keep public static inline function warn(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'WARN', 184, pos);

	@:keep public static inline function info(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'INFO', 45, pos);

	@:keep public static inline function script(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'SCRIPT', 128, pos);

	@:keep static inline function print(value:Dynamic, level:String, color:Int, ?pos:PosInfos):Void
	{
		var msg = '${ansi(33)}[${ansi(45)}${DateTools.format(Date.now(), '%H:%M:%S')} - ${ansi(255)}${pos.fileName.replace("source/", "")}:${pos.lineNumber}${ansi(33)}]';
		Sys.println(msg = '${msg.rpad(' ', 90)}${ansi(color)}$level: $value\033[0;0m');
		log.push('[${DateTools.format(Date.now(), '%H:%M:%S')} ${pos.fileName}:${pos.lineNumber}] $level: $value');
	}

	public static function prettyPrint(text:String)
	{
		var lines = text.split("\n");
		var length = -1;
		for (line in lines)
			if (line.length > length)
				length = line.length;

		var header = "======";
		for (i in 0...length)
			header += "=";

		Sys.println("");
		Sys.println('|$header|');
		for (line in lines)
		{
			Sys.println('|   ${ansi(45) + centerText(line, length) + ansi(255)}   |');
		}
		Sys.println('|$header|');
	}

	public static function centerText(text:String, width:Int):String
	{
		var centerOffset = (width - text.length) / 2;
		var left = repeat(' ', Math.floor(centerOffset));
		var right = repeat(' ', Math.ceil(centerOffset));
		return left + text + right;
	}

	public static inline function repeat(ch:String, amt:Int)
	{
		var str = "";
		for (i in 0...amt)
			str += ch;
		return str;
	}
}
