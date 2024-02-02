package game.objects;

import game.cdev.script.ScriptSupport;
import game.cdev.script.CDevScript;
import game.Stage.SpriteStage;
import meta.states.PlayState;
import game.cdev.engineutils.Highscore;
import flixel.util.FlxSort;
import game.song.Song;
import game.song.Section.SwagSection;
import meta.modding.char_editor.CharacterData.CharData;
import meta.modding.char_editor.CharacterData.AnimationArray;
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

	public var script:CDevScript;
	public var gotScript:Bool = false;

	var charLists:Array<String> = [];

	public var curCharacter:String = 'bf';
	public var specialAnim:Bool = false;
	public var heyTimer:Float = 0;

	public var singAltPrefix:String = "-alt"; // used For Alt anims
	public var idleAltPrefix:String = "-alt"; // overrides the default -alt prefix, if not ""
	public var idleSpeed:Int = 2;
	public var forceDance:Bool = false;

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

	//public var gfTestBop:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?usedForStoryChar:Bool = false)
	{
		super(x, y);
	
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		if (!debugMode) initScript();

		executeFunc("create", []);

		antialiasing = CDevConfig.saveData.antialiasing;

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
				if (!CDevConfig.saveData.antialiasing) // force disable antialiasing while CDevConfig.saveData.antialiasing was false.
					antialiasing = false;

				if (animArray != null && animArray.length > 0)
				{
					for (anim in animArray)
					{
						var animPrefix:String = '' + anim.animPrefix;
						var animName:String = '' + anim.animName;
						var animFpsVal:Int = anim.fpsValue;
						var animLooping:Bool = !!anim.looping;
						var animIndices:Array<Int> = anim.indices;
						var shouldshit:Array<String> = ['idle', 'danceLeft', 'danceRight'];

						if (usedForStoryChar && !shouldshit.contains(anim.animPrefix)) 
							continue;

						if (animIndices != null && animIndices.length > 0)
							animation.addByIndices(animPrefix, animName, animIndices, "", animFpsVal, animLooping);
						else
							animation.addByPrefix(animPrefix, animName, animFpsVal, animLooping);

						if (anim.offset != null && anim.offset.length > 1) 
							addOffset(anim.animPrefix, anim.offset[0], anim.offset[1]);
					}
				}
		}

		previousFlipX = flipX;

		if (isPlayer)
		{
			flipX = !flipX;
		}

		defineIdleDance();
		dance(false, 1);

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

		executeFunc("postCreate", []);
	}

	public function initScript(){
		if (debugMode) return;
		var scriptPath:String = Paths.modFolders("data/characters/"+curCharacter+".hx");
		if (!FileSystem.exists(scriptPath)) return;

		script = CDevScript.create(scriptPath);
		gotScript = true;
		script.setVariable("current", this);
		ScriptSupport.setScriptDefaultVars(script, PlayState.fromMod, PlayState.SONG.song);
		script.loadFile(scriptPath);
	}

	public var animNotes:Array<Dynamic> = []; // used for pico-speaker

	public var canDance:Bool = true;

	public var defaultAnims:Array<String> = [
		'idle', 'danceLeft', 'danceRight', 'singRIGHT', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT-alt', 'singLEFT-alt', 'singDOWN-alt', 'singUP-alt',
	];

	override function update(elapsed:Float)
	{
		executeFunc("update", [elapsed]);
		if (debugMode) {
			if (gotScript){
				gotScript = false;
				script.destroy();
			}
		}
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
					dance(animation.curAnim.name.endsWith(singAltPrefix), 1);
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
		executeFunc("postUpdate", [elapsed]);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	var idleDance:Bool = false;

	var danceShit:Bool = false;

	public function dance(?alt:Bool = false, ?beat:Int = 1)
	{
		executeFunc("onDance", [alt, beat]);
		if (!canDance)
			return;
		if (debugMode)
			return;
		if (specialAnim)
			return;
		if (forceDance && beat % idleSpeed == 0)
			return;

		var dRight:String = "danceRight"+(alt?idleAltPrefix:"");
		var dLeft:String = "danceLeft"+(alt?idleAltPrefix:"");
		var aIdle:String = "idle"+(alt?idleAltPrefix:"");

		if ((animation.getByName(dLeft) != null && animation.getByName(dRight) != null))
		{
			danced = !danced;

			if (danced)
				playAnim(dRight,forceDance);
			else
				playAnim(dLeft,forceDance);
		}
		else if (animation.getByName(aIdle) != null)
		{
			playAnim(aIdle, forceDance);
		}
		executeFunc("onPostDance", [alt, beat]);
	}

	public function defineIdleDance()
	{
		idleDance = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		executeFunc("onPlayAnim", [AnimName, Force, Reversed, Frame]);
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
		executeFunc("onPostPlayAnim", [AnimName, Force, Reversed, Frame]);
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

	public function executeFunc(name,data){
		if (!gotScript) return;
		script.executeFunc(name, data);
	}
}
