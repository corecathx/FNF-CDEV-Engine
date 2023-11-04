package game.objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundTankmen extends FlxSprite
{
	public static var animNotes:Array<Dynamic> = [];

	private var endingOffset:Float;
    private var speed:Float;
	private var moving:Bool;

	public var strumTime:Float;

	public function new(x:Float, y:Float, facingRight:Bool)
	{
		speed = 0.7;
		moving = false;
		strumTime = 0;
		moving = facingRight;
		super(x, y);

		frames = Paths.getSparrowAtlas('tankmanKilled1', 'week7');
		animation.addByPrefix('run', 'tankman running', 24, true);
		animation.addByPrefix('shot', 'John Shot ' + FlxG.random.int(1, 2), 24, false);
		animation.play('run');
		animation.curAnim.curFrame = FlxG.random.int(0, animation.curAnim.frames.length - 1);
		antialiasing = CDevConfig.saveData.antialiasing;

		updateHitbox();
		setGraphicSize(Std.int(0.8 * width));
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		visible = (x > -0.5 * FlxG.width && x < 1.2 * FlxG.width);

		if (animation.curAnim.name == "run")
		{
			var speed:Float = (Conductor.songPosition - strumTime) * speed;
			if (moving)
				x = (0.02 * FlxG.width - endingOffset) + speed;
			else
				x = (0.74 * FlxG.width + endingOffset) - speed;
		}
		else if (animation.curAnim.finished)
		{
			kill();
		}

		if (Conductor.songPosition > strumTime)
		{
			animation.play('shot');
			if (moving)
			{
				offset.x = 300;
				offset.y = 200;
			}
		}
	}

    public function resetStatus(x:Float, y:Float, moving:Bool):Void
        {
            this.x = x;
            this.y = y;
            this.moving = moving;
            endingOffset = FlxG.random.float(50, 200);
            speed = FlxG.random.float(0.6, 1);
            flipX = moving;
        }
    
}
