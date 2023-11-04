package game.cdev;

//basically flx text.
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;

class VCRGrpText extends FlxSpriteGroup {
    public var theText:FlxText;
    public var targetY:Float = 0;
	public var isMenu:Bool = false;
    public var theXPos:Float = 0;

    public function new(x:Float, y:Float, text:String = '', size:Int, color:FlxColor, alignment:FlxTextAlign) {
        super();
        theText = new FlxText(x,y,FlxG.width,text,size);
        theText.setFormat('VCR OSD Mono', size,color,alignment,OUTLINE,FlxColor.BLACK);
        theText.borderSize = 2;
        add(theText);
    }

    override function update(elapsed:Float) { //hehe boi, Alphabet.hx update code.
        var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3); 
        if (isMenu)
            {    
                theText.y = FlxMath.lerp(theText.y, 200 + (scaledY * 30) + (FlxG.height * 0.1), CDevConfig.utils.bound(elapsed * 6, 0, 1));
                theText.x = FlxMath.lerp(theText.x, theXPos, CDevConfig.utils.bound(elapsed * 32, 0, 1));	
            }
        super.update(elapsed);
    }
}