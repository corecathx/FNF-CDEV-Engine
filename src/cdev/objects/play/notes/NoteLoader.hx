package cdev.objects.play.notes;

import flixel.util.FlxSignal.FlxTypedSignal;
import cdev.backend.Chart;
import flixel.FlxBasic;

/**
 * An object that handles notes and events loading.
 */
class NoteLoader extends FlxBasic {
    /** Limits how much notes that could be spawned in a single frame. **/
    public var notesPerFrame:Int = 100;
    public var strums:Array<StrumLine> = [];
    public var chart:Chart;

    public var onEventSignal:FlxTypedSignal<ChartEvent -> Void>;

    public function new(strums:Array<StrumLine>, chart:Chart) {
        super();
        this.strums = strums;
        this.chart = chart;
        onEventSignal = new FlxTypedSignal<ChartEvent -> Void>(); 

        for (strum in strums) {
            for (note in strum.receptors) {
                note.speed = chart.info.speed;
            }
        }
    }

    var _currentNote:Int = 0;
    var _lastNoteData:Int = 0;
    var _lastNote:ChartNote = null;
    var _skippedNotes:Array<Int> = [];

    var _currentEvent:Int = 0;
    
    override function update(elapsed:Float) {
        var maxTimeDiff:Float = 1500 / FlxMath.roundDecimal(chart.info.speed, 2);
        FlxG.watch.addQuick("Skipped Notes", _skippedNotes);
        while (_currentNote < chart.notes.length)
        {
            var songNote:ChartNote = chart.notes[_currentNote];
            if (songNote == null) break;
    
            var timeDiff:Float = songNote.time - Conductor.current.time;
            if (songNote.data < 0) {
                _skippedNotes[songNote.strum]++;
                _currentNote++; break;
            }
            if (timeDiff > maxTimeDiff)
                break;
    
            // um
            if (timeDiff < 0) {
                _skippedNotes[songNote.strum]++;
                _currentNote++; continue;
            }
            // hi Sword
            if (_lastNote != null && _lastNote.time == songNote.time && _lastNote.data == songNote.data && _lastNote.strum == songNote.strum && Math.abs(songNote.time - _lastNote.time) > 0.25) {
                _skippedNotes[songNote.strum]++;
                _currentNote++; continue;
            }
    
            var parent:StrumLine = getStrum(songNote.strum);
    
            var note:Note = new Note(parent.getReceptor(songNote.data));
            note.init(songNote.time+Conductor.current.offset, songNote.data, songNote.length);
            parent.addNote(note);
    
            _currentNote++;
    
            _lastNote = songNote;
        }
        while (_currentEvent < chart.events.length) {
            var event:ChartEvent = chart.events[_currentEvent];
            if (Conductor.current.time < event.time) break;
            onEvent(event);
            _currentEvent++;
        }
        super.update(elapsed);
    }

    public function onEvent(event:ChartEvent) {
        onEventSignal.dispatch(event);
    }

    public function getStrum(index:Int):StrumLine return strums[index];
}