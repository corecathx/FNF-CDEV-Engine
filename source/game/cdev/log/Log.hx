package game.cdev.log;

import haxe.PosInfos;

/**
 * Helper class for GameLog and TerminalLog
 * Basically handles logging on each class
 */
class Log {
    public static function error(data:Dynamic, ?posInfo:PosInfos){
        GameLog.error(data);
        TerminalLog.error(data, posInfo);
    }
    public static function warn(data:Dynamic, ?posInfo:PosInfos){

        GameLog.warn(data);
        TerminalLog.warn(data, posInfo);
    }
    public static function info(data:Dynamic, ?posInfo:PosInfos){
        GameLog.log(data);
        TerminalLog.info(data, posInfo);
    }
    public static function script(data:Dynamic, ?posInfo:PosInfos){
        GameLog.script(data);
        TerminalLog.script(data, posInfo);
    }
}