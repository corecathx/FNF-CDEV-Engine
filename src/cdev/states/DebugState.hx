package cdev.states;

import cdev.objects.notes.StrumLine;
import cdev.objects.notes.Note;

class DebugState extends State {
    var strumline:StrumLine;
    override function create() {
        strumline = new StrumLine((FlxG.width-(Note.scaleWidth*Note.directions.length))*0.5,100,false);
        add(strumline);
        super.create();
    }

    override function update(elapsed:Float) {
        Conductor.current.time += (elapsed*1000);
        var keyPressed:Array<Bool> = [
            FlxG.keys.justPressed.S,
            FlxG.keys.justPressed.D,
            FlxG.keys.justPressed.K,
            FlxG.keys.justPressed.L
        ];
        var keyReleased:Array<Bool> = [
            FlxG.keys.justReleased.S,
            FlxG.keys.justReleased.D,
            FlxG.keys.justReleased.K,
            FlxG.keys.justReleased.L
        ];

        if (keyPressed.contains(true)){
            for (index => key in keyPressed) {
                if (key) 
                    strumline.addNote(new Note(Conductor.current.time+1500,index));
            }
        }

        super.update(elapsed);
    }
}