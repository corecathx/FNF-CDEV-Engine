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
		'Show Performance Text',
		'Antialiasing',
		'Camera Start Focus',
		'Trace Log',
		#if desktop 
		'Discord RPC',#end
		'Note Ripples',
		'FNF Note Style',
		'Check For Updates',
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
				var optionText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
				// optionText.screenCenter();
				optionText.isMenuItem = true;
				optionText.isOptionItem = true;
				optionText.targetY = i;
				//optionText.ID = i;
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

				//FlxG.sound.play(Paths.sound('cancelMenu', 'shared'));
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

		var optionText:Alphabet = new Alphabet(0, (70 * curSelected) + 30, options[curSelected], true, false);
		optionText.isMenuItem = true;
		optionText.isOptionItem = true;
		//optionText.ID = curSelected;
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

		var animations:Array<String> = (FlxG.save.data.fnfNotes ? ['arrowDOWN', 'down confirm'] : ['arrowDOWN-static', 'arrowDOWN-confirm']);
		var imgFrames = Paths.getSparrowAtlas('notes/' + (FlxG.save.data.fnfNotes ? 'NOTE_assets' : 'CDEVNOTE_assets'), 'shared');
		notePreview = new FlxSprite(1000, 0);
		notePreview.frames = imgFrames;
		notePreview.animation.addByPrefix('idle', animations[0], 24, false);
		notePreview.animation.addByPrefix('bump', animations[1], 24, false);
		notePreview.antialiasing = FlxG.save.data.antialiasing;
		notePreview.screenCenter(Y);
		add(notePreview);

		notePreview.animation.play('idle', true);
	}

	function saveOptions()
	{
		switch (options[curSelected])
		{
			case 'Show Performance Text' | 'Dont Show Performance Text':
				FlxG.save.data.performTxt = !FlxG.save.data.performTxt;
				Main.fps_mem.visible = FlxG.save.data.performTxt;
			case 'Antialiasing' | 'No Antialiasing':
				FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
			case 'Camera Start Focus':
				FlxG.save.data.cameraStartFocus += 1;
				doCheck();
			case 'Trace Log':
				FlxG.save.data.showTraceLogAt += 1;
				doCheck();
			case 'Note Ripples' | 'Note Splashes':
				FlxG.save.data.noteRipples = !FlxG.save.data.noteRipples;
			case 'Discord RPC' | 'No Discord RPC':
				FlxG.save.data.discordRpc = !FlxG.save.data.discordRpc;
				Main.discordRPC = FlxG.save.data.discordRpc;
				FlxG.resetGame();
			case 'FNF Note Style' | 'CDEV Note Style':
				FlxG.save.data.fnfNotes = !FlxG.save.data.fnfNotes;
				createNote();
			case 'Check For Updates' | 'Don\'t check for updates':
				FlxG.save.data.checkNewVersion = !FlxG.save.data.checkNewVersion;
			case 'Clear Cache':
				openfl.utils.Assets.cache.clear();
				Paths.destroyLoadedImages();
		}
	}

	function doCheck(){
		
		if (FlxG.save.data.cameraStartFocus < 0)
			FlxG.save.data.cameraStartFocus = 2;
		if (FlxG.save.data.cameraStartFocus > 2)
			FlxG.save.data.cameraStartFocus = 0;

		if (FlxG.save.data.showTraceLogAt < 0)
			FlxG.save.data.showTraceLogAt = 2;
		if (FlxG.save.data.showTraceLogAt >= 2)
			FlxG.save.data.showTraceLogAt = 0;
		
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

		if (options[curSelected] == (FlxG.save.data.fnfNotes ? 'FNF Note Style' : 'CDEV Note Style'))
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
		if (!fromPause)
			{
				options = [
					FlxG.save.data.performTxt ? 'Show Performance Text' : 'Dont Show Performance Text',
					#if desktop 
					FlxG.save.data.discordRpc ? 'Discord RPC' : 'No Discord RPC',#end
					'Camera Start Focus',
					'Trace Log',
					FlxG.save.data.noteRipples ? 'Note Ripples' : 'Note Splashes',
 					FlxG.save.data.fnfNotes ? 'FNF Note Style' : 'CDEV Note Style',
					FlxG.save.data.checkNewVersion ? 'Check For Updates' : 'Don\'t check for updates',
					'Clear Cache'
				];
			} else{
				options = [
					FlxG.save.data.performTxt ? 'Show Performance Text' : 'Dont Show Performance Text',
					FlxG.save.data.checkNewVersion ? 'Check For Updates' : 'Don\'t check for updates',
				];
			}

	}

	function changeText()
	{
		var text:String = '';
		switch (options[curSelected])
		{
			case 'Show Performance Text' | 'Dont Show Performance Text':
				text = "If enabled, it will show this engine's performance\non top left corner as a text";
			case 'Antialiasing' | 'No Antialiasing':
				text = "If disabled, the game graphics will not looking as smooth\nand increases performance";
			
			case 'Camera Start Focus':
				var t:String = '';
				switch (FlxG.save.data.cameraStartFocus){
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
				//I'M SORRY FOR THIS
				switch (FlxG.save.data.showTraceLogAt){
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
				text = 'Whether to check for a new updates for this engine on game boot';
			case 'Clear Cache':
				text = 'Select this option to clear the game cache.';
		}
		versionSht.alpha = 1;
		versionSht.text = text;
	}
}
