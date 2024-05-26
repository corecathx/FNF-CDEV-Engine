package meta.debug;

import game.objects.Note;
import game.system.native.Windows;
import lime.ui.MouseCursor;
import flixel.addons.ui.FlxUIList;
import game.objects.HealthIcon;
import game.cdev.objects.CDevTooltip;
import openfl.text.TextFormat;
import flixel.addons.ui.FontDef;
import flixel.addons.ui.Anchor;
import flixel.addons.ui.FlxUITooltipManager;
import flixel.addons.ui.FlxUITooltip;

class SustainDebug extends MusicBeatState
{
	var displayText:FlxText;

    var notes:Array<Note> = [];
    var curSusLength:Float = 0;

	override function create()
	{
		displayText = new FlxText(0,0,-1,"",14);
        displayText.font = FunkinFonts.CONSOLAS;
        displayText.color = 0xFFFFFFFF;
        displayText.alignment = LEFT;
        add(displayText);
        curSusLength = Conductor.stepCrochet;
		super.create();
	}

    function regenNote() {    
        while (notes.length > 0) {
            for (i in notes){
                i.destroy();
                remove(i);
                notes.remove(i);
            }
        }
        var swagNote:Note = new Note(0, 1, null, false, false, "Default Note", ["",""]);
        swagNote.sustainLength = curSusLength;
        swagNote.scrollFactor.set(0, 0);

        var susLength:Float = swagNote.sustainLength;

        susLength = susLength / Conductor.stepCrochet;

        add(swagNote);
        var susFloor = Math.floor(susLength);
        if (susFloor > 0)
        {
            for (susNote in 0...susFloor)
            {
                var oldNote = swagNote;

                var sustainNote:Note = new Note(0 + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, 1, oldNote,
                    true, true, "Default Note", ["",""]);
                sustainNote.scrollFactor.set();
                add(sustainNote);
                sustainNote.mainNote = swagNote;
                sustainNote.mustPress = gottaHitNote;

                if (!PlayState.isPixel)
                {
                    if (oldNote.isSustainNote)
                    {
                        oldNote.scale.y *= 44 / oldNote.frameHeight;
                        oldNote.updateHitbox();
                    }
                }

                if (playingLeftSide)
                    sustainNote.mustPress = !gottaHitNote;

                if (sustainNote.mustPress)
                    sustainNote.x += FlxG.width / 2; // general offset
            }
        }
    }

	var time:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        displayText.text = "step: " + Conductor.stepCrochet;

		if (FlxG.keys.justPressed.SPACE){
			trace("wintoast bugged :(");
		}

        if (FlxG.mouse.wheel < 0 || FlxG.mouse.wheel > 0){
            curSusLength += (FlxG.mouse.wheel < 0 ? Conductor.stepCrochet : -Conductor.stepCrochet);
        }

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new meta.states.MainMenuState());
		}
	}
}