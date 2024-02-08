package meta.substates;

import meta.states.PlayState;
import game.Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import game.*;
import game.objects.*;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	public function new(x:Float, y:Float)
	{
		super();

		if (PlayState.isStoryMode){
			if (PlayState.chartingMode){
				menuItems = ['Resume', 'Restart Song', 'End song', 'Exit Charting Mode', 'Options', 'Exit to menu'];
			} else{
				menuItems = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
			}
		} else{
			if (PlayState.chartingMode){
				menuItems = ['Resume', 'Restart Song', 'End song', 'Exit Charting Mode', 'Options', 'Exit to freeplay'];
			} else{
				menuItems = ['Resume', 'Restart Song', 'Options', 'Exit to freeplay'];
			}
		}

		
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		bg.scale.set(1/PlayState.camHUD.zoom, 1/PlayState.camHUD.zoom);
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += meta.states.PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += PlayState.difficultyName;
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var chartingText:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		chartingText.text = 'CHARTING MODE';
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font("vcr.ttf"), 32);
		chartingText.updateHitbox();
		add(chartingText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		chartingText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		chartingText.x = FlxG.width - (chartingText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(chartingText, {alpha: 1, y: chartingText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1});
		
		if (PlayState.chartingMode)
			chartingText.visible = true;
		else
			chartingText.visible = false;

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					GameOverSubstate.resetDeathStatus();
					FlxG.resetState();
				case "Options":
					for (item in grpMenuShit.members)
						{
							item.alpha = 0;
						}
					openSubState(new OptionsSubState());
				case 'Reload Script':
					PlayState.scripts.loadFiles();
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
				case 'End song':
					PlayState.instantEndSong = true;
					close();
				case 'Exit Charting Mode':
					PlayState.chartingMode = false;
					FlxG.resetState();
				case "Exit to menu", "Exit to freeplay":
					pauseMusic.stop();
					pauseMusic.destroy();
					FlxG.sound.music.stop();
					PlayState.chartingMode = false;
					FlxG.sound.music.onComplete = null;
					if (PlayState.isStoryMode){
						FlxG.switchState(new meta.states.MainMenuState());
					}
					else{
						FlxG.switchState(new meta.states.FreeplayState());
					}
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function closeSubState()
		{
			super.closeSubState();
			changeSelection();
		}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
