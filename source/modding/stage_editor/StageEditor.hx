package modding.stage_editor;

import flixel.animation.FlxAnimation;
import modding.CharacterData.AnimationArray;
import flixel.addons.ui.FlxButtonPlus;
import flixel.math.FlxMath;
import cdev.CDevConfig;
import engineutils.Discord.DiscordClient;
import game.Stage.SpriteStage;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import game.Stage.StageSprite;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUI;
import haxe.io.Path;
import cdev.UIDropDown;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.utils.Assets;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUITabMenu;
import game.Stage.StageJSONData;
import openfl.net.FileReference;
import flixel.FlxG;
import game.*;

using StringTools;

//fuck this lol

class StageEditor extends states.MusicBeatState
{
	var uiBox:FlxUITabMenu;
	var animBox:FlxUITabMenu;
	var _file:FileReference;
	var stageJSON:StageJSONData;

	var charInfo:FlxText;

	var BFXPOS:Float = 770;
	var BFYPOS:Float = 100;
	var DADXPOS:Float = 100;
	var DADYPOS:Float = 100;
	var GFXPOS:Float = 400;
	var GFYPOS:Float = 130;

	var bf:Character;
	var bfGroup:FlxTypedGroup<FlxSprite>;
	var gf:Character;
	var gfGroup:FlxTypedGroup<FlxSprite>;
	var dad:Character;
	var dadGroup:FlxTypedGroup<FlxSprite>;

	var characters:Array<String> = ['bf', 'gf', 'dad'];

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var camFollow:FlxObject;

	var stageToLoad:String = '<NO STAGES>';
	var stageObjects:FlxTypedGroup<SpriteStage>;

	var curObject:Dynamic;
	var selectedThing:Bool = false;
	var selectedObj:Int = 0;
	var stageObjID:Array<Dynamic> = []; // var(String), obj(SpriteStage)
	var stageDropDown:UIDropDown;
	var stageList:Array<String> = [];

	var cameraView:FlxSprite;
	var cameraView_check:FlxUICheckBox;
	var curStageAnim:Int = 0;

	override function create()
	{
		FlxG.sound.music.volume = 0.5;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		camFollow = new FlxObject(0, 0, 2, 2);
		// camFollow.setPosition(DEFAULT_POSITION[0], DEFAULT_POSITION[1]);
		add(camFollow);

		FlxG.camera.follow(camFollow);
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxCamera.defaultCameras = [camGame];
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.mouse.visible = true;

		stageObjects = new FlxTypedGroup<SpriteStage>();
		add(stageObjects);

		gfGroup = new FlxTypedGroup<FlxSprite>();
		add(gfGroup);

		dadGroup = new FlxTypedGroup<FlxSprite>();
		add(dadGroup);

		bfGroup = new FlxTypedGroup<FlxSprite>();
		add(bfGroup);
		// loadStage();
		loadStageJSON(stageToLoad);
		createChar('bf');
		createChar('gf');
		createChar('dad');
		loadCharDropDown();
		loadStageDropDown();

		createUIBOX();
		addCharUI();
		createSpriteUI();
		addStageDataUI();

		createAnimBox();
		addAnimBoxUI();
		addAnimUI();

		stageDropDown = new UIDropDown(FlxG.width - 380 + 50, 240, UIDropDown.makeStrIdLabelArray(stageList, true), function(stage:String)
		{
			stageToLoad = stageList[Std.parseInt(stage)];
			if (stageToLoad != '<NO STAGES>')
				loadStage();
			loadStageDropDown();
		});
		stageDropDown.selectedLabel = characters[0];
		var sddText:FlxText = new FlxText(stageDropDown.x, stageDropDown.y - 15, FlxG.width, "Current Stage", 8);

		add(stageDropDown);
		add(sddText);
		stageDropDown.cameras = [camHUD];
		sddText.cameras = [camHUD];

		charInfo = new FlxText(0, 0, FlxG.width, "", 20);
		charInfo.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(charInfo);
		charInfo.alpha = 1;
		charInfo.cameras = [camHUD];

		var contrls:FlxText = new FlxText(0, 0, FlxG.width, "[J / K / I / L] - Move Camera\n[Mouse Wheel] - Camera Zoom\n[2] - Show / Hide Sprite Info", 20);
		contrls.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		add(contrls);
		contrls.alpha = 1;
		contrls.cameras = [camHUD];
		contrls.setPosition(-10, FlxG.height - contrls.height - 10);

		cameraView = new FlxSprite().loadGraphic(Paths.image('stageEditor-camera', 'shared'));
		CDevConfig.utils.moveToCenterOfSprite(gf, cameraView, true);
		add(cameraView);

		cameraView_check = new FlxUICheckBox(stageDropDown.x + stageDropDown.width + 40, stageDropDown.y, null, null, 'Show Camera?');
		add(cameraView_check);
		cameraView_check.checked = cameraView.visible;
		cameraView_check.cameras = [camHUD];
	}

	function createUIBOX()
	{
		var tabs = [
			{name: "Sprite", label: 'Sprite'},
			{name: "Characters", label: 'Characters'},
			{name: "Stage Data", label: 'Stage Data'}
		];
		uiBox = new FlxUITabMenu(null, tabs, true);
		uiBox.resize(400, 200);
		uiBox.x = FlxG.width - uiBox.width - 20;
		uiBox.y = 20;
		uiBox.cameras = [camHUD];
		uiBox.scrollFactor.set();
		add(uiBox);
	}

	function createAnimBox()
	{
		var tabs = [
			{name: "Sprite Info", label: 'Sprite Info'},
			{name: "Animation", label: "Animation"}
		];
		animBox = new FlxUITabMenu(null, tabs, true);
		animBox.resize(300, 500);
		animBox.x = 20;
		animBox.y = 20;
		animBox.cameras = [camHUD];
		animBox.scrollFactor.set();
		add(animBox);
	}

	var showAnimBox:Bool = false;

	var input_spritePath2:FlxUIInputText;

	function addAnimBoxUI():Void
	{
		var tab_group_anmBx = new FlxUI(null, animBox);
		tab_group_anmBx.name = "Sprite Info";
		tab_group_anmBx.cameras = [camHUD];

		input_spritePath2 = new FlxUIInputText(10, 20, 200, '', 8);
		tab_group_anmBx.add(input_spritePath2);

		var createSprButton:FlxButton = new FlxButton(input_spritePath2.x, input_spritePath2.y + 20, 'Reload Sprite', function()
		{
			var e:SpriteStage = null;
			for (i in 0...stageObjID.length)
			{
				if (stageObjID[i][0] == curObject.spriteName)
				{
					e = stageObjID[i][1];
				}
			}
			updateSpriteImage(e,input_spritePath2.text);
		});
		tab_group_anmBx.add(createSprButton);
		animBox.scrollFactor.set();
	}

	// copied from charactereditor.hx
	var animDropDown:UIDropDown;
	var input_animPrefix:FlxUIInputText;
	var input_animIndices:FlxUIInputText;
	var stepper_fpsValue:FlxUINumericStepper;
	var check_isLooping:FlxUICheckBox;
	var input_animName:FlxUIInputText;

	// var selectedAnim:Int = 0;
	var curShit:SpriteStage = null;
	var focusing:StageSprite = null;
	var fuckingID:Int = 0;

	function addAnimUI()
	{
		input_animPrefix = new FlxUIInputText(10, 70, 200, '', 8);
		input_animName = new FlxUIInputText(10, 100, 200, '', 8);
		input_animIndices = new FlxUIInputText(10, 130, 200, '', 8);
		stepper_fpsValue = new FlxUINumericStepper(220, 30, 1, 24, 1, 300, 1);
		check_isLooping = new FlxUICheckBox(stepper_fpsValue.x, stepper_fpsValue.y +20, null, null, 'Looping');

		animDropDown = new UIDropDown(10, 30, UIDropDown.makeStrIdLabelArray([''], true), function(daAnim:String)
		{
			// if(char.animation.curAnim != null) {
			//	char.playAnim(char.animation.curAnim.name, true);
			// }
			var selectedAnim:Int = Std.parseInt(daAnim);
			var currentAnimArray:AnimationArray = curShit.animArray[selectedAnim];

			input_animPrefix.text = currentAnimArray.animPrefix;
			input_animName.text = currentAnimArray.animName;
			stepper_fpsValue.value = currentAnimArray.fpsValue;
			check_isLooping.checked = currentAnimArray.looping;

			var indString:String = currentAnimArray.indices.toString();
			input_animIndices.text = indString.substr(1, indString.length - 2);
		});

		var addUpdateAnimButton:FlxButton = new FlxButton(500, input_animIndices.y + 15, "Add Anim", function()
		{
			addAnimation();
		});
		var removeAnimButton:FlxButton = new FlxButton(150, input_animIndices.y + 15, "Remove Anim", function()
		{
		//	removeAnimation();
		});

		var animDDtxt:FlxText = new FlxText(animDropDown.x, animDropDown.y - 15, FlxG.width, "Animations", 8);
		var animPtxt:FlxText = new FlxText(input_animPrefix.x, input_animPrefix.y - 15, FlxG.width, "Anim Prefix", 8);
		var animNtxt:FlxText = new FlxText(input_animName.x, input_animName.y - 15, FlxG.width, ".XML / .TXT Animation Name", 8);
		var fpstxt:FlxText = new FlxText(stepper_fpsValue.x, stepper_fpsValue.y - 15, FlxG.width, "Animation FPS", 8);
		var aiTxt:FlxText = new FlxText(input_animIndices.x, input_animIndices.y - 15, FlxG.width, "Animation indices (Advanced)", 8);

		var tab_group_anim = new FlxUI(null, animBox);
		tab_group_anim.name = "Animation";
		tab_group_anim.add(input_animName);
		tab_group_anim.add(input_animPrefix);
		tab_group_anim.add(stepper_fpsValue);
		tab_group_anim.add(animPtxt);
		tab_group_anim.add(animNtxt);
		tab_group_anim.add(fpstxt);
		tab_group_anim.add(check_isLooping);

		tab_group_anim.add(input_animIndices);
		tab_group_anim.add(aiTxt);
		tab_group_anim.add(addUpdateAnimButton);
		tab_group_anim.add(removeAnimButton);
		tab_group_anim.add(animDropDown);
		tab_group_anim.add(animDDtxt);

		animBox.addGroup(tab_group_anim);
		animBox.scrollFactor.set();
	}

	function addAnimation()
	{
		var idShit:Int = 0;
		var e:SpriteStage = null;
		var the:StageSprite = null;
		for (i in 0...stageObjID.length)
		{
			if (stageObjID[i][0] == curObject.spriteName)
			{
				idShit = i;
				e = stageObjID[i][1];
				for (u in 0...stageJSON.sprites.length)
				{
					if (stageJSON.sprites[u].imageVar == e.spriteName)
					{
						the = stageJSON.sprites[u];
						break;
					}
				}
			}
		}
		curShit = e;
		focusing = the;
		fuckingID = idShit;

		var indices:Array<Int> = [];
		var indicesString:Array<String> = input_animIndices.text.trim().split(',');

		if (indicesString.length > 1)
			for (i in 0...indicesString.length)
			{
				var index:Int = Std.parseInt(indicesString[i]);
				if (indicesString[i] != null && indicesString[i] != '' && !Math.isNaN(index) && index > -1)
				{
					indices.push(index);
				}
			}

		var lastPlayedAnim:String = '';
		if (curShit.animArray[curStageAnim] != null)
		{
			lastPlayedAnim = curShit.animArray[curStageAnim].animPrefix;
		}

		var lastAnimOffsets:Array<Int> = [0, 0];

		for (anim in curShit.animArray)
		{
			if (input_animPrefix.text == anim.animPrefix)
			{
				lastAnimOffsets = anim.offset;
				if (curShit.animation.getByName(input_animPrefix.text) != null)
					curShit.animation.remove(input_animPrefix.text);

				curShit.animArray.remove(anim);
			}
		}

		var newAnim:AnimationArray = {
			animPrefix: input_animPrefix.text,
			animName: input_animName.text,
			fpsValue: Math.round(stepper_fpsValue.value),
			looping: check_isLooping.checked,
			indices: indices,
			offset: lastAnimOffsets
		};
		if (indices != null && indices.length > 0)
			curShit.animation.addByIndices(newAnim.animPrefix, newAnim.animName, newAnim.indices, "", newAnim.fpsValue, newAnim.looping);
		else
			curShit.animation.addByPrefix(newAnim.animPrefix, newAnim.animName, newAnim.fpsValue, newAnim.looping);

		curShit.animArray.push(newAnim);

		stageJSON.sprites[fuckingID].animations.push(newAnim);
		if (lastPlayedAnim == input_animPrefix.text)
		{
			var daAnim:FlxAnimation = curShit.animation.getByName(lastPlayedAnim);
			if (daAnim != null && daAnim.frames.length > 0)
			{
				curShit.animation.play(lastPlayedAnim, true);
			}
			else
			{
				for (i in 0...curShit.animArray.length)
				{
					if (curShit.animArray[i] != null)
					{
						daAnim = curShit.animation.getByName(curShit.animArray[i].animPrefix);
						if (daAnim != null && daAnim.frames.length > 0)
						{
							curShit.animation.play(curShit.animArray[i].animPrefix, true);
							curStageAnim = i;
							break;
						}
					}
				}
			}
		}

		loadAnimDropDown();
	}

	function loadAnimDropDown()
	{
		var anims:Array<String> = [];
		for (anim in curShit.animArray)
			anims.push(anim.animPrefix);

		if (anims.length < 1)
			anims.push('No Anims!');

		animDropDown.setData(UIDropDown.makeStrIdLabelArray(anims, true));
	}

	function updateAnimInfo()
	{
		var e:SpriteStage = null;
		for (i in 0...stageObjID.length)
		{
			if (stageObjID[i][0] == curObject.spriteName)
			{
				e = stageObjID[i][1];
			}
		}

		if (e != null)
		{
			var data:StageSprite = e.spriteData;

			input_spritePath2.text = data.imagePath;
		}
	}

	var stepper_stageZoom:FlxUINumericStepper;
	var check_pixelStage:FlxUICheckBox;

	function addStageDataUI():Void
	{
		var tab_group_stgdt = new FlxUI(null, uiBox);
		tab_group_stgdt.name = "Stage Data";
		tab_group_stgdt.cameras = [camHUD];

		stepper_stageZoom = new FlxUINumericStepper(10, 20, 0.1, 1, 0.1, 30, 1);
		stepper_stageZoom.name = 'step_stgZm';
		tab_group_stgdt.add(stepper_stageZoom);
		var sszText:FlxText = new FlxText(stepper_stageZoom.x, stepper_stageZoom.y - 15, FlxG.width, "Stage Zoom", 8);
		tab_group_stgdt.add(sszText);

		var saveStageButton:FlxButton = new FlxButton(150, stepper_imageScale.y, 'Save Stage', function()
		{
			saveStageShit();
		});
		tab_group_stgdt.add(saveStageButton);

		uiBox.addGroup(tab_group_stgdt);
		uiBox.scrollFactor.set();
	}

	function updateSpriteImage(sprite:SpriteStage, newSprite:String)
	{
		if (sprite != null)
		{
			sprite.updateSprite(newSprite);
		}
	}

	var charList:Array<String> = [];
	var bfDropDown:UIDropDown;
	var gfDropDown:UIDropDown;
	var opDropDown:UIDropDown;

	var changedChar:String = '';

	function addCharUI():Void
	{
		var tab_group_selchar = new FlxUI(null, uiBox);
		tab_group_selchar.name = "Characters";

		bfDropDown = new UIDropDown(10, 30, UIDropDown.makeStrIdLabelArray(charList, true), function(character:String)
		{
			characters[0] = charList[Std.parseInt(character)];
			changedChar = 'bf';
			createChar('bf');
			loadCharDropDown();
		});
		bfDropDown.selectedLabel = characters[0];
		var bfddText:FlxText = new FlxText(bfDropDown.x, bfDropDown.y - 15, FlxG.width, "Boyfriend", 8);

		gfDropDown = new UIDropDown(10, 30, UIDropDown.makeStrIdLabelArray(charList, true), function(character:String)
		{
			characters[1] = charList[Std.parseInt(character)];
			changedChar = 'gf';
			createChar('gf');
			loadCharDropDown();
		});
		gfDropDown.selectedLabel = characters[1];
		gfDropDown.x = 400 - gfDropDown.width - 10;
		var gfddText:FlxText = new FlxText(gfDropDown.x, gfDropDown.y - 15, FlxG.width, "Girlfriend", 8);

		opDropDown = new UIDropDown(bfDropDown.x + bfDropDown.width + 10, 30, UIDropDown.makeStrIdLabelArray(charList, true), function(character:String)
		{
			characters[2] = charList[Std.parseInt(character)];
			changedChar = 'dad';
			createChar('dad');
			loadCharDropDown();
		});
		//opDropDown.x = 400 - opDropDown.width - 10;
		opDropDown.selectedLabel = characters[2];
		var opText:FlxText = new FlxText(opDropDown.x, opDropDown.y - 15, FlxG.width, "Opponent", 8);

		tab_group_selchar.add(bfDropDown);
		tab_group_selchar.add(bfddText);
		tab_group_selchar.add(gfDropDown);
		tab_group_selchar.add(gfddText);
		tab_group_selchar.add(opDropDown);
		tab_group_selchar.add(opText);

		uiBox.addGroup(tab_group_selchar);
		uiBox.scrollFactor.set();
	}

	function loadStageDropDown()
	{
		var loadedStages:Map<String, Bool> = new Map();

		#if ALLOW_MODS
		stageList = [];
		var dirs:Array<String> = [];
		dirs.push(Paths.mods(Paths.curModDir[0] + '/data/stages/'));
		for (i in 0...dirs.length)
		{
			var dir:String = dirs[i];
			if (FileSystem.exists(dir))
			{
				for (i in FileSystem.readDirectory(dir))
				{
					var path = Path.join([dir, i]);
					if (!FileSystem.isDirectory(path) && i.endsWith('.json'))
					{
						var checkChar:String = i.substr(0, i.length - 5);
						if (!loadedStages.exists(checkChar))
						{
							stageList.push(checkChar);
							loadedStages.set(checkChar, true);
						}
					}
				}
			}
		}

		if (stageList.length == 0)
			stageList.push('<NO STAGES>');
		#end
	}

	function loadCharDropDown()
	{
		var loadedCharacters:Map<String, Bool> = new Map();

		#if ALLOW_MODS
		charList = [];
		var dirs:Array<String> = [];
		dirs.push(Paths.getPreloadPath('data/characters/'));
		dirs.push(Paths.mods(Paths.curModDir[0] + '/data/characters/'));
		for (i in 0...dirs.length)
		{
			var dir:String = dirs[i];
			if (FileSystem.exists(dir))
			{
				for (i in FileSystem.readDirectory(dir))
				{
					var path = Path.join([dir, i]);
					if (!FileSystem.isDirectory(path) && i.endsWith('.json'))
					{
						var checkChar:String = i.substr(0, i.length - 5);
						if (!loadedCharacters.exists(checkChar))
						{
							charList.push(checkChar);
							loadedCharacters.set(checkChar, true);
						}
					}
				}
			}
		}
		#else
		charList = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#end
	}

	var input_spritePath:FlxUIInputText;
	var input_spriteVar:FlxUIInputText;
	var check_imgAntialias:FlxUICheckBox;
	var stepper_imageSf:FlxUINumericStepper;
	var stepper_imageScale:FlxUINumericStepper;
	var stepper_imageAlpha:FlxUINumericStepper;
	var check_imgFlipX:FlxUICheckBox;
	var check_imgAnimated:FlxUICheckBox;
	var oaText:FlxText;

	function createSpriteUI()
	{
		var tab_group_sprite = new FlxUI(null, uiBox);
		tab_group_sprite.cameras = [camHUD];
		tab_group_sprite.name = "Sprite";

		input_spritePath = new FlxUIInputText(10, 20, 200, '', 8);
		tab_group_sprite.add(input_spritePath);
		var opText:FlxText = new FlxText(input_spritePath.x, input_spritePath.y - 15, FlxG.width, "Sprite Image Path", 8);
		tab_group_sprite.add(opText);

		check_imgAntialias = new FlxUICheckBox(10, 40, null, null, "Antialiasing", 70);
		check_imgAntialias.name = 'check_antialiasing';
		tab_group_sprite.add(check_imgAntialias);

		check_imgFlipX = new FlxUICheckBox(120, 40, null, null, "FlipX", 70);
		check_imgFlipX.name = 'check_flipx';
		tab_group_sprite.add(check_imgFlipX);

		check_imgAnimated = new FlxUICheckBox(230, 40, null, null, "Animated", 70);
		check_imgAnimated.name = 'check_animated';
		tab_group_sprite.add(check_imgAnimated);

		stepper_imageSf = new FlxUINumericStepper(10, 60, 0.1, 1, 0, 1, 1);
		tab_group_sprite.add(stepper_imageSf);
		var sisfText:FlxText = new FlxText(stepper_imageSf.x + stepper_imageSf.width + 10, stepper_imageSf.y + 1, FlxG.width, "Scroll Factor", 8);
		tab_group_sprite.add(sisfText);

		stepper_imageScale = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 50, 1);
		tab_group_sprite.add(stepper_imageScale);
		var sisText:FlxText = new FlxText(stepper_imageScale.x + stepper_imageScale.width + 10, stepper_imageScale.y + 1, FlxG.width, "Scale", 8);
		tab_group_sprite.add(sisText);

		stepper_imageAlpha = new FlxUINumericStepper(10, 100, 0.1, 1, 0.1, 1, 1);
		tab_group_sprite.add(stepper_imageAlpha);
		var sisaText:FlxText = new FlxText(stepper_imageAlpha.x + stepper_imageAlpha.width + 10, stepper_imageAlpha.y + 1, FlxG.width, "Alpha", 8);
		tab_group_sprite.add(sisaText);

		var createSprButton:FlxButton = new FlxButton(stepper_imageScale.x + 120, stepper_imageScale.y, 'Add Sprite', function()
		{
			addSpriteShit();
		});
		tab_group_sprite.add(createSprButton);

		input_spriteVar = new FlxUIInputText(10, stepper_imageAlpha.y + 30, 200, '', 8);
		tab_group_sprite.add(input_spriteVar);
		oaText = new FlxText(input_spriteVar.x, input_spriteVar.y - 15, FlxG.width, "Sprite Variable", 8);
		tab_group_sprite.add(oaText);

		uiBox.addGroup(tab_group_sprite);
		uiBox.scrollFactor.set();
	}

	function addSpriteShit()
	{
		var existed:Bool = false;
		for (i in 0...stageJSON.sprites.length)
		{
			if (stageJSON.sprites[i].imageVar == input_spriteVar.text)
				existed == true;
		}
		if (input_spriteVar.text != '' && !existed)
		{
			var shit:StageSprite = {
				animated: check_imgAnimated.checked,
				animations: [],
				imagePath: input_spritePath.text,
				imageAlpha: stepper_imageAlpha.value,
				imageScale: stepper_imageScale.value,
				imageSF: stepper_imageSf.value,
				imageAntialias: check_imgAntialias.checked,
				position: [0, 0],
				imageVar: input_spriteVar.text,
				imageFlipX: check_imgFlipX.checked
			}
			stageJSON.sprites.push(shit);

			var daSprite:SpriteStage = new SpriteStage(0, 0, stageJSON, shit.imageVar);
			stageObjects.add(daSprite);

			stageObjID.push([shit.imageVar, daSprite]);
			settingsToDefault();
		}
		else if (input_spriteVar.text != '' && existed)
		{
			oaText.text = 'Sprite Variable (ALREADY USED!!!)';
		}
		else
		{
			oaText.color = FlxColor.RED;
		}
	}

	function settingsToDefault()
	{
		input_spritePath.text = '';
		stepper_imageAlpha.value = 1;
		stepper_imageScale.value = 1;
		stepper_imageSf.value = 1;
		check_imgAntialias.checked = false;
		input_spriteVar.text = '';
		check_imgFlipX.checked = false;
		check_imgAnimated.checked = false;
	}

	var jsonWasNull:Bool = false;

	function loadStageJSON(stage:String = "")
	{
		if (stageToLoad != '<NO STAGES>')
		{
			var crapJSON = null;

			#if ALLOW_MODS
			var charFile:String = Paths.modStage(stage);
			if (FileSystem.exists(charFile))
				crapJSON = File.getContent(charFile);
			#end

			if (crapJSON == null)
			{
				#if ALLOW_MODS
				crapJSON = File.getContent(Paths.stage(stage));
				#else
				crapJSON = Assets.getText(Paths.stage(stage));
				#end
			}

			var json:StageJSONData = cast Json.parse(crapJSON);

			if (crapJSON != null)
			{
				jsonWasNull = false;
				stageJSON = json;
			}
			else
			{
				jsonWasNull = true;
			}
		}
		else
		{
			stageJSON = {
				sprites: [],
				boyfriendPosition: [770, 100],
				girlfriendPosition: [400, 130],
				opponentPosition: [100, 100],
				stageZoom: 1,
				useCustomFollowLerp: false,
				followLerp: 0.03
			}
		}
	}

	function loadStage()
	{
		stageJSON = null;
		for (i in 0...stageObjects.length)
		{
			if (stageObjects.members[i] != null)
			{
				stageObjects.members[i].kill();
				stageObjects.remove(stageObjects.members[i]);
				stageObjects.members[i].destroy();
			}
		}

		for (i in 0...stageObjID.length)
		{
			stageObjID.remove(stageObjID[i]);
		}

		loadStageJSON(stageToLoad);
		createChar('bf');
		createChar('gf');
		createChar('dad');
		#if desktop
		// Updating Discord Rich Presence
		if (Main.discordRPC)
			DiscordClient.changePresence('In Stage Editor", "Editing: $stageToLoad', null, true);
		#end
		if (!jsonWasNull)
		{
			stepper_stageZoom.value = stageJSON.stageZoom;
			for (i in 0...stageJSON.sprites.length)
			{
				var daSprite:SpriteStage = new SpriteStage(stageJSON.sprites[i].position[0], stageJSON.sprites[i].position[1], stageJSON,
					stageJSON.sprites[i].imageVar);
				stageObjects.add(daSprite);

				stageObjID.push([stageJSON.sprites[i].imageVar, daSprite]);
			}
		}
	}

	function createChar(charToAdd:String = '')
	{
		switch (charToAdd)
		{
			case 'bf':
				if (bf != null)
				{
					bf.kill();
					bfGroup.remove(bf);
					bf.destroy();
				}

				bf = new Character(BFXPOS, BFYPOS, characters[0], true, true);
				bfGroup.add(bf);

				if (!jsonWasNull)
				{
					bf.x = stageJSON.boyfriendPosition[0];
					bf.y = stageJSON.boyfriendPosition[1];
				}
			case 'gf':
				if (gf != null)
				{
					gf.kill();
					gfGroup.remove(gf);
					gf.destroy();
				}

				gf = new Character(GFXPOS, GFYPOS, characters[1], false, true);
				gf.gfTestBop = true;
				gfGroup.add(gf);

				if (!jsonWasNull)
				{
					gf.x = stageJSON.girlfriendPosition[0];
					gf.y = stageJSON.girlfriendPosition[1];
				}
			case 'dad':
				if (dad != null)
				{
					dad.kill();
					dadGroup.remove(dad);
					dad.destroy();
				}

				dad = new Character(DADXPOS, DADYPOS, characters[2], false, true);
				dadGroup.add(dad);

				if (!jsonWasNull)
				{
					dad.x = stageJSON.opponentPosition[0];
					dad.y = stageJSON.opponentPosition[1];
				}
		}
	}

	var curObjectID:Int = 0;

	function checkChars()
	{
		if (FlxG.mouse.overlaps(gf) && gf != null)
		{
			if (FlxG.mouse.pressed && selectedThing != true)
			{
				selectedThing = true;
				curObject = gf;
			}
		}

		if (FlxG.mouse.overlaps(bf) && bf != null)
		{
			if (FlxG.mouse.pressed && selectedThing != true)
			{
				selectedThing = true;
				curObject = bf;
			}
		}

		if (FlxG.mouse.overlaps(dad) && dad != null)
		{
			if (FlxG.mouse.pressed && selectedThing != true)
			{
				selectedThing = true;
				curObject = dad;
			}
		}

		stageObjects.forEachAlive(function(object:FlxSprite)
		{
			if (FlxG.mouse.overlaps(object))
			{
				if (FlxG.mouse.pressed && selectedThing != true)
				{
					curObject = object;
					selectedThing = true;
					curObjectID = object.ID;
				}
				if (FlxG.mouse.justReleased)
				{
					trace('\n\nON JSON: ' + stageJSON.sprites.length + '\nON ARRAY: ' + stageObjects.length);
				}
			}
		});
		if (!FlxG.mouse.pressed)
			selectedThing = false;
		if (FlxG.mouse.pressed && selectedThing)
		{
			if (curObject != null)
			{
				if (!curObject.lockedChar)
				{
					curObject.x = FlxG.mouse.x - curObject.frameWidth / 2;
					curObject.y = FlxG.mouse.y - curObject.frameHeight / 2;
				}

				if (curObject != bf && curObject != gf && curObject != dad)
				{
					var idShit:Int = 0;
					var e:SpriteStage = null;
					for (i in 0...stageObjID.length)
					{
						if (stageObjID[i][0] == curObject.spriteName)
						{
							idShit = i;
							e = stageObjID[i][1];
						}
					}
					stageJSON.sprites[idShit].position = [curObject.x, curObject.y];
					updateAnimBox(e);
					// updateAnimInfo();
				}
			}
		}

		if (curObject != bf && curObject != gf && curObject != dad)
		{
			if (FlxG.keys.justPressed.DELETE && curObject != null)
			{
				trace('\n\nON JSON: ' + stageJSON.sprites.length + '\nON ARRAY: ' + stageObjects.length);
				var idShit:Int = 0;
				var e:SpriteStage = null;
				var ass:Dynamic = [];
				var the:StageSprite = null;
				for (i in 0...stageObjID.length)
				{
					if (stageObjID[i][0] == curObject.spriteName)
					{
						idShit = i;
						e = stageObjID[i][1];
						ass = stageObjID[i];
						for (u in 0...stageJSON.sprites.length)
						{
							if (stageJSON.sprites[u].imageVar == e.spriteName)
							{
								the = stageJSON.sprites[u];
								break;
							}
						}
					}
				}
				stageJSON.sprites.splice(stageJSON.sprites.indexOf(the), 1);
				stageObjects.remove(e, true);
				stageObjID.splice(ass, 1);

				curObject = null;
			}
		}

		var ugh:Bool = (bf == null && gf == null && dad == null);

		if (!jsonWasNull && !ugh)
		{
			stageJSON.girlfriendPosition = [gf.x, gf.y];
			stageJSON.boyfriendPosition = [bf.x, bf.y];
			stageJSON.opponentPosition = [dad.x, dad.y];
		}

		// for (obj in 0...stageObjects.length){
		//	if (!jsonWasNull && stageObjects.members[obj - 1] != null)
		//		stageJSON.sprites[obj - 1].position = [stageObjects.members[obj].x, stageObjects.members[obj].y];
		// }
	}

	var characterObjectsIsSelected:Bool = false;
	var msize:Float = 0.1;

	function checkInputs()
	{
		if (characterObjectsIsSelected)
		{
			if (!inputTexts.contains(true))
			{
				if (FlxG.keys.justPressed.Z)
				{
					curObject.lockedChar = !curObject.lockedChar;
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
				}
			}
		}
		else
		{
			if (curObject != null)
			{
				// lol
				var obj:SpriteStage = null;
				var set:StageSprite = null;
				for (i in 0...stageObjID.length)
				{
					if (stageObjID[i][1] == curObject)
					{
						obj = curObject;
						for (u in 0...stageJSON.sprites.length)
						{
							if (stageJSON.sprites[u].imageVar == obj.spriteName)
							{
								set = stageJSON.sprites[u];
								break;
							}
						}
					}
				}

				msize = (FlxG.keys.pressed.SHIFT ? 0.1 : 0.05);

				// scale
				if (!inputTexts.contains(true) || obj != null && !obj.lockedChar)
				{
					if (FlxG.keys.justPressed.Q)
					{
						if (set.imageScale >= 0.1)
						{
							set.imageScale -= msize;
						}
						else
						{
							set.imageScale = 0.1;
						}
					}
					else if (FlxG.keys.justPressed.E)
					{
						if (set.imageScale < 10)
						{
							set.imageScale += msize;
						}
						else
						{
							set.imageScale = 10;
						}
					}

					// scrollfactor
					if (FlxG.keys.justPressed.O)
					{
						if (set.imageSF >= 0.1)
						{
							set.imageSF -= msize;
						}
						else
						{
							set.imageSF = 0.1;
						}
					}
					else if (FlxG.keys.justPressed.P)
					{
						if (set.imageSF < 10)
						{
							set.imageSF += msize;
						}
						else
						{
							set.imageSF = 10;
						}
					}

					// antialiasin'
					if (FlxG.keys.justPressed.G)
					{
						set.imageAntialias = !set.imageAntialias;
						FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
					}

					if (FlxG.keys.justPressed.N)
					{
						if (set.imageAlpha >= 0.1)
						{
							set.imageAlpha -= msize;
						}
						else
						{
							set.imageAlpha = 0.1;
						}
					}
					else if (FlxG.keys.justPressed.M)
					{
						if (set.imageAlpha < 10)
						{
							set.imageAlpha += msize;
						}
						else
						{
							set.imageAlpha = 10;
						}
					}

					if (FlxG.keys.justPressed.F)
					{
						set.imageFlipX = !set.imageFlipX;
						FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
					}

					if (FlxG.keys.justPressed.Z)
					{
						curObject.lockedChar = !curObject.lockedChar;
						FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
					}
				}

				if (obj != null && !obj.lockedChar)
				{
					obj.scale.set(set.imageScale, set.imageScale);
					obj.flipX = set.imageFlipX;
					obj.scrollFactor.set(set.imageSF, set.imageSF);
					if (FlxG.save.data.antialiasing)
					{
						obj.antialiasing = set.imageAntialias;
					}

					obj.alpha = set.imageAlpha;
				}
			}
		}
	}

	function updateAnimBox(stageObject:SpriteStage)
	{
		input_spritePath2.text = stageObject.spriteData.imagePath;
	}

	function updateInfoText()
	{
		if (curObject != null)
		{
			if (curObject == dad || curObject == gf || curObject == bf)
			{
				characterObjectsIsSelected = true;
				var obj:Character = curObject;
				var aaaaaaaa:String = '';
				if (obj == dad)
				{
					aaaaaaaa = '[OPPONENT]';
				}
				else if (obj == gf)
				{
					aaaaaaaa = '[GIRLFRIEND]';
				}
				else if (obj == bf)
				{
					aaaaaaaa = '[BOYFRIEND]';
				}
				else
				{
					aaaaaaaa = '[UNKNOWN]';
				}
				charInfo.text = '$aaaaaaaa\n[LMB] - Position: ${obj.x}, ${obj.y}\n[Z] - Lock Character: ${obj.lockedChar}';
				charInfo.setPosition(10, FlxG.height - charInfo.height - 10);
			}
			else
			{
				characterObjectsIsSelected = false;
				var obj:Dynamic = curObject;
				var aaaaaaaa:String = '';

				var idShit:Int = 0;
				var e:SpriteStage = null;
				var ass:Dynamic = [];
				for (i in 0...stageObjID.length)
				{
					if (stageObjID[i][0] == curObject.spriteName)
					{
						idShit = i;
						e = stageObjID[i][1];
					}
				}

				if (e != null)
					aaaaaaaa = '[STAGE_OBJ_${e.spriteName}]';
				else
					aaaaaaaa = '[STAGE_OBJ_NULL]';

				if (obj != null)
				{
					charInfo.text = '$aaaaaaaa\n[LMB] - Position: ${obj.x}, ${obj.y}\n[Q / E] - Scale: ${obj.scale.x}\n[O / P] - ScrollFactor: ${obj.scrollFactor.x}\n[G] - Antialiasing: ${obj.antialiasing}\n[N / M] - Alpha: ${obj.alpha}\n[F] - Flip X: ${obj.flipX}\n[Z] - Lock Sprite: ${obj.lockedChar}'
						+ (obj.spriteData.animated ? '\n[W / S] - Change Animation' : '');
				}
				else
				{
					charInfo.text = '$aaaaaaaa\n[LMB] - Position: 0, 0\n[Q / E] - Scale: 0\n[O / P] - ScrollFactor: 0\n[G] - Antialiasing: null\n[N / M] - Alpha: 0\n[F] - Flip X: null\n[Z] - Lock Sprite: null';
				}

				charInfo.setPosition(10, FlxG.height - charInfo.height - 10);
			}
		}
	}

	// uh
	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Show Camera?':
					cameraView.visible = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			switch (wname)
			{
				case 'step_stgZm':
					var aaaa:Float = FlxMath.roundDecimal(nums.value, 2);
					var diff:Float = 1 - (aaaa-1);
					cameraView.scale.set(diff, diff);
					stageJSON.stageZoom = nums.value;
			}
		}
	}

	var inputTexts:Array<Bool> = [];
	var followAnimBoxX:Float = 0;

	override function update(elapsed:Float)
	{
		if (changedChar != '')
		{
			if (changedChar == 'bf' && curObject != bf)
			{
				curObject = bf;
				changedChar = '';
			}
			else if (changedChar == 'gf' && curObject != gf)
			{
				curObject = gf;
				changedChar = '';
			}
			else if (changedChar == 'dad' && curObject != dad)
			{
				curObject = dad;
				changedChar = '';
			}
		}
		checkChars();
		updateInfoText();
		checkInputs();

		inputTexts = [input_spritePath.hasFocus, input_spriteVar.hasFocus];

		if (input_spriteVar.hasFocus && oaText.color == FlxColor.RED)
		{
			oaText.color = FlxColor.WHITE;
			oaText.text = 'Sprite Variable';
		}

		if (bf != null)
			bf.dance();
		if (gf != null)
			gf.dance();
		if (dad != null)
			dad.dance();

		if (FlxG.keys.justPressed.TWO)
		{
			showAnimBox = !showAnimBox;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		if (showAnimBox)
		{
			followAnimBoxX = 20;
		}
		else
		{
			followAnimBoxX = -320;
		}

		animBox.x = FlxMath.lerp(followAnimBoxX, animBox.x, CDevConfig.utils.bound(1 - (elapsed * 12), 0, 1));

		if (FlxG.keys.pressed.ESCAPE)
			FlxG.switchState(new ModdingState());

		var zoomAdd:Float = 500 * elapsed;
		if (FlxG.keys.pressed.SHIFT)
			zoomAdd *= 4;

		if (FlxG.keys.justPressed.R)
			FlxG.camera.zoom = 1;
		if (FlxG.keys.pressed.I)
			camFollow.y -= zoomAdd;
		if (FlxG.keys.pressed.K)
			camFollow.y += zoomAdd;

		if (FlxG.keys.pressed.J)
			camFollow.x -= zoomAdd;
		if (FlxG.keys.pressed.L)
			camFollow.x += zoomAdd;

		if (FlxG.mouse.wheel < 0 && FlxG.camera.zoom < 3)
		{
			FlxG.camera.zoom += elapsed * (FlxG.camera.zoom * 3);
			if (FlxG.camera.zoom > 3)
				FlxG.camera.zoom = 3;
		}
		if (FlxG.mouse.wheel > 0 && FlxG.camera.zoom > 0.1)
		{
			FlxG.camera.zoom -= elapsed * (FlxG.camera.zoom * 3);
			if (FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;
		}
		super.update(elapsed);
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	function saveStageShit()
	{
		var jsonFile = {
			"sprites": stageJSON.sprites,
			"stageZoom": stageJSON.stageZoom,
			"useCustomFollowLerp": stageJSON.useCustomFollowLerp,
			"followLerp": stageJSON.followLerp,
			"boyfriendPosition": stageJSON.boyfriendPosition,
			"girlfriendPosition": stageJSON.girlfriendPosition,
			"opponentPosition": stageJSON.opponentPosition
		};

		var data:String = Json.stringify(jsonFile, "\t");

		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, "stagename.json");
		}
	}
}
