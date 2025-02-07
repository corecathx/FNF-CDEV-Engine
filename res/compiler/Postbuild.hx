package res.compiler;

import sys.io.File;
import haxe.Timer;

class Postbuild {
    static var filePath:String = "./res/compiler/compile.time";
    static var lastCompileTimePath:String = "./res/compiler/lastcompile.time";
    static function main() {
        var cmd:String = Sys.systemName() == "Windows" ? "cls" : "clear";
        // Get current timestamp
        Sys.command(cmd);

        var now = Timer.stamp();
        var data = Std.parseFloat(File.getContent(filePath));
        File.saveContent(lastCompileTimePath, '${now-data}');

        Sys.println("[CDEV] >> CDEV Engine successfully compiled!");
        Sys.println("[CDEV] >> Time elapsed: " + secondsToTime(now-data) + "s");
        Sys.println("=+=+=+=+=+=+=+=+=+ CDEV Engine Log +=+=+=+=+=+=+=+=+=");

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
