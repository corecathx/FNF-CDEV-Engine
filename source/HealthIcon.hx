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

	public var charColorArray:Array<FlxColor> = [];
	private var char:String;
	private var iconOffset:Array<Float> = [0, 0];
	private var isPlayer:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		this.char = char;
		this.isPlayer = isPlayer;
		super();

		changeDaIcon(char);
		scrollFactor.set();
	}

	public function changeDaIcon(char:String) {
		var name:String = 'icons/' + char + '-icon';

		if (!CDevConfig.utils.fileIsExist('images/' + name + '.png', IMAGE))
			name = 'icons/face-icon'; //to prevent crashing while loading an not existed character icon
				
		var file:Dynamic = Paths.image(name, 'preload');
		loadGraphic(file, true, 150, 150);
		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
		this.char = char;

		iconOffset[0] = (width - 150) / 2;
		iconOffset[1] = (width - 150) / 2;	

		antialiasing = FlxG.save.data.antialiasing;
		if (char.endsWith('-pixel'))
		{
			antialiasing = false;
		}

		getColorArray();			
	}
	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffset[0];
		offset.y = iconOffset[1];
	}

	function getColorArray()
	{
		// this is messed up bruh
		var REDC:Int = 0;
		var GREENC:Int = 0;
		var BLUEC:Int = 0;
		switch (char)
		{
			case 'bf' | 'bf-pixel':
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
			case 'mom':
				REDC = 199;
				GREENC = 60;
				BLUEC = 120;
			case 'dad':
				REDC = 159;
				GREENC = 70;
				BLUEC = 194;
			case 'senpai':
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
			case 'parents':
				REDC = 192;
				GREENC = 37;
				BLUEC = 187;
			case 'monster':
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
