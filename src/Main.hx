package;

import openfl.display.DisplayObject;
import cdev.backend.engine.Game;
import openfl.display.Sprite;
import cdev.backend.engine.StatsDisplay;

/**
 * Program's starting point.
 */
class Main extends Sprite
{
	/** Current active instance of the Main class. **/
	public static var current:Main = null;
	
	public function new()
	{
		super();
		addChild(new Game());
		addChild(new StatsDisplay(10,10,0xFFFFFF));
		trace("CDEV Engine is ready :3");

		postInit();
	}

	function postInit() {
		FlxG.mouse.visible = false;
		FlxG.cameras.useBufferLocking = true;
		FlxG.autoPause = false;
		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
	}

	// Get rid of hit test function because mouse memory ramp up during first move (-Bolo)
	@:noCompletion override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool return false;
	@:noCompletion override function __hitTestHitArea(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool return false;
	@:noCompletion override function __hitTestMask(x:Float, y:Float):Bool return false;
}