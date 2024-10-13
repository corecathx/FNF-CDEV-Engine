package cdev.objects.play.notes;

import cdev.objects.play.notes.Note.JudgementData;
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

    /** Note Splashes of this Strum Line. **/
    public var splashes:FlxTypedSpriteGroup<Splash>;
    
    /** Characters that are attached to this Strum Line. **/
    public var characters:Array<Character> = [];

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

        splashes = new FlxTypedSpriteGroup<Splash>();
        add(splashes);

        var _tSplash:Splash = new Splash();
        _tSplash.alpha = 0;
        splashes.add(_tSplash);

        for (index => dir in Note.directions) {
            var spr:ReceptorNote = new ReceptorNote(Note.scaleWidth*index, 0, dir, this);
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
        
            // CPU Note Hit
            if (cpu && Conductor.instance.time > note.time && !note.hit) {
                _onNoteHit(note, note.length == 0);
            }
        
            // Note Miss
            var _maxTime:Float = note.time + note.length + Conductor.instance.step_ms;
            if (!note.hit && note.invalid && !note.missed) {
                _onNoteMiss(note);
            }
        
            // Sustain Note Miss
            if (note.length > 0 && note.missed) {
                note.alpha = 0.3;
                if (_maxTime < Conductor.instance.time) {
                    killNote(note);
                }
            }

            // Note has been hit, and passed the maximum time, kill it.
            if (note.hit && _maxTime < Conductor.instance.time) {
                killNote(note);
            }

            if (cpu && note.hit && note.length > 0 && Conductor.instance.time < _maxTime - Conductor.instance.step_ms*2) {
                playDirectionAnim(note);
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
                if (note.hit) return;
                if (!note.hitable || note.invalid) return;
                if (directions[note.data]) {
                    for (pNote in possibleNotes) {
                        if (pNote.data != note.data) continue;
                        if (note.time < pNote.time) {
                            possibleNotes.remove(pNote);
                            possibleNotes.push(note);
                            return;
                        }
                    }
                } else {
                    possibleNotes.push(note);
                    directions[note.data] = true;
                }
            });

            possibleNotes.sort((a, b) -> Std.int(a.time - b.time));
    
            var blockNote:Bool = false;
    
            for (index => press in pressedKeys) if (press && !directions[index]) blockNote = true;
    
            if (possibleNotes.length > 0 && !blockNote) {
                for (note in possibleNotes) {
                    if (pressedKeys[note.data]) {
                        _onNoteHit(note, note.length == 0);
                    }
                }
            }
        }
    
        if (releasedKeys.contains(true)) {
            for (index => key in releasedKeys) if (key) getReceptor(index).playAnim("static", true);
        }
    }
    

    function _onNoteHit(note:Note, kill:Bool = false) {
        playDirectionAnim(note);

        note.hit = true;
        note.judgement.rating = Utils.getNoteRating(note, Conductor.instance.time);
        var newJudge:JudgementData = switch (note.judgement.rating) {
            case SICK: {rating: note.judgement.rating, score: 400, health: 0.05, accuracy: 1};
            case GOOD: {rating: note.judgement.rating, score: 350, health: 0.04, accuracy: 0.8};
            case BAD: {rating: note.judgement.rating, score: 200, health: 0.02, accuracy: 0.6};
            case SHIT: {rating: note.judgement.rating, score: 150, health: 0.015, accuracy: 0.4};
            default: {rating: note.judgement.rating, score: 0, health: 0, accuracy: 0};
        }
        note.judgement = newJudge;
        if (!cpu && note.judgement.rating == SICK) {
            _spawnSplash(note);
        }
        onNoteHit.dispatch(note);

        if (kill) killNote(note);
    }

    function playDirectionAnim(note:Note) {
        getReceptor(note.data).playAnim("confirm",true);
        _character_playAnim('sing${Note.directions[note.data]}', true);
    }

    function _spawnSplash(note:Note) {
        var splash:Splash = splashes.recycle(Splash, ()->{return new Splash();});
        var receptor:ReceptorNote = getReceptor(note.data);
        splash.setPosition(receptor.x, receptor.y);
        splash.cameras = cameras;
        splash.init(note);
    }

    function _onNoteMiss(note:Note) {
        note.judgement.health = -0.06;
        note.judgement.score = -150;
        note.missed = true;

        _character_playAnim('sing${Note.directions[note.data]}miss',true);
        onNoteMiss.dispatch(note);
        if (note.length == 0) 
            killNote(note);
    }

    function killNote(note:Note) {
        note.destroy();
        notes.remove(note);
        note.kill();
    }

    function _character_playAnim(name:String, force:Bool) {
        if (characters.length == 0) return;
        for (char in characters) {
            if (char == null) continue;
            char.playAnim(name,force);
        }
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