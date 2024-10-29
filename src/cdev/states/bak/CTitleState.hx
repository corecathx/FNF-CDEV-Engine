package cdev.states.bak;

import cdev.objects.Visualizer;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxGridOverlay;
import openfl.display.BitmapData;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;

class CTitleState extends State
{
    var bg:Sprite;
    var philly:Sprite;
    var topText:FlxBackdrop;
    var bottomText:FlxBackdrop;
    var checker:FlxBackdrop;
    var logoBl:Sprite;
    var visualizer:Visualizer;
    var barHeight:Int = 80;
	override public function create()
	{
		super.create();
        FlxG.sound.music = null;
        bg = new Sprite().loadGraphic(FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [FlxColor.BLACK, Utils.engineColor.primary], 1, 90, true));
		bg.setScale(1.7, true);
		bg.alpha = 0.4;
		add(bg);

        checker = new FlxBackdrop(Assets.image("menus/checker"), XY);
		checker.scale.set(1.2, 1.2);
		checker.color = Utils.engineColor.primary;
		checker.blend = LAYER;
		add(checker);
		checker.scrollFactor.set(0, 0.07);
		checker.alpha = 0.3;
		checker.updateHitbox();

        visualizer = new Visualizer(0,0,200,4, FlxG.width,FlxG.height * 0.7,null);
		visualizer.y = (FlxG.height - visualizer.height) * 0.5;
        visualizer.color = Utils.engineColor.primary;
		add(visualizer);

        logoBl = new Sprite(-30, 50);
		logoBl.frames = Assets.sparrowAtlas('menus/title/cdev/logoBumpin');
        logoBl.addAnim('bump', 'logo bumpin', 24, false);
        logoBl.playAnim("bump", true);
        logoBl.setScale(0.7);
        logoBl.screenCenter();
        add(logoBl);

        /*philly = new Sprite();
        philly.frames = Assets.sparrowAtlas("menus/title/cdev/funkinBg");
        philly.addAnim("idle", "idle", 24);
        philly.playAnim("idle", true);
        philly.alpha = 0.4;
        philly.blend = openfl.display.BlendMode.MULTIPLY;
        //philly.color = Utils.engineColor.primary;
        philly.setScale(4);
        philly.screenCenter();
        add(philly);*/

        // Top and Bottom Bars //
        var topBar:Sprite = new Sprite().makeGraphic(FlxG.width, barHeight, 0xFF000000);
        topBar.scrollFactor.set();
        topBar.active = false;
        add(topBar);
        var bottomBar:Sprite = cast new Sprite(0,FlxG.height-barHeight).loadGraphic(topBar.graphic);
        bottomBar.scrollFactor.set();
        bottomBar.active = false;
        add(bottomBar);

        topText = new FlxBackdrop(Assets.image("menus/title/cdev/titleEnter"), X);
        topText.scale.set(0.8,0.8);
        topText.y = topBar.y + (topBar.height - topText.height) * 0.5;
		add(topText);

        bottomText = new FlxBackdrop(Assets.image("menus/title/cdev/titleEnter"), X);
        bottomText.scale.set(0.8,0.8);
        bottomText.y = bottomBar.y + (bottomBar.height - bottomText.height) * 0.5;
		add(bottomText);

        Utils.playBGM("funkinBeat");
        Conductor.instance.updateBPM(91.5);
        FlxG.sound.music.fadeIn((Conductor.instance.beat_ms*4)/1000, 0, 0.7);
        
        visualizer.source = FlxG.sound.music;
	}

    var _checkerX:Float = 0;
    var _checkerY:Float = 0;
	override function update(elapsed:Float)
	{
        if (FlxG.sound.music != null)
            Conductor.instance.time = FlxG.sound.music.time;

        checker.x = FlxMath.lerp(_checkerX, checker.x, 1-(elapsed*3.5));
        checker.y = FlxMath.lerp(_checkerY, checker.y, 1-(elapsed*3.5));

        topText.x = checker.x * 2;
        bottomText.x = -(checker.x * 2);
        
        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 1 - (elapsed * 7));
        bg.alpha = FlxMath.lerp(0.2, bg.alpha, 1 - (elapsed * 7));
        topText.color = bottomText.color = FlxColor.interpolate(0xFF000852, 0xFF00A2FF, Math.abs(Math.sin(2 * Math.PI * (Conductor.instance.time / (Conductor.instance.beat_ms*4)))));
		if (FlxG.keys.justPressed.ENTER) {
            FlxG.camera.flash();
            FlxG.sound.play(Assets.sound("confirmMenu"));
            FlxTimer.wait(2, ()->{
                FlxG.switchState(new MainMenuState());
            });
        }
        super.update(elapsed);
	}

    override function beatHit(beats:Int) {
        logoBl.playAnim("bump",true);

        FlxG.camera.zoom += 0.04;
        _checkerX -= 70;
        _checkerY -= 42;
        bg.alpha += 0.2;
    }
}
