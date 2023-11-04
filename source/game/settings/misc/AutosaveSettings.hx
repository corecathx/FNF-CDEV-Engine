package game.settings.misc;

import flixel.FlxG;
import flixel.FlxSprite;
import game.objects.Alphabet;
import meta.substates.MusicBeatSubstate;

using StringTools;

class AutosaveSettings extends MusicBeatSubstate
{
	var options:Array<String> = [
		"30 Seconds",
		"1 Minute",
		"2 Minutes",
		"5 Minutes",
		"10 Minutes",
		"Before any risky actions"
	];

	public function new()
	{
		super();
	}

	var cur:Int = 0;
	var obj:Array<Alphabet> = [];

	override function create()
	{
		super.create();
		var bgBlack:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bgBlack.alpha = 0.7;
		add(bgBlack);

		var lengthy:Float = (FlxG.height / 2) - ((options.length * 28) / 2);

		for (i in options)
		{
			var opt:Alphabet = new Alphabet(0, 0, i, true, false,18);
			opt.y = lengthy + (28 * options.indexOf(i));
			opt.screenCenter(X);
			add(opt);
			opt.ID = options.indexOf(i);
			obj.push(opt);
		}

		var text:Alphabet = new Alphabet(0, 0, "Set Autosave chart interval", false, 20);
		add(text);
		text.screenCenter(X);
		text.y += 80;

		changeOptions();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UP_P)
		{
			changeOptions(-1);
		}

		if (controls.DOWN_P)
		{
			changeOptions(1);
		}

        if (controls.ACCEPT)
        {
            setShit();
        }

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
            close();
        }
	}

	function changeOptions(a:Int = 0)
	{
		if (a != 0)FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		cur += a;

		if (cur < 0)
			cur = options.length - 1;
		if (cur >= options.length)
			cur = 0;
		var shit = 0;
		for (item in obj)
		{
			item.targetY = shit - cur;
			shit++;
            var color:Int = 0xFFFFFFFF;
            var beep:String = "";
            switch(CDevConfig.saveData.autosaveChart_interval){
                case 30:
                    beep = "30 Seconds";
                case 60:
                    beep = "1 Minute";
                case 120:
                    beep = "2 Minutes";
                case 300:
                    beep = "5 Minutes";
                case 600:
                    beep = "10 Minutes";
                case -1:
                    beep = "Before any risky actions";
            }

			if (item.text == beep){
				color = 0xFF008CFF;
			}
			item.color = color;
			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	function setShit()
	{
        FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
        var save:Float = -1;
		switch (options[cur].toLowerCase())
		{
			case "30 seconds":
                save = 30;
			case "1 minute":
                save = 60;
			case "2 minutes":
                save = 120;
			case "5 minutes":
                save = 300;
			case "10 minutes":
                save = 600;
			case "before any risky actions":
                save = -1;
		}

        CDevConfig.saveData.autosaveChart_interval = save;
		changeOptions();
	}
}
