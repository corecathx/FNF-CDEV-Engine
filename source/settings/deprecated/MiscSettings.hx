package settings;

import flixel.util.FlxTimer;
import openfl.Lib;
import game.Controls.Control;
import game.Controls.KeyboardScheme;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import game.*;

class MiscSettings extends substates.MusicBeatSubstate
{
	var loaded:Bool = false;
	private var curSelected:Int = 0;

	var options:Array<String> = [
		'FPS Counter',
		'Antialiasing',
		'Camera Start Focus',
		'Trace Log',
		#if desktop
		'Discord RPC',
		#end
		'Note Ripples',
		'FNF Note Style',
		'Check For Updates',
		'Autosave Chart File',
		'Clear Cache'
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var allowToPress:Bool = false;
	var notePreview:FlxSprite;

	private var versionSht:FlxText;

	var fromPause:Bool = false;

	public function new(fromPause:Bool = false)
	{
		super();
		if (!loaded)
		{
			this.fromPause = fromPause;
			// quick checking
			updateOptions();

			grpOptions = new FlxTypedGroup<Alphabet>();
			add(grpOptions);

			for (i in 0...options.length)
			{
				var optionText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true);
				// optionText.screenCenter();
				optionText.isMenuItem = true;
				optionText.isOptionItem = true;
				optionText.targetY = i;
				// optionText.ID = i;
				// optionText.y += (100 * (i - (options.length / 2))) + 50;
				grpOptions.add(optionText);
			}

			versionSht = new FlxText(20, FlxG.height - 100, 1000, '', 24);
			versionSht.scrollFactor.set();
			versionSht.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			versionSht.screenCenter(X);
			add(versionSht);
			versionSht.borderSize = 2;
			changeSelection();
			new FlxTimer().start(0.2, function(bruh:FlxTimer)
			{
				allowToPress = true;
			});

			if (fromPause)
				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		}

		if (!loaded)
		{
			loaded = true;
		}
	}

	override function update(elapsed:Float)
	{
		if (loaded)
		{
			if (FlxG.sound.music != null && !fromPause)
			{
				Conductor.songPosition = FlxG.sound.music.time;
			}
			if (controls.UP_P)
			{
				changeSelection(-1);
			}
			if (controls.DOWN_P)
			{
				changeSelection(1);
			}

			if (allowToPress)
			{
				if (controls.ACCEPT)
					pressSelection();

				if (FlxG.keys.justPressed.SHIFT){
					if (options[curSelected] == 'Autosave Chart File')
					{
						openSubState(new settings.misc.AutosaveSettings());
					}
				}
			}

			if (notePreview != null && !fromPause)
			{
				if (notePreview.animation.curAnim.name == 'bump' && notePreview.animation.finished)
				{
					notePreview.animation.play('idle');
					notePreview.centerOffsets();
				}
			}

			if (controls.BACK)
			{
				loaded = false;
				grpOptions.clear();
				versionSht.kill();
				for (memes in 0...options.length)
					options.remove(options[memes]);

				// FlxG.sound.play(Paths.sound('cancelMenu', 'shared'));
				close();
			}

			super.update(elapsed);
		}
	}

	function pressSelection()
	{
		// FlxG.save.flush();
		FlxG.sound.play(Paths.sound('confirmMenu'));

		saveOptions();
		updateOptions();

		grpOptions.remove(grpOptions.members[curSelected]);

		var optionText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, options[curSelected], true);
		optionText.isMenuItem = true;
		optionText.isOptionItem = true;
		// optionText.ID = curSelected;
		grpOptions.add(optionText);

		changeSelection();
		grpOptions.forEach(function(spr:FlxSprite)
		{
			if (curSelected == spr.ID)
			{
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					spr.alpha = 1;
					spr.visible = true;
				});
			}
		});
	}

	function createNote()
	{
		if (notePreview != null)
			remove(notePreview);

		var animations:Array<String> = (CDevConfig.saveData.fnfNotes ? ['arrowDOWN', 'down confirm'] : ['arrowDOWN-static', 'arrowDOWN-confirm']);
		var imgFrames = Paths.getSparrowAtlas('notes/' + (CDevConfig.saveData.fnfNotes ? 'NOTE_assets' : 'CDEVNOTE_assets'), 'shared');
		notePreview = new FlxSprite(1000, 0);
		notePreview.frames = imgFrames;
		notePreview.animation.addByPrefix('idle', animations[0], 24, false);
		notePreview.animation.addByPrefix('bump', animations[1], 24, false);
		notePreview.antialiasing = CDevConfig.saveData.antialiasing;
		notePreview.screenCenter(Y);
		add(notePreview);

		notePreview.animation.play('idle', true);
	}

	function saveOptions()
	{
		switch (options[curSelected])
		{
			case 'Only FPS' | 'FPS and Memory' | "Only Memory" | "Hide Performance Text":
				var things:Array<String> = ["fps", "fps-mem", "mem", "hide"];
				var curIndex:Int = 0;

				trace("before: " + CDevConfig.saveData.performTxt);
				for (i in things){
					trace("data: " + i);
					if (CDevConfig.saveData.performTxt == i){
						curIndex = things.indexOf(i);
						trace("it similiar: " + i);
						break;
					}
				}

				curIndex += 1;
				if (curIndex >= things.length)
					curIndex = 0;
				CDevConfig.saveData.performTxt = things[curIndex];
				trace("after: " + CDevConfig.saveData.performTxt);

				Main.fps_mem.visible = (CDevConfig.saveData.performTxt=="hide" ? false : true);
			case 'Antialiasing' | 'No Antialiasing':
				CDevConfig.saveData.antialiasing = !CDevConfig.saveData.antialiasing;
			case 'Camera Start Focus':
				CDevConfig.saveData.cameraStartFocus += 1;
				doCheck();
			case 'Trace Log':
				CDevConfig.saveData.showTraceLogAt += 1;
				doCheck();
			case 'Note Ripples' | 'Note Splashes':
				CDevConfig.saveData.noteRipples = !CDevConfig.saveData.noteRipples;
			case 'Discord RPC' | 'No Discord RPC':
				CDevConfig.saveData.discordRpc = !CDevConfig.saveData.discordRpc;
				Main.discordRPC = CDevConfig.saveData.discordRpc;
				FlxG.resetGame();
			case 'FNF Note Style' | 'CDEV Note Style':
				CDevConfig.saveData.fnfNotes = !CDevConfig.saveData.fnfNotes;
				createNote();
			case 'Check For Updates' | 'Don\'t check for updates':
				CDevConfig.saveData.checkNewVersion = !CDevConfig.saveData.checkNewVersion;
			case 'Autosave Chart File' | "No Autosave Chart File":
				CDevConfig.saveData.autosaveChart = !CDevConfig.saveData.autosaveChart;
			case 'Clear Cache':
				openfl.utils.Assets.cache.clear();
				Paths.destroyLoadedImages();
		}
	}

	function doCheck()
	{
		if (CDevConfig.saveData.cameraStartFocus < 0)
			CDevConfig.saveData.cameraStartFocus = 2;
		if (CDevConfig.saveData.cameraStartFocus > 2)
			CDevConfig.saveData.cameraStartFocus = 0;

		if (CDevConfig.saveData.showTraceLogAt < 0)
			CDevConfig.saveData.showTraceLogAt = 2;
		if (CDevConfig.saveData.showTraceLogAt >= 2)
			CDevConfig.saveData.showTraceLogAt = 0;
	}

	override function closeSubState()
	{
		super.closeSubState();
		changeSelection();
	}

	function changeSelection(change:Int = 0)
	{
		var bullShit:Int = 0;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length;
		if (curSelected >= options.length)
			curSelected = 0;

		changeText();

		if (options[curSelected] == (CDevConfig.saveData.fnfNotes ? 'FNF Note Style' : 'CDEV Note Style'))
		{
			createNote();
		}
		else
		{
			remove(notePreview);
		}

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if (notePreview != null)
		{
			notePreview.animation.play('bump', true);
			notePreview.centerOffsets();
		}
	}

	function updateOptions()
	{
		var thingies:Array<String> = ["fps", "fps-mem", "mem", "hide"];
		var things:Array<String> = ["Only FPS", "FPS and Memory", "Only Memory", "Hide Performance Text"];
		var curIndex:Int = 0;
		for (i in thingies){
			if (CDevConfig.saveData.performTxt == i){
				curIndex = thingies.indexOf(i);
			}
		}

		trace(CDevConfig.saveData.performTxt);

		if (!fromPause)
		{
			options = [
				things[curIndex],
				#if desktop
				CDevConfig.saveData.discordRpc ? 'Discord RPC' : 'No Discord RPC',
				#end
				'Camera Start Focus',
				'Trace Log',
				CDevConfig.saveData.noteRipples ? 'Note Ripples' : 'Note Splashes',
				CDevConfig.saveData.fnfNotes ? 'FNF Note Style' : 'CDEV Note Style',
				CDevConfig.saveData.checkNewVersion ? 'Check For Updates' : 'Don\'t check for updates',
				CDevConfig.saveData.autosaveChart ? 'Autosave Chart File' : "No Autosave Chart File",
				'Clear Cache'
			];
		}
		else
		{
			options = [
				things[curIndex],
				CDevConfig.saveData.checkNewVersion ? 'Check For Updates' : 'Don\'t check for updates',
			];
		}
	}

	function changeText()
	{
		var text:String = '';
		switch (options[curSelected])
		{
			case 'Only FPS' | 'FPS and Memory' | "Only Memory" | "Hide Performance Text":
				text = "If enabled, it will show this engine's performance\non top left corner as a text";
			case 'Antialiasing' | 'No Antialiasing':
				text = "If disabled, the game graphics will not looking as smooth\nand increases performance";

			case 'Camera Start Focus':
				var t:String = '';
				switch (CDevConfig.saveData.cameraStartFocus)
				{
					case 0:
						t = 'Opponent';
					case 1:
						t = 'Girlfriend';
					case 2:
						t = 'Player';
				}
				text = 'Set your starting camera position when you playing a song.\nCurrently focusing at $t';
			case 'Trace Log':
				var t:String = '';
				// I'M SORRY FOR THIS
				switch (CDevConfig.saveData.showTraceLogAt)
				{
					case 0:
						t = 'hiding the trace log';
					case 1:
						t = 'showing the trace log';
				}
				text = 'Whether to show / hide the Trace Log.\nCurrently $t';
			case 'Discord RPC' | 'No Discord RPC':
				text = 'Enables / Disables Discord Rich Presence.\n(Select this option will restart your game.)';
			case 'Note Ripples' | 'Note Splashes':
				text = 'Choose your preferred Note Impacts';
			case 'FNF Note Style' | 'CDEV Note Style':
				text = "Choose your current Note Style.";
			case 'Check For Updates' | 'Don\'t check for updates':
				text = 'Whether to check for a new updates for this engine on game boot.';
			case 'Autosave Chart File' | "No Autosave Chart File":
				text = "Whether to create an autosave chart file on your song chart folder.\n(Press shift for more options)";
				if (options[curSelected] == "No Autosave Chart File")
					text = "Whether to create an autosave chart file on your song chart folder.";
				case 'Clear Cache':
				text = 'Select this option to clear the game cache.';
		}
		versionSht.alpha = 1;
		versionSht.text = text;
	}
}
