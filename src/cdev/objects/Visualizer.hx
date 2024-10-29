package cdev.objects;

import flixel.util.FlxColor;
import cdev.backend.audio.AudioUtils;
import haxe.Timer;
import flixel.FlxBasic;
import flixel.graphics.FlxGraphic;

class Visualizer extends FlxBasic {
    public var x:Float = 0;
    public var y:Float = 0;
    public var width:Float = 0;
    public var height:Float = 0;
    public var count:Int = 0;
    public var gap:Float = 0;
    public var bars:Array<Sprite> = [];
    public var amplitude:Array<Float> = [];
    public var source:FlxSound;
    public var maxTimeCount:Float;
    public var color:FlxColor = 0xFFFFFFFF;

    public function new(nX:Float, nY:Float, barCount:Int, gap:Float, nWidth:Float, nHeight:Float, source:FlxSound, maxTimeCount:Float = 1.0) {
        super();
        x = nX;
        y = nY;
        width = nWidth;
        height = nHeight;
        count = barCount;
        this.gap = gap;
        this.source = source;
        this.maxTimeCount = maxTimeCount;
        regenBars();
    }

    public function regenBars() {
        destroyAllBars();
        var graphic:FlxGraphic = null;
    
        var totalGaps:Float = gap * (count - 1);
        var barWidth:Float = width / count;
    
        var curX:Float = x;
        for (i in 0...count) {
            var bar:Sprite = new Sprite();
            if (graphic != null) {
                bar.loadGraphic(graphic);
            } else {
                bar.makeGraphic(1, 1, 0xFFFFFFFF);
                graphic = bar.graphic;
            }
    
            bar.setGraphicSize(barWidth, 1);
            bar.x = curX;
            bar.y = y + height;
    
            curX += barWidth + gap;
    
            bar.active = false;
            bars.push(bar);
        }
    }
    

    override public function update(elapsed:Float) {
        super.update(elapsed);

        amplitude.push(AudioUtils.getPeakAmplitude(source));
    
        if (amplitude.length > count)
            amplitude.shift();
    }

    override public function draw() {
        var curX:Float = x + width;
    
        for (i in 0...count) {
            var bar:Sprite = bars[i];
            if (bar != null && amplitude.length > i) {
                var delayedAmp:Float = amplitude[i];
                var barHeight:Float = delayedAmp * height;
    
                var barWidth:Float = (width - (gap * (count - 1))) / count;
                bar.setGraphicSize(barWidth, barHeight);
    
                curX -= barWidth; 
                bar.x = curX;
                bar.y = y + (height - barHeight) * 0.5;
    
                curX -= gap;
    
                bar.updateHitbox();
                bar.color = color;
            }
        }
    
        for (bar in bars) {
            if (bar != null)
                bar.draw();
        }
    }

    function destroyAllBars() {
        for (bar in bars) {
            if (bar != null) {
                bar.kill();
                bar.destroy();
            }
        }
        bars = [];
    }
}
