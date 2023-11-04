package meta.states.charter;

import flixel.FlxG;
import game.Paths;
import game.objects.Note;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class StrumNote extends FlxSprite {
    var animOffsets:Map<String, Array<Dynamic>>;
    var xPos:Float = 0;
    var yPos:Float = 0;
    var imgWidth:Int = 0;
    var imgHeight:Int = 0;
    var noteKey:Int = 0; //0 Left, 1 Down, 2 Up, 3 Right

    public var currentlyBeingStrummed:Bool = false;

    public function new(x:Float,y:Float, widthW:Int, heightH:Int, noteKey:Int=0) {
        super(x,y);
        this.imgWidth = widthW;
        this.imgHeight = heightH;
        this.noteKey = noteKey;

        animOffsets = new Map<String, Array<Dynamic>>();

        createNote();
    }
    function createNote(){
        frames = Paths.getSparrowAtlas('notes/NOTE_assets');
        animation.addByPrefix('green', 'arrowUP');
        animation.addByPrefix('blue', 'arrowDOWN');
        animation.addByPrefix('purple', 'arrowLEFT');
        animation.addByPrefix('red', 'arrowRIGHT');

        switch (Math.abs(noteKey))
        {
            case 0:
                animation.addByPrefix('static', 'arrowLEFT');
                animation.addByPrefix('confirm', 'left confirm', 24, false);
            case 1:
                animation.addByPrefix('static', 'arrowDOWN');
                animation.addByPrefix('confirm', 'down confirm', 24, false);
            case 2:
                animation.addByPrefix('static', 'arrowUP');
                animation.addByPrefix('confirm', 'up confirm', 24, false);
            case 3:
                animation.addByPrefix('static', 'arrowRIGHT');
                animation.addByPrefix('confirm', 'right confirm', 24, false);
        }
        addOffset('static',55+4,55+2);
        addOffset('confirm',65+4,65+2);
        antialiasing = CDevConfig.saveData.antialiasing;
        setGraphicSize(imgWidth,imgHeight);
        updateHitbox();
        //scrollFactor.set();
        setPosition(xPos,yPos);
    }

    public function playAnim(anim:String,force:Bool = false){
        animation.play(anim,force);
        var daOffset = animOffsets.get(anim);
		if (animOffsets.exists(anim))
		{
			offset.set(daOffset[0], daOffset[1]);
		} else {
            offset.set(0, 0);
        }
			
    }

    public function hitAnim() {
        playAnim('confirm', true);
        currentlyBeingStrummed = true;
    }

    override function update(elapsed:Float) {
        //updateHitbox();
		if (animation.finished)
		{
			playAnim('static');
            currentlyBeingStrummed = false;
		}
        super.update(elapsed);
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0)
    {
        animOffsets[name] = [x, y];
    }
}