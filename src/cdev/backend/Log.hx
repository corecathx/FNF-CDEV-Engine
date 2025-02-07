package cdev.backend;

import haxe.PosInfos;
import haxe.Constraints.Function;

/**
 * Handles in-game internal logs.
 */
class Log {
    /**
     * Original Haxe Trace function before it's being replaced by CDEV's.
     */
    private static var haxeTrace:Function;

    /**
     * Stores every logged texts in the engine, it'll get flushed at certain amount of history
     * to prevent memory leaks.
     */
    private static var history:Array<String> = [];

    /**
     * Initializes the Log class, will attach itself to haxe.Log.trace function.
     */
    public static function init():Void
    {
        haxeTrace = haxe.Log.trace;
        haxe.Log.trace = (v:Dynamic, ?infos:PosInfos) -> {
            __trace(v, infos);
        };
        prettyPrint(Engine.label + "\n(Logging style written by CobaltBar!)");
        info('Logger Initialized');

        lime.app.Application.current.onExit.add((_) ->
        {
            if (!FileSystem.exists('log'))
                FileSystem.createDirectory('log');
            Log.info('Log Written');
            File.saveContent('log/log.txt', history.join('\n'));
        });
    }

    @:keep static inline function ansi(color:Int):String
        return '\033[38;5;${color}m';

    @:keep static inline function __trace(value:Dynamic, ?pos:PosInfos):Void
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
        history.push('[${DateTools.format(Date.now(), '%H:%M:%S')} ${pos.fileName}:${pos.lineNumber}] $level: $value');
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