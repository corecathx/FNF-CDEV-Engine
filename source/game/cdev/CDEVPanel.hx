package game.cdev;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
using StringTools;

class CDEVPanel extends FlxSpriteGroup
{
	public var itemCount:Int = 0;
	var isBold:Bool = false;
    var box:FlxSprite;
    var boxGap:Float;
    var txtCrap:FlxText;
    var origY:Float;
	public function new(xPos:Float, yPos:Float, text:String = "", daGap:Float = 0)
	{
		super(xPos, yPos);
        this.boxGap = daGap;

        this.origY = yPos;
        box = new FlxSprite(xPos,yPos).makeGraphic(Std.int((FlxG.width - boxGap) / itemCount), 66,FlxColor.BLACK);
        add(box);

        txtCrap = new FlxText(((box.x + box.width) / 2) / text.length , ((box.y + box.height) - 8),box.width,text,18);
        txtCrap.setFormat('VCR OSD Mono', 18,FlxColor.WHITE,CENTER,OUTLINE,FlxColor.BLACK);
        add(txtCrap);

        updateSpriteShit();
	}

    public function updateSpriteShit()
    {
        box.width = (FlxG.width - boxGap) / itemCount;
        txtCrap.x = ((box.x + box.width) / 2) / txtCrap.text.length;
        txtCrap.y = ((box.y + box.height) - 8);
        txtCrap.fieldWidth = box.width;
    }

    var lerpPos:Float = 0;
	override function update(elapsed:Float)
	{
        if (FlxG.mouse.overlaps(this)){
            alpha = 1;
            lerpPos = origY;
        } else{
            lerpPos = FlxG.height;
            alpha = 0.7;
        }

        y = FlxMath.lerp(lerpPos,y, CDevConfig.utils.bound(elapsed * 7, 0, 1));

		super.update(elapsed);
	}
}