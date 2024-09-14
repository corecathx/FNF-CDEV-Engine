package cdev.objects.notes;

import cdev.objects.notes.ReceptorNote.NoteDirection;

/**
 * Note object of Funkin.
 */
class Note extends Sprite {
    /** Default note direction sort. **/
    public static var directions:Array<NoteDirection> = [ LEFT, DOWN, UP, RIGHT ];
    public static var animColor:Array<String> = ["purple", "blue", "green", "red"];

    /** Note scaling, this applies to every notes in game. **/
    public static var noteScale:Float = 0.6;

    /** Default note width without scaling applied. **/
    public static var originWidth:Float = 160;

    /** Default note width with scaling applied. **/
    public static var scaleWidth:Float = originWidth * noteScale;

    public var time:Float = 0;
    public var data:Int = 0;

    public function new(time:Float, data:Int) {
        super();
        this.time = time;
        this.data = data;

        frames = Assets.sparrowAtlas("notes/NOTE_assets");

        var _colorData:String = animColor[data];
        addAnim(_colorData+"Scroll", _colorData+"0", 24);
        playAnim(_colorData+"Scroll",true);

        setGraphicSize(scaleWidth);
        updateHitbox();
    }

    public function follow(receptor:ReceptorNote) {
        x = receptor.x;
        y = receptor.y - (Conductor.current.time - time) * (receptor.speed * receptor.scrollMult);
    }
}