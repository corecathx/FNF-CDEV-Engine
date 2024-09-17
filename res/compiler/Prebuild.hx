package res.compiler;

import sys.io.File;
import haxe.Timer;

class Prebuild {
    static var filePath:String = "./res/compiler/compile.time";
    static function main() {
        var cmd:String = Sys.systemName() == "Windows" ? "cls" : "clear";
        // Get current timestamp
        Sys.command(cmd);
        Sys.println("[CDEV] >> Compiling CDEV Engine now...");
        var now = Timer.stamp();
        File.saveContent(filePath,Std.string(now));
        Sys.println("=+=+=+=+=+=+=+=+=+ Compiler Log +=+=+=+=+=+=+=+=+=");
    }
}
