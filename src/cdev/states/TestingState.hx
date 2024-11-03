package cdev.states;

import openfl.media.Sound;
import cdev.objects.Visualizer;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import cdev.objects.menus.Alphabet;
import openfl.display.BitmapData;
import flixel.text.FlxText;
import flixel.addons.display.FlxGridOverlay;

class TestingState extends State
{
	var alphatest:Alphabet;
	var vistest:Visualizer;
	var status:String = "";
	override public function create()
	{
		super.create();
        createBackground();
		status = "Alphabet";
		add(new FlxText(10,50,"Testing State! Use this for whatever testing stuff you want.\nEach grid here is 10px in size.\n\n== State ==\n"+status));
	
		switch (status.toLowerCase()) {
			case "alphabet": 
				alphatest = new Alphabet(100,100,"", true);
				add(alphatest);
			case "visualizer":
				var snd:FlxSound = FlxG.sound.load(Sound.fromFile("./assets/music/funkinBeat.ogg"));
				snd.play();
				vistest = new Visualizer(0,0,200,2, FlxG.width,FlxG.height * 0.7,snd);
				vistest.y = (FlxG.height - vistest.height) * 0.5;
				add(vistest);
		}
	}

    function createBackground() {
		FlxG.camera.bgColor = 0xFF505050;
        var bmd:BitmapData = FlxGridOverlay.createGrid(10,10,FlxG.width, FlxG.height, true, 0xFF202020, 0xFF303030);
        var spr:Sprite = new Sprite().loadGraphic(bmd);
        add(spr);
        spr.alpha = 0.4;
    }

	var time:Float = 0;
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.switchState(new PlayState());
		}
		if (status.toLowerCase() == "alphabet") {
			if (FlxG.keys.justPressed.TAB) {
				alphatest.bold = !alphatest.bold;
			}
			var allowList:String = "abcdefghijklmnopqrstuvwxyz";
			if (FlxG.keys.pressed.ANY) {
				if (time == 0 || time > 0.5) {
					if (time > 0.5) time = 0.48;
					var keys:Array<FlxInput<FlxKey>> = FlxG.keys.getIsDown();
					for (key in keys) {
						var id:FlxKey = key.ID;
						if (!allowList.contains(id.toString().toLowerCase())) continue;
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

			if (FlxG.keys.justReleased.ANY) {
				time = 0;
			}
		}
		/*
		FlxG.watch.addQuick("time",time);*/
	}

	override function destroy() {
		FlxG.camera.bgColor = 0xFF000000;
		super.destroy();
	}
}
