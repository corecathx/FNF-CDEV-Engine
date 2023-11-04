package meta.modding.stage_editor;

import lime.system.Clipboard;
import meta.modding.char_editor.CharacterData.AnimationArray;
import game.cdev.UIDropDown;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.FlxObject;
import sys.FileSystem;
import game.cdev.CDevPopUp;
import game.cdev.CDevPopUp.CDevPopUpButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import meta.substates.MusicBeatSubstate;
import flixel.group.FlxSpriteGroup;

using StringTools;

// yet another copy of missingfilemessage, missingfilesubstate, and cdevpopup
class AddStageSprite extends MusicBeatSubstate
{
	var state:Better_StageEditor;
	var box:FlxSprite;
	var exitButt:FlxSprite;
	var bgBlack:FlxSprite;

	var spriteMode:String = "bitmap";

	var buttons:Array<PopUpButton> = [];
	var titleT:String = "";

	var _hideBG:Bool = false;
	var _hideCloseButton:Bool = false;

	var displayGroup:FlxSpriteGroup;
	var header:FlxText;
	var header2:FlxText;

	var highlightSprite:FlxSprite = new FlxSprite();

	public function new(mainState:Better_StageEditor)
	{
		super();
		var button:Array<game.cdev.CDevPopUp.PopUpButton> = [
			{
				text: "Add Sprite",
				callback: function()
				{
					close();
				}
			}
		];
		this.buttons = button;
		this.state = mainState;

		this.cameras = [mainState.camHUD];
		titleT = "New Sprite";
		_hideBG = false;
		_hideCloseButton = false;
		if (!_hideBG)
		{
			bgBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF5D5D5D);
			bgBlack.alpha = 0.5;
			add(bgBlack);
			bgBlack.scrollFactor.set();
		}

		box = new FlxSprite().makeGraphic(800, 400, FlxColor.BLACK);
		box.alpha = 0.7;
		box.screenCenter();
		add(box);
		box.scrollFactor.set();

		highlightSprite.makeGraphic(400, 50);
		highlightSprite.alpha = 0.5;
		highlightSprite.y = box.y;
		highlightSprite.visible = false;
		add(highlightSprite);
		if (!_hideCloseButton)
		{
			exitButt = new FlxSprite().makeGraphic(30, 20, FlxColor.RED);
			exitButt.alpha = 0.7;
			exitButt.x = ((box.x + box.width) - 30) - 10;
			exitButt.y = (box.y + 20) - 10;
			add(exitButt);
			exitButt.scrollFactor.set();
		}

		displayGroup = new FlxSpriteGroup(box.x, box.y + 50);
		displayGroup.scrollFactor.set();
		add(displayGroup);

		if (!_hideBG)
		{
			bgBlack.alpha = 0;
			FlxTween.tween(bgBlack, {alpha: 0.5}, 0.3, {ease: FlxEase.linear});
		}

		box.alpha = 0;

		FlxSpriteUtil.drawRoundRect(box, 0, 0, 800, 400, 50, 50, FlxColor.BLACK);
		box.alpha = 0;
		FlxTween.tween(box, {alpha: 0.7}, 0.3, {ease: FlxEase.linear});
		if (!_hideCloseButton)
		{
			exitButt.alpha = 0;
			FlxTween.tween(exitButt, {alpha: 0.7}, 0.3, {ease: FlxEase.linear});
		}

		header = new FlxText(box.x, box.y + 10, 400, "Bitmap", 40);
		header.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header);
		header.scrollFactor.set();

		header2 = new FlxText(box.x + 400, box.y + 10, 400, "Sparrow", 40);
		header2.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header2);
		header2.scrollFactor.set();

		createBitmapUI();
		for (i in members)
		{
			if (Std.isOfType(i, FlxSprite))
			{
				var s = cast(i, FlxSprite);
				s.scrollFactor.set();
				s.cameras = [state.camHUD];
			}
		}
	}

	var buttonsCrap:Array<CDevPopUpButton> = [];

	function createBitmapUI()
	{
		resetDisplayGroup();
		var input_spritePath:FlxUIInputText;
		var input_spriteName:FlxUIInputText;

		input_spritePath = new FlxUIInputText(10, 25, 400, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_spritePath.setFormat("VCR OSD Mono", 16, FlxColor.WHITE);
		displayGroup.add(input_spritePath);

		var txtMna = new FlxText(10, 5, 0, "Path to sprite bitmap", 16);
		txtMna.font = "VCR OSD Mono";
		displayGroup.add(txtMna);

		input_spriteName = new FlxUIInputText(10, 75, 400, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_spriteName.setFormat("VCR OSD Mono", 16, FlxColor.WHITE);
		displayGroup.add(input_spriteName);

		var txtMnae = new FlxText(10, 55, 0, "Sprite Bitmap Name", 16);
		txtMnae.font = "VCR OSD Mono";
		displayGroup.add(txtMnae);

		var button:Array<game.cdev.CDevPopUp.PopUpButton> = [
			{
				text: "Add Sprite",
				callback: function()
				{
					if (input_spritePath.text.trim().length <= 0 || input_spritePath.text.trim() == "")
					{
						showError("Error", "Bitmap Sprite Path cannot be empty.", [
							{
								text: "OK",
								callback: function()
								{
									closeSubState();
								}
							}
						]);
						return;
					}

					if (input_spriteName.text.trim().length <= 0 || input_spriteName.text.trim() == "")
					{
						showError("Error", "Bitmap Sprite Name cannot be empty.", [
							{
								text: "OK",
								callback: function()
								{
									closeSubState();
								}
							}
						]);
						return;
					}

					if (!FileSystem.exists(Paths.modImages(input_spritePath.text.trim())))
					{
						showError("Error", "The specified Bitmap Sprite Path cannot be found.", [
							{
								text: "OK",
								callback: function()
								{
									closeSubState();
								}
							}
						]);
						return;
					}

					for (s in state.__STAGE_JSON.sprites)
					{
						if (s.imageVar.trim() == input_spriteName.text.trim())
						{
							showError("Error", "Another sprite with that name already exists.", [
								{
									text: "OK",
									callback: function()
									{
										closeSubState();
									}
								}
							]);
							return;
						}
					}

					state.__STAGE_JSON.sprites.push({
						animation: null,
						animType: null,

						position: [0, 0],
						imagePath: input_spritePath.text.trim(),
						imageScale: 1,
						imageSF: 1,
						imageAntialias: false,
						imageAlpha: 1,
						imageFlipX: false,
						imageVar: input_spriteName.text.trim(),
						spriteType: "bitmap",
					});
					state.updateStageElements();
					close();
				}
			}
		];

		for (i in 0...button.length)
		{
			var button:CDevPopUpButton = new CDevPopUpButton(0, 0, button[i].text, button[i].callback);
			button.x = box.x + 20 + (button.bWidth * i); // ((box.width / 2)-(button.bWidth/2))-(button.bWidth*i);
			button.y = (box.y - button.bHeight) - 20;
			displayGroup.add(button);
			button.scrollFactor.set();
			buttonsCrap.push(button);
		}

		for (i in 0...buttonsCrap.length)
		{
			buttonsCrap[i].x = (box.x + (box.width / 2) - (buttonsCrap[i].bWidth / 2)) - 20 - (buttonsCrap[i].bWidth * i);
			buttonsCrap[i].y = (box.y + box.height - buttonsCrap[i].bHeight) - 20;
		}

		for (i in displayGroup.members)
		{
			i.scrollFactor.set();
		}
	}

	function createSparrowUI()
	{
		resetDisplayGroup();
		var input_sparrowPath:FlxUIInputText;
		var input_sparrowName:FlxUIInputText;
		var stepper_sparrowFrameRate:FlxUINumericStepper;
		var drop_sparrowAnimType:UIDropDown;
		var input_sparrowAnim:FlxUIInputText;

		input_sparrowPath = new FlxUIInputText(10, 25, 400, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_sparrowPath.setFormat("VCR OSD Mono", 16, FlxColor.WHITE);
		displayGroup.add(input_sparrowPath);

		var txtMna = new FlxText(10, 5, 0, "Path to sparrow file", 16);
		txtMna.font = "VCR OSD Mono";
		displayGroup.add(txtMna);

		input_sparrowName = new FlxUIInputText(10, 75, 400, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_sparrowName.setFormat("VCR OSD Mono", 16, FlxColor.WHITE);
		displayGroup.add(input_sparrowName);

		var txtMnae = new FlxText(10, 55, 0, "Sparrow Sprite Name", 16);
		txtMnae.font = "VCR OSD Mono";
		displayGroup.add(txtMnae);

		stepper_sparrowFrameRate = new FlxUINumericStepper(10, 125, 1, 24, 1, 999, 0);
		displayGroup.add(stepper_sparrowFrameRate);

		var txtMnaae = new FlxText(10, 125-15, 0, "Animation Framerate", 14);
		txtMnaae.font = "VCR OSD Mono";
		displayGroup.add(txtMnaae);

		var dops:Array<String> = ["beat-force", "beat", "normal"];
		var current:String = "";
		drop_sparrowAnimType = new UIDropDown(210, 120, UIDropDown.makeStrIdLabelArray(dops, false), function(crap:String)
		{
			current = dops[Std.parseInt(crap)];
		});

		displayGroup.add(drop_sparrowAnimType);

		var txtMnaaee = new FlxText(210, 120-15, 0, "Animation Type", 14);
		txtMnaaee.font = "VCR OSD Mono";
		displayGroup.add(txtMnaaee);

		input_sparrowAnim = new FlxUIInputText(10, 165, 200, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_sparrowAnim.setFormat("VCR OSD Mono", 16, FlxColor.WHITE);
		displayGroup.add(input_sparrowAnim);

		var txtMnae = new FlxText(10, 145, 0, "Sparrow Animation (XML File Anim)", 16);
		txtMnae.font = "VCR OSD Mono";
		displayGroup.add(txtMnae);

		var button:Array<game.cdev.CDevPopUp.PopUpButton> = [
			{
				text: "Add Sprite",
				callback: function()
				{
					if (input_sparrowPath.text.trim().length <= 0 || input_sparrowPath.text.trim() == "")
					{
						showError("Error", "Sparrow File Path cannot be empty.", [
							{
								text: "OK",
								callback: function()
								{
									closeSubState();
								}
							}
						]);
						return;
					}

					if (input_sparrowName.text.trim().length <= 0 || input_sparrowName.text.trim() == "")
					{
						showError("Error", "Sparrow Sprite Name cannot be empty.", [
							{
								text: "OK",
								callback: function()
								{
									closeSubState();
								}
							}
						]);

						return;
					}
					var xmlExist:Bool = false;
					var pngExist:Bool = false;
					if (FileSystem.exists(Paths.modImages(input_sparrowPath.text.trim())))
					{
						pngExist = true;
					}

					if (FileSystem.exists(Paths.modXml(input_sparrowPath.text.trim())))
					{
						xmlExist = true;
					}

					var err:String = "";
					if (!pngExist)
						err+= "No images found in the Sparrow File Path.\n";
					if (!xmlExist)
						err+= "No XML file found in the Sparrow File Path.\n";

					if (err != ""){
						showError("Error", err, [
							{
								text: "OK",
								callback: function()
								{
									closeSubState();
								}
							}
						]);
	
						return;
					}

					for (s in state.__STAGE_JSON.sprites)
					{
						if (s.imageVar.trim() == input_sparrowName.text.trim())
						{
							showError("Error", "Another sprite with that name already exists.", [
								{
									text: "OK",
									callback: function()
									{
										closeSubState();
									}
								}
							]);
							return;
						}
					}

					var anim:AnimationArray = {
						animPrefix: input_sparrowAnim.text,
						animName: input_sparrowAnim.text,
						fpsValue: Math.floor(stepper_sparrowFrameRate.value),
						looping: false,
						indices: [],
						offset: [0, 0]
					}
					state.__STAGE_JSON.sprites.push({
						animation: anim,
						animType: current.toLowerCase(),

						position: [0, 0],
						imagePath: input_sparrowPath.text.trim(),
						imageScale: 1,
						imageSF: 1,
						imageAntialias: false,
						imageAlpha: 1,
						imageFlipX: false,
						imageVar: input_sparrowName.text.trim(),
						spriteType: "sparrow",
					});
					state.updateStageElements();
					close();
				}
			}
		];

		for (i in 0...button.length)
		{
			var button:CDevPopUpButton = new CDevPopUpButton(0, 0, button[i].text, button[i].callback);
			button.x = box.x + 20 + (button.bWidth * i); // ((box.width / 2)-(button.bWidth/2))-(button.bWidth*i);
			button.y = (box.y - button.bHeight) - 20;
			displayGroup.add(button);
			button.scrollFactor.set();
			buttonsCrap.push(button);
		}

		for (i in 0...buttonsCrap.length)
		{
			buttonsCrap[i].x = (box.x + (box.width / 2) - (buttonsCrap[i].bWidth / 2)) - 20 - (buttonsCrap[i].bWidth * i);
			buttonsCrap[i].y = (box.y + box.height - buttonsCrap[i].bHeight) - 20;
		}
	}

	var curOverlap:FlxObject = null;

	override function update(elapsed:Float)
	{
		if (!_hideCloseButton)
		{
			if (FlxG.mouse.overlaps(exitButt))
			{
				exitButt.alpha = 1;
				if (FlxG.mouse.justPressed)
					close();
			}
			else
			{
				exitButt.alpha = 0.7;
			}
		}

		if (FlxG.mouse.overlaps(header2))
		{
			highlightSprite.visible = true;
			highlightSprite.x = header2.x;
			if (curOverlap != header2)
				FlxG.sound.play(Paths.sound("scrollMenu"), 0.7);
			if (FlxG.mouse.justPressed)
			{
				if (spriteMode != "sparrow")
				{
					spriteMode = "sparrow";
					createSparrowUI();

					FlxG.sound.play(Paths.sound("clickText", "shared"), 0.7);
				}
			}

			curOverlap = header2;
		}

		if (FlxG.mouse.overlaps(header))
		{
			highlightSprite.visible = true;
			highlightSprite.x = header.x;
			if (curOverlap != header)
				FlxG.sound.play(Paths.sound("scrollMenu"), 0.7);
			if (FlxG.mouse.justPressed)
			{
				if (spriteMode != "bitmap")
				{
					spriteMode = "bitmap";
					createBitmapUI();

					FlxG.sound.play(Paths.sound("clickText", "shared"), 0.7);
				}
			}

			curOverlap = header;
		}

		if (!FlxG.mouse.overlaps(header) && !FlxG.mouse.overlaps(header2) && curOverlap != null)
		{
			highlightSprite.visible = false;
			highlightSprite.x = header.x;
			curOverlap = null;
		}

		switch (spriteMode)
		{
			case "bitmap":
				header.color = FlxColor.WHITE;
				header2.color = FlxColor.GRAY;
			case "sparrow":
				header.color = FlxColor.GRAY;
				header2.color = FlxColor.WHITE;
		}

		var keysEnabled:Bool = true;

		for (e in members)
		{
			if (Std.isOfType(e, FlxUIInputText))
			{
				var dum = cast(e, FlxUIInputText);
				if (cast(e, FlxUIInputText).hasFocus)
				{
					keysEnabled = false;
					if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null)
					{
						dum.text = game.cdev.CDevConfig.utils.pasteFunction(dum.text);
						dum.caretIndex = dum.text.length;
					}
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					if (FlxG.keys.justPressed.ENTER)
						dum.hasFocus = false;

					// break;
				}
			}
		}
		super.update(elapsed);
	}

	function resetDisplayGroup()
	{
		for (i in buttonsCrap)
		{
			i.kill();
			i.destroy();
			remove(i);
			buttonsCrap.remove(i);
			displayGroup.members.remove(i);
		}
		for (m in displayGroup.members)
		{
			m.kill();
			displayGroup.members.remove(m);
			remove(m);
			m.destroy();
		}
		displayGroup.clear();
	}

	function showError(t:String, b:String, btn:Array<PopUpButton>)
	{
		var t = new CDevPopUp(t, b, btn, false, true);
		t.cameras = [state.camHUD];
		openSubState(t);
	}
}
