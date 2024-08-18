package game.objects;

import flixel.group.FlxGroup.FlxTypedGroup;

// Fixing the weird note layering between normal note and a sustain note
class NoteGroup extends FlxTypedGroup<Note> {
    var __loopSprite:Note;
	var __currentlyLooping:Bool = false;
	var __time:Float = -1.0;
	public override function draw() {
        var loop:Int = length-1;
        var note:Note = null;

        while (loop >= 0) {
            note = members[loop--];
            if (note == null || !note.exists || !note.visible) continue;
            note.draw();
        }
	}
}