package meta.debug;

import openfl.utils.ByteArray;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import game.cdev.objects.ModList;
import game.cdev.objects.CDevChartUI;
import lime.ui.MouseCursor;
import flixel.addons.ui.FlxUIList;
import game.objects.HealthIcon;
import game.cdev.objects.CDevTooltip;
import openfl.text.TextFormat;
import flixel.addons.ui.FontDef;
import flixel.addons.ui.Anchor;
import flixel.addons.ui.FlxUITooltipManager;
import flixel.addons.ui.FlxUITooltip;

class BitmapListState extends MusicBeatState
{
    var spriteList:Array<BitmapViewSprite> = [];
	override function create()
	{
		FlxG.sound.music.stop();
		FlxG.mouse.visible = true;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('aboutMenu'));
		bg.color = CDevConfig.utils.CDEV_ENGINE_BLUE;
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		CDevConfig.utils.setFitScale(bg, 0.1, 0.1);
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.7;
		bg.antialiasing = CDevConfig.saveData.antialiasing;
		add(bg);

        updateSpriteList();

		super.create();
	}

    function updateSpriteList() {
        while(spriteList.length>0){
            for (i in spriteList) {
                if (i == null) continue;
    
                i.destroy();
                spriteList.remove(i);
                remove(i);
            }
        }

        @:privateAccess {
            for (bitmap in FlxG.bitmap._cache.keys()){
                var obj:FlxGraphic = FlxG.bitmap._cache.get(bitmap);
                var n:BitmapViewSprite = new BitmapViewSprite(0,0,obj,bitmap);
                add(n);

                spriteList.push(n);
            }
        }
    }

	var time:Float = 3;
	var time2:Float = 3;

    var curY:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (FlxG.mouse.wheel != 0) curY += FlxG.mouse.wheel * 50;

        for (index => i in spriteList) {
            if (i == null) continue;

            i.y = curY + (210*index);
        }

        if (FlxG.keys.justPressed.SPACE) {
            updateSpriteList();
        }

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new meta.states.MainMenuState());
		}
	}
}

class BitmapViewSprite extends FlxSprite {
    var spriteText:FlxText;
    var spriteView:FlxSprite;
    public function new(nX:Float, nY:Float, data:FlxGraphic, text:String) {
        super(nX,nY);
        makeGraphic(FlxG.width,200);
        color = 0xFF222222;
        alpha = 0.5;

        spriteText = new FlxText(0,0,FlxG.width-300, text, 30);
        spriteText.setFormat("VCR OSD Mono", 24, 0xFFFFFFFF);
        if (data != null) {
            spriteText.text += "\n"+getBitmapSize(data);
        }

        spriteView = new FlxSprite().loadGraphic(data);
        spriteView.setGraphicSize(180,180);
        spriteView.updateHitbox();
    }
    function getBitmapSize(graphic:FlxGraphic) {
        var bitmapData:BitmapData = graphic.bitmap;
        var byteArray:ByteArray = bitmapData.getPixels(bitmapData.rect);
        var sizeInBytes:Int = byteArray.length;
        return CDevConfig.utils.convert_size(sizeInBytes*1.0);
    }


    override function draw() {
        super.draw();
        spriteView.setPosition(x + 20, y + (height-spriteView.height)*0.5);
        spriteView.draw();

        spriteText.setPosition(spriteView.x + spriteView.width + 20, y + (height-spriteText.height)*0.5);
        spriteText.draw();
    }
}