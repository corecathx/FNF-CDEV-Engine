package meta.substates;

import game.cdev.CDevPopUp;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import game.cdev.log.GameLog;
import flixel.FlxG;

using StringTools;

/**
 * Helper Substate for drag and dropping files
 */
class DropFileSubstate extends MusicBeatSubstate {
    var state:Dynamic;
    var variable:String;
    var wantedFileType:String;
    var exitte:Void -> Void = function () {};
    var noData:Void -> Void = function () {};
    var success:Bool = false;
    public function new(mainState:Dynamic, variable:String, dataType:String, onExit:Void -> Void, ?onNoData:Void -> Void = null){
        super();
        this.state = mainState;
        this.variable = variable;
        wantedFileType = dataType;
        exitte = onExit;
        if (onNoData != null) noData = onNoData;
        FlxG.stage.window.onDropFile.add(onDroppedFile);

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        bg.alpha = 0.1;
        add(bg);

        var text:FlxText = new FlxText(0, 0, -1, 'DROP .$dataType FILE TO THIS WINDOW.', 24);
		text.setFormat("VCR OSD Mono", 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter();
		add(text);
		text.borderSize = 4;
        text.borderQuality = 5;
    }

    override function update(elapsed:Float){
        super.update(elapsed);

        if (controls.BACK){
            close();
        }
    }

    function onDroppedFile(data:String){
        if (!data.endsWith(wantedFileType)){
            openSubState(new CDevPopUp("Error", "Please drop a ."+wantedFileType+" file.", [{text:"OK", callback: function(){closeSubState();}}]));
            return;
        }
        
        try {
            Reflect.setProperty(state,variable,data);
            trace("Got data: " + Reflect.getProperty(state,variable));
            FlxG.sound.play(Paths.sound("confirmMenu"), 0.5);
            success = true;
            close();
        } catch (e){
            success = false;
            close();
            gError("Failed to set field from state, " + e.toString());
        }
    }

    function gError(stuff:String){
        GameLog.error("Drop File Error: " + stuff);
    }

    override function close() {
        FlxG.stage.window.onDropFile.remove(onDroppedFile);
        if (success) 
            exitte(); 
        else 
            noData();
        super.close();
    }
}