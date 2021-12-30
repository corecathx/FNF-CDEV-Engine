package;

import flixel.math.FlxMath;
import flixel.FlxG;
import Controls.KeyboardScheme;
import openfl.Lib;
using StringTools;

class CoreDevSaves extends MusicBeatState
{
    public static function createSaves()
        {
            if (FlxG.save.data.dfjk == null)
                FlxG.save.data.dfjk = false;

            if (FlxG.save.data.downscroll == null)
                FlxG.save.data.downscroll = false;

			if (FlxG.save.data.songtime == null)
                FlxG.save.data.songtime = true;
				
            if (FlxG.save.data.flashing == null)
                FlxG.save.data.flashing = true;

			if (FlxG.save.data.camZoom == null)
                FlxG.save.data.camZoom = true;

			if (FlxG.save.data.camMovement == null)
                FlxG.save.data.camMovement = true;

            if (FlxG.save.data.fpplay == null)
                FlxG.save.data.fpplay = true;

            if (FlxG.save.data.fullinfo == null)
                FlxG.save.data.fullinfo = true;

            if (FlxG.save.data.frames == null)
                FlxG.save.data.frames = 10;

            if (FlxG.save.data.offset == null)
                FlxG.save.data.offset = 0;

            if (FlxG.save.data.ghost == null)
                FlxG.save.data.ghost = false;

            if (FlxG.save.data.fpscap == null)
                FlxG.save.data.fpscap = 120;

            if (FlxG.save.data.botplay == null)
                FlxG.save.data.botplay = false;

            if (FlxG.save.data.noteRipple == null)
                FlxG.save.data.noteRipple = true;

            if (FlxG.save.data.autoPause == null)
                FlxG.save.data.autoPause = false;

            //the keybinds
            if (FlxG.save.data.leftBind == null)
                FlxG.save.data.leftBind = 'A';

            if (FlxG.save.data.downBind == null)
                FlxG.save.data.downBind = 'S';

            if (FlxG.save.data.upBind == null)
                FlxG.save.data.upBind = 'W';

            if (FlxG.save.data.rightBind == null)
                FlxG.save.data.rightBind = 'D';

            //more flxgsave
            if (FlxG.save.data.performTxt == null)
                FlxG.save.data.performTxt = true;

            if (FlxG.save.data.smoothAF == null)
                FlxG.save.data.smoothAF = true;

            if (FlxG.save.data.middlescroll == null)
                FlxG.save.data.middlescroll = false;

            if (FlxG.save.data.antialiasing == null)
                FlxG.save.data.antialiasing = true;
            
            FlxG.autoPause = FlxG.save.data.autoPause;
            setFPS(FlxG.save.data.fpscap);
        }

    public static function setFPS(daSet:Int)
        {
            openfl.Lib.current.stage.frameRate = daSet;
        }
    public static function reInitLerp()
        {
            GlobalVars.lerpValue = Math.max(0.02 * (1000 / FlxG.save.data.fpscap), 0.98);
        }
    public static function resetSaves() {
        FlxG.save.data.dfjk = false;
        FlxG.save.data.downscroll = false;
        FlxG.save.data.fpscap = 120;
        FlxG.save.data.songtime = true;
        FlxG.save.data.flashing = true;
        FlxG.save.data.camZoom = true;
        FlxG.save.data.camMovement = true;
        FlxG.save.data.fpplay = true;
        FlxG.save.data.fullinfo = true;
        FlxG.save.data.offset = 0;
        FlxG.save.data.frames = 10;
        FlxG.save.data.ghost = false;
    }
}