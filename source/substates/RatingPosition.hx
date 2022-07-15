package substates;

import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import game.*;

class RatingPosition extends MusicBeatSubstate
{
	var rating:FlxSprite = new FlxSprite();
	var combo:Int = 248;

	var defXPos:Float = FlxG.width * 0.55 - 135;
	var defYPos:Float = FlxG.height / 2 - 50;

	var onRange:Bool = false;

	var grpCombo:FlxTypedGroup<FlxSprite>;
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
		rating = new FlxSprite().loadGraphic(Paths.image('perfect', 'shared'));
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = FlxG.save.data.antialiasing;
		add(rating);

		rating.cameras = [camHUD];

		var originalXPos:Float = 45;

		if (FlxG.save.data.middlescroll)
			originalXPos = -270;
		// originalXPos = -278;

		strumXpos = originalXPos;

		grpCombo = new FlxTypedGroup<FlxSprite>();
		add(grpCombo);

		var seperatedScore:Array<Int> = [];

		if (combo >= 100)
			seperatedScore.push(Math.floor(combo / 100) % 10);

		if (combo >= 10)
			seperatedScore.push(Math.floor(combo / 10) % 10);

		seperatedScore.push(combo % 10);

		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
			numScore.screenCenter();
			numScore.x = rating.x + (43 * daLoop) - 50;
			numScore.y = rating.y + 100;
			numScore.antialiasing = FlxG.save.data.antialiasing;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();

			numScore.cameras = [camHUD];
			grpCombo.add(numScore);

			daLoop++;
		}

		strumLine = new FlxSprite(strumXpos, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
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

		if (!FlxG.save.data.rChanged)
		{
			FlxG.save.data.rX = defXPos;
			FlxG.save.data.rY = defXPos;
		}

		rating.x = FlxG.save.data.rX;
		rating.y = FlxG.save.data.rY;
		for (i in 0...grpCombo.length)
		{
			grpCombo.members[i].x = rating.x + (43 * i) - 50;
			grpCombo.members[i].y = rating.y + 100;
		}

		if (!FlxG.save.data.middlescroll)
			generateStaticArrows(0);
		generateStaticArrows(1);

		rating.updateHitbox();

		if (isFromPause)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		// dumb codes

		if ((FlxG.mouse.getScreenPosition().x >= rating.x)
			&& (FlxG.mouse.getScreenPosition().x < rating.x + rating.width)
			&& (FlxG.mouse.getScreenPosition().y >= rating.y)
			&& (FlxG.mouse.getScreenPosition().y < rating.y + rating.height))
			onRange = true;

		if (onRange && FlxG.mouse.pressed)
		{
			rating.x = (FlxG.mouse.getPositionInCameraView().x - rating.width / 2);
			rating.y = (FlxG.mouse.getPositionInCameraView().y - rating.height) + 60;
			for (i in 0...grpCombo.length)
			{
				grpCombo.members[i].x = rating.x + (43 * i) - 50;
				grpCombo.members[i].y = rating.y + 100;
			}
		}

		if (onRange && FlxG.mouse.justReleased)
		{
			FlxG.save.data.rX = rating.x;
			FlxG.save.data.rY = rating.y;
			FlxG.save.data.rChanged = true;
		}

		if (controls.RESET)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.save.data.rX = defXPos;
			FlxG.save.data.rY = defYPos;

			rating.setPosition(defXPos, defYPos);
			for (i in 0...grpCombo.length)
			{
				grpCombo.members[i].setPosition(defXPos + (43 * i) - 90, defYPos);
			}
		}

		if (controls.BACK)
		{
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

			if (FlxG.save.data.fnfNotes)
			{
				babyArrow.frames = Paths.getSparrowAtlas('notes/NOTE_assets');
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.antialiasing = FlxG.save.data.antialiasing;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

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
				babyArrow.frames = Paths.getSparrowAtlas('notes/CDEVNOTE_assets');
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.antialiasing = FlxG.save.data.antialiasing;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

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

			if (FlxG.save.data.botplay)
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
