package game.objects;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import game.cdev.CDevConfig;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	/**Whether to force the X Position to a certain point.**/
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	/**If this was set to true, it will do a smooth positioning effect to the forceX variable.**/
	public var lerpOnForceX:Bool = true;
	/**Current target counter, usually used for scrolling UIs**/
	public var targetY:Float = 0;
	/**If it's true, then positioning will be automatically handled like menus (FreeplayState, for example)**/
	public var isMenuItem:Bool = false;
	/**Whether to set if this Alphabet object is an option item**/
	public var isOptionItem:Bool = false;
	/**Whether to set if this Alphabet object is used for Freeplay as it's songs items**/
	public var isFreeplay:Bool = false;
	/**Used in FreeplayState, centers the text screen's center**/
	public var wasChoosed:Bool = false;
	/**Used in FreeplayState, centers the text screen's center**/
	public var selected:Bool = false;
	/**Kinda like offset, or addition to the x position of this Alphabet object**/
	public var xAdd:Float = 0;
	/**Kinda like offset, or addition to the y position of this Alphabet object**/
	public var yAdd:Float = 0;
	/**Whether to limit amount of texts to screen, default is true (Used for Menus)**/
	public var forcePositionToScreen:Bool = true;
	/**Like the name, the height offset if forcePositionToScreen is false**/
	public var heightOffset:Float = 0;

	public var innerX:Float = 0;

	/**Current text size**/
	public var size:Float = 42;

	/**Current text**/
	public var text:String = '';

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	// used for TitleState.hx
	public var effect:String = "";

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, ?typed:Bool = false, ?size:Float = 42)
	{
		super(x, y);
		this.size = size;
		innerX = x;
		forceX = Math.NEGATIVE_INFINITY;

		_finalText = text;
		isBold = bold;
		this.text = text;

		if (text != "")
		{
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}
		}
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		for (index => character in splitWords)
		{
			// if (character.fastCodeAt() == " ")
			// {
			// }

			if (character == " ")
			{
				lastWasSpace = true;
			}
			var isNumber:Bool = AlphaCharacter.numbers.contains(character);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(character);
			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1 || isNumber || isSymbol)
			{
				if (lastSprite != null)
				{
					if (isNumber)
					{
						xPos = lastSprite.x + lastSprite.width + 7;
					}
					else if (isSymbol)
					{
						xPos = lastSprite.x + lastSprite.width + 5;
					}
					else
					{
						xPos = lastSprite.x + lastSprite.width;
						//trace(text + ": x" + lastSprite.x + ", width" + lastSprite.width);
					}
				}

				if (lastWasSpace)
				{
					xPos += size;
					lastWasSpace = false;
				}

				var yPos:Float = 0;

				if (isNumber || isSymbol)
				{
					yPos += 5;
				}

				if (character == '-')
				{
					yPos += 15;
				}

				if (xPos != 0) xPos -= x;

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				//trace(text + " === "+ index +" === " +xPos);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, yPos, this);
				letter.updateSize(size);
				if (isBold)
				{
					if (isNumber)
					{
						letter.createNumber(character, true);
					}
					else if (isSymbol)
					{
						letter.createSymbol(character, true);
					}
					else
					{
						letter.createBold(character);
					}
				}
				else
				{
					letter.createLetter(character);
				}

				add(letter);

				lastSprite = letter;
			}

			// loopNum += 1;
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			#end

			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
				// if (AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti, this);
				letter.row = curRow;
				if (isBold)
				{
					letter.createBold(splitWords[loopNum]);
				}
				else
				{
					if (isNumber)
					{
						letter.createNumber(splitWords[loopNum]);
					}
					else if (isSymbol)
					{
						letter.createSymbol(splitWords[loopNum]);
					}
					else
					{
						letter.createLetter(splitWords[loopNum]);
					}

					letter.x += 90;
				}

				if (FlxG.random.bool(40))
				{
					var daSound:String = "GF_";
					FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
				}

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}

	override function update(elapsed:Float)
	{
		updatePosition(elapsed);
		super.update(elapsed);
	}

	//..reworking this... thing.
	private function updatePosition(elapsed:Float):Void
	{
		if (!isMenuItem)
			return;

		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		if (FlxG.keys.justPressed.TAB && CDevConfig.saveData.testMode){
			trace(text + ": "+x+" , "+y);
		}
		if (forcePositionToScreen)
		{
			if (forceX == Math.NEGATIVE_INFINITY)
			{
				y = FlxMath.lerp(y, (scaledY * 120) + getYOffset(), CDevConfig.utils.bound(elapsed * 6, 0, 1));
				x = (isFreeplay) ? getFreeplayX(elapsed) : FlxMath.lerp(x, (targetY * 20) + 120 + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
			}
			else
			{
				y = FlxMath.lerp(y, (scaledY * 120) + getYOffset(), CDevConfig.utils.bound(elapsed * 6, 0, 1));
				x = (lerpOnForceX) ? FlxMath.lerp(x, forceX, CDevConfig.utils.bound(elapsed * 6, 0, 1)) : forceX;
			}
		}
		else
		{
			y = FlxMath.lerp(y, (targetY * (size+heightOffset)) + getYOffset(), CDevConfig.utils.bound(elapsed * 6, 0, 1));
			x = (isFreeplay) ? getFreeplayX(elapsed) : FlxMath.lerp(x, (targetY * 20) + 120 + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));

			if (forceX != Math.NEGATIVE_INFINITY)
			{
				x = (lerpOnForceX) ? FlxMath.lerp(x, forceX, CDevConfig.utils.bound(elapsed * 6, 0, 1)) : forceX;
			}
		}

		if (isOptionItem) {
			screenCenter(X);
			x += xAdd;
		}
	}

	private function getYOffset():Float
	{
		return (FlxG.height * 0.48) + ((!isOptionItem) ? yAdd : 0);
	}
	var targetX:Float;
	private function getFreeplayX(elapsed:Float):Float
	{
		if (!isFreeplay)
			return innerX;

		if (!wasChoosed)
		{
			targetX = (!selected) ? 120 : 200 + xAdd;
		}
		else
		{
			targetX = (FlxG.width / 2) - (width / 2) + xAdd;
		}

		return FlxMath.lerp(x, targetX, CDevConfig.utils.bound(elapsed * 6, 0, 1));
	}
	/*override function update(elapsed:Float)
		{
			if (isMenuItem)
			{
				var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
				if (forcePositionToScreen)
				{
					if (forceX == Math.NEGATIVE_INFINITY)
					{
						if (!isFreeplay)
						{
							if (!isOptionItem)
								y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48) + yAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							else
								y = FlxMath.lerp(y, (scaledY * 100) + (FlxG.height * 0.48) + yAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							if (!isOptionItem)
								x = FlxMath.lerp(x, (targetY * 20) + 120 + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							else
								screenCenter(X);
						}
						else
						{
							y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48) + yAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							if (!wasChoosed)
							{
								if (!selected)
									x = FlxMath.lerp(x, 120 + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
								else
									x = FlxMath.lerp(x, 200 + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							}
							else
							{
								x = FlxMath.lerp(x, (FlxG.width / 2) - (width / 2) + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							}
						}
					}
					else
					{
						if (lerpOnForceX)
							x = FlxMath.lerp(x, forceX, CDevConfig.utils.bound(elapsed * 6, 0, 1));
						else
							x = forceX;
					}
				}
				else
				{
					if (forceX == Math.NEGATIVE_INFINITY)
					{
						if (!isFreeplay)
						{
							if (!isOptionItem)
								y = FlxMath.lerp(y, (scaledY * 120) + yAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							else
								y = FlxMath.lerp(y, (scaledY * 100) + yAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							if (!isOptionItem)
								x = FlxMath.lerp(x, (targetY * 20) + 120 + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							else
								screenCenter(X);
						}
						else
						{
							y = FlxMath.lerp(y, (scaledY * 120) + yAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							if (!wasChoosed)
							{
								if (!selected)
									x = FlxMath.lerp(x, 120 + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
								else
									x = FlxMath.lerp(x, 200 + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							}
							else
							{
								x = FlxMath.lerp(x, (FlxG.width / 2) - (width / 2) + xAdd, CDevConfig.utils.bound(elapsed * 6, 0, 1));
							}
						}
					}
					else
					{
						if (lerpOnForceX)
							x = FlxMath.lerp(x, forceX, CDevConfig.utils.bound(elapsed * 6, 0, 1));
						else
							x = forceX;
					}
				}
			}
			super.update(elapsed);
	}*/
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	var currentState:Alphabet;

	public function new(x:Float, y:Float, current:Alphabet)
	{
		super(x, y);
		this.currentState = current;
		var tex = Paths.getSparrowAtlas('alphabet');
		frames = tex;
		antialiasing = CDevConfig.saveData.antialiasing;
	}

	public function createBold(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);

		updateHitbox();

		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 60;
		// color = FlxColor.WHITE;
	}

	public function createNumber(letter:String, ?white:Bool = false):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
		if (white)
			color = FlxColor.WHITE;
		else
			color = FlxColor.BLACK;
	}

	public function createSymbol(letter:String, ?white:Bool = false)
	{
		var wawaaa:Bool = false;
		for (i in [".", "'", "?", "!"])
		{
			var l:Array<String> = letter.split('');
			if (l.contains(i))
			{
				wawaaa = true;
				break;
			}
		}
		if (wawaaa)
		{
			switch (letter)
			{
				case '.':
					animation.addByPrefix(letter, 'period', 24);
					animation.play(letter);

					y += 50;
				case "'":
					animation.addByPrefix(letter, 'apostraphie', 24);
					animation.play(letter);

					y -= 0;
				case "?":
					animation.addByPrefix(letter, 'question mark', 24);
					animation.play(letter);

				case "!":
					animation.addByPrefix(letter, 'exclamation point', 24);
					animation.play(letter);
			}
		}
		else
		{
			animation.addByPrefix(letter, letter, 24);
			animation.play(letter);
		}

		updateHitbox();
		if (white)
			color = FlxColor.WHITE;
		else
			color = FlxColor.BLACK;
	}

	public function updateSize(size)
	{
		setGraphicSize(-1, Std.int(size));
	}
}
