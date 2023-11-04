package meta.substates;

import flixel.math.FlxPoint;
import openfl.ui.Mouse;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import game.objects.*;
import game.*;

class RatingPosition extends MusicBeatSubstate
{
	var rating:FlxSprite = new FlxSprite();
	var combo:Int = 6;

	public var leftState:Bool = false;

	var defXPos:Float = FlxG.width * 0.55 - 135;
	var defYPos:Float = FlxG.height / 2 - 50;

	var onRange:Bool = false;

	var onRangee:Bool = false;

	var grpCombo:FlxSpriteGroup;
	var daLoop:Int = 0;

	private var camHUD:FlxCamera;
	var strumXpos:Float = 35;
	private var strumLine:FlxSprite;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	var p2Strums:FlxTypedGroup<FlxSprite>;

	public function new(isFromPause:Bool = false)
	{
		super();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);

		// basically ripped off from playstate
		// cuz' i'm lazy
		rating = new FlxSprite().loadGraphic(Paths.image('sick', 'shared'));
		rating.setGraphicSize(Std.int(rating.width * 0.6));
		rating.antialiasing = CDevConfig.saveData.antialiasing;
		add(rating);

		rating.cameras = [camHUD];

		var originalXPos:Float = 65;

		if (CDevConfig.saveData.middlescroll)
			originalXPos = -290;
		// originalXPos = -278;

		strumXpos = originalXPos;

		grpCombo = new FlxSpriteGroup();
		grpCombo.cameras = [camHUD];
		add(grpCombo);

		combo = FlxG.random.int(100, 600);

		var seperatedScore:Array<Int> = [];

		if (combo >= 100)
			seperatedScore.push(Math.floor(combo / 100) % 10);

		if (combo >= 10)
			seperatedScore.push(Math.floor(combo / 10) % 10);

		seperatedScore.push(combo % 10);

		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
			numScore.x = 36 * daLoop;
			numScore.ID = daLoop;
			numScore.antialiasing = CDevConfig.saveData.antialiasing;
			numScore.setGraphicSize(Std.int(numScore.width * 0.4));
			numScore.updateHitbox();
			numScore.cameras = [camHUD];
			numScore.scrollFactor.set();
			grpCombo.add(numScore);
			daLoop++;
		}
		grpCombo.scrollFactor.set();

		strumLine = new FlxSprite(strumXpos, 70).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (CDevConfig.saveData.downscroll)
			strumLine.y = FlxG.height - 160;

		FlxG.mouse.visible = true;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		p2Strums = new FlxTypedGroup<FlxSprite>();

		var versionSht:FlxText = new FlxText(20, FlxG.height - 150, 1000, 'Drag the Rating sprite to change\nthe position.', 24);
		versionSht.scrollFactor.set();
		versionSht.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionSht.screenCenter(X);
		versionSht.borderSize = 2;
		add(versionSht);

		if (!CDevConfig.saveData.rChanged)
		{
			CDevConfig.saveData.rX = defXPos;
			CDevConfig.saveData.rY = defXPos;
		}

		rating.x = CDevConfig.saveData.rX;
		rating.y = CDevConfig.saveData.rY;
		rating.scrollFactor.set();

		if (CDevConfig.saveData.cChanged)
		{
			grpCombo.x = CDevConfig.saveData.cX;
			grpCombo.y = CDevConfig.saveData.cY;
		}
		else
		{
			grpCombo.x = rating.x - 50;
			grpCombo.y = rating.y + 100;
		}

		grpCombo.scrollFactor.set();

		if (!isFromPause){
			if (!CDevConfig.saveData.middlescroll)
				generateStaticArrows(0);
	
			generateStaticArrows(1);
		}


		rating.updateHitbox();
		grpCombo.updateHitbox();

		if (isFromPause)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var selectedThing:Bool = false;
	var sel:String = "";

	var mouseOffset:FlxPoint = new FlxPoint(0,0);

	override function update(elapsed:Float)
	{
		// dumb codes

		onRange = ((FlxG.mouse.getScreenPosition(camHUD).x >= rating.x)
			&& (FlxG.mouse.getScreenPosition(camHUD).x < rating.x + rating.width)
			&& (FlxG.mouse.getScreenPosition(camHUD).y >= rating.y)
			&& (FlxG.mouse.getScreenPosition(camHUD).y < rating.y + rating.height));

		onRangee = ((FlxG.mouse.getScreenPosition(camHUD).x >= grpCombo.x)
			&& (FlxG.mouse.getScreenPosition(camHUD).x < grpCombo.x + grpCombo.width)
			&& (FlxG.mouse.getScreenPosition(camHUD).y >= grpCombo.y)
			&& (FlxG.mouse.getScreenPosition(camHUD).y < grpCombo.y + grpCombo.height));

		if ((onRange || onRangee) && FlxG.mouse.justPressed && !selectedThing){
			var mP = [FlxG.mouse.getScreenPosition(camHUD).x, FlxG.mouse.getScreenPosition(camHUD).y];
			mouseOffset.x = (onRange ? rating.x - mP[0] : grpCombo.x - mP[0]);
			mouseOffset.y = (onRange ? rating.y - mP[1] : grpCombo.y - mP[1]);
		}
		if ((onRange || onRangee) && FlxG.mouse.pressed && !selectedThing)
		{
			sel = (onRange ? "rating" : "combo");
			selectedThing = true;
		}

		if (selectedThing)
		{
			switch (sel)
			{
				case "rating":
					rating.x = (FlxG.mouse.getScreenPosition(camHUD).x + mouseOffset.x);
					rating.y = (FlxG.mouse.getScreenPosition(camHUD).y + mouseOffset.y);
				case "combo":
					grpCombo.x = (FlxG.mouse.getScreenPosition(camHUD).x + mouseOffset.x);
					grpCombo.y = (FlxG.mouse.getScreenPosition(camHUD).y + mouseOffset.y);
			}
		}

		if (sel != "" && FlxG.mouse.justReleased)
		{
			selectedThing = false;
			switch (sel)
			{
				case "rating":
					CDevConfig.saveData.rX = rating.x;
					CDevConfig.saveData.rY = rating.y;
					CDevConfig.saveData.rChanged = true;
				case "combo":
					trace([grpCombo.members[0].getScreenPosition(FlxG.mouse.getPosition(), camHUD).x, grpCombo.members[0].getScreenPosition(FlxG.mouse.getPosition(), camHUD).y]);
					CDevConfig.saveData.cX = grpCombo.members[0].getScreenPosition(FlxG.mouse.getPosition(), camHUD).x + (43 *2);
					CDevConfig.saveData.cY = grpCombo.members[0].getScreenPosition(FlxG.mouse.getPosition(), camHUD).y + 43;
					CDevConfig.saveData.cChanged = true;
			}
			sel = "";
		}

		if (controls.RESET)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			CDevConfig.saveData.rX = defXPos;
			CDevConfig.saveData.rY = defYPos;

			CDevConfig.saveData.cChanged = false;

			rating.setPosition(defXPos, defYPos);
			grpCombo.setPosition(defXPos - 90 - 43, rating.y + 100 - 43);
		}

		if (controls.BACK)
		{
			leftState = true;
			close();
		}

		super.update(elapsed);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(strumXpos, strumLine.y);

			if (CDevConfig.saveData.fnfNotes)
			{
				babyArrow.frames = Paths.getSparrowAtlas('notes/NOTE_assets', "shared");
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.antialiasing = CDevConfig.saveData.antialiasing;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

				switch (Math.abs(i))
				{
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.addByPrefix('static', 'arrowLEFT');
						babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.addByPrefix('static', 'arrowDOWN');
						babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.addByPrefix('static', 'arrowUP');
						babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
						babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
				}
			}
			else
			{
				babyArrow.frames = Paths.getSparrowAtlas('notes/CDEVNOTE_assets', "shared");
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.antialiasing = CDevConfig.saveData.antialiasing;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));

				switch (Math.abs(i))
				{
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.addByPrefix('static', 'arrowLEFT-static');
						babyArrow.animation.addByPrefix('pressed', 'arrowLEFT-pressed', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'arrowLEFT-confirm', 24, false);
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.addByPrefix('static', 'arrowDOWN-static');
						babyArrow.animation.addByPrefix('pressed', 'arrowDOWN-pressed', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'arrowDOWN-confirm', 24, false);
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.addByPrefix('static', 'arrowUP-static');
						babyArrow.animation.addByPrefix('pressed', 'arrowUP-pressed', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'arrowUP-confirm', 24, false);
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.addByPrefix('static', 'arrowRIGHT-static');
						babyArrow.animation.addByPrefix('pressed', 'arrowRIGHT-pressed', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'arrowRIGHT-confirm', 24, false);
				}
			}

			babyArrow.ID = i;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			switch (player)
			{
				case 0:
					p2Strums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (CDevConfig.saveData.botplay)
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.centerOffsets();
				});

			p2Strums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets();
			});
			strumLineNotes.add(babyArrow);
		}
	}
}

class ComboCounter
{
	public static function checkDragableObject(obj:FlxSprite):Bool
	{
		// haxe hitboxes are a bit weird if scaling was applied to the object.
		obj.scrollFactor.set();
		obj.updateHitbox();
		if (FlxG.mouse.x >= obj.x
			&& FlxG.mouse.x < (obj.width * obj.scale.x)
			&& FlxG.mouse.y >= obj.y
			&& FlxG.mouse.y < (obj.height * obj.scale.y))
		{
			trace("it is dragable");
			return true;
		}

		return false;
	}

	public static function getDragableObjectPos(obj:FlxSprite):FlxPoint
	{
		obj.scrollFactor.set();
		obj.updateHitbox();
		return new FlxPoint((FlxG.mouse.x - (obj.x+(obj.width*obj.scale.x)))
		,(FlxG.mouse.y - (obj.x+(obj.width*obj.scale.x))));
	}
}
