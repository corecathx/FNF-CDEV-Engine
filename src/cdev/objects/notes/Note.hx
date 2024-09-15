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
    public var hitable(get,never):Bool;
    function get_hitable() {
        return time > Conductor.current.time - (Conductor.current.safe_zone_offset * 1.5)
            && time < Conductor.current.time + (Conductor.current.safe_zone_offset * 0.5);
    }
    public var invalid(get,never):Bool;
    function get_invalid() {
        return time < (Conductor.current.time - 166);
    }

    public function new() {
        super();
        frames = Assets.sparrowAtlas("notes/NOTE_assets");
    }

    public function init(time:Float, data:Int) {
        this.time = time;
        this.data = data;

        var _colorData:String = animColor[data];
        addAnim(_colorData+"Scroll", _colorData+"0", 24);
        playAnim(_colorData+"Scroll",true);

        setGraphicSize(scaleWidth);
        updateHitbox();

        y = -1000; //make sure it's completely offscreen.
    }

    public function follow(receptor:ReceptorNote) {
        x = receptor.x;
        y = receptor.y - ((Conductor.current.time - time) * (receptor.speed * receptor.scrollMult))*0.45;
    }
}