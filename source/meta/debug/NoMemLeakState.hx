package meta.debug;

import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import openfl.filesystem.FileStream;
import flixel.addons.util.PNGEncoder;
import haxe.io.Bytes;
import openfl.display.BitmapData;
import sys.io.File;

import cpp.vm.Gc;
import lime.utils.Preloader;

class NoMemLeakState extends MusicBeatState {
    var displayText:FlxText;
    var previewLogo:FlxSprite;
    override function create(){
        FlxG.sound.music.stop();
        Gc.run(true);
        previewLogo = new FlxSprite();
        previewLogo.setGraphicSize(Std.int(150));
        previewLogo.screenCenter();
        add(previewLogo);

        displayText = new FlxText(0,0,-1,"start dropping your png stuffs here.",14);
        displayText.font = FunkinFonts.CONSOLAS;
        displayText.color = 0xFFFFFFFF;
        add(displayText);


        FlxG.stage.application.window.onDropFile.add(processDropFile);
        super.create();
    }
    var time:Float = 3;
    var time2:Float = 3;
    override function update(elapsed:Float){
        super.update(elapsed);
        previewLogo.angle += (30 * elapsed);

        if (FlxG.keys.justPressed.ESCAPE){
            FlxG.stage.application.window.onDropFile.remove(processDropFile);
            FlxG.switchState(new meta.states.MainMenuState());
        }
    }
    
    var redrawSprite:Bool = true;
    function processDropFile(data:String) 
    {
        displayText.text = "file: " + data;
        previewLogo.graphic.bitmap = BitmapData.fromBytes(File.getBytes(data));
        previewLogo.pixels;
        previewLogo.scale.set(1,1);
        previewLogo.screenCenter();
        previewLogo.updateHitbox();
        trace("applied");
    }
}