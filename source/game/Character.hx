package game;

import game.Stage.SpriteStage;
import states.PlayState;
import engineutils.Highscore;
import flixel.util.FlxSort;
import song.Song;
import song.Section.SwagSection;
import modding.CharacterData.CharData;
import modding.CharacterData.AnimationArray;
import lime.utils.Assets;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends SpriteStage
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	var charLists:Array<String> = [];

	public var curCharacter:String = 'bf';
	public var specialAnim:Bool = false;
	public var heyTimer:Float = 0;

	var defaultChar:String = 'bf';

	public var lockedChar:Bool = false; // used in WeekEditor.hx

	public var holdTimer:Float = 0;

	public var imgFile:String = ''; // same as = 'spritePath'
	public var jsonScale:Float = 1; // same as = 'charScale'
	public var charXYPos:Array<Float> = [0, 0]; // same as = 'charXYOffset'
	public var charCamPos:Array<Float> = [0, 0]; // same as = 'camXYPos'
	public var charHoldTime:Float = 4; // same as = 'singHoldTime';
	public var healthBarColors:Array<Int> = [0, 0, 0]; // same as = 'healthBarColor'
	public var animArray:Array<AnimationArray> = []; // same as = 'animations'
	public var healthIcon:String = 'face'; // same as = 'iconName'
	public var isPlayer:Bool = false; // same as 'isPlayer'
	public var previousFlipX:Bool = false;
	public var usingAntiAlias:Bool = false;

	public var gfTestBop:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?usedForStoryChar:Bool = false)
	{
		super(x, y);

		/*
			var charList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
			var miscCharList:Array<String> = CoolUtil.coolTextFile(Paths.txt('miscCharacterList'));
			var gfList:Array<String> = CoolUtil.coolTextFile(Paths.txt('gfList'));
			for (i in 0...charList.length)
			{
				charLists.push(charList[i]);
			}

			for (i in 0...miscCharList.length)
			{
				charLists.push(miscCharList[i]);
			}

			for (i in 0...gfList.length)
			{
				charLists.push(gfList[i]);
		}*/

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = FlxG.save.data.antialiasing;

		switch (curCharacter)
		{
			default:
				var charPath:String = 'characters/' + curCharacter + '.json';
				var daRawJSON = null;
				#if ALLOW_MODS
				var path:String = Paths.modChar(curCharacter);
				if (!FileSystem.exists(path))
					path = Paths.char(curCharacter);

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(charPath);
				if (!Assets.exists(path))
				#end
				{
					path = Paths.char('bf');
				}

				#if ALLOW_MODS
				daRawJSON = File.getContent(path);
				#else
				daRawJSON = Assets.getText(path);
				#end

				var parsedJSON:CharData = cast Json.parse(daRawJSON);
				if (Assets.exists(Paths.getPath('images/' + parsedJSON.spritePath + '.txt', TEXT)))
					frames = Paths.getPackerAtlas(parsedJSON.spritePath, 'shared');
				else
					frames = Paths.getSparrowAtlas(parsedJSON.spritePath, 'shared');

				imgFile = parsedJSON.spritePath;
				jsonScale = parsedJSON.charScale;
				charXYPos = parsedJSON.charXYPosition;
				charCamPos = parsedJSON.camXYPos;
				charHoldTime = parsedJSON.singHoldTime;
				healthBarColors = parsedJSON.healthBarColor;
				animArray = parsedJSON.animations;
				healthIcon = parsedJSON.iconName;
				usingAntiAlias = parsedJSON.usingAntialiasing;
				setGraphicSize(Std.int(width * jsonScale));
				updateHitbox();

				flipX = !!parsedJSON.flipX;

				antialiasing = parsedJSON.usingAntialiasing;
				if (!FlxG.save.data.antialiasing) // force disable antialiasing while FlxG.save.data.antialiasing was false.
					antialiasing = false;

				if (animArray != null && animArray.length > 0)
				{
					for (anim in animArray)
					{
						if (usedForStoryChar)
						{ // a really bad code
							var shouldshit:Array<String> = ['idle', 'danceLeft', 'danceRight',];
							if (shouldshit.contains(anim.animPrefix))
							{
								var animPrefix:String = '' + anim.animPrefix;
								var animName:String = '' + anim.animName;
								var animFpsVal:Int = anim.fpsValue;
								var animLooping:Bool = !!anim.looping;
								var animIndices:Array<Int> = anim.indices;
								if (animIndices != null && animIndices.length > 0)
								{
									animation.addByIndices(animPrefix, animName, animIndices, "", animFpsVal, animLooping);
								}
								else
								{
									animation.addByPrefix(animPrefix, animName, animFpsVal, animLooping);
								}

								if (anim.offset != null && anim.offset.length > 1)
									addOffset(anim.animPrefix, anim.offset[0], anim.offset[1]);
							}
						}
						else
						{
							var animPrefix:String = '' + anim.animPrefix;
							var animName:String = '' + anim.animName;
							var animFpsVal:Int = anim.fpsValue;
							var animLooping:Bool = !!anim.looping;
							var animIndices:Array<Int> = anim.indices;
							if (animIndices != null && animIndices.length > 0)
							{
								animation.addByIndices(animPrefix, animName, animIndices, "", animFpsVal, animLooping);
							}
							else
							{
								animation.addByPrefix(animPrefix, animName, animFpsVal, animLooping);
							}

							if (anim.offset != null && anim.offset.length > 1)
								addOffset(anim.animPrefix, anim.offset[0], anim.offset[1]);
						}
					}
				}
		}
		previousFlipX = flipX;

		defineIdleDance();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			/*// Doesn't flip for BF, since his are already in the right place???
				if (!curCharacter.startsWith('bf'))
				{
					// var animArray
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;

					// IF THEY HAVE MISS ANIMATIONS??
					if (animation.getByName('singRIGHTmiss') != null)
					{
						var oldMiss = animation.getByName('singRIGHTmiss').frames;
						animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
						animation.getByName('singLEFTmiss').frames = oldMiss;
					}
			}*/
		}

		if (!usedForStoryChar)
		{
			switch (curCharacter)
			{
				case 'pico-speaker':
					canDance = false;
					loadMappedAnims();
					playAnim("shoot1");
			}
		}
	}

	public var animNotes:Array<Dynamic> = []; // used for pico-speaker

	public var canDance:Bool = true;

	public var defaultAnims:Array<String> = [
		'idle', 'danceLeft', 'danceRight', 'singRIGHT', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT-alt', 'singLEFT-alt', 'singDOWN-alt', 'singUP-alt',
	];

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			/*if(heyTimer > 0)
				{
					heyTimer -= elapsed;
					if(heyTimer <= 0)
					{
						if(specialAnim && defaultAnims.contains(animation.curAnim.name))
						{
							specialAnim = false;
							dance();
						}
						heyTimer = 0;
					}
			} else*/
			if (specialAnim)
			{
				if (defaultAnims.contains(animation.curAnim.name))
				{
					specialAnim = false;
					dance();
				}

				if (animation.curAnim.finished)
				{
					specialAnim = false;
					dance();
				}
			}

			switch (curCharacter)
			{
				case 'pico-speaker':
					if (animNotes.length > 0 && Conductor.songPosition > animNotes[0][0])
					{
						var noteData:Int = 1;
						if (animNotes[0][1] > 2)
							noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animNotes.shift();
					}
					if (animation.curAnim.finished)
						playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			}
			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * 0.001 * charHoldTime)
				{
					dance();
					holdTimer = 0;
				}
			}
			// finally.
			if (animation.curAnim.finished)
			{
				if (animation.getByName(animation.curAnim.name + '-looping') != null)
					playAnim(animation.curAnim.name + '-looping');
			}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	var idleDance:Bool = false;

	var danceShit:Bool = false;

	public function dance()
	{
		if (canDance)
		{
			if (!debugMode)
			{
				if (!specialAnim)
				{
					if (!gfTestBop)
					{
						if (idleDance)
						{
							danced = !danced;

							if (danced)
								playAnim('danceRight');
							else
								playAnim('danceLeft');
						}
						else if (animation.getByName('idle') != null)
						{
							playAnim('idle');
						}
					}
					else
					{
						if (animation.getByName('idle') != null)
						{
							playAnim('idle');
						}
						else
						{
							if (animation.curAnim.name == 'danceRight' && animation.curAnim.finished)
							{
								playAnim('danceLeft');
							}
							else if (animation.curAnim.name == 'danceLeft' && animation.curAnim.finished)
							{
								playAnim('danceRight');
							}
						}
					}
				}
			}
		}
	}

	public function defineIdleDance()
	{
		idleDance = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;

		animation.play(AnimName, Force, Reversed, Frame);
		// updateHitbox();
		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	function loadMappedAnims():Void
	{
		var nd:Array<SwagSection> = Song.loadFromJson('picoGunMap', PlayState.SONG.song.toLowerCase().replace(' ', '-')).notes;
		for (s in nd)
		{
			for (sn in s.sectionNotes)
			{
				animNotes.push(sn);
			}
		}
		BackgroundTankmen.animNotes = animNotes;
		animNotes.sort(sortByValue);
	}

	function sortByValue(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}
}
