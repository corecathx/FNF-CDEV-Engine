package meta.debug;

import lime.ui.MouseCursor;
import flixel.addons.ui.FlxUIList;
import game.objects.HealthIcon;
import game.cdev.objects.CDevTooltip;
import openfl.text.TextFormat;
import flixel.addons.ui.FontDef;
import flixel.addons.ui.Anchor;
import flixel.addons.ui.FlxUITooltipManager;
import flixel.addons.ui.FlxUITooltip;

class UIDebugState extends MusicBeatState
{
    var curTooltip:CDevTooltip;
	var displayText:FlxText;
	var previewLogo:FlxSprite;
	var list:FlxUIList;

	var bruh:Array<Dynamic> = [];

	override function create()
	{
		FlxG.sound.music.stop();
		FlxG.mouse.visible = true;
		previewLogo = new FlxSprite().loadGraphic(Paths.image("icon16", "shared"));
		previewLogo.setGraphicSize(Std.int(150));
		previewLogo.screenCenter();
        previewLogo.updateHitbox();
		add(previewLogo);

		var m:Int = 0;
		for (char in ["bf", "dad", "gf", "spooky", "tankman"]){
			var h:HealthIcon = new HealthIcon(char);
			h.setPosition(20+(800*(m%2)),20+(150*m));
			add(h);
			h.updateHitbox();
			m++;
			bruh.push([h, "Health Bar Icon " + (m-1), "This sprite index is "+(m-1)+".\nCharacter assigned to this icon is \"" + char + "\""]);
		}

		displayText = new FlxText(0,0,-1,"UIDebugState // CDEV Engine v" + CDevConfig.engineVersion,14);
        displayText.font = FunkinFonts.CONSOLAS;
		displayText.setPosition(FlxG.width-displayText.width-10, FlxG.height - displayText.height - 10);
        displayText.color = 0xFFFFFFFF;
        add(displayText);

		list = new FlxUIList();

		curTooltip = new CDevTooltip();
        add(curTooltip);

		bruh.push([previewLogo, "Application Icon", "This is a rotating BF icon, pretty cool right?"]);
		super.create();
	}

	var time:Float = 3;
	var time2:Float = 3;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		previewLogo.angle += (30 * elapsed);
        curTooltip.hide();
		curMouse = openfl.ui.MouseCursor.ARROW;
		for (stuff in bruh){
			if (FlxG.mouse.overlaps(stuff[0])){
				curTooltip.show(stuff[0], stuff[1], stuff[2], true);
				curMouse = openfl.ui.MouseCursor.BUTTON;
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new meta.states.MainMenuState());
		}
	}
}
