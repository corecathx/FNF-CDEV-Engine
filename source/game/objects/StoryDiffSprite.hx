package game.objects;

import flixel.tweens.FlxTween;
import lime.utils.Assets;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class StoryDiffSprite extends FlxSpriteGroup
{
	public var curText:String = '';
	var prevText:String = '';
	public var targetY:Float = 0;
	public var diff:FlxSprite;
	public var diffText:Alphabet; //this is unstable ofc
	public var fileMissing:Bool = true;

	var _defX:Float = 0;
	var _defY:Float = 0;

	var a:Float = 0;

	public function new(x:Float, y:Float, diffic:String)
	{
		super(x, y);
		_defX = x;
		_defY = y;

		diff = new FlxSprite().loadGraphic(Paths.image('storymenu/difficulty/' + diffic));
		add(diff);

		a = diff.y+diff.height+10;
		diffText = new Alphabet(0,a,"", true, false, 20);
		add(diffText);
		diffText.visible = false;
	}

	public function changeDiff(diffName:String)
	{
		diffText.visible = false;
		fileMissing = true;
		var fileName:String = diffName.trim();

		if (fileName != null && fileName.length > 0)
		{
			if (#if ALLOW_MODS FileSystem.exists(Paths.modImages('storymenu/difficulty/' + fileName))
				|| #end Assets.exists(Paths.image('storymenu/difficulty/' + fileName), IMAGE))
			{
				diff.loadGraphic(Paths.image('storymenu/difficulty/' + fileName));
				fileMissing = false;
			}
		}

		curText = fileName;

		if (fileMissing)
		{
			diff.loadGraphic(Paths.image('no_diff_image'));
			diffText.visible = true;
			if (curText != prevText)
			{
				remove(diffText);
				diffText = new Alphabet(0,a,fileName, true, false, 20);
				add(diffText);
			}
		}

		prevText = curText;
	}
	
	var tweenDifficulty:FlxTween;
	var tweenNoDiffText:FlxTween;

	public function doTween()
	{
		diff.y = _defY - 15;
		diff.alpha = 0;

		diffText.y = a - 15;
		diffText.alpha = 0;

		if (tweenDifficulty != null)
			tweenDifficulty.cancel();
		tweenDifficulty = FlxTween.tween(diff, {y: _defY, alpha: 1}, 0.07, {
			onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}
		});

		if (tweenNoDiffText != null)
			tweenNoDiffText.cancel();
		tweenNoDiffText = FlxTween.tween(diffText, {y: a, alpha: 1}, 0.07, {
			onComplete: function(twn:FlxTween)
			{
				tweenNoDiffText = null;
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
