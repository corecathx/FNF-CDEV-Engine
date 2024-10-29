package cdev.states;

import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;

class MainMenuState extends State {
    var options:Array<{name:String,callback:Void->Void}> = [
        {name: "storymode", callback:() -> FlxG.switchState(new PlayState())},
        {name: "freeplay", callback:() -> trace("free")},
        {name: "options", callback:() -> trace("options")},
        {name: "credits", callback:() -> trace("credits")},
    ];
    var currentSelection(default,set):Int = 0;

    var bg:Sprite;
    var optionGrp:SpriteGroup;
    var infoText:Text;
    var versionText:Text;

    var _camFollow:FlxObject;
    var _followPoint:{x:Float,y:Float,xAdd:Float, yAdd:Float} = {x:0.0,y:0.0,xAdd:0.0,yAdd:0.0};

    var _barHeight:Int = 80;
    override function create() {
        Utils.playBGM();

        // Background //
        bg = new Sprite(0,0,Assets.image("menus/menuBG"));
        bg.scrollFactor.set(0.1,0.1);
        bg.scale.set(1.15,1.15);
        bg.screenCenter();
        add(bg);

        // Options //
        optionGrp = new SpriteGroup(0,60);
        optionGrp.scrollFactor.set(0.3,0.3);
        add(optionGrp);

        var lastY:Float = 20;
        for (index => option in options) {
            var spr:Sprite = new Sprite(0,lastY);
            spr.ID = index;
            spr.frames = Assets.sparrowAtlas("menus/main/"+option.name);
            for (anim in ["idle","selected"])
                spr.addAnim(anim, '${option.name} $anim',24);
            spr.playAnim("idle",true);
            spr.scale.set(0.8,0.8);
            spr.updateHitbox();
            spr.screenCenter(X);
            optionGrp.add(spr);
            lastY += spr.height + 50;
        }

        // Top and Bottom Bars //
        /*var topBar:Sprite = new Sprite().makeGraphic(FlxG.width, _barHeight, 0xFF000000);
        topBar.scrollFactor.set();
        add(topBar);
        var bottomBar:Sprite = cast new Sprite(0,FlxG.height-_barHeight).loadGraphic(topBar.graphic);
        bottomBar.scrollFactor.set();
        add(bottomBar);*/

        // Texts //
        infoText = new Text(0,25,"[Info should be here.]",RIGHT);
        infoText.scrollFactor.set();
        add(infoText);

        versionText = new Text(20,25,Engine.label,LEFT);
        versionText.y = FlxG.height - (versionText.height + 20);
        versionText.scrollFactor.set();
        add(versionText);
        
        // Camera Related Stuffs //
        _followPoint.x = FlxG.width*0.5; _followPoint.y = 20;
        _camFollow = new FlxObject(_followPoint.x,_followPoint.y,1,1);
        _camFollow.scrollFactor.set(0.5,0.5);
        add(_camFollow);

        FlxG.camera.follow(_camFollow);

        // Others //
        currentSelection = 0;
        super.create();
    }

    override function update(elapsed:Float) {
        _updateCamera(elapsed);
        _updateControls();
        _updateObjects();
        super.update(elapsed);
    }

    function _updateCamera(elapsed:Float) {
        _followPoint.xAdd = Math.sin(Game._ACTIVE_TIME)*25;
        _followPoint.yAdd = Math.sin(Game._ACTIVE_TIME/2)*40;
        _camFollow.x = FlxMath.lerp(_followPoint.x + _followPoint.xAdd, _camFollow.x, 1-(elapsed*6));
        _camFollow.y = FlxMath.lerp(_followPoint.y + _followPoint.yAdd, _camFollow.y, 1-(elapsed*6));
    }

    function _updateControls() {
        if (Controls.UI_UP_P) currentSelection -= 1;
        if (Controls.UI_DOWN_P) currentSelection += 1;
        if (Controls.ACCEPT) {
            FlxG.sound.music.stop();
            options[currentSelection].callback();
        }
    }

    // don't mind this.
    var __inf_text_large_format:FlxTextFormat = new FlxTextFormat(Utils.engineColor.primary);
    function _updateObjects() {
        // Info text // 
        var _now:Date = Date.now();
        var _localTime:String = '${StringTools.lpad(_now.getHours()+'','0',2)}:${StringTools.lpad(_now.getMinutes()+'','0',2)}';

        var __infTxt:String = ""
        + 'CDEV Engine has been running for #${Utils.getTimeFormat(Game._ACTIVE_TIME*1000)}#\n'
        + 'It is currently #${_localTime}#';

        infoText.applyMarkup(__infTxt,[
            new FlxTextFormatMarkerPair(__inf_text_large_format, "#")
        ]);
        infoText.x = (FlxG.width - infoText.width) - 20;
    }

    function set_currentSelection(val:Int):Int {
        val = FlxMath.wrap(val,0,options.length-1);
        FlxG.sound.play(Assets.sound("scrollMenu"),0.7);
        
        optionGrp.forEachAlive((opt:Sprite)->{
            opt.alpha = opt.ID == val ? 1 : 0.7;
            opt.playAnim(opt.ID == val ? "selected" : "idle", true);
            opt.updateHitbox();
            opt.screenCenter(X);
            if (opt.ID == val) {
                _followPoint.y = opt.getGraphicMidpoint().y;
            }
        });
        return currentSelection = val;
    }
}