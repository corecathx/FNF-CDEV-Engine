package game.objects;

import game.cdev.log.GameLog;
import meta.states.PlayState;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;

class RatingSprite extends FlxSprite {
	var spriteGraphics:RSprites; // class for rating graphics
	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);
        spriteGraphics = new RSprites();

		antialiasing = CDevConfig.saveData.antialiasing;
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null && animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}

	public function popUp(name:String)
	{
        
	}
}

class RSprites {
	var sprites:Map<String, FlxGraphic>;
    public function new(){
        sprites = new Map<String, FlxGraphic>();

        var pixel1:String = "";
		var pixel2:String = '';
		var lib:String = 'shared';

		if (PlayState.isPixel)
		{
			pixel1 = 'weeb/pixelUI/';
			pixel2 = '-pixel';
			lib = 'week6';
		}

        for (name in ["sick", "good", "bad" , "shit",
                      "num0", "num1", "num2", "num3",
                      "num4", "num5", "num6", "num7",
                      "num8", "num9"]){
            var filename:String = pixel1 + name + pixel2;
            trace("Loading Rating: \"" + filename + "\" in library: \n" + lib + "\".");

            sprites[name] = Paths.image(filename, lib);
        }
            
    }

    public function getGraphic(name:String):FlxGraphic {
        if (sprites.exists(name)){
            return sprites[name];
        }
        GameLog.warn("No rating asset found for \"" + name + "\n.");
        return sprites["shit"];
    }
}