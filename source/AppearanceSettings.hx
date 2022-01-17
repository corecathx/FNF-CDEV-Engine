package;

import flixel.util.FlxTimer;
import openfl.Lib;
import Controls.Control;
import Controls.KeyboardScheme;
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

class AppearanceSettings extends MusicBeatSubstate
{
	var loaded:Bool = false;
	private var curSelected:Int = 0;

	var options:Array<String> = [
		'Show Performance Text', 
		'Smooth Motions', 
		'Show Opponent Notes',
		'Show Strum Lane',
		'Antialiasing',
		#if desktop 
		'Discord RPC',#end
		'Change Rating Position',
		'FNF Note Style'];
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
			if (FlxG.sound.music != null)
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

			if (notePreview != null)
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

				FlxG.sound.play(Paths.sound('cancelMenu', 'shared'));
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

		if (options[curSelected] == 'Change Rating Position')
			{
				for (item in grpOptions.members)
					{
						item.alpha = 0;
					}			
				versionSht.alpha = 0;	
			}

	}

	function createNote()
	{
		if (notePreview != null)
			remove(notePreview);

		var imgFrames = Paths.getSparrowAtlas('notes/' + (FlxG.save.data.fnfNotes ? 'NOTE_assets' : 'CDEVNOTE_assets'), 'shared');
		notePreview = new FlxSprite(1000, 0);
		notePreview.frames = imgFrames;
		notePreview.animation.addByPrefix('idle', 'arrowDOWN', 24, false);
		notePreview.animation.addByPrefix('bump', 'down confirm', 24, false);
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
			case 'Show Opponent Notes' | 'Hide Opponent Notes':
				FlxG.save.data.bgNote = !FlxG.save.data.bgNote;
			case 'Show Strum Lane' | 'Hide Strum Lane':
				FlxG.save.data.bgLane = !FlxG.save.data.bgLane;
			case 'Change Rating Position':
				openSubState(new RatingPosition(fromPause));
			case 'Discord RPC' | 'No Discord RPC':
				FlxG.save.data.discordRpc = !FlxG.save.data.discordRpc;
				Main.discordRPC = FlxG.save.data.discordRpc;

				FlxG.resetGame();
			case 'Smooth Motions' | 'Dont Smooth Motions':
				FlxG.save.data.smoothAF = !FlxG.save.data.smoothAF;
			case 'FNF Note Style' | 'CDEV Note Style':
				FlxG.save.data.fnfNotes = !FlxG.save.data.fnfNotes;
				createNote();
		}
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
					FlxG.save.data.smoothAF ? 'Smooth Motions' : 'Dont Smooth Motions',
					FlxG.save.data.bgLane ? 'Show Strum Lane' : 'Hide Strum Lane',
					FlxG.save.data.bgNote ? 'Show Opponent Notes' : 'Hide Opponent Notes',
					'Change Rating Position',
					FlxG.save.data.antialiasing ? 'Antialiasing' : 'No Antialiasing',
					#if desktop 
					FlxG.save.data.discordRpc ? 'Discord RPC' : 'No Discord RPC',#end
					FlxG.save.data.fnfNotes ? 'FNF Note Style' : 'CDEV Note Style'
				];
			} else{
				options = [
					FlxG.save.data.performTxt ? 'Show Performance Text' : 'Dont Show Performance Text',
					FlxG.save.data.smoothAF ? 'Smooth Motions' : 'Dont Smooth Motions',
					FlxG.save.data.bgLane ? 'Show Strum Lane' : 'Hide Strum Lane',
					FlxG.save.data.bgNote ? 'Show Opponent Notes' : 'Hide Opponent Notes',
					'Change Rating Position'
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
			case 'Smooth Motions' | 'Dont Smooth Motions':
				text = "Makes this engine smooth while doing transitions!\n(Disable this if you're sensitive to motions)";
			case 'Show Opponent Notes' | 'Hide Opponent Notes':
				text = "Show / Hide the opponent's note.\n(Requires 'Middlescroll' option to be turned on!)";
			case 'Show Strum Lane' | 'Hide Strum Lane':
				text = "If enabled, it will shows your strum lane.\n(Requires 'Middlescroll' option to be turned on!)";
			case 'Antialiasing' | 'No Antialiasing':
				text = "If disabled, the game graphics will not looking as smooth\nand increases performance";
			case 'Change Rating Position':
				text = "Change your rating sprite position.";
			case 'Discord RPC' | 'No Discord RPC':
				text = 'Enables / Disables Discord Rich Presence.\n(This option will restart your game.)';
			case 'FNF Note Style' | 'CDEV Note Style':
				text = "Choose your current Note Style.";
		}
		versionSht.alpha = 1;
		versionSht.text = text;
	}
}
