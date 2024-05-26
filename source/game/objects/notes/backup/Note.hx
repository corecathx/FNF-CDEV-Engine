package game.objects.notes;

// note rewrite attempt (fail)
typedef NoteInfo = {
    var time:Float;
    var data:Float;
    var length:Float;
    @:optional var type:String;
    @:optional var args:Array<String>;
}

class NoteR extends FlxSprite {
    public static var NOTE_TEXTURE:FlxAtlasFrames = null;
	public static var noteScale:Float = 0.65;
	public static var defaultGraphicSize:Float = 160;
	public static var swagWidth:Float = defaultGraphicSize * noteScale; // Parent note size after scaling
	public static var directions:Array<String> = ["purple", "blue", "green", "red"];

	// avoid repetitive missing note type file warnings
	public static var noteTypeFail:Array<String> = [];
	public var script:CDevScript = null;
	var gotScript:Bool = false;

	// Data stuff retrieved from the chart json
	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var isSustainNote:Bool = false;
	public var holdLength(default,set):Float = 0;
	public var noteType:String = "Default Note";
	public var noteArgs:Array<String> = ["", ""];

	// Indicating if this note belongs to the player or opponent
	public var mustPress:Bool = false;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	// Legacy chart editor stuffs
	public var sustainLength:Float = 0;
	public var rawNoteData:Int = 0;
	public var noteStep:Int = 0;

	public var noteYOffset:Float = 0;

	// HScript stuffs
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var followX:Bool = true;
	public var followY:Bool = true;
	public var noAnim:Bool = false; // Whether this note should trigger an animation?
	public var canIgnore:Bool = false;

	public var followAngle:Bool = true; // follow the strum's arrow angle
	public var followAlpha:Bool = true; // and alpha

	public var rating:String = "shit";

	// TESTING AND SHET
	public var mainNote:Note = null; // used for sustain notes.
	public var strumParent:StrumArrow;

    public function new(data:NoteInfo) {
        if (data != null) {
            strumTime = data.time;
            noteData = data.data;
            isSustainNote = data.length;
            holdLength = data.length > 0;
            noteType = data.type != null ? data.type : "Default Note";
            noteArgs = data.args != null ? data.args : ["", ""];
        }
    }
}