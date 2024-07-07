package meta.modding.chart_editor;

import flixel.addons.display.FlxGridOverlay;
import openfl.display.BitmapData;
import flixel.addons.display.FlxTiledSprite;
import flixel.group.FlxSpriteGroup;

// Inspired by Eternal Engine's ChartCheckerboard.hx
class ChartingArea extends FlxSpriteGroup {
    public var opponentField:FlxTiledSprite;
    public var playerField:FlxTiledSprite;
    public var eventField:FlxTiledSprite; // Brief view for the event objects.
    
    var wholefieldWidth:Float = (ChartEditor.grid_size * 8) + ChartEditor.separator_width;
    var playfieldWidth:Float = ChartEditor.grid_size * 4;
    var graphicSize:Int = ChartEditor.grid_size * 2;

    var gridColors = {
        color1: 0xFF2E2E2E,
        color2: 0xFF5F5F5F
    }
    
    public function new() {
        super();
    }
    var fieldSep:FlxSprite;
    public function init(){
        var grid_data:BitmapData = FlxGridOverlay.createGrid(ChartEditor.grid_size,ChartEditor.grid_size,graphicSize,graphicSize,true,gridColors.color1,gridColors.color2);
        var fieldBG:FlxSprite = new FlxSprite().makeGraphic(Std.int(wholefieldWidth), FlxG.height, FlxColor.BLACK);
        fieldBG.alpha = 0.7;
        fieldBG.scrollFactor.set();
        fieldBG.active = false;
        group.add(fieldBG);

        opponentField = new FlxTiledSprite(grid_data, playfieldWidth, 0);
        add(opponentField);

        playerField = new FlxTiledSprite(grid_data, playfieldWidth, 0);
        playerField.x = opponentField.width + ChartEditor.separator_width;
        add(playerField);

        //eventField = new FlxTiledSprite(grid_data, ChartEditor.grid_size, 0);
        //eventField.x = playerField.x + playerField.width + ChartEditor.separator_width;
        //add(eventField);

        //var eventWidth:Float = wholefieldWidth+ChartEditor.grid_size+ChartEditor.separator_width;
        for (i in [-ChartEditor.separator_width,opponentField.width,wholefieldWidth/*,eventWidth*/]){
            fieldSep = new FlxSprite(i);
            fieldSep.makeGraphic(ChartEditor.separator_width, FlxG.height,FlxColor.BLACK);
            fieldSep.scrollFactor.set();
            fieldSep.active = false;
            group.add(fieldSep);
        }
    }

    var op_tween:FlxTween;
    var pl_tween:FlxTween;
    public var target_isPlayer:Bool = false;
    public function changeTarget(player:Bool = false) {
        if (target_isPlayer == player) return;
        if (op_tween != null) op_tween.cancel();
        if (pl_tween != null) pl_tween.cancel();

        op_tween = FlxTween.tween(opponentField, {alpha: (player ? 0.5 : 1)}, 0.2, {onComplete:(_)->{
            op_tween = null;
        }});

        pl_tween = FlxTween.tween(playerField, {alpha: (!player ? 0.5 : 1)}, 0.2, {onComplete:(_)->{
            pl_tween = null;
        }});

        target_isPlayer = player;
    }

    override function set_height(value:Float):Float {
        if (playerField != null) playerField.height = opponentField.height = /*eventField.height =*/ value;
        return height = value;
    }

    override function get_height():Float {
        return height;
    }

    override function get_width():Float {
        if (playerField == null) return opponentField.width + ChartEditor.separator_width;
        if (opponentField == null) return playerField.width + ChartEditor.separator_width;
        return playerField.width + opponentField.width /*+ eventField.width*/ + (ChartEditor.separator_width/* *2 */);
    }
}