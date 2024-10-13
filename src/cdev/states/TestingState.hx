package cdev.states;

import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import cdev.objects.menus.Alphabet;
import openfl.display.BitmapData;
import flixel.text.FlxText;
import flixel.addons.display.FlxGridOverlay;

class TestingState extends State
{
	var alphatest:Alphabet;
	override public function create()
	{
		super.create();
        createBackground();
		add(new FlxText(10,50,"Testing State! Use this for whatever testing stuff you want.\nEach grid here is 10px in size."));
	
		alphatest = new Alphabet(100,100,"abcdefghijklmnopqrstuvwxyz\n
		ABCDEFGHIJKLMNOPQRSTUVWXYZ\n
		1234567890\n
		!@#$%^&*()_+\n
		[]\\;',./\n
		{}|:\"<>?\n
		-=", true);
		add(alphatest);
	}

    function createBackground() {
        var bmd:BitmapData = FlxGridOverlay.createGrid(10,10,FlxG.width, FlxG.height, true, 0xFF202020, 0xFF303030);
        var spr:Sprite = new Sprite().loadGraphic(bmd);
        add(spr);
        spr.alpha = 0.4;
    }

	var time:Float = 0;
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.BACKSLASH) {
			trace("i hope the crash handler works");
			throw "i hope the crash handler works";
		}
		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.switchState(new PlayState());
		}
		if (FlxG.keys.justPressed.TAB) {
			alphatest.bold = !alphatest.bold;
		}
		if (FlxG.keys.pressed.ANY) {
			if (time == 0 || time > 0.5) {
				if (time > 0.5) time = 0.48;
				var keys:Array<FlxInput<FlxKey>> = FlxG.keys.getIsDown();
				for (key in keys) {
					var id:FlxKey = key.ID;
					switch (id) {
						case FlxKey.BACKSPACE:
							alphatest.text = alphatest.text.substring(0, alphatest.text.length-1);
						case FlxKey.ENTER:
							alphatest.text += "\n";
						case FlxKey.SPACE:
							alphatest.text += " ";
						default:
							var keyID:String = Utils.getKeyFormat(key.ID);
							alphatest.text += FlxG.keys.pressed.SHIFT ? keyID.toUpperCase() : keyID.toLowerCase();
					}
				}
			}
			time += elapsed;
		} else {
			time = 0;
		}
		FlxG.watch.addQuick("time",time);
	}
}
