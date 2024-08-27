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
import meta.states.PlayState;

using StringTools;

/**
 * Note object for Funkin
 */
class Note extends FlxSprite
{
	public static var default_notetypes:Array<String> = ["Default Note", "Alt Anim", "No Animation", "GF Note"];
	public static var NOTE_TEXTURE:FlxAtlasFrames = null;

	public static var defaultGraphicSize:Float = 160;
	public static var noteScale(default,set):Float = 0.62;
	static function set_noteScale(val:Float):Float {
		swagWidth = defaultGraphicSize * val;
		return noteScale = val;
	}
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

	public var rating:String = "shit";

	// TESTING AND SHET
	public var mainNote:Note = null; // used for sustain notes.
	public var strumParent:StrumArrow;

	/**
	 * Creates a new Note object (You need to call `load` after calling this).
	 */
	public function new()
	{
		super();
	}

	/**
	 * Get your Note ready with Data provided by your chart.
	 * @param time Strum time in miliseconds
	 * @param data Note Data / Column
	 * @param isSustain Whether if it's a sustain note or not
	 * @param lastNote Last note added to the notes group after this note
	 * @param noteTyp Note Type
	 * @param noteArg Note Arguments / Parameters
	 */
	public function load(time:Float, data:Int, isSustain:Bool = false, lastNote:Note = null, ?noteTyp:String = "Default Note", ?noteArg:Array<String>, ?noteSkin:String)
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
				ScriptSupport.setScriptDefaultVars(script, PlayState.fromMod, PlayState.SONG.info.name);

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
			loadTexture(noteSkin != null ? noteSkin : "notes/NOTE_assets");
			initialize();
			if (noteType == "No Animation")
				noAnim = true;
		}
	}

	/**
	 * Call this function to fully stop scripting in this Note.
	 */
	public function disableScript()
	{
		if (script == null)
			return;
		script.destroy();
		script = null;
		gotScript = false;
	}

	/**
	 * Initializes the note, such as it's animations, scaling, flip properties, and more.
	 */
	public function initialize()
	{
		x += swagWidth * noteData;
		animation.play(directions[noteData]+'Scroll'); // Press note / normal note

		if (CDevConfig.saveData.downscroll && isSustainNote)
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			animation.play(directions[noteData]+'holdend'); // Hold tail end
			updateHitbox();

			noteYOffset = offset.y;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(directions[prevNote.noteData]+'hold'); // Hold body

				var sSpeed:Float = (CDevConfig.saveData.scrollSpeed == 1 && PlayState.SONG != null ? PlayState.SONG.info.speed : CDevConfig.saveData.scrollSpeed);
				prevNote.scale.y = ((Conductor.stepCrochet+0.5) * (sSpeed*0.45)) / prevNote.frameHeight;
				prevNote.updateHitbox();
			}
		}
	}

	/**
	 * Loads a texture this note, call this function if you want to change it's texture.
	 * @param tex Texture / Spritesheet File Path.
	 */
	public function loadTexture(tex:String = "notes/NOTE_assets")
	{
		Paths.currentMod = PlayState.fromMod;
		frames = null;
		animation.destroyAnimations();
		var newSize:Int = Std.int(swagWidth);
		if (PlayState.isPixel) { // If it's a Pixel Note / Week 6
			if (isSustainNote) {
				loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);
				animation.add('purpleholdend', [4]);
				animation.add('greenholdend', [6]);
				animation.add('redholdend', [7]);
				animation.add('blueholdend', [5]);

				animation.add('purplehold', [0]);
				animation.add('greenhold', [2]);
				animation.add('redhold', [3]);
				animation.add('bluehold', [1]);
			} else {
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);
			}

			newSize = Std.int((width * PlayState.daPixelZoom));
		} else { // If it's not a pixel note / week 6
			frames = (tex == "notes/NOTE_assets" && Note.NOTE_TEXTURE != null ? Note.NOTE_TEXTURE : Paths.getSparrowAtlas(tex));
			if (frames == null) {
				Log.warn("Texture asset \"" + tex + "\" for note type \"" + noteType + "\" doesn't exist!");
				frames = Paths.getSparrowAtlas("notes/NOTE_assets");
			}

			for (i in directions) {
				if (isSustainNote) {
					animation.addByPrefix(i+"holdend", (i == "purple" ? "pruple end hold" : i+" hold end"), 24);
					animation.addByPrefix(i+"hold", i+" hold piece", 24);
				} else {
					animation.addByPrefix(i+"Scroll", i+"0", 24);
				}
			}
			newSize = Std.int(width * noteScale);
			antialiasing = CDevConfig.saveData.antialiasing;
		}
		setGraphicSize(newSize);
		updateHitbox();
	}

	/**
	 * This function will be called on every frame update.
	 * @param elapsed Seconds passed since last frame 
	 */
	override function update(elapsed:Float)
	{
		if (gotScript)
			script.executeFunc("update", [elapsed]);
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			canBeHit = strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5);


			if (strumTime < (Conductor.songPosition - 166) /* && !wasGoodHit*/)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (Conductor.songPosition >= strumTime)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3) alpha = 0.3;
		}

		if (gotScript)
			script.executeFunc("postUpdate", [elapsed]);
	}

	/**
	 * Called when the note gets hit by either player or the opponent
	 * @param rating Rating like "sick", "bad", "good", "shit".
	 * @param player If it's true, then it means the player hits this note and vice versa.
	 */
	public function onNoteHit(rating:String, player:Bool){
		if (gotScript) script.executeFunc("onNoteHit", [rating, player]);
	}

	/**
	 * Called when this note gets spawned / added to the gameplay.
	 */
	public function onNoteSpawn(){
		if (gotScript) script.executeFunc("onNoteSpawn", []);
	}

	/**
	 * Called when the player missed this note.
	 */
	public function onNoteMiss() {
		if (gotScript) script.executeFunc("onNoteMiss", []);
	}

	public function resetProp() {
		if (gotScript) {
			script.destroy();
		}
	}

	/** You should ignore anything below this comment **/

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
				return [];
			}
		}
		else
		{
			return [];
		}

		return notesNames;
	}

	public static function getNoteInfo(ntDt:Int = 0):Note
	{
		var noteToReturn:Note = new Note();
		noteToReturn.load(0,(ntDt==-1?0:ntDt));
		return noteToReturn;
	}
}