package meta.states;

import flixel.util.FlxSort;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.FlxInput.FlxInputState;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import game.objects.*;
import game.cdev.*;
import game.*;

class OffsetTest extends MusicBeatState
{
	var bg:FlxSprite;
	var offsetText:FlxText;

	var offs:Float = 0;
	var daOffset:String;
	var infoTxt:FlxText;

	var gfDance:FlxSprite;

	var canTestNow:Bool = false;

	override function create()
	{
		FlxG.sound.playMusic(Paths.music('offsetSong', 'shared'));
		FlxG.sound.music.onComplete = endShit;

		Conductor.changeBPM(100);
		Conductor.updateSettings();

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		bg.alpha = 0.2;
		add(bg);


		gfDance = new FlxSprite(0, 0);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'GF Dancing Beat blue', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'GF Dancing Beat blue', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = CDevConfig.saveData.antialiasing;
		gfDance.scale.set(0.7,0.7);
		gfDance.updateHitbox();
		gfDance.alpha = 0;
		CDevConfig.utils.objectScreenCenter(gfDance);
		add(gfDance);

		daOffset = 'Tap any keys to the beat!\nCurrent Offset: ' + offs + 'ms';

		offsetText = new FlxText(20, 800, FlxG.width, daOffset, 20);
		offsetText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		offsetText.screenCenter(X);
		add(offsetText);
		offsetText.borderSize = 2;

		var daInf:String = "Welcome to Offset Testing\n\nPress Any keys on your keyboard to the beep sound\nto set your global song offset!\n\nYour current song offset: "
			+ CDevConfig.saveData.offset
			+ 'ms';
		infoTxt = new FlxText(0, 0, FlxG.width, daInf, 28);
		infoTxt.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoTxt.screenCenter();
		infoTxt.alpha = 0;
		add(infoTxt);
		infoTxt.borderSize = 3;
		infoTxt.antialiasing = CDevConfig.saveData.antialiasing;
		FlxTween.tween(infoTxt, {alpha: 1}, 2, {ease: FlxEase.linear});
		super.create();
	}

	override function update(elapsed:Float)
	{
		bg.alpha = FlxMath.lerp(0.2, bg.alpha, CDevConfig.utils.bound(1 - (elapsed * 3), 0, 1));
		offsetText.scale.x = FlxMath.lerp(1, offsetText.scale.x, CDevConfig.utils.bound(1 - (elapsed * 10), 0, 1));
		offsetText.scale.y = FlxMath.lerp(1, offsetText.scale.x, CDevConfig.utils.bound(1 - (elapsed * 10), 0, 1));
		daOffset = 'Tap any keys to the beat!\nCurrent Offset: ' + offs + 'ms';
		offsetText.text = daOffset;

		FlxG.watch.addQuick('DABEATS', curBeat);
		Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.ENTER) endShit();
		if (canTestNow) keyShit();

		super.update(elapsed);
	}

	function endShit()
	{
		FlxG.sound.music.stop();
		FlxG.sound.music.onComplete = null;
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		FlxG.switchState(new OptionsState());
	}

	var danceLeft:Bool = false;
	private function keyShit():Void
	{
		var press:Bool = FlxG.keys.checkStatus(ANY, FlxInputState.JUST_PRESSED);

		if (press)
		{
			//better?
			offs = Math.abs(FlxG.sound.music.time - (Conductor.crochet*curBeat));
			dance();
			offsetText.scale.x = 1.2;
			var rating:FlxSprite = new FlxSprite();
			rating.loadGraphic(Paths.image("sick", "shared"));
			rating.screenCenter();
			rating.y -= 50;
			rating.x -= 255;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			add(rating);
			rating.setGraphicSize(Std.int(rating.width * 0.5));
			rating.antialiasing = CDevConfig.saveData.antialiasing;
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});
		}
	}

	function dance()
	{
		danceLeft = !danceLeft;

		if (danceLeft) 
			gfDance.animation.play('danceLeft', true); 
		else 
			gfDance.animation.play('danceRight', true); 

	}
	var hitVal:Array<Float> = [];

	function goodNoteHit(daNote:Note)
	{
		//var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);

		var msTime = RatingsCheck.fixFloat(noteDiff, 3);

		if (msTime >= 0.03)
		{
			hitVal.shift();
			hitVal.shift();
			hitVal.shift();
			hitVal.pop();
			hitVal.pop();
			hitVal.pop();
			hitVal.push(msTime);

			var valTotal = 0.0;

			for (e in hitVal)
				valTotal += e;
			
			offs = RatingsCheck.fixFloat(valTotal / hitVal.length, 2);
		}

		offsetText.scale.x = 1.2;
	}

	override function beatHit()
	{
		super.beatHit();
		if (CDevConfig.saveData.flashing)
			bg.alpha = 0.5;

		switch (curBeat)
		{
			case 8:
				infoTxt.text = "Let's begin the test.";
				infoTxt.screenCenter();
			case 10:
				FlxTween.tween(infoTxt, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.linear});
			case 13:
				dance();
				FlxTween.tween(gfDance, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.linear});
				var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ready', 'shared'));
				ready.scrollFactor.set();
				ready.updateHitbox();
				ready.screenCenter();
				add(ready);
				FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						ready.destroy();
					}
				});
			case 14:
				dance();
				var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('set', 'shared'));
				set.scrollFactor.set();

				set.screenCenter();
				add(set);
				FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						set.destroy();
					}
				});
			case 15:
				dance();
				var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('go', 'shared'));
				go.scrollFactor.set();
				go.updateHitbox();
				go.screenCenter();
				add(go);
				FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						go.destroy();
					}
				});
			case 16:
				canTestNow = true;
				FlxTween.tween(offsetText, {y: FlxG.height - 100}, Conductor.crochet / 1000, {ease: FlxEase.circOut});
			case 80:
				dance();
				canTestNow = false;
				FlxTween.tween(gfDance, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.linear});
				FlxTween.tween(offsetText, {y: 800}, Conductor.crochet / 1000, {ease: FlxEase.circOut});

				CDevConfig.saveData.offset = offs;
				infoTxt.text = "Offset Testing has ended!\n\nYour Global Offset has set to:\n" + offs + "ms.";
				infoTxt.screenCenter();
				FlxTween.tween(infoTxt, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.linear});
		}
	}
}
