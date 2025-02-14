package;

import sys.io.File;
import haxe.Json;
import sys.FileSystem;

class ConvertChar {
    public static function main():Void {
        if (Sys.args().length < 2) 
            return trace("Two arguments required, legacyCharPath, rewriteCharPath.");

        var path:String = Sys.args()[0];
        trace("Loading from " + path);

        if (!FileSystem.exists(path) || FileSystem.isDirectory(path))
            return trace("Could not load from this path, path either a directory or does not exist.");
        var legacyFile:Dynamic = null;
        try{
            legacyFile = Json.parse(File.getContent(path));
        } catch(e) {
            return trace("An error occured while parsing json, " + e.message);
        }

        trace("Converting...");

        var rewriteFile = {
            animations: [],
            antialiasing: legacyFile.usingAntialiasing,
            position_offset: {
                x: legacyFile.charXYPosition[0],
                y: legacyFile.charXYPosition[1]
            },
            flip_x: legacyFile.flipX,
            bar_color: legacyFile.healthBarColor,
            camera_offset: legacyFile.camXYPos,
            hold_time: legacyFile.singHoldTime,
            char_scale: legacyFile.charScale
        };

        var a:Array<Dynamic> = legacyFile.animations;
        for (i in a) {
            rewriteFile.animations.push({
                loop: i.looping,
                offset: {
                    x: i.offset[0],
                    y: i.offset[1]
                },
                name: i.animPrefix, // In legacy, name and prefix fields are flipped.
                prefix: i.animName,
                fps: i.fpsValue,
                indices: i.indices
            });
        }

        trace("Converted everything smoothly (wee)");
        File.saveContent(Sys.args()[1], Json.stringify(rewriteFile, '\t'));
        trace("File saved to " + Sys.args()[1]);
    }
}