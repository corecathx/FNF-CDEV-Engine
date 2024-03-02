package game.objects;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;

// ORIGINAL BY PSYCH ENGINEEEE
class FunkinBar extends FlxSpriteGroup
{
	public var leftBar:FlxSprite;
	public var rightBar:FlxSprite;
	public var bgSprite:FlxSprite;
	public var valueFunction:Void->Float = null;
	public var percent(default, set):Float = 0;
	public var bounds:Dynamic = {min: 0, max: 1};
	public var leftToRight(default, set):Bool = true;
	public var barCenter(default, null):Float = 0;

	// you might need to change this if you want to use a custom bar
	public var barWidth(default, set):Int = 1;
	public var barHeight(default, set):Int = 1;
	public var barOffset:FlxPoint = new FlxPoint(3, 3);

	public function new(x:Float, y:Float, image:String = 'healthBar', valueFunction:Void->Float = null, boundX:Float = 0, boundY:Float = 1)
	{
		super(x, y);

		this.valueFunction = valueFunction;
		setBounds(boundX, boundY);

		bgSprite = new FlxSprite().loadGraphic(Paths.image(image));
		bgSprite.antialiasing = CDevConfig.saveData.antialiasing;
		barWidth = Std.int(bgSprite.width - 6);
		barHeight = Std.int(bgSprite.height - 6);

		leftBar = new FlxSprite().makeGraphic(Std.int(bgSprite.width), Std.int(bgSprite.height), FlxColor.WHITE);

		rightBar = new FlxSprite().makeGraphic(Std.int(bgSprite.width), Std.int(bgSprite.height), FlxColor.WHITE);
		rightBar.color = FlxColor.BLACK;

		add(leftBar);
		add(rightBar);
		add(bgSprite);
		regenerateClips();

        leftBar.antialiasing = antialiasing = rightBar.antialiasing = CDevConfig.saveData.antialiasing;
	}

	public var enabled:Bool = true;

	override function update(elapsed:Float)
	{
		if (!enabled)
		{
			super.update(elapsed);
			return;
		}

		if (valueFunction != null)
		{
			var value:Null<Float> = FlxMath.remapToRange(FlxMath.bound(valueFunction(), bounds.min, bounds.max), bounds.min, bounds.max, 0, 100);
			percent = (value != null ? value : 0);
		}
		else
			percent = 0;
		super.update(elapsed);
	}

	public function setBounds(min:Float, max:Float)
	{
		bounds.min = min;
		bounds.max = max;
	}

	public function setColors(left:FlxColor = null, right:FlxColor = null)
	{
		if (left != null)
			leftBar.color = left;
		if (right != null)
			rightBar.color = right;
	}

	public function updateBar()
	{
		if (leftBar == null || rightBar == null)
			return;

		leftBar.setPosition(bgSprite.x, bgSprite.y);
		rightBar.setPosition(bgSprite.x, bgSprite.y);

		var leftSize:Float = 0;
		if (leftToRight)
			leftSize = FlxMath.lerp(0, barWidth, percent / 100);
		else
			leftSize = FlxMath.lerp(0, barWidth, 1 - percent / 100);

		leftBar.clipRect.width = leftSize;
		leftBar.clipRect.height = barHeight;
		leftBar.clipRect.x = barOffset.x;
		leftBar.clipRect.y = barOffset.y;

		rightBar.clipRect.width = barWidth - leftSize;
		rightBar.clipRect.height = barHeight;
		rightBar.clipRect.x = barOffset.x + leftSize;
		rightBar.clipRect.y = barOffset.y;

		barCenter = leftBar.x + leftSize + barOffset.x;

		// flixel is retarded
		leftBar.clipRect = leftBar.clipRect;
		rightBar.clipRect = rightBar.clipRect;
	}

	public function regenerateClips()
	{
		if (leftBar != null)
		{
			leftBar.setGraphicSize(Std.int(bgSprite.width), Std.int(bgSprite.height));
			leftBar.updateHitbox();
			leftBar.clipRect = new FlxRect(0, 0, Std.int(bgSprite.width), Std.int(bgSprite.height));
		}
		if (rightBar != null)
		{
			rightBar.setGraphicSize(Std.int(bgSprite.width), Std.int(bgSprite.height));
			rightBar.updateHitbox();
			rightBar.clipRect = new FlxRect(0, 0, Std.int(bgSprite.width), Std.int(bgSprite.height));
		}
		updateBar();
	}

	private function set_percent(value:Float)
	{
		var doUpdate:Bool = false;
		if (value != percent)
			doUpdate = true;
		percent = value;

		if (doUpdate)
			updateBar();
		return value;
	}

	private function set_leftToRight(value:Bool)
	{
		leftToRight = value;
		updateBar();
		return value;
	}

	private function set_barWidth(value:Int)
	{
		barWidth = value;
		regenerateClips();
		return value;
	}

	private function set_barHeight(value:Int)
	{
		barHeight = value;
		regenerateClips();
		return value;
	}
}
