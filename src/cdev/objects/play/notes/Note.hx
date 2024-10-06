package cdev.objects.play.notes;

import cdev.objects.play.hud.RatingSprite.Rating;
import cdev.objects.play.notes.ReceptorNote.NoteDirection;

typedef JudgementData = {rating:Rating, score:Int, health:Float, accuracy:Float};

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

    public static var pixel_per_ms:Float = 0.45;

    public var time:Float = 0;
    public var data:Int = 0;
    public var length:Float = 0;

    public var judgement:JudgementData = {
        rating: SHIT,
        score: 0,
        health: 0.0,
        accuracy: 0.0
    }

    public var receptor:ReceptorNote = null;

    public var hit:Bool = false;
    public var missed:Bool = false;

    public var hitable(get,never):Bool;
    function get_hitable() {
        return time > Conductor.current.time - (Conductor.current.safe_zone_offset * 1.5)
            && time < Conductor.current.time + (Conductor.current.safe_zone_offset * 0.5);
    }

    public var invalid(get,never):Bool;
    function get_invalid() {
        return time < (Conductor.current.time - 166);
    }

    public var sustain:Sustain;

    public function new(receptor:ReceptorNote) {
        super();
        this.receptor = receptor;
        frames = Assets.sparrowAtlas("notes/NOTE_assets", false);
    }

    public function init(time:Float, data:Int, length:Float) {
        this.time = time;
        this.data = data;
        this.length = length;

        var _colorData:String = animColor[data];
        addAnim("idle", _colorData+"0", 24);
        playAnim("idle",true);

        setGraphicSize(scaleWidth);
        updateHitbox();

        if (length > 0) {
            sustain = new Sustain(this);
            sustain.init();
            
            sustain.y = sustain.x = -1000; //offscreen pls
        }
        
        x = y = -1000; //make sure it's completely offscreen.
    }

    override function draw() {
        if (sustain != null) sustain.draw();
        if (!hit) super.draw();
    }
    
    override function destroy() {
        if (sustain != null) sustain.destroy();
        super.destroy();
    }

    public function follow(receptor:ReceptorNote) {
        x = receptor.x;
        y = receptor.y - ((Conductor.current.time - time) * (receptor.speed * receptor.scrollMult))*Note.pixel_per_ms;
    }
}