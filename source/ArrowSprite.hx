package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

//well uh...
class ArrowSprite extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public function new()
	{
		super();
		loadGraphic(Paths.image('notes/arrowSelection', 'shared'));
        antialiasing = FlxG.save.data.antialiasing;
        scale.set(0.7,0.7);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 5, sprTracker.y - 10);
	}
}
