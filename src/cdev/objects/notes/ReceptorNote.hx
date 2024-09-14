package cdev.objects.notes;

enum abstract NoteDirection(String) {
    var LEFT  = "LEFT";
    var DOWN  = "DOWN";
    var UP    = "UP";
    var RIGHT = "RIGHT";
}

/**
 * Note receptor object.
 */
class ReceptorNote extends Sprite {
    /** Scroll multiplier, also used to determine upscroll & downscroll. **/
    public var scrollMult:Float = 1;
    public var speed:Float = 1;
    public function new(nX:Float, nY:Float, direction:NoteDirection) {
        super(nX,nY);
        var animArray:Array<Array<String>> = [
            ["static", "arrow<A>"],
            ["pressed", "<a> press"],
            ["confirm", "<a> confirm"],
        ];
        frames = Assets.sparrowAtlas("notes/NOTE_assets");
        
        var dirStr:String = cast direction;
        for (anim in animArray) {
            var formattedAnim:String = anim[1].replace("<A>", dirStr.toUpperCase());
            formattedAnim = formattedAnim.replace("<a>", dirStr.toLowerCase());

            addAnim(anim[0],formattedAnim,24,false);
        }
        playAnim(animArray[0][0],true);

        setGraphicSize(Note.scaleWidth);
        updateHitbox();
    }

	override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
    {
        animation.play(name, force);
        centerOffsets();
        centerOrigin();
    }
}