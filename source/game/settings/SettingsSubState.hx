package game.settings;

import flixel.FlxSprite;
import flixel.util.FlxTimer;
import game.settings.data.SettingsProperties.SettingsType;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import game.settings.data.SettingsProperties;
import game.settings.data.SettingsProperties.SettingsCategory;
import meta.substates.MusicBeatSubstate;

class FlxTextTag extends FlxText
{
	public var targetID:Int = 0;
}

class SettingsSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;
	var theCat:SettingsCategory = null;
	var grpOptions:FlxTypedGroup<FlxTextTag>;
	var versionSht:FlxText;

	var allowToPress:Bool = false;
	var loaded:Bool = false;

	public var fromPause:Bool = false;
    var bg:FlxSprite;
	var title:FlxText;
	public function new(cat:SettingsCategory, ?fromPause:Bool = false)
	{
		super();
		if (!loaded)
		{
			this.fromPause = fromPause;
			SettingsProperties.setCurrentClass(this);
			theCat = cat;

            if (fromPause){
                bg = new FlxSprite().makeGraphic(FlxG.width,FlxG.height, 0xFF000000);
                bg.alpha = 0.4;
                add(bg);
            }

			grpOptions = new FlxTypedGroup<FlxTextTag>();
			add(grpOptions);

			title = new FlxTextTag(50, 50, 0, theCat.name, 38);
			title.setFormat("wendy", 68, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			// text.screenCenter(X);
			title.borderSize = 4;
			add(title);

			for (i in 0...theCat.settings.length)
			{
				var currentSetting:BaseSettings = theCat.settings[i];
				var text:FlxTextTag = new FlxTextTag(50, 0, 0, currentSetting.name, 38);
				text.setFormat("wendy", 38, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
				text.y = 0 + ((66) * i) + 5;
				text.borderSize = 2;
				// text.screenCenter(X);
				text.ID = i;
				grpOptions.add(text);

				if (fromPause && !currentSetting.pausable)
				{
					text.color = FlxColor.GRAY;
				}
				// updateText(i);
			}

			versionSht = new FlxText(20, FlxG.height - 100, 1000, '', 24);
			versionSht.scrollFactor.set();
			versionSht.setFormat("wendy", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			versionSht.screenCenter(X);
			add(versionSht);
			versionSht.borderSize = 2;
			changeSelection();
			new FlxTimer().start(0.2, function(bruh:FlxTimer)
			{
				allowToPress = true;
				for (i in 0...theCat.settings.length)
				{
					theCat.settings[i].onUpdateHit(0.01);
					updateText(i);
				}
			});

			if (fromPause)
				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
			loaded = true;
		}
	}

	var largestLengthText:Int = 0;

	function checkTexts()
	{
		for (i in theCat.settings)
		{
			if (i.name.length > largestLengthText)
			{
				largestLengthText = i.name.length;
			}
		}
	}

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (loaded)
		{
			if (controls.UI_UP_P)
			{
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(1);
			}
			if (controls.BACK)
			{
				close();
			}

			grpOptions.forEachAlive(function(theText:FlxTextTag)
			{
				var scaledY = FlxMath.remapToRange(theText.targetID, 0, 1, 0, 1.3);
				theText.y = FlxMath.lerp(theText.y, 200 + (scaledY * 40) + (FlxG.height * 0.1), CDevConfig.utils.bound(elapsed * 12, 0, 1));

				if (theText.ID == curSelected)
				{
                    if (allowToPress){
                        if (fromPause){
                            if (theCat.settings[theText.ID].pausable)
                                doAction(elapsed, theText);
                        } else doAction(elapsed, theText);
                    }
				}
			});
		}
		super.update(elapsed);
	}

	function doAction(elapsed:Float, theText:FlxTextTag)
	{
		var curSet:BaseSettings = theCat.settings[curSelected];
		curSet.onUpdateHit(elapsed);
		switch (curSet.type)
		{
			case 0: // bool
				if (controls.ACCEPT)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					CDevConfig.setData(curSet.savedata_field, !CDevConfig.getData(curSet.savedata_field));
					updateText(theText.ID);
				}
			case 1: // int
				var daValueToAdd:Int = FlxG.keys.pressed.RIGHT ? 1 : -1;
				if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
					holdTime += elapsed;

				if (holdTime <= 0)
					FlxG.sound.play(Paths.sound('scrollMenu'));

				if (holdTime > 0.5 || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
				{
					CDevConfig.setData(curSet.savedata_field, CDevConfig.getData(curSet.savedata_field) + daValueToAdd);
					updateText(theText.ID);
				}
				curSet.value_name[0] = CDevConfig.getData(curSet.savedata_field);
			case 2: // float
				var daValueToAdd:Float = FlxG.keys.pressed.RIGHT ? 0.1 : -0.1;
				if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
					holdTime += elapsed;

				if (holdTime <= 0)
					FlxG.sound.play(Paths.sound('scrollMenu'));

				if (holdTime > 0.5 || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
				{
					CDevConfig.setData(curSet.savedata_field, CDevConfig.getData(curSet.savedata_field) + daValueToAdd);
					updateText(theText.ID);
				}
				curSet.value_name[0] = CDevConfig.getData(curSet.savedata_field);
			case 3: // function
				// currently unknown
				updateText(theText.ID);
			case 4: // self defined
				updateText(theText.ID);
		}
	}

	function updateText(set:Int)
	{
		checkTexts();
		var curText:String = "";
		switch (theCat.settings[set].type)
		{
			case 0:
				CDevConfig.checkDataField(theCat.settings[set].savedata_field);

				if (CDevConfig.getData(theCat.settings[set].savedata_field))
					curText = theCat.settings[set].value_name[1];
				else
					curText = theCat.settings[set].value_name[0];
			default:
				curText = theCat.settings[set].value_name[0];
		}
		var spaces:String = "";
		for (i in 0...largestLengthText - theCat.settings[set].name.length + 1)
		{
			spaces += " ";
		}
		grpOptions.members[set].text = (set == curSelected ? "> " : "") + theCat.settings[set].name + spaces + " : " + curText;
	}

	public function hideAllOptions(){
		for (item in grpOptions.members)
		{
			item.alpha = 0;
		}
		title.alpha = 0;
	}

	public function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(game.Paths.sound('scrollMenu'), 0.5);
		curSelected += change;
		var bullShit:Int = 0;
		if (curSelected < 0)
			curSelected = theCat.settings.length - 1;
		if (curSelected >= theCat.settings.length)
			curSelected = 0;

		if (fromPause && !theCat.settings[curSelected].pausable)
			versionSht.text = "This setting cannot be changed in game.";
		else
			versionSht.text = theCat.settings[curSelected].description;

		for (i in 0...theCat.settings.length)
			updateText(i);

		title.alpha = 1;
		for (item in grpOptions.members)
		{
			item.targetID = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;

			if (item.targetID == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
