package game.objects;

import game.cdev.script.ScriptSupport;
import game.cdev.script.CDevScript;
import sys.FileSystem;
import game.cdev.CDevConfig;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import meta.states.PlayState;

using StringTools;

/**
 * Note object for Funkin
 */
class Note extends FlxSprite
{
	public static var NOTE_TEXTURE:FlxAtlasFrames = null;
	public static var noteScale:Float = 0.65;
	public static var defaultGraphicSize:Float = 160;
	public static var swagWidth:Float = defaultGraphicSize * noteScale; // Parent note size after scaling
	public static var directions:Array<String> = ["purple", "blue", "green", "red"];

	// avoid repetitive missing note type file warnings
	public static var noteTypeFail:Array<String> = [];

	public var script:CDevScript = null;

	var gotScript:Bool = false;

	// Data stuff retrieved from the chart json
	public var strumTime:Float = 0;
	public var noteData:Int = 0;
	public var isSustainNote:Bool = false;
	public var noteType:String = "Default Note";
	public var noteArgs:Array<String> = ["", ""];

	// Indicating if this note belongs to the player or opponent
	public var mustPress:Bool = false;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	// Legacy chart editor stuffs
	public var sustainLength:Float = 0;
	public var rawNoteData:Int = 0;
	public var noteStep:Int = 0;

	public var noteYOffset:Float = 0;

	// HScript stuffs
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var followX:Bool = true;
	public var followY:Bool = true;
	public var noAnim:Bool = false; // Whether this note should trigger an animation?
	public var canIgnore:Bool = false;

	public var followAngle:Bool = true; // follow the strum's arrow angle
	public var followAlpha:Bool = true; // and alpha

	public var graphicHeightOrigin:Float = 0;
	public var theYScale:Float = 0;

	public var rating:String = "shit";

	// TESTING AND SHET
	public var mainNote:Note = null; // used for sustain notes.
	public var strumParent:StrumArrow;

	// Creates a new note object.
	public function new()
	{
		super();
	}

	public function load(time:Float, data:Int, isSustain:Bool = false, lastNote:Note = null, ?noteTyp:String = "Default Note", ?noteArg:Array<String>)
	{
		prevNote = (lastNote == null) ? this : lastNote;
		isSustainNote = isSustain;
		strumTime = time;
		noteData = data;
		noteType = noteTyp;
		noteArgs = noteArg == null ? ['',''] : noteArg;

		x += PlayState.strumXpos + 50;
		y -= 2000;

		// damn bro.
		if (!default_notetypes.contains(noteType))
		{
			var scriptPath:String = Paths.modFolders("notes/" + noteType + ".hx");
			if (FileSystem.exists(scriptPath))
			{
				script = CDevScript.create(scriptPath);
				gotScript = true;

				script.setVariable("initialize", initialize);
				script.setVariable("loadTexture", loadTexture);
				script.setVariable("current", this);
				ScriptSupport.setScriptDefaultVars(script, PlayState.fromMod, PlayState.SONG.song);

				script.loadFile(scriptPath);

				if (gotScript)
					script.executeFunc("create", noteArgs);
			}
			else
			{
				if (!noteTypeFail.contains(noteType))
				{
					noteTypeFail.push(noteType);
					Log.warn("Note Type " + noteType + " doesn't exist on path " + scriptPath);
				}
				loadTexture("notes/NOTE_assets");
				initialize();
			}
		}
		else
		{
			loadTexture("notes/NOTE_assets");
			initialize();
			if (noteType == "No Animation")
				noAnim = true;
		}
	}

	public function disableScript()
	{
		if (script == null)
			return;
		script.destroy();
		script = null;
		gotScript = false;
	}

	public static var traceMe:Bool = false;
	public function initialize()
	{
		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		graphicHeightOrigin = frameHeight;
		// prevNote.graphicHeightOrigin = prevNote.frameHeight;

		if (CDevConfig.saveData.downscroll && isSustainNote)
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			// noteScore * 0.2;
			alpha = 0.6;

			x += width / 2 + 30;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2 + 30;
			noteYOffset = offset.y;
			if (PlayState.curStage.startsWith('school'))
				x += 30;

			var sSpeed:Float = (CDevConfig.saveData.scrollSpeed == 1
				&& PlayState.SONG != null ? PlayState.SONG.speed : CDevConfig.saveData.scrollSpeed);
			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y = ((Conductor.stepCrochet+2) * (sSpeed*0.45)) / 44;

				if (!traceMe) {
					traceMe = true;
					trace(prevNote.scale.y);
				}

				prevNote.updateHitbox();
			}
		}
	}

	public function loadTexture(tex:String = "notes/NOTE_assets")
	{
		Paths.currentMod = PlayState.fromMod;

		var pixelStage:Bool = PlayState.isPixel;

		if (pixelStage)
		{
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);

			animation.add('greenScroll', [6]);
			animation.add('redScroll', [7]);
			animation.add('blueScroll', [5]);
			animation.add('purpleScroll', [4]);

			if (isSustainNote)
			{
				loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);

				animation.add('purpleholdend', [4]);
				animation.add('greenholdend', [6]);
				animation.add('redholdend', [7]);
				animation.add('blueholdend', [5]);

				animation.add('purplehold', [0]);
				animation.add('greenhold', [2]);
				animation.add('redhold', [3]);
				animation.add('bluehold', [1]);
			}

			setGraphicSize(Std.int(width * (PlayState.daPixelZoom - 0.1)));
			updateHitbox();
			graphicHeightOrigin = height;
		}
		else
		{
			// What
			frames = (tex == "notes/NOTE_assets" && Note.NOTE_TEXTURE != null ? Note.NOTE_TEXTURE : Paths.getSparrowAtlas(tex, "shared"));
			if (frames == null)
			{
				Log.warn("Note.hx:0: Texture asset \"" + tex + "\" for note type \"" + noteType + "\" doesn't exist!");
				frames = Paths.getSparrowAtlas("notes/NOTE_assets", "shared");
			}

			animation.addByPrefix('greenScroll', 'green0');
			animation.addByPrefix('redScroll', 'red0');
			animation.addByPrefix('blueScroll', 'blue0');
			animation.addByPrefix('purpleScroll', 'purple0');

			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');

			setGraphicSize(Std.int(width * noteScale));
			updateHitbox();
			antialiasing = CDevConfig.saveData.antialiasing;
		}
	}

	public static function getNoteInfo(ntDt:Int = 0):Note
	{
		var noteToReturn:Note = new Note();
		noteToReturn.load(0,(ntDt==-1?0:ntDt));
		return noteToReturn;
	}

	public function curAnim():String
	{
		return animation.curAnim.name; // shut
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < (Conductor.songPosition - 166) /* && !wasGoodHit*/)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}

		if (gotScript)
			script.executeFunc("update", [elapsed]);
	}

	// scripting purposes
	public function onNoteHit(rating:String, player:Bool)
	{
		if (gotScript)
			script.executeFunc("onNoteHit", [rating, player]);
	}

	public function onNoteSpawn()
	{
		if (gotScript)
			script.executeFunc("onNoteSpawn", []);
	}

	public function onNoteMiss()
	{
		if (gotScript)
			script.executeFunc("onNoteMiss", []);
	}

	public static var default_notetypes:Array<String> = ["Default Note", "Alt Anim", "No Animation", "GF Note"];

	// COPIED STRAIGHT FROM CHARTEVENT.HX LOLLL
	public static function getNoteList()
	{
		var notesNames:Array<String> = [];
		var path:Array<String> = [];
		var canDoShit = false;
		if (FileSystem.exists(Paths.modFolders("notes/")))
		{
			path = FileSystem.readDirectory(Paths.modFolders("notes/"));
			canDoShit = true;
		}
		if (canDoShit)
		{
			if (path.length > 0)
			{
				for (i in 0...path.length)
				{
					var noteShit:String = path[i];
					if (noteShit.endsWith(".hx"))
					{
						noteShit = noteShit.substr(0, noteShit.length - 3);
						notesNames.push(noteShit);
						trace("loaded " + noteShit);
					}
				}
			}
			else
			{
				return [""];
			}
		}
		else
		{
			return [""];
		}

		return notesNames;
	}
}