package game.objects;

import flixel.animation.FlxAnimationController;
import sys.FileSystem;
import lime.utils.Assets;
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

	private var char:String;
	private var iconOffset:Array<Float> = [0, 0];
	private var isPlayer:Bool = false;
	public var hasWinningIcon:Bool = false;

	var first_x:Float = 0;
	var first_y:Float = 0;
	public var add_y:Float = 0;
	public var add_x:Float = 0;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?updateNow:Bool = true)
	{
		this.isPlayer = isPlayer;
		super();

		if (updateNow){
			changeDaIcon(char);
		}

		scrollFactor.set();
	}

	public function changeDaIcon(char:String) {
		if (this.char == char) return;

		//bruh.
		this.char = char;
		var name:String = 'icons/' + char;
		if(!CDevConfig.utils.fileIsExists('images/' + name + '.png', IMAGE))
			name = 'icons/'+char+'-icon';
		if(!CDevConfig.utils.fileIsExists('images/' + name + '.png', IMAGE))
			name = 'icons/face-icon';
		
		var file:Dynamic = Paths.image(name);
		var testSprite:FlxSprite = new FlxSprite().loadGraphic(file);
		
		loadGraphic(file, true, 150, 150);

		hasWinningIcon = (testSprite.width > 300 && testSprite.width <= 450);
		animation.add(char, (hasWinningIcon ? [0,1,2] : [0,1]), 0, false, isPlayer);
		animation.play(char);

		iconOffset[0] = (width - 150) / 2;
		iconOffset[1] = (height - 150) / 2;
		antialiasing = CDevConfig.saveData.antialiasing;
		if (char.endsWith('-pixel'))
			antialiasing = false;	
	}
	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffset[0];
		offset.y = iconOffset[1];
	}
	
	public function changeFrame(frameNum:Int){
		if (animation.curAnim == null) return;

		animation.curAnim.curFrame = frameNum;
	}

	public function getChar():String{
		return char;
	}

	override public function setPosition(x:Float = 0.0, y:Float = 0.0):Void {
		super.setPosition(x,y);
		first_x = x;
		first_y = y;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10 + add_x, sprTracker.y - 30 + add_y);
		else
			setPosition(first_x+add_x,first_y+add_y);
	}
}
