package game.settings.keybinds;

import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.text.FlxText;
import game.objects.*;
import game.*;

using StringTools;

class RebindControls extends meta.substates.MusicBeatSubstate
{
	private var curSelected:Int = 0;
	var keyBinds:Array<String> = [
		CDevConfig.saveData.leftBind,
		CDevConfig.saveData.downBind,
		CDevConfig.saveData.upBind,
		CDevConfig.saveData.rightBind,
	];

	var otherKeyBinds:Array<Dynamic> = [
		// ["main text", data, shouldUseBlackList?]
		["//> UI Keybinds", null, false],
		["UI LEFT : ", CDevConfig.saveData.ui_leftBind, true],
		["UI DOWN : ", CDevConfig.saveData.ui_downBind, true],
		["UI UP : ", CDevConfig.saveData.ui_upBind, true],
		["UI RIGHT : ", CDevConfig.saveData.ui_rightBind, true],
		["//", null, false],
		["//> Other Keybinds", null, false],
		["RESET  : ", CDevConfig.saveData.resetBind, false],
		["ACCEPT : ", CDevConfig.saveData.acceptBind, false],
		["BACK : ", CDevConfig.saveData.backBind, false],
		["PAUSE : ", CDevConfig.saveData.pauseBind, false],
	];

	var allowedToPress:Bool = false;
	var daText:FlxText;
	var mainStatus:String = "gameplay"; // gameplay/other
	var status:String = "select";
	var tempBind:String = "";
	var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "TAB"];

	var notes:FlxTypedGroup<RebindNote>;
	var otherUI:FlxTypedGroup<RebindText>;
	var nextButton:FlxSprite;
	var backButton:FlxSprite;

	public function new(isFromPause:Bool)
	{
		super();

		FlxG.mouse.visible = true;

		var blackBox:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBox.alpha = 0.7;
		blackBox.scrollFactor.set();
		if (!isFromPause)
			add(blackBox);

		notes = new FlxTypedGroup<RebindNote>();
		add(notes);

		otherUI = new FlxTypedGroup<RebindText>();
		add(otherUI);

		var lastX = 0;
		for (i in 0...keyBinds.length)
		{
			var n:RebindNote = new RebindNote(0, 0, i);
			n.ID = i;
			n.screenCenter(Y);
			// n.scrollFactor.set();
			n.changeBindText(keyBinds[i]);
			n.playAnim("static", true);
			notes.add(n);
			var center = (FlxG.width / 2) - (n.width * 2) - 20;
			n.x = 10 + center + ((n.width + 20) * i);
		}

		textUpdate();

		var title:FlxText = new FlxText(0, 60, -1, "Gameplay Keybinds", 72);
		title.setFormat("wendy", 66, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		title.borderSize = 4;
		title.screenCenter(X);
		add(title);

		var txt = "(Left Click on notes below to edit the keybind, Arrow Keys are added by default.)";
		var subtitle:FlxText = new FlxText(0, title.y + title.height + 10, -1, txt, 34);
		subtitle.setFormat("wendy", 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		subtitle.borderSize = 2;
		subtitle.screenCenter(X);
		add(subtitle);

		nextButton = new FlxSprite().loadGraphic(Paths.image("ui/next", "shared"));
		nextButton.setPosition(FlxG.width - nextButton.width - 10, FlxG.height - nextButton.height - 10);
		add(nextButton);

		// UI KEYBINDS//

		backButton = new FlxSprite().loadGraphic(Paths.image("ui/back", "shared"));
		backButton.setPosition(FlxG.width - backButton.width - 10, FlxG.height + 10);
		add(backButton);

		var titleB:FlxText = new FlxText(0, FlxG.height + 60, -1, "Other Keybinds", 72);
		titleB.setFormat("wendy", 66, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		titleB.borderSize = 4;
		titleB.screenCenter(X);
		add(titleB);

		var txt = "(Keybinds that'll be used for UI, or others. Press ENTER on one of them to edit.)";
		var subtitlee:FlxText = new FlxText(0, titleB.y + titleB.height + 10, -1, txt, 34);
		subtitlee.setFormat("wendy", 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		subtitlee.borderSize = 2;
		subtitlee.screenCenter(X);
		add(subtitlee);

		for (i in 0...otherKeyBinds.length)
		{
			var space:Float = (subtitlee.y + subtitlee.height) + 50 + (30 * i);
			var text:String = (!StringTools.startsWith(otherKeyBinds[i][0], "//") ? otherKeyBinds[i][0] : StringTools.replace(otherKeyBinds[i][0], "//", ""));

			var n:RebindText = new RebindText(50, space, text, otherKeyBinds[i][1]);
			n.ID = i;
			otherUI.add(n);
		}

		/////////////////////////////////

		new FlxTimer().start(0.2, function(bruh:FlxTimer)
		{
			allowedToPress = true;
		});

		if (isFromPause)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var overlapped:FlxObject = null;
	var canNext:Bool = false;
	var camTween:FlxTween = null;

	function tweenCam(down:Bool)
	{
		var camHUD = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		if (camTween != null)
			camTween.cancel();
		camTween = FlxTween.tween(camHUD.scroll, {y: (down ? FlxG.height : 0)}, 0.3, {ease: FlxEase.circInOut});
	}

	function getOverlap(object:FlxSprite)
	{
		var camHUD = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		return (FlxG.mouse.getWorldPosition(camHUD).x > object.x)
			&& (FlxG.mouse.getWorldPosition(camHUD).x < (object.x) + object.width)
			&& (FlxG.mouse.getWorldPosition(camHUD).y > object.y)
			&& (FlxG.mouse.getWorldPosition(camHUD).y < (object.y) + object.height);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (mainStatus == "gameplay")
		{
			nextButton.alpha = 0;
			if (canNext)
			{
				if (getOverlap(nextButton))
				{
					nextButton.alpha = 1;
					if (FlxG.mouse.justPressed)
					{
						mainStatus = "other";
						curSelected = 0;
						tweenCam(true);
					}
				}
				else
				{
					nextButton.alpha = 0.6;
				}
			}
			switch (status)
			{
				case 'select':
					canNext = true;
					var c = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
					overlapped = null;
					notes.forEachAlive(function(n:RebindNote)
					{
						if (getOverlap(n))
						{
							overlapped = n;
							if (FlxG.mouse.justPressed)
							{
								FlxG.sound.play(Paths.sound('scrollMenu'));
								status = "input";
							}
						}
					});
					for (i in notes.members)
					{
						if (overlapped != null)
						{
							i.alpha = 0.7;
							if (i == overlapped)
							{
								i.alpha = 1;
								curSelected = i.ID;
							}
						}
						else
						{
							i.alpha = 1;
							curSelected = -1;
						}

						if (c[i.ID])
						{
							i.playAnim("confirm", true);
						}
					}
					if (FlxG.keys.justPressed.ESCAPE)
					{
						var camHUD = FlxG.cameras.list[FlxG.cameras.list.length - 1];
						camHUD.scroll.y = 0;
						FlxG.sound.play(Paths.sound('cancelMenu'));
						close();
					}
				case 'input':
					canNext = false;
					for (i in notes.members)
					{
						i.alpha = 0;
						if (i.ID == curSelected)
						{
							i.alpha = 1;
							i.playAnim("pressed", true);
							curSelected = i.ID;
						}
					}
					tempBind = keyBinds[curSelected];
					keyBinds[curSelected] = "?";
					status = "wait";
					textUpdate();
				case 'wait':
					if (FlxG.keys.justPressed.ESCAPE)
					{
						keyBinds[curSelected] = tempBind;
						status = "select";
						FlxG.sound.play(Paths.sound('confirmMenu'));
						textUpdate();
					}
					else if (FlxG.keys.justPressed.ENTER)
					{
						if (allowedToPress)
						{
							keyBinds[curSelected] = tempBind;
							status = "select";
							FlxG.sound.play(Paths.sound('confirmMenu'));
							textUpdate();
						}
					}
					else if (FlxG.keys.justPressed.ANY)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));
						addKey(FlxG.keys.getIsDown()[0].ID.toString());
						save();
						status = "select";
						textUpdate();
					}
			}
		}
		else
		{
			backButton.alpha = 0;

			if (canNext)
			{
				if (getOverlap(backButton))
				{
					backButton.alpha = 1;
					if (FlxG.mouse.justPressed)
					{
						mainStatus = "gameplay";
						tweenCam(false);
					}
				}
				else
				{
					backButton.alpha = 0.6;
				}
			}
			switch (status)
			{
				case 'select':
					canNext = true;
					var c = [controls.UI_LEFT_P, controls.UI_DOWN_P, controls.UI_UP_P, controls.UI_RIGHT_P];
					if (FlxG.keys.justPressed.UP)
					{
						changeItem(-1);
					}
					if (FlxG.keys.justPressed.DOWN)
					{
						changeItem(1);
					}

					otherUI.forEachAlive(function(n:RebindText)
					{
						if (!n.isTitle)
						{
							n.alpha = 0.7;
							if (n.ID == curSelected)
							{
								n.alpha = 1;
								if (FlxG.keys.justPressed.LEFT)
								{
									n.changeSel(-1);
								}
								if (FlxG.keys.justPressed.RIGHT)
								{
									n.changeSel(1);
								}

								if (FlxG.keys.justPressed.ENTER)
								{
									n.focusOnSelected();
									status = "input";
									FlxG.sound.play(Paths.sound('scrollMenu'));
								}
							}
						} else{
							n.alpha = 1;
						}
					});

					if (FlxG.keys.justPressed.ESCAPE)
					{
						var camHUD = FlxG.cameras.list[FlxG.cameras.list.length - 1];
						camHUD.scroll.y = 0;
						FlxG.sound.play(Paths.sound('cancelMenu'));
						close();
					}
				case 'input':
					canNext = false;
					for (i in otherUI.members)
					{
						i.alpha = 0;
						if (i.ID == curSelected)
						{
							i.alpha = 1;
							curSelected = i.ID;

							tempBind = i.data[i.curSelected];
						}
					}
					status = "wait";

				case 'wait':
					/*if (FlxG.keys.justPressed.ESCAPE)
					{
						status = "select";
						FlxG.sound.play(Paths.sound('confirmMenu'));
						for (i in otherUI.members)
						{
							i.changeSel(0);
						}
					}
					else if (FlxG.keys.justPressed.ENTER)
					{
						if (allowedToPress)
						{
							status = "select";
							FlxG.sound.play(Paths.sound('confirmMenu'));
							for (i in otherUI.members)
							{
								i.changeSel(0);
							}
						}
					}
					else */if (FlxG.keys.justPressed.ANY)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));
						addKey(FlxG.keys.getIsDown()[0].ID.toString(), true);
						save();
						status = "select";
						var index = 0;
						for (i in otherUI.members)
						{
							var dataList = otherKeyBinds[index][1];
							i.updateSetting(dataList);
							index++;
						}
					}
			}
		}
	}

	function save()
	{
		for (i in notes.members)
		{
			i.alpha = 1;
			i.playAnim("static", true);
		}

		CDevConfig.saveData.upBind = keyBinds[2];
		CDevConfig.saveData.downBind = keyBinds[1];
		CDevConfig.saveData.leftBind = keyBinds[0];
		CDevConfig.saveData.rightBind = keyBinds[3];

		CDevConfig.saveData.ui_leftBind = otherKeyBinds[1][1];
		CDevConfig.saveData.ui_downBind = otherKeyBinds[2][1];
		CDevConfig.saveData.ui_upBind = otherKeyBinds[3][1];
		CDevConfig.saveData.ui_rightBind = otherKeyBinds[4][1];

		CDevConfig.saveData.resetBind = otherKeyBinds[7][1];
		CDevConfig.saveData.acceptBind = otherKeyBinds[8][1];
		CDevConfig.saveData.backBind = otherKeyBinds[9][1];
		CDevConfig.saveData.pauseBind = otherKeyBinds[10][1];

		FlxG.save.flush();

		game.cdev.CDevConfig.saveCurrentKeyBinds();
		game.cdev.engineutils.PlayerSettings.player1.controls.loadKeyBinds();
	}

	function textUpdate()
	{
		for (item in notes.members)
		{
			var i = item.ID;
			var txt = keyBinds[i];
			item.changeBindText(txt);
		}
	}

	public var lastKey:String = "";

	function addKey(r:String, ?others:Bool = false)
	{
		if (!others)
		{
			var shouldReturn:Bool = true;

			var notAllowed:Array<String> = [];
			var swapKey:Int = -1;

			for (x in blacklist)
			{
				notAllowed.push(x);
			}

			trace(notAllowed);

			for (x in 0...keyBinds.length)
			{
				var oK = keyBinds[x];
				if (oK == r)
				{
					swapKey = x;
					keyBinds[x] = null;
				}
				if (notAllowed.contains(oK))
				{
					keyBinds[x] = null;
					lastKey = oK;
					return;
				}
			}

			if (notAllowed.contains(r))
			{
				keyBinds[curSelected] = tempBind;
				lastKey = r;
				return;
			}

			lastKey = "";

			if (shouldReturn)
			{
				if (swapKey != -1)
				{
					keyBinds[swapKey] = tempBind;
				}
				keyBinds[curSelected] = r;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else
			{
				keyBinds[curSelected] = tempBind;
				lastKey = r;
			}
		}
		else
		{
			var shouldReturn:Bool = true;

			var notAllowed:Array<String> = [];
			var swapKey:Int = -1;
			var allowBlackList = otherKeyBinds[curSelected][2];
			var dataList:Array<String> = otherKeyBinds[curSelected][1];
			var parent:RebindText = otherUI.members[curSelected];

			if (allowBlackList)
				for (x in blacklist) notAllowed.push(x);

			for (x in 0...dataList.length){
				var oK = dataList[x];
				if (oK == r){
					swapKey = x;
					dataList[x] = null;
				}

				if (notAllowed.contains(oK))
				{
					dataList[x] = null;
					lastKey = oK;
					return;
				}
			}

			if (allowBlackList) if (notAllowed.contains(r)){
				dataList[parent.curSelected] = tempBind;
				lastKey = r;
				return;
			}

			lastKey = "";

			if (shouldReturn){
				if (swapKey != -1) dataList[swapKey] = tempBind;
				dataList[parent.curSelected] = r;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			} else{
				dataList[parent.curSelected] = tempBind;
				lastKey = r;
			}

			otherKeyBinds[curSelected][1] = dataList;
		}
	}

	function changeItem(_amount:Int = 0)
	{
		curSelected += _amount;
		if (mainStatus == "gameplay")
		{
			textUpdate();

			if (curSelected > 4)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = 4;
		}
		else
		{
			if (curSelected < 0)
				curSelected = otherKeyBinds.length - 1;
			if (curSelected >= otherKeyBinds.length)
				curSelected = 0;

			if (otherUI.members[curSelected].isTitle) {
				changeItem(_amount);
				trace("skipped " + curSelected);
			}
		}
	}
}

class RebindNote extends FlxSpriteGroup
{
	var noteSprite:StrumArrow;
	var noteLabel:FlxText;

	var animXML_static:Array<Dynamic> = [];
	var animXML_pressed:Array<Dynamic> = [];
	var animXML_confirm:Array<Dynamic> = [];

	function loadDefault()
	{
		animXML_static.push(['arrowLEFT', 0]);
		animXML_static.push(['arrowDOWN', 1]);
		animXML_static.push(['arrowUP', 2]);
		animXML_static.push(['arrowRIGHT', 3]);

		animXML_pressed.push(['left press', 0]);
		animXML_pressed.push(['down press', 1]);
		animXML_pressed.push(['up press', 2]);
		animXML_pressed.push(['right press', 3]);

		animXML_confirm.push(['left confirm', 0]);
		animXML_confirm.push(['down confirm', 1]);
		animXML_confirm.push(['up confirm', 2]);
		animXML_confirm.push(['right confirm', 3]);
	}

	public function new(x, y, noteData)
	{
		super(x, y);

		loadDefault();

		noteSprite = new StrumArrow(0, 0);
		noteSprite.frames = Paths.getSparrowAtlas('notes/NOTE_assets', "shared");
		noteSprite.animation.addByPrefix('purple', animXML_static[0][0]);
		noteSprite.animation.addByPrefix('blue', animXML_static[1][0]);
		noteSprite.animation.addByPrefix('green', animXML_static[2][0]);
		noteSprite.animation.addByPrefix('red', animXML_static[3][0]);

		noteSprite.antialiasing = CDevConfig.saveData.antialiasing;
		noteSprite.scale.set(1, 1);

		noteSprite.animation.addByPrefix('static', animXML_static[noteData][0]);
		noteSprite.animation.addByPrefix('pressed', animXML_pressed[noteData][0], 24, false);
		noteSprite.animation.addByPrefix('confirm', animXML_confirm[noteData][0], 24, false);

		noteSprite.ID = noteData;

		// noteSprite.scrollFactor.set();
		noteSprite.playAnim('static', false);
		add(noteSprite);
		noteSprite.updateHitbox();

		noteLabel = new FlxText(0, 0, -1, "", 72);
		noteLabel.setFormat("wendy", 62, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		noteLabel.borderSize = 5;
		noteLabel.borderQuality = 2;
		// noteLabel.scrollFactor.set();
		CDevConfig.utils.moveToCenterOfSprite(noteLabel, noteSprite, true);
		add(noteLabel);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (noteSprite.animation.curAnim != null)
		{
			if (noteSprite.animation.curAnim.name == "confirm" && noteSprite.animation.curAnim.finished)
			{
				playAnim("static", true);
			}
		}
	}

	public function playAnim(anim:String, ?force:Bool = false)
	{
		noteSprite.playAnim(anim, force);
	}

	public function changeBindText(t:String)
	{
		noteLabel.text = t;
		noteLabel.updateHitbox();
		CDevConfig.utils.moveToCenterOfSprite(noteLabel, noteSprite);
		noteLabel.x -= 20;
		noteLabel.y -= 20;
	}
}

// man
typedef FlxTextGroup = FlxTypedSpriteGroup<FlxText>;

class RebindText extends FlxSpriteGroup
{
	var n:FlxText;

	public var nD:FlxTextGroup;
	public var data:Array<String> = [];
	public var curSelected:Int = 0;
	public var isTitle:Bool = true;

	public function new(x:Float, y:Float, text:String, dat:Array<String>)
	{
		super(x, y);
		n = new FlxText(0, 0, -1, text, 24);
		n.setFormat("wendy", 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		n.borderSize = 2;
		add(n);

		nD = new FlxTextGroup();
		add(nD);

		updateSetting(dat);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function updateSetting(dat:Array<String>)
	{
		data = dat;
		isTitle = (data == null);

		nD.forEachAlive(function(t:FlxText)
		{
			t.destroy();
			nD.remove(t);
			t.kill();
		});

		if (isTitle) return;

		for (d in 0...data.length)
		{
			var xPos = (n.x) + 100 + (130 * d);
			var t:FlxText = new FlxText(xPos, 0, -1, data[d], 28);
			t.setFormat("wendy", 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			t.borderSize = 2;
			t.ID = d;
			nD.add(t);
		}

		changeSel();
	}

	public function focusOnSelected()
	{
		n.alpha = 0.3;
		for (i in nD)
		{
			i.alpha = 0;
			if (i.ID == curSelected)
			{
				i.alpha = 1;
				i.text = "?";
			}
		}
	}

	public function changeSel(add:Int = 0)
	{
		if (isTitle) return;
		curSelected += add;

		if (curSelected < 0)
			curSelected = data.length - 1;
		if (curSelected >= data.length)
			curSelected = 0;

		for (i in nD)
		{
			i.alpha = 0.5;
			if (i.ID == curSelected)
			{
				i.alpha = 1;
			}
		}
	}
}
