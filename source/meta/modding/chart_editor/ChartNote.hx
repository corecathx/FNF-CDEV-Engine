package meta.modding.chart_editor;

import game.objects.Note;

/**
 * A dummy note that's used on the Chart Editor
 */
class ChartNote extends FlxSprite {
    public var strumTime:Float = 0;
    public var noteData:Int = 0;
    public var holdLength:Float = 0;
    public var noteType:String = "Default Note";
    public var noteArgs:Array<String> = ["",""];

    public var isSustain:Bool = false;

    public var nSustain:ChartNote = null;
    public var nSustainEnd:ChartNote = null;
    public var bgHighlight:FlxSprite = null;

    public var asDummyNote:Bool = false;

    public function new(nX:Float = 0, nY:Float = 0)
    {
        super(nX,nY);
        bgHighlight = new FlxSprite().makeGraphic(ChartEditor.grid_size,ChartEditor.grid_size,FlxColor.WHITE);
        bgHighlight.active = false;
    }

    /**
     * Start initializing the note.
     * @param noteArray Note array from CDevChart's `notes` array. (what am i saying)
     * @return } hm
     */
    public function init(noteArray:Array<Dynamic>, isSustain:Bool){
        strumTime = noteArray[0];
        noteData = noteArray[1];
        holdLength = noteArray[2];
        noteType = noteArray[3];
        noteArgs = noteArray[4];

        this.isSustain = isSustain;

        frames = ChartEditor.note_texture;

        for (i in Note.directions) {
            animation.addByPrefix(i+"anim", i+"0", 24);
            animation.addByPrefix("end"+i, (i == "purple" ? "pruple end hold" : i+" hold end"), 24);
            animation.addByPrefix("hold"+i, i+" hold piece", 24);
        }

        antialiasing = CDevConfig.saveData.antialiasing;
        setGraphicSize(ChartEditor.grid_size,ChartEditor.grid_size);
        updateHitbox();

        if (!isSustain && holdLength > 0){
            nSustain = new ChartNote();
            nSustain.init([strumTime + Conductor.stepCrochet,noteData, 0, noteType, noteArgs], true);
            nSustain.setGraphicSize(ChartEditor.grid_size/2.5, Std.int(ChartEditor.grid_size*((holdLength-(Conductor.stepCrochet*2)) / Conductor.stepCrochet)));
            nSustain.updateHitbox();

            nSustainEnd = new ChartNote();
            nSustainEnd.init([Conductor.stepCrochet,noteData, 0, noteType, noteArgs], true);
            nSustainEnd.setGraphicSize(ChartEditor.grid_size/2.5, Std.int(ChartEditor.grid_size/1.8));
            nSustainEnd.updateHitbox();

            nSustain.active = nSustainEnd.active = false;
        }

    }

    override function draw():Void {
        if (asDummyNote){
            bgHighlight.x = x;
            bgHighlight.y = y;
            bgHighlight.alpha = alpha * 0.5;
            bgHighlight.draw();
        }

        if (!isSustain && holdLength > 0) {
            nSustain.x = x + (width - nSustain.width) * 0.5;
            nSustain.y = y + ChartEditor.grid_size;
            nSustain.alpha = alpha*0.7;
            nSustain.animation.play("hold"+Note.directions[noteData%4], true);
            nSustain.setGraphicSize(ChartEditor.grid_size/2.5, Std.int(ChartEditor.grid_size*((holdLength-(Conductor.stepCrochet*2)) / Conductor.stepCrochet)));
            nSustain.updateHitbox();
            nSustain.draw();

            nSustainEnd.x = nSustain.x;
            nSustainEnd.y = Math.floor(nSustain.y + nSustain.height);
            nSustainEnd.alpha = nSustain.alpha;
            nSustainEnd.animation.play("end"+Note.directions[noteData%4], true);
            nSustainEnd.setGraphicSize(ChartEditor.grid_size/2.5, Std.int(ChartEditor.grid_size/1.8));
            nSustainEnd.updateHitbox();
            nSustainEnd.draw();
        }

        if (!isSustain){
            animation.play(Note.directions[noteData%4]+"anim",true);
        }
        super.draw();
    }
}