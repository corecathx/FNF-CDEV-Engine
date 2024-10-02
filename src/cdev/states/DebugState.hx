package cdev.states;

import cdev.objects.play.hud.RatingSprite;
import cdev.objects.play.Character;
import cdev.backend.audio.SoundGroup;
import cdev.objects.play.notes.NoteLoader;
import cdev.objects.play.notes.StrumLine;
import cdev.objects.play.notes.Note;

class DebugState extends State {
    var playerStrums:StrumLine;
    var opponentStrums:StrumLine;
    var sounds:SoundGroup;

    var noteLoader:NoteLoader;

    var playerChar:Character;

    var ratingSprite:RatingSprite;

    override function create() {
        var strumCount:Float = 2;
        var maxPlayField:Float = FlxG.width / strumCount;
        var strumWidth:Float = Note.scaleWidth*Note.directions.length;
        var centerX:Float = (maxPlayField-strumWidth)*0.5;

        var up:Float = 70;
        var down:Float = (FlxG.height-Note.scaleWidth)-up;

        playerChar = new Character(0,0,"bf",false);
        playerChar.screenCenter();
        add(playerChar);

        opponentStrums = new StrumLine(centerX,up,true);
        opponentStrums.scrollMult = 1;
        add(opponentStrums);

        playerStrums = new StrumLine((FlxG.width*0.5)+centerX,up,false);
        playerStrums.scrollMult = 1;
        playerStrums.characters.push(playerChar);
        add(playerStrums);

        var song = Utils.loadSong("Test Chart", "hard");

        sounds = new SoundGroup(song.inst,song.voices);
        add(sounds);
        sounds.play();

        noteLoader = new NoteLoader([opponentStrums, playerStrums],song.chart);
        add(noteLoader);

        ratingSprite = new RatingSprite(FlxG.width*0.5, FlxG.height*0.5);
        add(ratingSprite);

        playerStrums.onNoteHit.add(onNoteHit);

        Conductor.current.updateBPM(song.chart.info.bpm);
        Conductor.current.onBeatTick.add(()->{
            if (Conductor.current.current_beats % 4 == 0) FlxG.camera.zoom += 0.05;
            playerChar.dance();
        });
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        FlxG.camera.zoom = FlxMath.lerp(0.5, FlxG.camera.zoom, 1-(elapsed*6));
        if (FlxG.keys.justPressed.B) {
            playerStrums.cpu = !playerStrums.cpu;
        }

        if (FlxG.keys.pressed.Z)
            sounds.speed *= 0.99;
        if (FlxG.keys.pressed.X)
            sounds.speed *= 1.01;

        FlxG.watch.addQuick("Render Blit", FlxG.renderBlit);
    }

    public function onNoteHit(note:Note) {
        ratingSprite.show(SICK);
    }
}