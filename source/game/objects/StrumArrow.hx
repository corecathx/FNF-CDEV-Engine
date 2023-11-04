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

		updateHitbox();
		offset.set(frameWidth / 2, frameHeight / 2);

		offset.x -= 50;
		offset.y -= 52;
	}

	public static function checkRects(daNote:Note, strum:StrumArrow)
	{
		var strumLineMid = strum.y + Note.swagWidth / 2;
		if ((daNote.isSustainNote && (daNote.mustPress || !daNote.canIgnore) &&
			(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
			|| CDevConfig.saveData.botplay)
		{
			var swagRect:FlxRect = daNote.clipRect;
			if(swagRect == null) swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);

			if (strum.noteScroll < 0)
			{
				if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= strumLineMid)
				{
					swagRect.width = daNote.frameWidth;
					swagRect.height = (strumLineMid - daNote.y) / daNote.scale.y;
					swagRect.y = daNote.frameHeight - swagRect.height;
				}
			}
			else if (daNote.y + daNote.offset.y * daNote.scale.y <= strumLineMid)
			{
				swagRect.y = (strumLineMid - daNote.y) / daNote.scale.y;
				swagRect.width = daNote.width / daNote.scale.x;
				swagRect.height = (daNote.height / daNote.scale.y) - swagRect.y;
			}
			daNote.clipRect = swagRect;
		}
	}
}