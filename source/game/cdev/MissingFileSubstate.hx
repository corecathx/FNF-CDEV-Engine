package game.cdev;

import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class MissingFileSubstate extends meta.substates.MusicBeatSubstate
{
	public function new(file:String = "")
	{
		super();
		var songName:String = "";
		var f:Array<String> = file.split("-");
		trace(f);
		songName = file.toLowerCase().replace(f[f.length], "");

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.7;
		add(bg);

		var bigText:game.objects.Alphabet = new game.objects.Alphabet(0, 150, "Error", true, false);
		bigText.screenCenter(X);
		add(bigText);

		var detailText:FlxText = new FlxText(0, bigText.y + 100, FlxG.width, "", 24);
		detailText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(detailText);

		detailText.borderSize = 2;

		detailText.text = "Uh oh! we encountered an error while loading this file!"
			+ "\nThe file that we're trying to load is '"
			+ file
			+ ".json'\n and we can't find that file!"
			+ "\nPlease check the directory path below: "
			+ "\n '/assets/data/charts/"
			+ songName
			+ "/'\n or \n'/cdev-mods/data/charts/"
			+ songName
			+ "/'\n and make sure if '"
			+ file
			+ ".json' file are there!";

	}
	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY)
			close();
		super.update(elapsed);
	}
}
