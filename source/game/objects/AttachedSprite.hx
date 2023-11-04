package game.objects;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class AttachedSprite extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var angleAdd:Float = 0;
	public var alphaAdd:Float = 0;

	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var copyVisible:Bool = false;

	public function new(file:String)
	{
		super();

		loadGraphic(Paths.image(file));
		antialiasing = CDevConfig.saveData.antialiasing;
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			scrollFactor.set(sprTracker.scrollFactor.x, sprTracker.scrollFactor.y);

			if (copyAngle) angle = sprTracker.angle + angleAdd;

			if (copyAlpha) alpha = sprTracker.alpha + alphaAdd;

			if (copyVisible) visible = sprTracker.visible;
		}
	}
}
