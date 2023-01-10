package substates;

import game.Paths;
import flixel.system.FlxSound;
import states.PlayState;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:game.Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var week7GmOvSnd:FlxSound;

	public static var deathCharacter:String = "bf";
	public static var disableFlipX:Bool = false; //false= flipX, true= no flipX

	public static var songBpm:Float = 100;

	public function new(x:Float, y:Float)
	{
		var daStage = states.PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school', 'schoolEvil':
				stageSuffix = '-pixel';
		}
		switch (PlayState.boyfriend.curCharacter){
			case 'bf-pixel':
				daBf = 'bf-pixel-dead';
			case 'bf-holding-gf':
				daBf = 'bf-holding-gf-dead';
			default:
				daBf = deathCharacter;
		}
		super();

		game.Conductor.songPosition = 0;

		bf = new game.Boyfriend(x, y, daBf);
		if (disableFlipX) bf.flipX = false;
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(game.Paths.sound('fnf_loss_sfx' + stageSuffix, "shared"));
		game.Conductor.changeBPM(songBpm);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim("firstDeath");
		if (PlayState.boyfriend.curCharacter == 'bf-holding-gf' && daStage == 'tank'){
			week7GmOvSnd = FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-'+FlxG.random.int(1,25),'week7'));
			week7GmOvSnd.pause();
			isWeek7 = true;
		}
	}
	var isWeek7:Bool = false;
	var played:Bool = false;
	var changed:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.camera.zoom = FlxMath.lerp(states.PlayState.defaultCamZoom, FlxG.camera.zoom, cdev.CDevConfig.utils.bound(1 - (elapsed * 6), 0, 1));

		if (controls.ACCEPT)
			endBullshit();

		FlxG.camera.angle = Math.sin((game.Conductor.songPosition / 1000) * (game.Conductor.bpm / 60) * -1.0) * 2;

		if (controls.BACK){
			FlxG.sound.music.stop();

			if (states.PlayState.isStoryMode)
				FlxG.switchState(new states.StoryMenuState());
			else
				FlxG.switchState(new states.FreeplayState());
		}

		if (bf.animation.curAnim.name == "firstDeath" && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim.name == "firstDeath" && bf.animation.curAnim.finished){
			FlxG.sound.playMusic(game.Paths.music('gameOver' + stageSuffix, "shared"));
		}
			
		if (FlxG.sound.music.playing && !changed && isWeek7)
		{
			if (!week7GmOvSnd.playing){
				week7GmOvSnd.play();
				played = true;
			}

			if (week7GmOvSnd.playing){
				FlxG.sound.music.fadeOut(0.5, 0.2);
			}
			if (!week7GmOvSnd.playing && played) {
				FlxG.sound.music.fadeIn(0.5,0.3,1);
				changed = true;
			}
		}

		if (FlxG.sound.music.playing)
			game.Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();
		bf.playAnim("deathLoop", true);
		FlxG.camera.zoom += 0.030;

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim("deathConfirm", true);
			GameOverSubstate.resetDeathStatus();
			FlxG.sound.music.stop();
			FlxG.sound.play(game.Paths.music('gameOverEnd' + stageSuffix, "shared"));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					states.LoadingState.loadAndSwitchState(new states.PlayState());
				});
			});
		}
	}

	public static function resetDeathStatus()
	{
		deathCharacter = "bf";
		disableFlipX = false; //false= flipX, true= no flipX
		songBpm = 100;
	
	}
}
