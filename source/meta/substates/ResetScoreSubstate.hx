package meta.substates;

import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class ResetScoreSubstate extends MusicBeatSubstate
{
	var yesText:FlxText;
	var noText:FlxText;

	var curSelected:Int = 0;

	var theSong:String = "";
	var theDiff:String = "";
	var diffshit:Int = 1;

	public function new(theSong:String = "", theDiff:String = "", diffshit:Int = 1)
	{
		super();

		this.theDiff = theDiff;
		this.theSong = theSong;
		this.diffshit = diffshit;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.7;
		add(bg);

		var warnText:game.objects.Alphabet = new game.objects.Alphabet(0, 150, "Warning", true, false);
		warnText.screenCenter(X);
		add(warnText);

		var detailText:FlxText = new FlxText(0, warnText.y + 100, FlxG.width, "", 24);
		detailText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(detailText);

		detailText.borderSize = 2;

		detailText.text = "You're about to reset your score on: " + theSong.toUpperCase() + " " + theDiff.toUpperCase() + ".\n" + "Are you sure that you want to do this?\n"
			+ "(NOTE: THIS OPTION IS IRREVERSIBLE!)";

		yesText = new FlxText(0, detailText.y + detailText.height + 50, FlxG.width, "", 24);
		yesText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(yesText);

		noText = new FlxText(0, yesText.y + yesText.height + 10, FlxG.width, "", 24);
		noText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(noText);

        changeSelection();
	}

	override function update(elapsed:Float)
	{
		if (yesText != null)
		{
			yesText.screenCenter(X);
		}
		if (noText != null)
		{
			noText.screenCenter(X);
		}
		if (FlxG.keys.justPressed.ENTER)
			checkEnter();

		if (controls.UI_UP_P)
			changeSelection(-1);
        if (controls.UI_DOWN_P)
            changeSelection(1);

		if (controls.BACK)
		{
            FlxG.save.flush();
			FlxG.sound.play(game.Paths.sound('cancelMenu'));
			close();
		}
		super.update(elapsed);
	}

	function changeSelection(add:Int = 0)
	{
        curSelected += add;
		FlxG.sound.play(game.Paths.sound('scrollMenu'));
		if (curSelected < 0)
			curSelected = 1;
		if (curSelected > 1)
			curSelected = 0;

		switch (curSelected)
		{
			case 0:
				yesText.text = "> Yes";
				noText.text = "  No";
			case 1:
				yesText.text = "  Yes";
				noText.text = "> No";
		}
	}

	function checkEnter()
	{
		switch (curSelected)
		{
			case 0:
				game.cdev.engineutils.Highscore.resetSong(theSong, diffshit);
				FlxG.sound.play(game.Paths.sound('confirmMenu'));
				close();
			case 1:
				FlxG.sound.play(game.Paths.sound('cancelMenu'));
				close();
		}
	}
}
