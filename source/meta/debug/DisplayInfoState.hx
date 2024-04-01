package meta.debug;

import game.system.FunkinFonts;
import game.cdev.engineutils.CDevFPSMem;
import lime.app.Application;

using StringTools;

class DisplayInfoState extends MusicBeatState {
    var displayText:FlxText;
    var previewLogo:FlxSprite;
    override function create(){
        FlxG.sound.playMusic(Paths.music('updateSong', "shared"), 0);
        FlxG.sound.music.fadeIn(4, 0, 0.7);
        previewLogo = new FlxSprite().loadGraphic(Paths.image("icon16", "shared"));
        previewLogo.setGraphicSize(Std.int(150));
        previewLogo.screenCenter();
        add(previewLogo);

        displayText = new FlxText(0,0,-1,"",14);
        displayText.font = FunkinFonts.CONSOLAS;
        displayText.color = 0xFFFFFFFF;
        add(displayText);

        super.create();
    }
    var time:Float = 3;
    var time2:Float = 3;
    override function update(elapsed:Float){
        super.update(elapsed);
        previewLogo.angle += (30 * elapsed);
        time+=elapsed;
        time2+=elapsed;
        displayText.text = "// Display Information //"
            + '\n[ Lime ] Native Refresh Rate (In Hz)       : ${Application.current.window.displayMode.refreshRate} Hz'
            + '\n[ Lime ] Window Resolution                 : ${Application.current.window.displayMode.width + "x" + Application.current.window.displayMode.height}'
            + '\n[ Lime ] Application Window Framerate      : ${Application.current.window.frameRate} FPS'
            + '\n[ CDEV ] CDEV Engine FPS Counter Data      : ${CDevFPSMem.current.times.length} FPS'
            + '\n[ CDEV ] Framerate Cap (Settings)          : ${CDevConfig.saveData.fpscap} FPS'
            + '\n[  HF  ] Flixel Framerate (Update | Draw)  : ${FlxG.updateFramerate} FPS | ${FlxG.drawFramerate} FPS'
            + '\n[  HF  ] Game Resolution                   : ${FlxG.width + "x" + FlxG.height}'
            + '\nWhat to see here: Check if there\'s any weird values.'
            + '\n\n[  IM  ] Sprite Angle : ${FlxMath.roundDecimal(previewLogo.angle % 360,2)} | ${(30 * elapsed)}'
            + '\n\nPress SPACE to update Flixel Framerate. ${time < 1 ? "(Updated!)" : ""}'
            + '\nPress CTRL to match every data to current refresh rate. ${time2 < 1 ? "(Updated!)" : ""}';
        displayText.setPosition(20,FlxG.height-displayText.height-20);

        if (FlxG.keys.justPressed.SPACE){
            FlxG.drawFramerate = FlxG.updateFramerate = CDevConfig.saveData.fpscap;
            time = 0;
        }

        if (FlxG.keys.justPressed.CONTROL){
            FlxG.drawFramerate = FlxG.updateFramerate = Application.current.window.displayMode.refreshRate;
            Application.current.window.frameRate = Application.current.window.displayMode.refreshRate;
            CDevConfig.saveData.fpscap = Application.current.window.displayMode.refreshRate;
            time2 = 0;
        }

        if (FlxG.keys.justPressed.ESCAPE){
            FlxG.switchState(new meta.states.MainMenuState());
        }
    }
}