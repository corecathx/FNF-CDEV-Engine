package meta.modding.event_editor;

import sys.io.File;
import game.Paths;
import flixel.util.FlxColor;
import lime.system.Clipboard;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIInputText;
import flixel.FlxSprite;
import flixel.FlxG;

class CreateEventScript extends meta.substates.MusicBeatSubstate
{
	var curSelected:Int = 0;
	var menuBG:FlxSprite;
	var box:FlxSprite;
	var exitButt:FlxSprite;

	public function new()
	{
		super();
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];

		FlxG.mouse.visible = true;

		menuBG = new FlxSprite().makeGraphic(FlxG.width,FlxG.height, FlxColor.BLACK);
		menuBG.screenCenter();
		menuBG.alpha = 0.7;

		add(menuBG);

		box = new FlxSprite().makeGraphic(800, 400, FlxColor.BLACK);
		box.alpha = 0.7;
		box.screenCenter();
		add(box);

		exitButt = new FlxSprite().makeGraphic(30, 20, FlxColor.RED);
		exitButt.alpha = 0.7;
		exitButt.x = ((box.x + box.width) - 30) - 10;
		exitButt.y = (box.y + 20) - 10;
		add(exitButt);

		createBoxUI();
	}

	var input_modName:FlxUIInputText;
	var butt_createMod:FlxSprite;
	var txtbcm:FlxText;

    var txtMn:FlxText;

	function createBoxUI()
	{
		var header:FlxText = new FlxText(box.x, box.y + 10, 800, "Create new Event Script", 40);
		header.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header);

		input_modName = new FlxUIInputText(box.x + 50, box.y + 100, 500, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_modName.font = "VCR OSD Mono";
		add(input_modName);
		txtMn = new FlxText(input_modName.x, input_modName.y - 25, 500, "Event Name", 20);
		txtMn.font = "VCR OSD Mono";
		add(txtMn);

		butt_createMod = new FlxSprite(865, 510).makeGraphic(150, 32, FlxColor.fromRGB(70, 70, 70));
		add(butt_createMod);
		txtbcm = new FlxText(870, 515, 140, "Create Event", 18);
		txtbcm.font = "VCR OSD Mono";
		txtbcm.alignment = CENTER;
		add(txtbcm);

		trace("x: " + txtbcm.x + " y: " + txtbcm.y);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

			if (input_modName.hasFocus)
			{
				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null)
				{
					input_modName.text = game.cdev.CDevConfig.utils.pasteFunction(input_modName.text);
					input_modName.caretIndex = input_modName.text.length;
				}

				if (FlxG.keys.justPressed.ENTER)
					input_modName.hasFocus = false;
			}

		if (input_modName.hasFocus)
		{
			txtMn.color = FlxColor.WHITE;
		}

		if (FlxG.mouse.overlaps(exitButt))
		{
			exitButt.alpha = 1;
			if (FlxG.mouse.justPressed)
				exitStateShit();
		}
		else
		{
			exitButt.alpha = 0.7;
		}

		if (FlxG.keys.justPressed.ESCAPE){
			exitStateShit();
		}

		if (FlxG.mouse.overlaps(butt_createMod))
		{
			butt_createMod.alpha = 1;
			txtbcm.alpha = 1;

			if (FlxG.mouse.justPressed)
			{
				if (input_modName.text != '')
				{
                    FlxG.sound.play(game.Paths.sound('confirmMenu'));

                    createHScript();

					close();
					EventScriptEditor.onSubstate = false;
				}
				else
				{
                    txtMn.color = FlxColor.RED;
					FlxG.sound.play(game.Paths.sound('cancelMenu'));
				}
			}
		}
		else
		{
			txtbcm.alpha = 0.7;
			butt_createMod.alpha = 0.7;
		}
	}

	function exitStateShit()
	{
		FlxG.save.flush();
        FlxG.sound.play(game.Paths.sound('cancelMenu'));
		EventScriptEditor.onSubstate = false;
		close();
		
	}
    
    function createHScript()
    {
        var data:String = 
'eventDescription = ""; // Write your event description here.

function onScriptCall(val1, val2)
{
	//val1 = Value 1 of the event.
	//val2 = Value 2 of the event.

	//put your script here
}';
    
        if (data.length > 0)
        {
			File.saveContent('cdev-mods/' + Paths.curModDir[0] + '/events/${input_modName.text}.hx' , data);
		}
    }
}
