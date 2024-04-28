package meta.states;

import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
import game.Conductor;
import game.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = -1;
	private var curBeat:Int = -1;
	public var controls(get, never):game.Controls;

	public var curMouse(default, set):MouseCursor;

	// my attempt of preventing repeating beats
	var _highestPassedBeats:Int = -1;
	var passedBeats:Array<Int> = [];
	var _highestPassedSteps:Int = -1;
	var passedSteps:Array<Int> = [];
	var syncingSensitivity:Int = 2;

	inline function get_controls():game.Controls
		return game.cdev.engineutils.PlayerSettings.player1.controls;
	
	inline function set_curMouse(val:MouseCursor):MouseCursor {
		return Mouse.cursor = val;
	}

	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if (FlxG.keys.justPressed.F11)
			FlxG.fullscreen = !FlxG.fullscreen;

		//this is awfully ass
		if (Math.abs(curStep - _highestPassedSteps) >= syncingSensitivity){
			if (CDevConfig.saveData.testMode) GameLog.warn("Game desynced! Trying to sync the _highestPassedSteps with curStep...");
			_highestPassedSteps = curStep;
			passedSteps = [];
			for (i in 0..._highestPassedSteps){
				passedSteps[i] = i;
			}
			if (CDevConfig.saveData.testMode) GameLog.warn("Game synced, current values: "  + curStep + " // " + _highestPassedSteps +".");
		}

		Conductor.curBeat = this.curBeat;
		Conductor.curStep = this.curStep;
		super.update(elapsed);
	}

	override function onFocus() {
		super.onFocus();
		CDevConfig.setFPS(CDevConfig.saveData.fpscap);
	}

	private function updateBeat():Void
	{
		curBeat = Std.int(curStep / 4);
	}

	function getLargerInt(array:Array<Int>):Int {
		var get:Int = -1000;
		for (i in array){
			if (i > get){
				get = i;
			}
		}
		return get;
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition + Conductor.offset >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}
		var newSteps:Int = lastChange.stepTime + Std.int(((Conductor.songPosition + Conductor.offset) - lastChange.songTime) / Conductor.stepCrochet);
		if (!passedSteps.contains(newSteps)){
			curStep = newSteps;
			passedSteps.push(newSteps);
			_highestPassedSteps = getLargerInt(passedSteps);
		}
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
