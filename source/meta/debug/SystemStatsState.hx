package meta.debug;

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

class SystemStatsState extends MusicBeatState
{
	var displayText:FlxText;

	override function create()
	{
		displayText = new FlxText(0,0,-1,"",14);
        displayText.font = FunkinFonts.CONSOLAS;
        displayText.color = 0xFFFFFFFF;
        displayText.alignment = CENTER;
        add(displayText);
		super.create();
	}

	var time:Float = 0;
	var lastCPU:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        time+=elapsed;
        if (time > 1) {
            lastCPU = Windows.getCurrentCPUUsage();
            time = 0;
        }
        displayText.text = "CPU Usage: " + FlxMath.roundDecimal(lastCPU,2) + "%"
        + "\n(native) Memory Usage: " + CDevConfig.utils.convert_size(Windows.getCurrentUsedMemory())
        + "\nFree disk space (cwd): " + FlxMath.roundDecimal(Windows.getCurrentDriveSize(),2) + "GB";
        displayText.screenCenter();

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new meta.states.MainMenuState());
		}
	}
}
