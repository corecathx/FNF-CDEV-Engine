package cdev.states;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;

class EngineInfoState extends State {
    var tween:FlxTween;
    override function create() {
        super.create();
        var bigTxt:Text = new Text(0,280,"Hey there!",CENTER,29);
        bigTxt.screenCenter(X);
        add(bigTxt);

        var info:String = "" // # = big, & = cdev blue, - = warn
        + "You're currently playing the rewritten version &CDEV Engine&.\n"
        + "As of now, it's still on development stage, so expect noticable\n"
        + "-bugs-, -errors-, or -glitches-. Though if you notice any of it, please\n"
        + "report it to the engine's &repository&!\n\n"
        + "Press any key to start.";
        var txt:Text = new Text(0,bigTxt.y + bigTxt.height + 10,"",CENTER, 19);
        txt.applyMarkup(info,[
            new FlxTextFormatMarkerPair(new FlxTextFormat(Utils.engineColor.primary),"&"),
            new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF2600),"-"),
        ]);
        txt.screenCenter(X);
        add(txt);

        camTween(0.6, 1, 6, FlxEase.expoOut);
    }

    var pressed:Bool = false;
    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.TAB) {
            FlxG.switchState(new DebugState());
        } else if (FlxG.keys.justPressed.ANY && !pressed) {
            pressed = true;
            FlxG.camera.flash();
            FlxG.sound.play(Assets.sound("confirmMenu"));
            
            FlxTimer.wait(2, ()->{
                camTween(null, 0, 4, FlxEase.backInOut);
                FlxG.switchState(new TitleState());
            });
        }
        super.update(elapsed);
    }

    function camTween(?from:Float, zoom:Float, time:Float, ease:EaseFunction) {
        if (tween != null)
            tween.cancel();
        if (from != null)
            FlxG.camera.zoom = from;
        tween = FlxTween.tween(FlxG.camera, {zoom: zoom}, time, {ease: ease, onComplete:(_)->{
            tween = null;
        }});
    }
}