package game.objects;

import flixel.sound.FlxSound;
import lime.media.AudioSource;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import funkin.vis.dsp.SpectralAnalyzer;
import flixel.graphics.frames.FlxAtlasFrames;

using Lambda;

class VisualizerSprite extends FlxSpriteGroup
{
    var analyzer:SpectralAnalyzer;
    var wawaHeight:Int = 0;
    var wawaWidth:Int = 0;
    /**
     * Creates a new visualizer.
     * @param audioSource 
     */
    public function new(nX:Float, nY:Float, nWidth:Int, nHeight:Int, bands:Int, audioSource:FlxSound)
    {
        super(nX, nY);
        wawaHeight=nHeight;
        wawaWidth=nWidth;

        var barWidth:Int = Math.floor(nWidth / bands);
        var space:Float = Math.max(8, (nWidth - (barWidth * bands)) / (bands - 1));
    
        for (i in 0...bands)
        {
            var viz:FlxSprite = new FlxSprite((barWidth+space)*i, 0).makeGraphic(barWidth, nHeight);
            viz.scale.y = 0;
            add(viz);
        }
    
        @:privateAccess
        analyzer = new SpectralAnalyzer(audioSource._channel.__audioSource, bands, 0.04, 0);
    }
        
    var levels:Array<Bar> = [];
    override function update(wawa:Float)
    {
        levels = analyzer.getLevels(levels);

        var grp = members.length;
        var lvls = levels.length;
        for (i in 0...(grp > lvls ? lvls : grp))
        {
            members[i].scale.y = levels[i].value;
            members[i].updateHitbox();
            members[i].y = wawaHeight+(wawaHeight-(wawaHeight*levels[i].value));
        }
        updateHitbox();
        super.update(wawa);
    }

    override function get_height():Float {
        return wawaHeight;
    }

    override function get_width():Float {
        return wawaWidth;
    }
}
