package cdev.states;

import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;

class MainMenuState extends State {
    var options:Array<{name:String,callback:Void->Void}> = [
        {name: "storymode", callback:() -> trace("story")},
        {name: "freeplay", callback:() -> trace("free")},
        {name: "options", callback:() -> trace("options")},
        {name: "credits", callback:() -> trace("credits")},
    ];
    var currentSelection(default,set):Int = 0;

    var bg:Sprite;
    var optionGrp:SpriteGroup;

    var _camFollow:FlxObject;
    var _followPoint:{x:Float,y:Float,xAdd:Float, yAdd:Float} = {x:0.0,y:0.0,xAdd:0.0,yAdd:0.0};

    var _barHeight:Int = 80;
    override function create() {
        FlxG.sound.playMusic(Assets.music("funkinBeat"),0.7);

        // Background //
        bg = new Sprite(0,0,Assets.image("menus/menuBG"));
        bg.scrollFactor.set(0.1,0.1);
        bg.scale.set(1.2,1.2);
        bg.screenCenter();
        bg.color = Utils.engineColor.primary;
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
        var topBar:Sprite = new Sprite().makeGraphic(FlxG.width, _barHeight, 0xFF000000);
        topBar.scrollFactor.set();
        add(topBar);
        var bottomBar:Sprite = new Sprite(0,FlxG.height-_barHeight).makeGraphic(FlxG.width, _barHeight, 0xFF000000);
        bottomBar.scrollFactor.set();
        add(bottomBar);
        
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