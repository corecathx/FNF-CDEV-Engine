package game;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NotePress extends FlxSprite
{
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
	var splashOffsets:Array<Float> = [-15,-10,-10,-10];
	//y offsets
	var splashOffset:Array<Float> = [5,10,-5,10];
	public function prepareImage(x:Float, y:Float, note:Int = 0, col:FlxColor = FlxColor.WHITE)
	{
		if (CDevConfig.saveData.noteRipples)
			setPosition((x - Note.swagWidth * 0.95) + 30, (y - Note.swagWidth) + 30);
		else
			setPosition((x - Note.swagWidth * 0.95) + -10 + splashOffsets[note], (y - Note.swagWidth) + -10+ splashOffset[note]);

		if (CDevConfig.saveData.noteRipples)
			alpha = 1;
		else
			alpha = 0.8;

		var daAnim:String = '';

		if (CDevConfig.saveData.noteRipples)
			switch (note)
			{
				case 0:
					daAnim = 'left';
				case 1:
					daAnim = 'down';
				case 2:
					daAnim = 'up';
				case 3:
					daAnim = 'right';
			}
		else
			switch (note)
			{
				case 0:
					daAnim = 'leftS';
				case 1:
					daAnim = 'downS';
				case 2:
					daAnim = 'upS';
				case 3:
					daAnim = 'rightS';
			}
		animation.play(daAnim, true);
		if (!CDevConfig.saveData.noteRipples)
			angle = FlxG.random.int(0,360);

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
			animation.addByPrefix("left", 'leftclick', 30, false);
			animation.addByPrefix("down", 'downclick', 30, false);
			animation.addByPrefix("up", 'upclick', 30, false);
			animation.addByPrefix("right", 'rightclick', 30, false);
		}
		else
		{
			animation.addByPrefix("leftS", 'leftSplash', 35, false);
			animation.addByPrefix("downS", 'downSplash', 35, false);
			animation.addByPrefix("upS", 'upSplash', 35, false);
			animation.addByPrefix("rightS", 'rightSplash', 35, false);
		}
	}
}
