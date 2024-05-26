package game.objects;

import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumArrow extends FlxSprite
{
	public var isPixel:Bool = false;
	// public var downscroll:Bool = false;
	public var noteScroll:Float = 1;
	public var inEditor:Bool = false;

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

		if (CDevConfig.saveData.testMode)
		{
			if (FlxG.keys.pressed.THREE)
			{
				angle += 3;
			}

			if (FlxG.keys.pressed.TWO)
			{
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
				centerOffsets(); */
	}

	public function playAnim(AnimName:String, ?force:Bool = false):Void
	{
		animation.play(AnimName, force);
		centerOffsets();
		centerOrigin();
	}

	public static function checkRects(daNote:Note, strum:StrumArrow)
	{
		var strumLineMid:Float = strum.y + Note.swagWidth / 2;
		var isDownscroll:Bool = strum.noteScroll < 0;
		if ((daNote.isSustainNote && ((daNote.mustPress && daNote.wasGoodHit) || (!daNote.mustPress)))
			|| CDevConfig.saveData.botplay)
		{
			var swagRect:FlxRect = daNote.clipRect;
			if (swagRect == null) 
				swagRect = new FlxRect(0, 0, (strum.noteScroll < 0) ? daNote.frameWidth : daNote.width / daNote.scale.x, daNote.frameHeight);

			if (isDownscroll) {
				if (daNote.y + daNote.height >= strumLineMid){
					swagRect.height = (strumLineMid - daNote.y) / daNote.scale.y;
					swagRect.y = daNote.frameHeight - swagRect.height;
				}
			} else {
				if (daNote.y <= strumLineMid){
					swagRect.y = (strumLineMid - daNote.y) / daNote.scale.y;
					swagRect.height = (daNote.height / daNote.scale.y) - swagRect.y;
				}
			}
			daNote.clipRect = swagRect;
		}
	}
}