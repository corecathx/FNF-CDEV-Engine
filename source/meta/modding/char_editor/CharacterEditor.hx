package meta.modding.char_editor;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxButtonPlus;
import game.cdev.CDevPopUp;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import meta.substates.MusicBeatSubstate;
import flixel.graphics.tile.FlxDrawQuadsItem;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.graphics.FlxGraphic;
import flixel.animation.FlxAnimation;
import lime.system.Clipboard;
import lime.utils.Assets;
import meta.modding.char_editor.CharacterData.AnimationArray;
import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import haxe.io.Path;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUINumericStepper;
import game.cdev.UIDropDown;
import sys.io.File;
import sys.FileSystem;
import flixel.addons.ui.FlxUITabMenu;
import haxe.Json;
import meta.modding.char_editor.CharacterData.CharData;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import game.*;
import game.objects.*;

using StringTools;

/**
	*DEBUG MODE
 */
class CharacterEditor extends meta.states.MusicBeatState
{
	var _file:FileReference;
	var uiBox:FlxUITabMenu;
	var cameraPosition:Array<Float> = [];

	var charJSON:CharData;
	var char:Character;
	var ghostAnim:FlxSprite;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var fromPlayState:Bool = false;
	var camFollow:FlxObject;

	var healthBarBG:FlxSprite;
	var healthIcon:HealthIcon;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var characterToAdd:String = 'bf';
	var charList:Array<String> = [];

	var DEFAULT_POSITION:Array<Float> = [100, 100];
	var camFolPoint:FlxSprite;

	var check_toggleStageHelper:FlxUICheckBox;
	var check_playableChar:FlxUICheckBox;

	var noJson:Bool = false;
	var isPp1:Bool = false;

	public var moddingMode:Bool = false;

	var baseModdingJson:CharData;

	public function new(wasFromPlayState:Bool = false, noJson:Bool = false, isPlayer1:Bool = false)
	{
		super();
		this.fromPlayState = wasFromPlayState;
		this.noJson = noJson;
		this.isPp1 = isPlayer1;
	}

	override function create()
	{
		baseModdingJson = {
			animations: [],
			spritePath: 'characters/DADDY_DEAREST',
			charScale: 1,
			singHoldTime: 4,
			iconName: 'dad',

			charXYPosition: [0, 0],
			camXYPos: [0, 0],

			flipX: false,
			usingAntialiasing: true,
			healthBarColor: [255, 255, 255]
		};

		FlxG.sound.muteKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.volumeUpKeys = [];
		FlxG.sound.music.stop();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.camera.bgColor = 0xFF000000;

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.setPosition(DEFAULT_POSITION[0], DEFAULT_POSITION[1]);

		add(camFollow);

		FlxG.camera.follow(camFollow);
		FlxG.camera.focusOn(camFollow.getPosition());
		cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
		FlxCamera.defaultCameras = [camGame]; // FlxG.cameras.setDefaultDrawTarget(camGame, true);

		FlxG.mouse.visible = true;

		// var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		// gridBG.scrollFactor.set(0.5, 0.5);
		// add(gridBG);

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('menuDesat', 'preload'));
		bg.antialiasing = true;
		bg.scale.set(1.5, 1.5);
		bg.alpha = 0.1;
		bg.screenCenter();
		bg.scrollFactor.set(0.3, 0.3);
		bg.active = false;
		add(bg);

		if (fromPlayState)
		{
			if (isPp1)
				characterToAdd = meta.states.PlayState.SONG.player1;
			else
				characterToAdd = meta.states.PlayState.SONG.player2;
		}

		if (noJson)
			characterToAdd = 'bf';

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		textAnim.setFormat('VCR OSD Mono', 26, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(textAnim);

		if (moddingMode)
		{
			// charJSON = baseModdingJson;
			characterToAdd = 'dad';
		}

		loadChar();
		loadCharDropDown();
		// createCameraPointer();

		createHealthBar();
		createUIBOX();
		addCharUI();
		addSelCharUI();
		addAnimUI();
		loadAnimDropDown();
		loadCharSettings();

		check_toggleStageHelper = new FlxUICheckBox(uiBox.x + uiBox.width - 100, uiBox.y + uiBox.height + 20, null, null, 'Gray Background', 300);
		check_toggleStageHelper.checked = false;
		add(check_toggleStageHelper);
		check_toggleStageHelper.cameras = [camHUD];

		check_playableChar = new FlxUICheckBox(uiBox.x + 120, uiBox.y + uiBox.height + 20, null, null, 'Playable Character');
		check_playableChar.checked = char.previousFlipX;
		add(check_playableChar);
		check_playableChar.cameras = [camHUD];

		textAnim.cameras = [camHUD];
		dumbTexts.cameras = [camHUD];
		super.create();
	}

	function createCameraPointer()
	{
		if (camFolPoint != null)
			remove(camFolPoint);
		var pointerSprite:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		camFolPoint = new FlxSprite().loadGraphic(pointerSprite);
		camFolPoint.setGraphicSize(40, 40);
		camFolPoint.updateHitbox();
		camFolPoint.color = FlxColor.WHITE;
		add(camFolPoint);
	}

	function createUIBOX()
	{
		var tabs = [
			{name: "Character", label: 'Character'},
			{name: "Animation", label: 'Animation'},
			{name: "Select Character", label: 'Select Character'}
		];
		uiBox = new FlxUITabMenu(null, tabs, true);
		uiBox.resize(400, 200);
		uiBox.x = FlxG.width - uiBox.width - 20;
		uiBox.y = 20;
		uiBox.cameras = [camHUD];
		uiBox.scrollFactor.set();
		add(uiBox);
	}

	var animDropDown:UIDropDown;
	var input_animPrefix:FlxUIInputText;
	var input_animIndices:FlxUIInputText;
	var stepper_fpsValue:FlxUINumericStepper;
	var check_isLooping:FlxUICheckBox;
	var input_animName:FlxUIInputText;

	var ghostCreate:FlxUIButton;
	var ghostDelete:FlxUIButton;

	// var selectedAnim:Int = 0;

	function addAnimUI()
	{
		input_animPrefix = new FlxUIInputText(10, 70, 200, '', 8);
		input_animName = new FlxUIInputText(10, 100, 200, '', 8);
		input_animIndices = new FlxUIInputText(10, 130, 200, '', 8);
		stepper_fpsValue = new FlxUINumericStepper(220, 100, 1, 24, 1, 300, 1);
		check_isLooping = new FlxUICheckBox(stepper_fpsValue.x, stepper_fpsValue.y + 25, null, null, 'Looping');

		animDropDown = new UIDropDown(10, 30, UIDropDown.makeStrIdLabelArray([''], true), function(daAnim:String)
		{
			// if(char.animation.curAnim != null) {
			//	char.playAnim(char.animation.curAnim.name, true);
			// }
			var selectedAnim:Int = Std.parseInt(daAnim);
			var currentAnimArray:AnimationArray = char.animArray[selectedAnim];

			input_animPrefix.text = currentAnimArray.animPrefix;
			input_animName.text = currentAnimArray.animName;
			stepper_fpsValue.value = currentAnimArray.fpsValue;
			check_isLooping.checked = currentAnimArray.looping;

			var indString:String = currentAnimArray.indices.toString();
			input_animIndices.text = indString.substr(1, indString.length - 2);
		});

		ghostCreate = new FlxUIButton(220, 30, "Create Ghost", function()
		{
			ghostAnim.setPosition(char.x, char.y);
			ghostAnim.visible = true;
			ghostAnim.revive();
			ghostAnim.loadGraphic(char.graphic);
			ghostAnim.frames.frames = char.frames.frames;
			ghostAnim.animation.copyFrom(char.animation);
			ghostAnim.animation.play(char.animation.curAnim.name, true, false, char.animation.curAnim.curFrame);
			ghostAnim.offset.copyFrom(char.offset);
			ghostAnim.scale.copyFrom(char.scale);
			ghostAnim.flipX = char.flipX;
			ghostAnim.animation.pause();
		}, true, false, 0xFF009921);
		ghostCreate.setLabelFormat(null, 8, FlxColor.WHITE);

		ghostDelete = new FlxUIButton(220, 60, "Delete Ghost", function()
		{
			ghostAnim.kill();
			ghostAnim.visible = false;
		}, true, false, 0xFFC00000);
		ghostDelete.setLabelFormat(null, 8, FlxColor.WHITE);

		var addUpdateAnimButton:FlxButton = new FlxButton(120, input_animIndices.y + 15, "Add Anim", function()
		{
			addAnimation();
		});
		var removeAnimButton:FlxButton = new FlxButton(220, input_animIndices.y + 15, "Remove Anim", function()
		{
			removeAnimation();
		});

		var animDDtxt:FlxText = new FlxText(animDropDown.x, animDropDown.y - 15, FlxG.width, "Animations", 8);
		var animPtxt:FlxText = new FlxText(input_animPrefix.x, input_animPrefix.y - 15, FlxG.width, "Anim Prefix", 8);
		var animNtxt:FlxText = new FlxText(input_animName.x, input_animName.y - 15, FlxG.width, ".XML / .TXT Animation Name", 8);
		var fpstxt:FlxText = new FlxText(stepper_fpsValue.x, stepper_fpsValue.y - 15, FlxG.width, "Animation FPS", 8);
		var aiTxt:FlxText = new FlxText(input_animIndices.x, input_animIndices.y - 15, FlxG.width, "Animation indices (Advanced)", 8);

		var tab_group_anim = new FlxUI(null, uiBox);
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

		tab_group_anim.add(ghostCreate);
		tab_group_anim.add(ghostDelete);

		uiBox.addGroup(tab_group_anim);
		uiBox.scrollFactor.set();
	}

	function addAnimation()
	{
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
		if (char.animArray[curAnim] != null)
		{
			lastPlayedAnim = char.animArray[curAnim].animPrefix;
		}

		var lastAnimOffsets:Array<Int> = [0, 0];

		for (anim in char.animArray)
		{
			if (input_animPrefix.text == anim.animPrefix)
			{
				lastAnimOffsets = anim.offset;
				if (char.animation.getByName(input_animPrefix.text) != null)
					char.animation.remove(input_animPrefix.text);

				char.animArray.remove(anim);
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
			char.animation.addByIndices(newAnim.animPrefix, newAnim.animName, newAnim.indices, "", newAnim.fpsValue, newAnim.looping);
		else
			char.animation.addByPrefix(newAnim.animPrefix, newAnim.animName, newAnim.fpsValue, newAnim.looping);

		if (!char.animOffsets.exists(newAnim.animPrefix))
			char.addOffset(newAnim.animPrefix, 0, 0);

		char.animArray.push(newAnim);

		if (lastPlayedAnim == input_animPrefix.text)
		{
			var daAnim:FlxAnimation = char.animation.getByName(lastPlayedAnim);
			if (daAnim != null && daAnim.frames.length > 0)
			{
				char.playAnim(lastPlayedAnim, true);
			}
			else
			{
				for (i in 0...char.animArray.length)
				{
					if (char.animArray[i] != null)
					{
						daAnim = char.animation.getByName(char.animArray[i].animPrefix);
						if (daAnim != null && daAnim.frames.length > 0)
						{
							char.playAnim(char.animArray[i].animPrefix, true);
							curAnim = i;
							break;
						}
					}
				}
			}
		}

		loadAnimDropDown();
		genBoyOffsets();
	}

	function removeAnimation()
	{
		for (anim in char.animArray)
		{
			if (input_animPrefix.text == anim.animPrefix)
			{
				var reset:Bool = false;
				if (char.animation.curAnim != null && anim.animPrefix == char.animation.curAnim.name)
					reset = true;

				if (char.animation.getByName(anim.animPrefix) != null)
					char.animation.remove(anim.animPrefix);

				if (char.animOffsets.exists(anim.animPrefix))
					char.animOffsets.remove(anim.animPrefix);

				char.animArray.remove(anim);

				if (reset && char.animArray.length > 0)
					char.playAnim(char.animArray[0].animPrefix, true);

				loadAnimDropDown();
				genBoyOffsets();
				break;
			}
		}
	}

	function createHealthBar()
	{
		healthBarBG = new FlxSprite(30, FlxG.height - 78).loadGraphic(Paths.image("healthBar", 'shared'));
		healthBarBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(healthBarBG);

		healthIcon = new HealthIcon(charJSON.iconName, false);
		add(healthIcon);

		healthIcon.setPosition(healthBarBG.getGraphicMidpoint().x - (healthIcon.width/2), healthBarBG.y - (healthIcon.height / 2));

		updateHealthBarDisplay();

		healthBarBG.cameras = [camHUD];
		healthIcon.cameras = [camHUD];
	}

	function updateHealthBarDisplay(updateHealthIconToo:Bool = false)
	{
		if (healthBarBG != null && healthIcon != null)
		{
			healthBarBG.color = FlxColor.fromRGB(charJSON.healthBarColor[0], charJSON.healthBarColor[1], charJSON.healthBarColor[2]);
			if (updateHealthIconToo)
				healthIcon.changeDaIcon(charJSON.iconName);
		}
	}

	var charSpritePath:FlxUIInputText;
	var healthIconName:FlxUIInputText;
	var check_usingAntialiasing:FlxUICheckBox;

	var check_flipX:FlxUICheckBox;
	var stepper_healthBarC1:FlxUINumericStepper;
	var stepper_healthBarC2:FlxUINumericStepper;
	var stepper_healthBarC3:FlxUINumericStepper;

	var stepper_charXPos:FlxUINumericStepper;
	var stepper_charYPos:FlxUINumericStepper;
	var stepper_camXPos:FlxUINumericStepper;
	var stepper_camYPos:FlxUINumericStepper;

	var stepper_scale:FlxUINumericStepper;
	var stepper_singTime:FlxUINumericStepper;

	function addCharUI():Void
	{
		charSpritePath = new FlxUIInputText(10, 20, 200, charJSON.spritePath, 8);
		charSpritePath.name = 'txt_spritePath';

		healthIconName = new FlxUIInputText(10, 50, 100, charJSON.iconName, 8);
		healthIconName.name = 'txt_iconName';

		var cspText:FlxText = new FlxText(charSpritePath.x, charSpritePath.y - 15, FlxG.width, "Character Sprite Path", 8);
		var cnText:FlxText = new FlxText(healthIconName.x, healthIconName.y - 15, FlxG.width, "Health Icon name", 8);
		var reloadCharacterBttn:FlxButton = new FlxButton((healthIconName.x + healthIconName.width) + 10, healthIconName.y - 5, 'Reload Image', function()
		{
			char.imgFile = charSpritePath.text;
			reloadCharSprite();
		});

		check_usingAntialiasing = new FlxUICheckBox(10, 80, null, null, "Antialiasing", 70);
		check_usingAntialiasing.name = 'check_usingAntialiasing';
		check_usingAntialiasing.checked = charJSON.usingAntialiasing;

		check_flipX = new FlxUICheckBox(100, 80, null, null, "Flip X", 40);
		check_flipX.name = 'check_flipX';
		check_flipX.checked = charJSON.usingAntialiasing;

		stepper_healthBarC1 = new FlxUINumericStepper(10, 120, 15, 0, 0, 255, 1);
		stepper_healthBarC1.value = charJSON.healthBarColor[0];
		stepper_healthBarC1.name = "step_hBar1";

		stepper_healthBarC2 = new FlxUINumericStepper(80, 120, 15, 0, 0, 255, 1);
		stepper_healthBarC2.value = charJSON.healthBarColor[1];
		stepper_healthBarC2.name = "step_hBar2";

		stepper_healthBarC3 = new FlxUINumericStepper(150, 120, 15, 0, 0, 255, 1);
		stepper_healthBarC3.value = charJSON.healthBarColor[2];
		stepper_healthBarC3.name = "step_hBar3";

		// THECHARPOSSHITS
		stepper_charXPos = new FlxUINumericStepper(220, 50, 10, 0, -5000, 5000, 1);
		stepper_charXPos.value = charJSON.charXYPosition[0];
		stepper_charXPos.name = "step_cXPos";

		stepper_charYPos = new FlxUINumericStepper(290, 50, 10, 0, -5000, 5000, 1);
		stepper_charYPos.value = charJSON.charXYPosition[1];
		stepper_charYPos.name = "step_cYPos";

		stepper_camXPos = new FlxUINumericStepper(220, 85, 10, 0, -5000, 5000, 1);
		stepper_camXPos.value = charJSON.camXYPos[0];
		stepper_camXPos.name = "step_cmXPos";

		stepper_camYPos = new FlxUINumericStepper(290, 85, 10, 0, -5000, 5000, 1);
		stepper_camYPos.value = charJSON.camXYPos[1];
		stepper_camYPos.name = "step_cmYPos";

		stepper_scale = new FlxUINumericStepper(10, 150, 0.1, 1, 0.1, 20, 1);
		stepper_scale.value = charJSON.charScale;
		stepper_scale.name = "step_charScale";

		stepper_singTime = new FlxUINumericStepper(100, 150, 0.1, 4, 0.1, 20, 1);
		stepper_singTime.value = charJSON.singHoldTime;
		stepper_singTime.name = "step_singTime";

		var saveCharacterButton:FlxButton = new FlxButton(stepper_singTime.x + 70, stepper_singTime.y, 'Save Character', function()
		{
			if (!moddingMode)
				saveCharacter();
			else
			{
				FlxG.camera.zoom = 1;
				var jsonShit:CharData = {
					animations: char.animArray,
					spritePath: char.imgFile,
					charScale: char.jsonScale,
					singHoldTime: char.charHoldTime,
					iconName: char.healthIcon,

					charXYPosition: char.charXYPos,
					camXYPos: char.charCamPos,

					flipX: char.previousFlipX,
					usingAntialiasing: char.usingAntiAlias,
					healthBarColor: char.healthBarColors
				};
				var aa:CharacterEditorSaveDialog = new CharacterEditorSaveDialog(jsonShit);
				aa.cameras = [camHUD];
				openSubState(aa);
			}
		});

		var camXYTxt:FlxText = new FlxText(stepper_camXPos.x, stepper_camXPos.y - 15, FlxG.width, "Camera Position (X, Y)", 8);
		var hBarTxt:FlxText = new FlxText(stepper_healthBarC1.x, stepper_healthBarC1.y - 15, FlxG.width, "Health Bar Color (R, G, B)", 8);
		var sTxt:FlxText = new FlxText(stepper_scale.x, stepper_scale.y - 15, FlxG.width, "Character Scale", 8);
		var sngTxt:FlxText = new FlxText(stepper_singTime.x, stepper_singTime.y - 15, FlxG.width, "Sing Hold Time", 8);
		var cXYTxt:FlxText = new FlxText(stepper_charXPos.x, stepper_charXPos.y - 15, FlxG.width, "Character Position (X, Y)", 8);

		var tab_group_char = new FlxUI(null, uiBox);
		tab_group_char.name = "Character";
		tab_group_char.add(charSpritePath);
		tab_group_char.add(healthIconName);
		tab_group_char.add(reloadCharacterBttn);
		tab_group_char.add(cspText);
		tab_group_char.add(cnText);
		tab_group_char.add(stepper_healthBarC1);
		tab_group_char.add(stepper_healthBarC2);
		tab_group_char.add(stepper_healthBarC3);
		tab_group_char.add(stepper_charXPos);
		tab_group_char.add(stepper_charYPos);
		tab_group_char.add(cXYTxt);
		tab_group_char.add(stepper_camXPos);
		tab_group_char.add(stepper_camYPos);
		tab_group_char.add(camXYTxt);
		tab_group_char.add(check_usingAntialiasing);
		tab_group_char.add(check_flipX);
		tab_group_char.add(hBarTxt);
		tab_group_char.add(stepper_scale);
		tab_group_char.add(stepper_singTime);
		tab_group_char.add(sTxt);
		tab_group_char.add(sngTxt);
		tab_group_char.add(saveCharacterButton);

		uiBox.addGroup(tab_group_char);
		uiBox.scrollFactor.set();
	}

	var characterDropDown:UIDropDown;

	function addSelCharUI():Void
	{
		characterDropDown = new UIDropDown(70, 50, UIDropDown.makeStrIdLabelArray(charList, true), function(character:String)
		{
			characterToAdd = charList[Std.parseInt(character)];
			loadChar();
			loadCharDropDown();
		});
		characterDropDown.selectedLabel = characterToAdd;
		var cspText:FlxText = new FlxText(characterDropDown.x, characterDropDown.y - 15, FlxG.width, "Character Lists", 8);
		var tab_group_selchar = new FlxUI(null, uiBox);
		tab_group_selchar.name = "Select Character";
		tab_group_selchar.add(characterDropDown);
		tab_group_selchar.add(cspText);

		uiBox.addGroup(tab_group_selchar);
		uiBox.scrollFactor.set();
	}

	var typingShit2:FlxInputText;

	function loadCharDropDown()
	{
		var loadedCharacters:Map<String, Bool> = new Map();

		#if ALLOW_MODS
		charList = [];
		var dirs:Array<String> = [];
		if (!moddingMode)
		{
			for (i in 0...Paths.curModDir.length)
			{
				dirs.push(Paths.mods(Paths.curModDir[i] + '/data/characters/'));
			}

			dirs.push(Paths.getPreloadPath('data/characters/'));
		}
		else
		{
			dirs.push(Paths.mods(Paths.curModDir[0] + '/data/characters/'));
		}

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
		if (moddingMode && charList.length <= 1)
			charList.push('dad');
		#else
		charList = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#end

		// characterDropDown.selectedLabel = daAnim;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Antialiasing':
					charJSON.usingAntialiasing = check.checked;
					if (CDevConfig.saveData.antialiasing)
						char.antialiasing = charJSON.usingAntialiasing;
					else
						char.antialiasing = false;
				case 'Flip X':
					char.previousFlipX = !char.previousFlipX;
					char.flipX = char.previousFlipX;
					if (char.isPlayer)
						char.flipX = !char.flipX;

				case 'Gray Background':
					FlxG.camera.bgColor = (check.checked ? 0xFF909090 : 0xFF000000);
				case 'Playable Character':
					char.isPlayer = !char.isPlayer;
					char.flipX = !char.flipX;
					updateCamPointPos();
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			switch (wname)
			{
				case 'step_hBar1':
					charJSON.healthBarColor[0] = Std.int(nums.value);
					char.healthBarColors[0] = charJSON.healthBarColor[0];
					updateHealthBarDisplay();
				case 'step_hBar2':
					charJSON.healthBarColor[1] = Std.int(nums.value);
					char.healthBarColors[1] = charJSON.healthBarColor[1];
					updateHealthBarDisplay();
				case 'step_hBar3':
					charJSON.healthBarColor[2] = Std.int(nums.value);
					char.healthBarColors[2] = charJSON.healthBarColor[2];
					updateHealthBarDisplay();
				case 'step_cmXPos':
					charJSON.camXYPos[0] = Std.int(nums.value);
					char.charCamPos[0] = charJSON.camXYPos[0];
					updateCamPointPos();
				case 'step_cmYPos':
					charJSON.camXYPos[1] = Std.int(nums.value);
					char.charCamPos[1] = charJSON.camXYPos[1];
					updateCamPointPos();
				case 'step_cXPos':
					charJSON.charXYPosition[0] = Std.int(nums.value);
					char.charXYPos[0] = charJSON.charXYPosition[0];
					updateCharPosition();
				case 'step_cYPos':
					charJSON.charXYPosition[1] = Std.int(nums.value);
					char.charXYPos[1] = charJSON.charXYPosition[1];
					updateCharPosition();
				case 'step_charScale':
					charJSON.charScale = nums.value;
					char.jsonScale = charJSON.charScale;
					char.scale.set(charJSON.charScale, charJSON.charScale);
					char.updateHitbox();
					updateCamPointPos();
			}
		}
		else if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			if (sender == healthIconName)
			{
				healthIcon.changeDaIcon(healthIconName.text);
				char.healthIcon = healthIconName.text;
			}
			else if (sender == charSpritePath)
			{
				char.imgFile = charSpritePath.text;
			}
		}
	}

	function loadAnimDropDown()
	{
		var anims:Array<String> = [];
		for (anim in char.animArray)
			anims.push(anim.animPrefix);

		if (anims.length < 1)
			anims.push('No Anims!');

		animDropDown.setData(UIDropDown.makeStrIdLabelArray(anims, true));
	}

	function reloadCharSprite()
	{
		var lastPlayedAnim:String = '';
		if (char.animation.curAnim != null)
			lastPlayedAnim = char.animation.curAnim.name;

		var frames:FlxAtlasFrames = null;

		if (game.cdev.CDevConfig.utils.fileIsExists('images/' + char.imgFile + '.txt', TEXT))
			frames = Paths.getPackerAtlas(char.imgFile, 'shared');
		else
			frames = Paths.getSparrowAtlas(char.imgFile, 'shared');

		if (frames == null)
		{
			var butt:Array<PopUpButton> = [];
			butt = [
				{
					text: "OK",
					callback: function()
					{
						closeSubState();
					}
				},
			];
			FlxG.camera.zoom = 1;
			openSubState(new CDevPopUp("",
				"Failed to get image asset for \""
				+ char.imgFile
				+ "\", please make sure the image asset exists on \"images/"
				+ char.imgFile
				+ "\".", butt,
				false, true));
			return;
		}
		else
		{
			char.frames = frames;
		}

		if (char.animArray != null && char.animArray.length > 0)
		{
			for (anim in char.animArray)
			{
				var animPrefix:String = '' + anim.animPrefix;
				var animName:String = '' + anim.animName;
				var animFpsVal:Int = anim.fpsValue;
				var animLooping:Bool = !!anim.looping;
				var animIndices:Array<Int> = anim.indices;
				if (animIndices != null && animIndices.length > 0)
				{
					char.animation.addByIndices(animPrefix, animName, animIndices, "", animFpsVal, animLooping);
				}
				else
				{
					char.animation.addByPrefix(animPrefix, animName, animFpsVal, animLooping);
				}
			}
		}

		if (lastPlayedAnim != '')
			char.playAnim(lastPlayedAnim, true);
		else
			char.dance();
	}

	function updateCharPosition()
	{
		char.setPosition(char.charXYPos[0] + 100, char.charXYPos[1]);
		// char.x = DEFAULT_POSITION[0] + charJSON.charXYPosition[0];
		// char.y = DEFAULT_POSITION[1] + charJSON.charXYPosition[1];
	}

	function loadCharJSON(theChar:String = "")
	{
		var crapJSON = null;

		#if ALLOW_MODS
		var charFile:String = Paths.modChar(theChar);
		if (FileSystem.exists(charFile))
			crapJSON = File.getContent(charFile);
		#end

		if (crapJSON == null)
		{
			#if ALLOW_MODS
			crapJSON = File.getContent(Paths.char(theChar));
			#else
			crapJSON = Assets.getText(Paths.char(theChar));
			#end
		}

		var json:CharData = cast Json.parse(crapJSON);

		if (crapJSON != null)
			charJSON = json;
	}

	function loadChar(updateAnimLists:Bool = true)
	{
		loadCharJSON(characterToAdd);

		if (char != null)
			char.kill();

		if (ghostAnim != null)
			ghostAnim.kill();
		ghostAnim = new FlxSprite();
		ghostAnim.visible = false;
		ghostAnim.alpha = 0.5;
		add(ghostAnim);

		isDad = true;
		if (characterToAdd.startsWith('bf'))
			isDad = false;
		char = new Character(0, 0, characterToAdd, !isDad);
		if (char.animArray[0] != null)
			char.playAnim(char.animArray[0].animPrefix, true);
		char.screenCenter();
		char.debugMode = true;

		add(char);

		if (updateAnimLists)
			genBoyOffsets();

		if (uiBox != null)
			loadCharSettings();

		updateHealthBarDisplay(true);

		// loadAnimDropDown();

		camFollow.x = char.getMidpoint().x;
		camFollow.y = char.getMidpoint().y;

		// char.flipX = charJSON.flipX;

		// if (CDevConfig.saveData.antialiasing)
		// char.antialiasing = charJSON.usingAntialiasing;
		updateCharPosition();

		createCameraPointer();
		updateCamPointPos();
		// else
		// char.antialiasing = false;
	}

	function updateCamPointPos()
	{
		var xPos:Float = char.getMidpoint().x;
		var yPos:Float = char.getMidpoint().y;
		if (!char.isPlayer)
			xPos += 150 + char.charCamPos[0];
		else
			xPos -= 100 + char.charCamPos[0];

		yPos -= 100 - char.charCamPos[1];

		xPos -= camFolPoint.width / 2;
		yPos -= camFolPoint.height / 2;
		camFolPoint.setPosition(xPos, yPos);
	}

	function loadCharSettings()
	{
		charSpritePath.text = charJSON.spritePath;
		healthIconName.text = charJSON.iconName;
		stepper_healthBarC1.value = charJSON.healthBarColor[0];
		stepper_healthBarC2.value = charJSON.healthBarColor[1];
		stepper_healthBarC3.value = charJSON.healthBarColor[2];
		stepper_camXPos.value = charJSON.camXYPos[0];
		stepper_camYPos.value = charJSON.camXYPos[1];
		stepper_charXPos.value = charJSON.charXYPosition[0];
		stepper_charYPos.value = charJSON.charXYPosition[1];
		stepper_scale.value = charJSON.charScale;
		stepper_singTime.value = charJSON.singHoldTime;

		check_flipX.checked = charJSON.flipX;
		check_usingAntialiasing.checked = charJSON.usingAntialiasing;

		updateHealthBarDisplay(true);
		loadAnimDropDown();
	}

	function genBoyOffsets():Void
	{
		var daLoop:Int = 0;

		var i:Int = dumbTexts.members.length - 1;
		while (i >= 0)
		{
			var member:FlxText = dumbTexts.members[i];
			if (member != null)
			{
				member.kill();
				dumbTexts.remove(member);
				member.destroy();
			}
			--i;
		}
		dumbTexts.clear();

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(20, 65 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.WHITE;
			text.setFormat('VCR OSD Mono', 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			dumbTexts.add(text);

			daLoop++;
		}

		textAnim.visible = true;

		if (dumbTexts.length < 1)
		{
			var text:FlxText = new FlxText(10, 65, 0, "Error: Can't find any animations.", 15);
			text.scrollFactor.set();
			text.setFormat('VCR OSD Mono', 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			text.borderSize = 1;
			dumbTexts.add(text);
			textAnim.visible = false;
		}

		var daLoop:Int = 0;
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	var multiplier = 0;
	var camMulti = 0;

	override function update(elapsed:Float)
	{
		multiplier = (FlxG.keys.pressed.SHIFT ? 10 : 1);
		camMulti = (FlxG.keys.pressed.SHIFT ? 5 : 1);
		if (char.animation.curAnim != null && textAnim != null)
			textAnim.text = char.animation.curAnim.name;

		var flxTypeTextOrSomething:Array<Bool> = [
			charSpritePath.hasFocus,
			healthIconName.hasFocus,
			input_animIndices.hasFocus,
			input_animName.hasFocus,
			input_animPrefix.hasFocus
		];

		var inputTexts:Array<FlxUIInputText> = [
			// dumb
			charSpritePath,
			healthIconName,
			input_animIndices,
			input_animName,
			input_animPrefix
		];

		// doing this to prevent the camera moving whenever typing "E,Q,I,K,J,L" word
		if (!flxTypeTextOrSomething.contains(true))
		{
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

			if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
			{
				FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
				if (FlxG.camera.zoom > 3)
					FlxG.camera.zoom = 3;
			}
			if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
			{
				FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
				if (FlxG.camera.zoom < 0.1)
					FlxG.camera.zoom = 0.1;
			}
		}
		else
		{
			for (i in 0...inputTexts.length)
			{
				if (inputTexts[i].hasFocus)
				{
					if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null)
					{
						inputTexts[i].text = game.cdev.CDevConfig.utils.pasteFunction(inputTexts[i].text);
						inputTexts[i].caretIndex = inputTexts[i].text.length;
						getEvent(FlxUIInputText.CHANGE_EVENT, inputTexts[i], null, []);
					}
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					if (FlxG.keys.justPressed.ENTER)
						inputTexts[i].hasFocus = false;
				}
			}
		}

		if (char.animArray.length > 0)
		{
			if (!flxTypeTextOrSomething.contains(true))
			{
				if (FlxG.keys.justPressed.W)
					curAnim -= 1;

				if (FlxG.keys.justPressed.S)
					curAnim += 1;

				if (curAnim < 0)
					curAnim = char.animArray.length - 1;

				if (curAnim >= char.animArray.length)
					curAnim = 0;

				if (FlxG.keys.justPressed.ESCAPE)
				{
					FlxG.camera.bgColor = 0xFF000000;
					if (!moddingMode)
					{
						if (fromPlayState)
							FlxG.switchState(new meta.states.PlayState());
						else
							FlxG.switchState(new ModdingState());
					}
					else
					{
						FlxG.switchState(new ModdingScreen());
					}
				}

				if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
				{
					char.playAnim(char.animArray[curAnim].animPrefix, true);
					genBoyOffsets();
				}

				var controlArray:Array<Bool> = [
					FlxG.keys.justPressed.LEFT,
					FlxG.keys.justPressed.RIGHT,
					FlxG.keys.justPressed.UP,
					FlxG.keys.justPressed.DOWN
				];
				for (i in 0...controlArray.length)
				{
					if (controlArray[i])
					{
						var arrayValue = 0;

						if (i > 1)
							arrayValue = 1;

						var negativeMult:Int = 1;
						if (i % 2 == 1)
							negativeMult = -1;

						char.animArray[curAnim].offset[arrayValue] += negativeMult * multiplier;

						char.addOffset(char.animArray[curAnim].animPrefix, char.animArray[curAnim].offset[0], char.animArray[curAnim].offset[1]);
						char.playAnim(char.animArray[curAnim].animPrefix, false);

						genBoyOffsets();
					}
				}
			}
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

	function saveCharacter()
	{
		var jsonFile = {
			"animations": char.animArray,
			"spritePath": char.imgFile,
			"charScale": char.jsonScale,
			"singHoldTime": char.charHoldTime,
			"iconName": char.healthIcon,

			"charXYPosition": char.charXYPos,
			"camXYPos": char.charCamPos,

			"flipX": char.previousFlipX,
			"usingAntialiasing": char.usingAntiAlias,
			"healthBarColor": char.healthBarColors
		};

		var data:String = Json.stringify(jsonFile, "\t");

		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, characterToAdd + ".json");
		}
	}
}

class CharacterEditorSaveDialog extends MusicBeatSubstate
{
	var box:FlxSprite;
	var exitButt:FlxSprite;
	var daData:CharData;

	public function new(characterData:CharData)
	{
		super();
		this.daData = characterData;
		var bgBlack:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgBlack.alpha = 0.5;
		add(bgBlack);

		box = new FlxSprite().makeGraphic(800, 400, FlxColor.BLACK);
		box.alpha = 0.7;
		box.screenCenter();
		add(box);

		exitButt = new FlxSprite().makeGraphic(30, 20, FlxColor.RED);
		exitButt.alpha = 0.7;
		exitButt.x = ((box.x + box.width) - 30) - 10;
		exitButt.y = (box.y + 20) - 10;
		add(exitButt);

		createBoxUI();

		bgBlack.alpha = 0;
		FlxTween.tween(bgBlack, {alpha: 0.5}, 0.3, {ease: FlxEase.linear});
		box.alpha = 0;
		FlxTween.tween(box, {alpha: 0.7}, 0.3, {ease: FlxEase.linear});
		exitButt.alpha = 0;
		FlxTween.tween(exitButt, {alpha: 0.7}, 0.3, {ease: FlxEase.linear});

		// cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		exitButt.scrollFactor.set();
	}

	var input_charName:FlxUIInputText;
	var butt_saveChar:FlxSprite;
	var txtBs:FlxText;
	var txtCn:FlxText;

	function createBoxUI()
	{
		var header:FlxText = new FlxText(box.x, box.y + 10, 800, "Save Character", 40);
		header.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header);

		input_charName = new FlxUIInputText(box.x + 50, box.y + 100, 500, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_charName.font = "VCR OSD Mono";
		add(input_charName);
		txtCn = new FlxText(input_charName.x, input_charName.y - 25, 500, "Character Name", 20);
		txtCn.font = "VCR OSD Mono";
		add(txtCn);

		butt_saveChar = new FlxSprite(865, 510).makeGraphic(150, 32, FlxColor.fromRGB(70, 70, 70));
		add(butt_saveChar);

		txtBs = new FlxText(865, 515, 150, "Save", 18);
		txtBs.font = "VCR OSD Mono";
		txtBs.alignment = CENTER;
		add(txtBs);

		input_charName.scrollFactor.set();
		butt_saveChar.scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		if (input_charName.hasFocus)
		{
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null)
			{
				input_charName.text = game.cdev.CDevConfig.utils.pasteFunction(input_charName.text);
				input_charName.caretIndex = input_charName.text.length;
			}

			if (FlxG.keys.justPressed.ENTER)
			{
				saveChar();
				close();
				kill();
			}
		}

		if (input_charName.hasFocus)
		{
			txtCn.color = FlxColor.WHITE;
		}

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

		if (FlxG.mouse.overlaps(butt_saveChar))
		{
			butt_saveChar.alpha = 1;
			txtBs.alpha = 1;

			if (FlxG.mouse.justPressed)
			{
				if (input_charName.text != '')
				{
					FlxG.sound.play(game.Paths.sound('confirmMenu'));

					saveChar();
					close();
					FlxG.save.flush();
					kill();
				}
				else
				{
					txtCn.color = FlxColor.RED;
					FlxG.sound.play(game.Paths.sound('cancelMenu'));
				}
			}
		}
		else
		{
			txtBs.alpha = 0.7;
			butt_saveChar.alpha = 0.7;
		}
		super.update(elapsed);
	}

	function saveChar()
	{
		var data:String = Json.stringify(daData, "\t");

		if (data.length > 0)
			File.saveContent('cdev-mods/' + Paths.curModDir[0] + '/data/characters/' + input_charName.text + '.json', data);
	}
}
