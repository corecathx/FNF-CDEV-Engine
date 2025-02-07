package res.compiler;

import sys.io.File;
import haxe.Timer;

class Prebuild {
    static var filePath:String = "./res/compiler/compile.time";
    static var lastCompileTimePath:String = "./res/compiler/lastcompile.time";
    static function main() {
        var cmd:String = Sys.systemName() == "Windows" ? "cls" : "clear";
        // Get current timestamp
        Sys.command(cmd);
        Sys.println("[CDEV] >> Compiling CDEV Engine now...");
        var now = Timer.stamp();
        File.saveContent(filePath,Std.string(now));
        if (sys.FileSystem.exists(lastCompileTimePath)) {
            var w:Float = Std.parseFloat(File.getContent(lastCompileTimePath));
            Sys.println("[CDEV] >> Last compile time: " + secondsToTime(w));
        } else {
            Sys.println("[CDEV] >> Could not find last compile time.");
        }
        Sys.println("=+=+=+=+=+=+=+=+=+ Compiler Log +=+=+=+=+=+=+=+=+=");
    }

    static function secondsToTime(seconds:Float):String {
        var hours = Math.floor(seconds / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);
        var secs = Std.int(seconds % 60);

        var formattedHours = StringTools.lpad(Std.string(hours), '0', 2);
        var formattedMinutes = StringTools.lpad(Std.string(minutes), '0', 2);
        var formattedSeconds = StringTools.lpad(Std.string(secs), '0', 2);

        return '${formattedHours}:${formattedMinutes}:${formattedSeconds}';
    }
}
