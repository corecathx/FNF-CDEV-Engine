package game;

import cdev.CDevConfig;
import shaders.WiggleEffect;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import states.PlayState;

using StringTools;

class Note extends FlxSprite
{	
	public static var noteScale:Float = 0.65;

	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var isPixelSkinNote:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var isTesting:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * noteScale;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var noteYOffset:Float = 0;

	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	// used for hscript
	public var followX:Bool = true;
	public var followY:Bool = true;

	// follow the strum's arrow angle & alpha
	public var followAngle:Bool = true;
	public var followAlpha:Bool = true;

	public var graphicHeightOrigin:Float = 0;
	public var theYScale:Float = 0;

	public var rating:String = "shit";

	public var noteColor:FlxColor = FlxColor.WHITE;

	var noteBeat:Float = 0;

	// TESTING AND SHET
	public var noteTrail:Array<Note> = []; // note trail yes
	public var strumParent:StrumArrow;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?MustCalcStepHeight:Bool = true, ?beatVal:Float = 0)
	{
		super();
		noteBeat = beatVal;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += PlayState.strumXpos + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

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

			setGraphicSize(Std.int(width * (PlayState.daPixelZoom-0.1)));
			updateHitbox();
			isPixelSkinNote = true;
			graphicHeightOrigin = height;
		}
		else
		{
			if (CDevConfig.saveData.fnfNotes)
			{
				frames = Paths.getSparrowAtlas('notes/NOTE_assets');

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
			else
			{
				frames = Paths.getSparrowAtlas('notes/CDEVNOTE_assets', 'shared');
				var aa:Array<String> = ['arrowLEFT', 'arrowDOWN', 'arrowUP', 'arrowRIGHT'];
				animation.addByPrefix('greenScroll', '${aa[2]}0');
				animation.addByPrefix('redScroll', '${aa[3]}0');
				animation.addByPrefix('blueScroll', '${aa[1]}0');
				animation.addByPrefix('purpleScroll', '${aa[0]}0');

				animation.addByPrefix('purpleholdend', 'arrowEnd');
				animation.addByPrefix('greenholdend', 'arrowEnd');
				animation.addByPrefix('redholdend', 'arrowEnd');
				animation.addByPrefix('blueholdend', 'arrowEnd');

				animation.addByPrefix('purplehold', 'arrowHold');
				animation.addByPrefix('greenhold', 'arrowHold');
				animation.addByPrefix('redhold', 'arrowHold');
				animation.addByPrefix('bluehold', 'arrowHold');

				setGraphicSize(Std.int(width * noteScale));
				updateHitbox();
				antialiasing = CDevConfig.saveData.antialiasing;
			}
		}

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
		prevNote.graphicHeightOrigin = prevNote.frameHeight;

		// trace(prevNote);
		if (CDevConfig.saveData.downscroll && sustainNote)
			flipY = true;

		if (MustCalcStepHeight)
			calculateNoteStepHeight();

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
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

			if (PlayState.curStage.startsWith('school'))
				x += 30;

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
				var shit:Float = (CDevConfig.saveData.scrollSpeed == 1 ? PlayState.SONG.speed : CDevConfig.saveData.scrollSpeed);
				prevNote.scale.y *= (Conductor.stepCrochet+10) / 100 * 1.5 * shit;
				prevNote.theYScale = prevNote.scale.y;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
				prevNote.noteYOffset = Math.round(prevNote.offset.y);

				// prevNote.setGraphicSize();

				noteYOffset = Math.round(offset.y);
			}

			noteColor = CDevConfig.utils.getColor(this);
		}
	}

	function changeNoteColor(newColor:Int)
	{
		color = newColor;
		noteColor = newColor;
	}

	var noteStepHeight:Float = 0;

	function calculateNoteStepHeight()
	{
		if (!isTesting)
			noteStepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(CDevConfig.saveData.scrollSpeed == 1 ? PlayState.SONG.speed : CDevConfig.saveData.scrollSpeed,
				2));
	}

	public static function getNoteInfo(ntDt:Int = 0):Note
	{
		var noteToReturn:Note;
		if (ntDt == -1)
			noteToReturn = new Note(0, 0);
		else
			noteToReturn = new Note(0, ntDt);

		return noteToReturn;
	}

	public function curAnim():String
	{
		return animation.curAnim.name; // shut
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!isTesting)
		{
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
		}
	}
}
