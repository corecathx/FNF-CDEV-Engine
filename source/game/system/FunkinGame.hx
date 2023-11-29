package game.system;

import flixel.FlxGame;

class FunkinGame extends FlxGame
{
	var skipUpdate:Bool = false;

	public override function switchState()
	{
		super.switchState();
		draw();
		_total = ticks = getTicks();
		skipUpdate = true;
	}

	public override function onEnterFrame(t)
	{
		if (skipUpdate != (skipUpdate = false))
			_total = ticks = getTicks();
		super.onEnterFrame(t);
	}
}
