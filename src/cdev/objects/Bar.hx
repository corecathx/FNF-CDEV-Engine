package cdev.objects;

import flixel.math.FlxRect;
import flixel.util.FlxColor;

/**
 * Bar object.
 */
class Bar extends Sprite {
    public var percent(default,set):Float = 0;
    function set_percent(val:Float):Float {
        var _dirty:Bool = val != percent;
		percent = val;

		if (_dirty) updateBar();
		return val;
    }
    public var bounds:{min:Float,max:Float};
    public var getValue:Void->Float;
    public var leftBar:Sprite;
    public var rightBar:Sprite;
    /**
     * Whether to draw the bar graphic (example: healthBar.png) after drawing the progress bars.
     */
    public var drawGraphicAboveBars:Bool = true;

    public var leftToRight:Bool = true;

    public var progressCenter:Float = 0;

    public function new(nX:Float,nY:Float,nGraphic:FlxGraphic,valueFunc:Void->Float,min:Float=0,max:Float=1) {
        super(nX,nY);
        getValue = valueFunc;
        bounds = {min:min,max:max};
        loadGraphic(nGraphic);
        
		leftBar = new Sprite().makeGraphic(Std.int(width), Std.int(height), FlxColor.WHITE);
		rightBar = new Sprite().loadGraphic(leftBar.graphic);
    }

    override function draw() {
        inline function __drawBars(){
            for (bar in [leftBar,rightBar]) {
                if (bar == null) continue;
                bar.cameras = this.cameras;
                bar.visible = this.visible;
                bar.alpha = this.alpha;
                bar.draw();
            }   
        }
        if (drawGraphicAboveBars) {
            __drawBars();
            super.draw();
        } else {
            super.draw();  
            __drawBars();  
        }
    }

	override function update(elapsed:Float)
	{
		if (getValue != null)
			percent = getValue()*100;
        
        updateBar();
		super.update(elapsed);
	}

    public function setColors(?left:FlxColor, ?right:FlxColor) {
        if (left != null) leftBar.color = left;
        if (right != null) rightBar.color = right;
    }

    public function updateBar() {
        if (leftBar == null || rightBar == null) return;

        regenClip();

		leftBar.setPosition(x, y);
		rightBar.setPosition(x, y);

        var progress:Float = FlxMath.bound((leftToRight ? percent : 100-percent)/100, bounds.min, bounds.max);
        leftBar.clipRect.width = width * progress;
        rightBar.clipRect.width = width - leftBar.clipRect.width;

		leftBar.clipRect.height = rightBar.clipRect.height = height;

        rightBar.clipRect.x = leftBar.clipRect.width;
        
        leftBar.clipRect = leftBar.clipRect;
		rightBar.clipRect = rightBar.clipRect;
        
        progressCenter = x + leftBar.clipRect.width;
    }

    public function regenClip() {
        if (leftBar != null) {
            leftBar.setGraphicSize(Std.int(width), Std.int(height));
            leftBar.updateHitbox();
            leftBar.clipRect = new FlxRect(0, 0, Std.int(width), Std.int(height));
        }
        if (rightBar != null) {
            rightBar.setGraphicSize(Std.int(width), Std.int(height));
            rightBar.updateHitbox();
            rightBar.clipRect = new FlxRect(0, 0, Std.int(width), Std.int(height));
        }
    }
}