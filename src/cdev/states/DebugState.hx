package cdev.states;

import cdev.backend.audio.SoundGroup;
import cdev.objects.notes.NoteLoader;
import cdev.objects.notes.StrumLine;
import cdev.objects.notes.Note;

class DebugState extends State {
    var playerStrums:StrumLine;
    var opponentStrums:StrumLine;
    var sounds:SoundGroup;

    var noteLoader:NoteLoader;
    override function create() {
        var strumCount:Float = 2;
        var maxPlayField:Float = FlxG.width / strumCount;
        var strumWidth:Float = Note.scaleWidth*Note.directions.length;
        var centerX:Float = (maxPlayField-strumWidth)*0.5;

        var scrollThing:Float = (FlxG.height-Note.scaleWidth)-70;
        opponentStrums = new StrumLine(centerX,70,true);
        add(opponentStrums);

        playerStrums = new StrumLine((FlxG.width*0.5)+centerX,scrollThing,false);
        playerStrums.scrollMult = -1;
        add(playerStrums);

        var song = Utils.loadSong("Roses Erect", "hard");

        sounds = new SoundGroup(song.inst,song.voices);
        add(sounds);
        sounds.play();

        noteLoader = new NoteLoader([opponentStrums, playerStrums],song.chart);
        add(noteLoader);

        Conductor.current.updateBPM(song.chart.info.bpm);
        Conductor.current.onBeatTick.add(()->{
            if (Conductor.current.current_beats % 4 == 0) FlxG.camera.zoom += 0.05;
            FlxG.camera.zoom += 0.015;
        });
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 1-(elapsed*6));
    }
}