package game.objects;

import lime.utils.Assets;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

// Used by the rewritten story mode menu
class StoryItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;
	public var moddedWeek:Bool = false;
	public var fileMissing:Bool = true; //used on editor
	public var disabled:Bool = false;

	public function new(x:Float, y:Float, weekNum:Int = 0, ?weekName:String)
	{
		super(x, y);
		if (!moddedWeek)
			week = new FlxSprite().loadGraphic(Paths.image('storymenu/week' + weekNum));
		else
			week = new FlxSprite().loadGraphic(Paths.image(weekName));
		add(week);

		antialiasing = CDevConfig.saveData.antialiasing;
	}
	public function changeGraphic(weekName:String)
	{
		week.visible = true;
		var fileName:String = weekName.trim();

		if (fileName != null && fileName.length > 0)
		{
			if (FileSystem.exists(Paths.modImages('storymenu/' + fileName)) || Assets.exists(Paths.image('storymenu/' + fileName),
				IMAGE))
			{
				week.loadGraphic(Paths.image('storymenu/' + fileName));
				fileMissing = false;
			}
		}

		if (fileMissing)
		{
			week.visible = false;
		}
	}

	private var isFlashing:Bool = false;
	private var spriteColor:FlxColor;

	public function startFlashing(color:FlxColor = 0xFF33ffff):Void
	{
		isFlashing = true;
		this.spriteColor = color;
	}

	public function stopFlashing():Void
	{
		week.color = FlxColor.WHITE;
		flashingInt = 0;
		spriteColor = FlxColor.WHITE;
		isFlashing = false;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 90) + ((FlxG.height-height)*0.5), game.cdev.CDevConfig.utils.bound(elapsed * 6, 0, 1));
		x = FlxMath.lerp(x, 30 - (35*targetY), game.cdev.CDevConfig.utils.bound(elapsed * 6, 0, 1));

		alpha = FlxMath.lerp(alpha, disabled ? 0 : (targetY==0 ? 1: 0.3), game.cdev.CDevConfig.utils.bound(elapsed * 12, 0, 1));

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = spriteColor;
		else
			week.color = FlxColor.WHITE;
	}
}
