package states;

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
import game.*;
import cdev.*;

class OffsetTest extends MusicBeatState
{
	var bg:FlxSprite;
	var offsetText:FlxText;
	var noteGrp:FlxTypedGroup<Note>;
	var strumLine:FlxSprite;

	var offs:Float = 0;
	var daOffset:String;
	var infoTxt:FlxText;

	override function create()
	{
		FlxG.sound.playMusic(Paths.music('offsetSong', 'shared'));
		FlxG.sound.music.onComplete = endShit;

		Conductor.changeBPM(100);
		Conductor.updateSettings();

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.screenCenter();
		bg.alpha = 0.5;
		add(bg);

		var tex = Paths.getSparrowAtlas('notes/NOTE_assets', 'shared');
		strumLine = new FlxSprite(FlxG.width / 2, 100);
		strumLine.frames = tex;
		strumLine.animation.addByPrefix('static', 'arrowDOWN', 24, false);
		strumLine.animation.addByPrefix('pressed', 'down press', 24, false);
		strumLine.animation.addByPrefix('confirm', 'down confirm', 24, false);
		strumLine.screenCenter(X);
		strumLine.setGraphicSize(Std.int(strumLine.width * 0.7));
		strumLine.antialiasing = FlxG.save.data.antialiasing;
		strumLine.alpha = 0;
		add(strumLine);

		noteGrp = new FlxTypedGroup<Note>();
		add(noteGrp);

		for (i in 0...64)
		{
			var note:Note = new Note((Conductor.crochet * i), 1);
			note.canBeHit = true;
			note.mustPress = true;
			note.wasGoodHit = false;
			note.isTesting = true;

			note.strumTime += Conductor.crochet * 16;
			noteGrp.add(note);
		}

		daOffset = 'Tap any keys to the beat!\nCurrent Offset: ' + offs + 'ms';

		offsetText = new FlxText(20, 800, FlxG.width, daOffset, 20);
		offsetText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		offsetText.screenCenter(X);
		add(offsetText);
		offsetText.borderSize = 2;

		var daInf:String = "Welcome to Offset Testing\n\nPress Any keys on your keyboard to the beat\nof the song to set your global song offset!\n\nYour current song offset: "
			+ FlxG.save.data.offset
			+ 'ms';
		infoTxt = new FlxText(0, 0, FlxG.width, daInf, 28);
		infoTxt.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoTxt.screenCenter();
		infoTxt.alpha = 0;
		add(infoTxt);
		infoTxt.borderSize = 3;
		infoTxt.antialiasing = FlxG.save.data.antialiasing;
		FlxTween.tween(infoTxt, {alpha: 1}, 2, {ease: FlxEase.linear});
		super.create();
	}

	override function update(elapsed:Float)
	{
		bg.alpha = FlxMath.lerp(0.4, bg.alpha, CDevConfig.utils.bound(1 - (elapsed * 3), 0, 1));
		offsetText.scale.x = FlxMath.lerp(1, offsetText.scale.x, CDevConfig.utils.bound(1 - (elapsed * 10), 0, 1));
		daOffset = 'Tap any keys to the beat!\nCurrent Offset: ' + offs + 'ms';
		offsetText.text = daOffset;

		FlxG.watch.addQuick('DABEATS', curBeat);
		Conductor.songPosition = FlxG.sound.music.time;

		noteGrp.forEachAlive(function(daNote:Note)
		{
			daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * 0.45);
			daNote.x = strumLine.x + 30;
		});

		keyShit();
		noteUpdate();

		super.update(elapsed);
	}

	function endShit()
	{
		FlxG.sound.music.stop();
		FlxG.sound.music.onComplete = null;
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		FlxG.switchState(new OptionsState());
	}

	private function keyShit():Void
	{
		var possibleNotes:Array<Note> = [];
		var directions:Array<Int> = [];
		var press:Bool = FlxG.keys.checkStatus(ANY, FlxInputState.JUST_PRESSED);

		if (press)
		{
			noteGrp.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && !daNote.wasGoodHit)
				{
					if (directions.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directions.push(daNote.noteData);
					}
				}
			});

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var stopNote = false;

			if (press && !directions.contains(1))
				stopNote = true;
			else if (possibleNotes.length > 0 && !stopNote)
			{
				for (coolNote in possibleNotes)
				{
					if (press)
					{
						goodNoteHit(coolNote);
						coolNote.kill();
						noteGrp.remove(coolNote, true);
						coolNote.destroy();
					}
				}
			}
		}

		if (press && strumLine.animation.curAnim.name != 'confirm')
			strumLine.animation.play('pressed');
		if (!FlxG.keys.checkStatus(ANY, FlxInputState.PRESSED))
			strumLine.animation.play('static');

		if (strumLine.animation.curAnim.name == 'confirm')
		{
			strumLine.centerOffsets();
			strumLine.offset.x -= 13;
			strumLine.offset.y -= 13;
		}
		else
			strumLine.centerOffsets();
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

		strumLine.animation.play('confirm', true);
		offsetText.scale.x = 1.2;
	}

	override function beatHit()
	{
		super.beatHit();
		noteGrp.sort(FlxSort.byY, FlxSort.DESCENDING);
		if (FlxG.save.data.flashing)
			bg.alpha = 0.7;

		switch (curBeat)
		{
			case 10:
				FlxTween.tween(infoTxt, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.linear});
			case 13:
				FlxTween.tween(strumLine, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.linear});
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
				FlxTween.tween(offsetText, {y: FlxG.height - 100}, Conductor.crochet / 1000, {ease: FlxEase.circOut});
			case 80:
				FlxTween.tween(strumLine, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.linear});
				FlxTween.tween(offsetText, {y: 800}, Conductor.crochet / 1000, {ease: FlxEase.circOut});

				FlxG.save.data.offset = offs;
				infoTxt.text = "Offset Testing has ended!\n\nYour Global Offset has set to:\n" + offs + "ms.";
				infoTxt.screenCenter();
				FlxTween.tween(infoTxt, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.linear});
		}
	}

	function noteUpdate()
	{
		noteGrp.forEachAlive(function(daNoet:Note)
		{
			if (daNoet.mustPress)
			{
				if (daNoet.strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& daNoet.strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.7))
					daNoet.canBeHit = true;
				else
					daNoet.canBeHit = false;

				if (daNoet.strumTime < (Conductor.songPosition - 176))
					daNoet.tooLate = true;
			}

			if (daNoet.tooLate)
			{
				daNoet.kill();
			}
		});
	}
}
