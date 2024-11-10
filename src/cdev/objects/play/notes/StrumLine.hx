package cdev.objects.play.notes;

import cdev.objects.play.notes.ReceptorNote.NoteDirection;
import flixel.input.keyboard.FlxKey;
import lime.ui.KeyModifier;
import lime.ui.KeyCode;
import lime.app.Application;
import cdev.states.PlayState;
import cdev.objects.play.notes.Note.JudgementData;
import flixel.util.FlxSignal;
import flixel.group.FlxSpriteGroup;

typedef NoteSignal = FlxTypedSignal<Note->Void>;

class NoteGroup extends FlxTypedSpriteGroup<Note> {
    public inline function getFirstHitable(direction:Int):Note {
        var note:Note = null;
        forEachAlive((n:Note) -> {
            if (n.hit) return;
            if (!n.hitable || n.invalid) return;
            if (n.data != direction) return;
            if (note != null) {
                if (n.time < note.time) {
                    note = n;
                    return;
                }
            } else {
                note = n;
            }
        });
        return note;
    }
}

/**
 * A sprite group contains receptors, splashes, and notes.
 */
class StrumLine extends FlxSpriteGroup {
    /** Notes that are assigned to this Strum Line. **/
    public var notes:NoteGroup;

    /** Receptors of this Strum Line. **/
    public var receptors:FlxTypedSpriteGroup<ReceptorNote>;

    /** Note Splashes of this Strum Line. **/
    public var splashes:FlxTypedSpriteGroup<Splash>;
    
    /** Characters that are attached to this Strum Line. **/
    public var characters:Array<Character> = [];

    /** Whether to automatically hit the notes. **/
    public var cpu(default,set):Bool = false;

    public var keys:Map<FlxKey, Int>;

    public var heldKeys:Array<Bool> = [false,false,false,false];

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

        notes = new NoteGroup();
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

    public function addNote(n:Note) {
        notes.add(n);
    }

    public function getReceptor(index:Int) return receptors.members[index];

    override function destroy():Void {
        notes?.destroy();
        splashes?.destroy();
        receptors?.destroy();
        // Make sure to unregister the inputs after this strumline is no longer being used.
        unregisterInputs(); 
        super.destroy();
    }
    /**
     * Updates this strumline.
     */
    override function update(elapsed:Float):Void {
        notes.forEachAlive((note:Note) -> {   
            note.follow(getReceptor(note.data));

            var _maxTime:Float = note.time + note.length + Conductor.instance.step_ms;
            var _inHoldRange:Bool = note.length > 0 && Conductor.instance.time < _maxTime - Conductor.instance.step_ms*2;
        
            // CPU Note Hit
            if (cpu && Conductor.instance.time > note.time && !note.hit) {
                _onNoteHit(note, note.length == 0);
            }
        
            // Note Miss
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

            // If the player is inside the note's hold range, play strum and character animation.
            if ((cpu || heldKeys[note.data]) && note.hit && !note.missed && _inHoldRange) {
                playDirectionAnim(note);
                if (!cpu) { // You won't get scores on botplay.
                    PlayState.current.score += Std.int(200 * elapsed);
                    PlayState.current.health += 0.075 * elapsed;
                }
            }

            // If the player released the corresponding key while still inside the note's hold range
            // Count that as a miss.
            if (note.hit && !note.missed && (!cpu && !heldKeys[note.data]) && _inHoldRange) {
                _onNoteMiss(note, true);
            }
        });

        super.update(elapsed);
    }

    public function registerInputs() {
        if (keys != null) return;
        keys = [];
        // We need to assign the key map first.
        var bindList:Array<Array<String>> = [
            Preferences.keybinds.left,
            Preferences.keybinds.down,
            Preferences.keybinds.up,
            Preferences.keybinds.right
        ];
        for (index=>dir in Note.directions) {
            var conv:Array<FlxKey> = [];
            for (_key in bindList[index]) 
                keys.set(FlxKey.fromString(_key), index);
        }

        Application.current.window.onKeyDown.add(_onKeyDown);
        Application.current.window.onKeyUp.add(_onKeyUp);
        trace("Input registered");
    }

    public function unregisterInputs() {
        if (keys == null) return;
        Application.current.window.onKeyDown.remove(_onKeyDown);
        Application.current.window.onKeyUp.remove(_onKeyUp);
        keys = null;
        trace("Input unregistered");
    }

    function _onKeyDown(limeKey:KeyCode, mod:KeyModifier) {
        var key:FlxKey = @:privateAccess openfl.ui.Keyboard.__convertKeyCode(limeKey);
        var dir:Int = keys[key] ?? -1;
        if (dir == -1 || heldKeys[dir]) 
            return;
        heldKeys[dir] = true;

        getReceptor(dir).playAnim("pressed", true);
        var note:Note = notes.getFirstHitable(dir);

        if (note != null)
            _onNoteHit(note, note.length == 0);
    }
    
    function _onKeyUp(limeKey:KeyCode, mod:KeyModifier) {
        var key:FlxKey = @:privateAccess openfl.ui.Keyboard.__convertKeyCode(limeKey);
        var dir:Int = keys[key] ?? -1;

        if (dir == -1) 
            return;
        heldKeys[dir] = false;
        getReceptor(dir).playAnim("static", true);
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

    function _onNoteMiss(note:Note, midHold:Bool = false) {
        note.judgement.health = -0.06;
        note.judgement.score = -150;
        note.missed = true;
        if (midHold) note.judgement.accuracy = 0; // this is dumb

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

    function set_cpu(newCPU:Bool):Bool {
        if (newCPU) {
            for (rec in receptors.members) {
                rec.animation.finishCallback = (name:String) -> {
                    if (name == "confirm") rec.playAnim("static", true);
                }
            }
            unregisterInputs();
        } else {
            for (rec in receptors.members) {
                rec.animation.finishCallback = (name:String) -> {}
            }
            registerInputs();
        }
        return cpu = newCPU;
    }
}