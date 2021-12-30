package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NotePress extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var fileName:String = 'NOTE_press';

		loadImage(fileName);

		prepareImage(x, y, note);
		antialiasing = FlxG.save.data.antialiasing;
	}

    override function update(elapsed:Float) {
		if(animation.curAnim.finished)
            kill();

		super.update(elapsed);
	}

	public function prepareImage(x:Float, y:Float, note:Int = 0) {
		setPosition((x - Note.swagWidth * 0.95) + 30, (y - Note.swagWidth) + 30);
		alpha = 1;

        var daAnim:String = '';

        switch (note)
        {
            case 0: daAnim = 'left';
            case 1: daAnim = 'down';
            case 2: daAnim = 'up';
            case 3: daAnim = 'right';
        }
        animation.play(daAnim, true);
	}

	function loadImage(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		animation.addByPrefix("left", 'leftclick', 30, false);
		animation.addByPrefix("down", 'downclick', 30, false);
		animation.addByPrefix("up", 'upclick',30, false);
		animation.addByPrefix("right", 'rightclick', 30, false);
	}
}