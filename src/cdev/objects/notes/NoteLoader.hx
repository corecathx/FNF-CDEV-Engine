package cdev.objects.notes;

import cdev.backend.Chart;
import flixel.FlxBasic;

class NoteLoader extends FlxBasic {
    /** Limits how much notes that could be spawned in a single frame. **/
    public var notesPerFrame:Int = 100;
    public var strums:Array<StrumLine> = [];
    public var chart:Chart;
    public function new(strums:Array<StrumLine>, chart:Chart) {
        super();
        this.strums = strums;
        this.chart = chart;

        for (strum in strums) {
            for (note in strum.receptors) {
                note.speed = chart.info.speed;
            }
        }
    }

    var _currentNote:Int = 0;
    var _lastNoteData:Int = 0;
	var _lastNote:Dynamic = null;
    override function update(elapsed:Float) {
        /** Better Note Spawning System**/
		var notesPerFrame:Int = 100;
		while (_currentNote < chart.notes.length && notesPerFrame > 0)
		{
			var songNotes:Dynamic = chart.notes[_currentNote];

			if (songNotes.data < 0) {
				_currentNote++;
				break;
			}

			if (songNotes.time - Conductor.current.time > 1500 / FlxMath.roundDecimal(chart.info.speed,2))
				break;

			// If the last note properties is the same as current note, skip this note.
			if (_lastNote != null && _lastNote.time == songNotes.time && _lastNote.data == songNotes.data && _lastNote.strum == songNotes.strum) {
				_currentNote++;
				break;
			}
            var parent:StrumLine = getStrum(songNotes.strum);

            var note:Note = new Note(parent.getReceptor(songNotes.data));
            note.init(songNotes.time, songNotes.data, songNotes.length);
            parent.addNote(note);

			_currentNote++;

			_lastNote = songNotes;
			notesPerFrame--;
		}
        super.update(elapsed);
    }

    public function getStrum(index:Int):StrumLine return strums[index];
}