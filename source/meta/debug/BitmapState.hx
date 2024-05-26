package meta.debug;

import openfl.geom.Point;
import flixel.graphics.FlxGraphic;
import game.ImageUtils;
import openfl.display.BitmapData;
import cpp.abi.Winapi;
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

class BitmapState extends MusicBeatState
{
	var spr:FlxSprite;

	override function create()
	{
        var bigBitmap:BitmapData = ImageUtils.drawBitmapArray([
            {
                data: BitmapData.fromFile("./assets/shared/images/stageback.png"),
                position: new Point(0,0)
            },
            {
                data: BitmapData.fromFile("./assets/shared/images/stagefront.png"),
                position: new Point(0,800)
            },
            {
                data: BitmapData.fromFile("./assets/shared/images/stagecurtains.png"),
                position: new Point(0,0)
            }
        ]);
        bigBitmap = ImageUtils.resizeBitmapData(bigBitmap,0.05,0.05);
        bigBitmap = ImageUtils.bitmapFillAndClip(bigBitmap, 1280,300);

        spr = new FlxSprite().loadGraphic(bigBitmap);
        spr.updateHitbox();
        spr.screenCenter();
        add(spr);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new meta.states.MainMenuState());
		}
	}
}