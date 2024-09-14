package cdev.objects.notes;

import flixel.group.FlxSpriteGroup;

/**
 * A sprite group contains
 */
class StrumLine extends FlxSpriteGroup {
    /** Notes that are assigned to this Strum Line. **/
    public var notes:FlxTypedSpriteGroup<Note>;

    /** Receptors of this Strum Line. **/
    public var receptors:FlxTypedSpriteGroup<ReceptorNote>;

    /** Whether to automatically hit the notes. **/
    public var cpu:Bool = false;

    public function new(x:Float = 0, y:Float = 0, cpu:Bool = false):Void {
        super(x, y);
        this.cpu = cpu;

        receptors = new FlxTypedSpriteGroup<ReceptorNote>();
        add(receptors);

        notes = new FlxTypedSpriteGroup<Note>();
        notes.active = false;
        add(notes);

        for (index => dir in Note.directions) {
            var spr:ReceptorNote = new ReceptorNote(Note.scaleWidth*index,0,dir);
            receptors.add(spr);
        }
    }

    /**
     * Updates this strumline.
     */
     override function update(elapsed:Float):Void {
        notes.forEachAlive((note:Note) -> {
            note.follow(getReceptor(note.data));
        });
        super.update(elapsed);
    }

    public function addNote(n:Note) {
        notes.add(n);
    }

    public function getReceptor(index:Int) return receptors.members[index];
}