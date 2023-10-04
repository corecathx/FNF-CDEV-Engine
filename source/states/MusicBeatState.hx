package states;

import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.BaseScaleMode;
import openfl.display.StageScaleMode;
import lime.app.Application;
import openfl.display.Window;
import game.Conductor;
import openfl.Lib;
import flixel.FlxSprite;
import game.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = -1;
	private var curBeat:Int = -1;
	public var controls(get, never):game.Controls;

	// my attempt of preventing repeating beats
	var hitBeats:Int = 0;
	var hitSteps:Int = 0;

	inline function get_controls():game.Controls
		return engineutils.PlayerSettings.player1.controls;

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function onResize(width:Int, height:Int)
	{
		super.onResize(width, height);
		FlxG.resizeGame(Application.current.window.width, Application.current.window.height);
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

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		hitBeats = Math.floor(curStep / 4);
		if (hitBeats > curBeat)
		{
			curBeat = hitBeats;
		}
	}

	private function updateCurStep():Void
	{
		/*if (FlxG.state == PlayState.current){
			var lastChange:BPMChangeEvent = {
				stepTime: 0,
				songTime: 0,
				bpm: 0
			}
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (Conductor.rawTime >= Conductor.bpmChangeMap[i].songTime)
					lastChange = Conductor.bpmChangeMap[i];
			}

			curStep = lastChange.stepTime + Math.floor((Conductor.rawTime - lastChange.songTime) / Conductor.stepCrochet); */

		// } else{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}
		hitSteps = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
		if (hitSteps > curStep)
		{
			curStep = hitSteps;
		}
		// }
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
