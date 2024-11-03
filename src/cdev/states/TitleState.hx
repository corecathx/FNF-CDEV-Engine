package cdev.states;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import cdev.objects.menus.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;

class TitleState extends State
{
    public static var haveSeenIntro:Bool = false;

    var logoBl:Sprite;
    var gfDance:Sprite;
    var titleText:Sprite;

    var screenOverlay:Sprite;
    var alphaGroup:FlxTypedSpriteGroup<Alphabet>;

    var introFinished:Bool = false;
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

        screenOverlay = new Sprite().makeGraphic(1,1,FlxColor.BLACK);
        screenOverlay.setGraphicSize(FlxG.width,FlxG.height);
        screenOverlay.updateHitbox();
        add(screenOverlay);

        alphaGroup = new FlxTypedSpriteGroup<Alphabet>();
        add(alphaGroup);

        Utils.playBGM("freakyMenu");
        Conductor.instance.updateBPM(102);
        FlxG.sound.music.fadeIn((Conductor.instance.beat_ms*4)/1000, 0, 0.7);
	}

    /**
     * Adds alphabet text to AlphaGroup.
     * @param texts Text you wanted to add, if empty, AlphaGroup will get emptied.
     */
    function appendAlphaText(?texts:Array<String>) {
        var alphaMembers:Array<Alphabet> = alphaGroup.members;
        var addY:Float = 60;
        if (texts != null && texts.length > 0) {
            var lastY:Float = alphaMembers.length > 0 ? alphaMembers[alphaMembers.length-1].y : 0;
            for (text in texts) {
                var obj:Alphabet = new Alphabet(0,lastY + addY,text,true);
                obj.screenCenter(X);
                alphaGroup.add(obj);

                lastY += addY;
            }

        } else {
            while (alphaMembers.length > 0) {
                var thisThing:Alphabet = alphaMembers[0];
                if (thisThing != null) 
                    thisThing.destroy();
                alphaMembers.remove(thisThing);
            }
        }
    }

	override function update(elapsed:Float)
	{
        if (FlxG.sound.music != null)
            Conductor.instance.time = FlxG.sound.music.time;

        if (!introFinished) {
            alphaGroup.y = FlxMath.lerp(FlxG.height - alphaGroup.height, alphaGroup.y, 1 - (elapsed * 12));
        }

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

        doIntroSequence(beats);
    }

    function doIntroSequence(beats:Int) {
        if (introFinished) return;
        switch (beats)
		{
			case 1:
				appendAlphaText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			case 3:
				appendAlphaText(['present']);
			case 4:
				appendAlphaText();
			case 5:
				appendAlphaText(['In association', 'with']);
			case 7:
				appendAlphaText(['newgrounds']);
				//ngSpr.visible = true;
			case 8:
				appendAlphaText();
				//ngSpr.visible = false;
			case 9:
				//appendAlphaText([curWacky[0]]);
                appendAlphaText(["Imagine youre seeing"]);
			case 11:
				//appendAlphaText(curWacky[1]);
                appendAlphaText(["Some random texts here"]);
			case 12:
				appendAlphaText();
			case 13:
				appendAlphaText(['Friday']);
			case 14:
				appendAlphaText(['Night']);
			case 15:
				appendAlphaText(['Funkin']); 
			case 16:
				finishIntro();
		}
    }

    function finishIntro() {
        if (introFinished) return;
        remove(screenOverlay);
        screenOverlay.destroy();

        remove(alphaGroup);
        alphaGroup.destroy();

        FlxG.camera.flash();
        introFinished = true;
    }
}
