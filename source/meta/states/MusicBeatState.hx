package meta.states;

import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
import game.Conductor;
import game.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState {
    private var lastBeat:Float = 0;
    private var lastStep:Float = 0;

    private var curStep:Int = -1;
    private var curBeat:Int = -1;
    public var controls(get, never):game.Controls;

    public var curMouse(default, set):MouseCursor;

    // Variables for tracking steps and beats
    var _highestPassedSteps:Int = -1;
    var passedSteps:Array<Int> = [];
    var syncingSensitivity:Int = 2;

    inline function get_controls():game.Controls
        return game.cdev.engineutils.PlayerSettings.player1.controls;


    inline function set_curMouse(val:MouseCursor):MouseCursor return Mouse.cursor = val;

    override function create() {
        super.create();
    }

    override function update(elapsed:Float) {
        var oldStep:Int = curStep;

        updateCurStep();
        updateBeat();

        if (oldStep != curStep && curStep > 0) stepHit();

        if (FlxG.keys.justPressed.F11) FlxG.fullscreen = !FlxG.fullscreen;

        handleDesync();

        Conductor.curBeat = this.curBeat;
        Conductor.curStep = this.curStep;
        super.update(elapsed);
    }

    override function onFocus() {
        super.onFocus();
        CDevConfig.setFPS(CDevConfig.saveData.fpscap);
    }

    private function updateBeat():Void {
        curBeat = Std.int(curStep / 4);
    }

    private function updateCurStep():Void {
        var lastChange:BPMChangeEvent = getLastBPMChangeEvent();
        var newSteps:Int = lastChange.stepTime + Std.int(((Conductor.songPosition - Conductor.offset) - lastChange.songTime) / Conductor.stepCrochet);
        
        if (!passedSteps.contains(newSteps)) {
            curStep = newSteps;
            passedSteps.push(newSteps);
            _highestPassedSteps = Std.int(Math.max(_highestPassedSteps, newSteps));
        }
    }

    private function getLastBPMChangeEvent():BPMChangeEvent {
        var lastChange:BPMChangeEvent = { stepTime: 0, songTime: 0, bpm: 0 };
        for (change in Conductor.bpmChangeMap) {
            if (Conductor.songPosition + Conductor.offset >= change.songTime) {
                lastChange = change;
            } else {
                break;
            }
        }
        return lastChange;
    }

    private function handleDesync():Void {
        if (Math.abs(curStep - _highestPassedSteps) >= syncingSensitivity) {
            if (CDevConfig.saveData.testMode) {
                Log.warn("Game desynced! Trying to sync the _highestPassedSteps with curStep...");
            }
            _highestPassedSteps = curStep;
            passedSteps = [];
            for (i in 0..._highestPassedSteps) {
                passedSteps.push(i);
            }
            if (CDevConfig.saveData.testMode) {
                Log.warn("Game synced, current values: " + curStep + " // " + _highestPassedSteps + ".");
            }
        }
    }

    public function stepHit():Void {
        if (curStep % 4 == 0) {
            beatHit();
        }
    }

    public function beatHit():Void {
        // do literally nothing dumbass
    }
}
