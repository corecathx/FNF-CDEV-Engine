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

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;
	public var moddedWeek:Bool = false;
	public var fileMissing:Bool = true; //used on editor

	public function new(x:Float, y:Float, weekNum:Int = 0, ?weekName:String)
	{
		super(x, y);
		if (!moddedWeek)
		{
			week = new FlxSprite().loadGraphic(Paths.image('storymenu/week' + weekNum));
		}
		else
		{
			week = new FlxSprite().loadGraphic(Paths.image(weekName));
		}

		add(week);
	}
	public function changeGraphic(weekName:String)
	{
		week.visible = true;
		var fileName:String = weekName.trim();

		if (fileName != null && fileName.length > 0)
		{
			if (#if ALLOW_MODS FileSystem.exists(Paths.modImages('storymenu/' + fileName)) || #end Assets.exists(Paths.image('storymenu/' + fileName),
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

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, game.cdev.CDevConfig.utils.bound(elapsed * 6, 0, 1));

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = spriteColor;
		else
			week.color = FlxColor.WHITE;
		screenCenter(X);
	}
}
