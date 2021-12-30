package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	var charList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

	/**
	 * An array that contains ^RGB^ color array of an character icon.
	 */
	public var charColorArray:Array<FlxColor> = [];
	var char:String;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		this.char = char;
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		getColorArray();

		antialiasing = FlxG.save.data.antialiasing;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('bf-cscared', [0, 1], 0, false, isPlayer);
		animation.add('bf-car', [0, 1], 0, false, isPlayer);
		animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
		animation.add('bf-pixel', [21, 21], 0, false, isPlayer);
		animation.add('spooky', [2, 3], 0, false, isPlayer);
		animation.add('pico', [4, 5], 0, false, isPlayer);
		animation.add('mom', [6, 7], 0, false, isPlayer);
		animation.add('mom-car', [6, 7], 0, false, isPlayer);
		animation.add('tankman', [8, 9], 0, false, isPlayer);
		animation.add('face', [10, 11], 0, false, isPlayer);
		animation.add('dad', [12, 13], 0, false, isPlayer);
		animation.add('senpai', [22, 22], 0, false, isPlayer);
		animation.add('senpai-angry', [22, 22], 0, false, isPlayer);
		animation.add('spirit', [23, 23], 0, false, isPlayer);
		animation.add('bf-old', [14, 15], 0, false, isPlayer);
		animation.add('gf', [16], 0, false, isPlayer);
		animation.add('parents-christmas', [17], 0, false, isPlayer);
		animation.add('monster', [19, 20], 0, false, isPlayer);
		animation.add('monster-christmas', [19, 20], 0, false, isPlayer);

		// to prevent crashing while loading an not existed character icon
		if (charList.contains(char))
			animation.play(char);
		else
			animation.play('face');
		scrollFactor.set();
	}

	function getColorArray()
	{
		var REDC:Int = 0;
		var GREENC:Int = 0;
		var BLUEC:Int = 0;
		switch (char)
		{
			case 'bf', 'bf-car', 'bf-christmas', 'bf-cscared', 'bf-pixel':
				REDC = 30;
				GREENC = 149;
				BLUEC = 179;
			case 'spooky':
				REDC = 175;
				GREENC = 133;
				BLUEC = 89;
			case 'pico':
				REDC = 158;
				GREENC = 190;
				BLUEC = 45;
			case 'mom', 'mom-car':
				REDC = 199;
				GREENC = 60;
				BLUEC = 120;
			case 'dad':
				REDC = 159;
				GREENC = 70;
				BLUEC = 194;
			case 'senpai', 'senpai-angry':
				REDC = 244;
				GREENC = 148;
				BLUEC = 80;
			case 'spirit':
				REDC = 219;
				GREENC = 46;
				BLUEC = 90;
			case 'gf':
				REDC = 133;
				GREENC = 0;
				BLUEC = 60;
			case 'parents-christmas':
				REDC = 192;
				GREENC = 37;
				BLUEC = 187;
			case 'monster', 'monster-christmas':
				REDC = 224;
				GREENC = 221;
				BLUEC = 42;
			default:
				REDC = 133;
				GREENC = 133;
				BLUEC = 133;
		}

		charColorArray = [REDC, GREENC, BLUEC];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
