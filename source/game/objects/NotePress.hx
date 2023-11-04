package game.objects;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NotePress extends FlxSprite
{
	public var animList:Array<String> = ["left", "down", "up", "right"];
	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);
		var fileName:String = '';

		if (CDevConfig.saveData.noteRipples)
			fileName = 'notes/NOTE_press';
		else
			fileName = 'notes/noteSplashes';
		loadImage(fileName);

		prepareImage(x, y, note);
		antialiasing = CDevConfig.saveData.antialiasing;
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null && animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
	//x offsets
	var splashOffsets:Array<Float> = [20,20,20,20];
	//y offsets
	var splashOffset:Array<Float> = [20,20,20,20];
	public function prepareImage(x:Float, y:Float, note:Int = 0, col:FlxColor = FlxColor.WHITE)
	{
		if (CDevConfig.saveData.noteRipples)
			setPosition((x - Note.swagWidth * 0.95) + 30, (y - Note.swagWidth) + 30);
		else
			setPosition((x - Note.swagWidth * 0.95) + -10 + splashOffsets[note], (y - Note.swagWidth) + -10+ splashOffset[note]);

		alpha = (CDevConfig.saveData.noteRipples ? 1 : 0.7);

		var daAnim:String = animList[note];

		animation.play(daAnim, true);

		if (!CDevConfig.saveData.noteRipples) angle = FlxG.random.int(0,360);

		if (CDevConfig.saveData.noteRipples){
			color = col;
		}

		updateHitbox();
		centerOffsets();
	}

	function loadImage(skin:String)
	{
		frames = Paths.getSparrowAtlas(skin);
		if (CDevConfig.saveData.noteRipples)
		{
			animation.addByPrefix("left", 'leftclick', 60, false);
			animation.addByPrefix("down", 'downclick', 60, false);
			animation.addByPrefix("up", 'upclick', 60, false);
			animation.addByPrefix("right", 'rightclick', 60, false);
		}
		else
		{
			animation.addByPrefix("left", 'purplesplash', 30, false);
			animation.addByPrefix("down", 'bluesplash', 30, false);
			animation.addByPrefix("up", 'greensplash', 30, false);
			animation.addByPrefix("right", 'redsplash', 24, false);
		}
	}
}
