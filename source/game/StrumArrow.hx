package game;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumArrow extends FlxSprite
{
	public var isPixel:Bool = false;
	//public var downscroll:Bool = false;
	public var noteScroll:Float = 1;
	public function new(xx:Float, yy:Float)
	{
		x = xx;
		y = yy;
		super(x, y);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (CDevConfig.saveData.testMode){
			if (FlxG.keys.pressed.THREE){
				angle += 3;
			}
	
			if (FlxG.keys.pressed.TWO){
				angle -= 3;
			}
		}


		/*if (animation.curAnim.name == 'confirm' && !isPixel)
			{
				centerOffsets();

				if (CDevConfig.saveData.fnfNotes)
				{
					offset.x -= 13;
					offset.y -= 13;
				}
				else
				{
					offset.x -= 30;
					offset.y -= 30;
				}
			}
			else
				centerOffsets();*/
		
	}

	public function playAnim(AnimName:String, ?force:Bool = false):Void
	{
		animation.play(AnimName, force);

		updateHitbox();
		offset.set(frameWidth / 2, frameHeight / 2);

		if (CDevConfig.saveData.fnfNotes){
			offset.x -= 50;
			offset.y -= 52;
		} else{
			offset.x -= 44;
			offset.y -= 46;
		}
	}
}
