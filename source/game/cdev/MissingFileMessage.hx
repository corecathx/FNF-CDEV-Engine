package game.cdev;

import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

//basically MissingFileSubstate.hx, but this one is customizeable...
class MissingFileMessage extends meta.substates.MusicBeatSubstate
{
    var callback:Void->Void;
	public function new(message:String, headerText:String,callbackF:Void->Void)
	{
		super();
		this.callback = callbackF;
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.7;
		add(bg);

		var bigText:game.objects.Alphabet = new game.objects.Alphabet(0, 150, headerText, true, false);
		bigText.screenCenter(X);
		add(bigText);

		var detailText:FlxText = new FlxText(0, bigText.y + 100, FlxG.width, "", 24);
		detailText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(detailText);

		detailText.borderSize = 2;

		detailText.text = message;
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		new FlxTimer().start(0.4,function(a:FlxTimer){
			canDoShit = true;
		});
	}

	var canDoShit:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY && canDoShit){
            close();
            callback();
        }
		super.update(elapsed);
	}
}
