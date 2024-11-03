package cdev.states;

import flixel.util.FlxTimer;

class TitleState extends State
{
    var logoBl:Sprite;
    var gfDance:Sprite;
    var titleText:Sprite;

	override public function create()
	{
		super.create();
        gfDance = new Sprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Assets.sparrowAtlas('menus/title/gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		add(gfDance);

        logoBl = new Sprite(-150, -100);
		logoBl.frames = Assets.sparrowAtlas('menus/title/logoBumpin');
        logoBl.addAnim('bump', "logo bumpin", 24, false);
        logoBl.playAnim('bump');
        add(logoBl);

        titleText = new Sprite(100, FlxG.height * 0.8);
		titleText.frames = Assets.sparrowAtlas('menus/title/titleEnter');
        titleText.addAnim('idle', "Press Enter to Begin", 24);
        titleText.addAnim('press', "ENTER PRESSED", 24);
        titleText.playAnim('idle');
		add(titleText);

        Utils.playBGM("freakyMenu");
        Conductor.instance.updateBPM(102);
        FlxG.sound.music.fadeIn((Conductor.instance.beat_ms*4)/1000, 0, 0.7);
	}

	override function update(elapsed:Float)
	{
        if (FlxG.sound.music != null)
            Conductor.instance.time = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.ENTER) {
            titleText.playAnim('press');
            FlxG.camera.flash();
            FlxG.sound.play(Assets.sound("confirmMenu"));
            FlxTimer.wait(2, ()->{
                FlxG.switchState(new MainMenuState());
            });
        }

        if (FlxG.keys.justPressed.C) {
            FlxG.sound.music.stop();
            FlxG.switchState(new cdev.states.bak.CTitleState());
        }
        super.update(elapsed);
	}

    var danceLeft:Bool = false;
    inline function _gf_dance() {
        gfDance.playAnim("dance" + (danceLeft ? "Left" : "Right"), true);
        danceLeft = !danceLeft;
    }
    override function beatHit(beats:Int) {
        logoBl.playAnim("bump",true);
        _gf_dance();
    }
}
