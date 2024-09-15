package cdev.objects.notes;

import flixel.util.FlxSignal;
import flixel.group.FlxSpriteGroup;

typedef NoteSignal = FlxTypedSignal<Note->Void>;
/**
 * A sprite group contains
 */
class StrumLine extends FlxSpriteGroup {
    /** Notes that are assigned to this Strum Line. **/
    public var notes:FlxTypedSpriteGroup<Note>;

    /** Receptors of this Strum Line. **/
    public var receptors:FlxTypedSpriteGroup<ReceptorNote>;

    /** Whether to automatically hit the notes. **/
    public var cpu(default,set):Bool = false;

    public var scrollMult(default, set):Float = 1;
    function set_scrollMult(val:Float):Float {
        for (i in receptors.members) {
            i.scrollMult = val;
        }
        return scrollMult = val;
    }

    public var onNoteHit:NoteSignal;
    public var onNoteMiss:NoteSignal;

    public function new(x:Float = 0, y:Float = 0, cpu:Bool = false):Void {
        super(x, y);
        receptors = new FlxTypedSpriteGroup<ReceptorNote>();
        add(receptors);

        notes = new FlxTypedSpriteGroup<Note>();
        notes.active = false;
        add(notes);

        for (index => dir in Note.directions) {
            var spr:ReceptorNote = new ReceptorNote(Note.scaleWidth*index,0,dir);
            receptors.add(spr);
        }

        onNoteHit = new NoteSignal();
        onNoteMiss = new NoteSignal();

        this.cpu = cpu;
    }

    /**
     * Updates this strumline.
     */
    override function update(elapsed:Float):Void {
        notes.forEachAlive((note:Note) -> {
            note.follow(getReceptor(note.data));
            if (cpu) {
                if (Conductor.current.time > note.time) {
                    getReceptor(note.data).playAnim("confirm",true);
                    note.destroy();
                    notes.remove(note);
                    note.kill();
                }
            }

            if (note.invalid) {
                _onNoteMiss(note);
            }
        });
        if (!cpu) {
            controlsLogic();
        }
        super.update(elapsed);
    }

    function controlsLogic() {
        var pressedKeys:Array<Bool> = [Controls.LEFT_P, Controls.DOWN_P, Controls.UP_P, Controls.RIGHT_P];
        var heldKeys:Array<Bool> = [Controls.LEFT, Controls.DOWN, Controls.UP, Controls.RIGHT];
        var releasedKeys:Array<Bool> = [Controls.LEFT_R, Controls.DOWN_R, Controls.UP_R, Controls.RIGHT_R];
    
        if (pressedKeys.contains(true)) {
            for (index => key in pressedKeys) if (key) getReceptor(index).playAnim("pressed", true);
            var possibleNotes:Array<Note> = [];
            var directions:Array<Bool> = [false, false, false, false];
    
            notes.forEachAlive((note:Note) -> {
                if (!note.hitable || note.invalid) return;
    
                // Check if a note with the same data is already considered
                if (directions[note.data]) {
                    for (pNote in possibleNotes) {
                        if (pNote.data != note.data) continue;
    
                        // Remove any note with a higher time difference and keep the closer one
                        if (note.time < pNote.time) {
                            possibleNotes.remove(pNote);
                            possibleNotes.push(note);
                            return;
                        }
                    }
                } else {
                    // Add the first note found with this data
                    possibleNotes.push(note);
                    directions[note.data] = true;
                }
            });
    
            // Sort notes by time, so the earlier ones get hit first
            possibleNotes.sort((a, b) -> Std.int(a.time - b.time));
    
            var blockNote:Bool = false;
    
            // Block notes if no direction was pressed
            for (index => press in pressedKeys) if (press && !directions[index]) blockNote = true;
    
            // Hit the notes only if no blocking condition exists
            if (possibleNotes.length > 0 && !blockNote) {
                for (note in possibleNotes) {
                    if (pressedKeys[note.data]) {
                        _onNoteHit(note);
                        break;  // Stop after the first hit to avoid hitting multiple notes
                    }
                }
            }
        }
    
        if (releasedKeys.contains(true)) {
            for (index => key in releasedKeys) if (key) getReceptor(index).playAnim("static", true);
        }
    }
    

    function _onNoteHit(note:Note) {
        onNoteHit.dispatch(note);

        getReceptor(note.data).playAnim("confirm",true);
        killNote(note);
    }

    function _onNoteMiss(note:Note) {
        onNoteMiss.dispatch(note);
        killNote(note);
    }

    function killNote(note:Note) {
        note.destroy();
        notes.remove(note);
        note.kill();
    }

    public function addNote(n:Note) {
        notes.add(n);
    }

    public function getReceptor(index:Int) return receptors.members[index];

    function set_cpu(newCPU:Bool):Bool {
        if (newCPU) {
            for (rec in receptors.members) {
                rec.animation.finishCallback = (name:String) -> {
                    if (name == "confirm") rec.playAnim("static", true);
                }
            }
        } else {
            for (rec in receptors.members) {
                rec.animation.finishCallback = (name:String) -> {}
            }
        }
        return cpu = newCPU;
    }
}