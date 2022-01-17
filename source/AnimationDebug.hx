package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;

/**
	*DEBUG MODE
 */
class AnimationDebug extends FlxState
{
	var bf:Boyfriend;
	var dad:Character;
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

		//var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		//gridBG.scrollFactor.set(0.5, 0.5);
		//add(gridBG);

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('menuDesat', 'preload'));
		bg.antialiasing = true;
		bg.scale.set(1.5, 1.5);
		bg.screenCenter();
		bg.scrollFactor.set(0.3, 0.3);
		bg.active = false;
		add(bg);

		if (daAnim == 'bf')
			isDad = false;

		if (isDad)
		{
			dad = new Character(0, 0, daAnim);
			dad.screenCenter();
			dad.debugMode = true;
			add(dad);

			char = dad;
			dad.flipX = false;
		}
		else
		{
			bf = new Boyfriend(0, 0);
			bf.screenCenter();
			bf.debugMode = true;
			add(bf);

			char = bf;
			bf.flipX = false;
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		textAnim.setFormat('VCR OSD Mono',26,FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(textAnim);

		genBoyOffsets();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		FlxG.camera.focusOn(camFollow.getPosition());

		FlxCamera.defaultCameras = [camGame];

		textAnim.cameras = [camHUD];
		dumbTexts.cameras = [camHUD];
		super.create();
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(20, 65 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.WHITE;
			text.setFormat('VCR OSD Mono',15,FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;

		//zoom
		if (FlxG.keys.pressed.E)
			FlxG.camera.zoom += 0.01 + (FlxG.keys.pressed.SHIFT ? 0.2 : 0);
		if (FlxG.keys.pressed.Q)
			FlxG.camera.zoom -= 0.01 + (FlxG.keys.pressed.SHIFT ? 0.2 : 0);

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90 * (FlxG.keys.pressed.SHIFT ? 2 : 1);
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90 * (FlxG.keys.pressed.SHIFT ? 2 : 1);
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90 * (FlxG.keys.pressed.SHIFT ? 2 : 1);
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90 * (FlxG.keys.pressed.SHIFT ? 2 : 1);
			else
				camFollow.velocity.x = 0 * (FlxG.keys.pressed.SHIFT ? 2 : 1);
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.ENTER)
			{
				FlxG.switchState(new PlayState());
			}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W)
		{
			char.playAnim(animList[curAnim]);

			updateTexts();
			genBoyOffsets(false);
		}

		if (FlxG.keys.justPressed.SPACE)
			{
				char.playAnim(animList[curAnim], true);
			}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

		super.update(elapsed);
	}
}
