package meta.modding.stage_editor;

import lime.system.Clipboard;
import meta.substates.MusicBeatSubstate;
import haxe.Json;
import sys.io.File;
import game.Stage;
import game.Stage.BeatSprite;
import game.Conductor;
import haxe.io.Path;
import sys.FileSystem;
import game.cdev.UIDropDown;
import flixel.tweens.FlxEase;
import game.cdev.CDevPopUp;
import flixel.addons.ui.FlxUIText;
import flixel.math.FlxPoint;
import game.Stage.SpriteStage;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import game.Paths;
import flixel.math.FlxMath;
import game.cdev.CDevConfig;
import flixel.addons.ui.*;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUI;
import game.Stage.StageJSONData;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxCamera;
import game.objects.Character;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxSprite;
import meta.states.MusicBeatState;

using StringTools;

typedef StageObject_Array =
{
	var object:FlxSprite;
	var name:String;

	var removable:Bool;
	var locked:Bool;
	var selected:Bool;
	var color:Int;
}

// A rewrited version of modding.stage_editor.StageEditor

class Better_StageEditor extends MusicBeatState
{
	public var __STAGE_JSON:StageJSONData;

	public static var stageToLoad:String = "<NO STAGE>";

	// OBJECTS //
	var character_list:Array<String> = ["dad", "gf", "bf"];
	var _followCam:FlxObject;
	var __objectButtons_array:Array<FlxUIButton> = [];

	// SELECTED OBJECT //
	var mouseOffsetPos:FlxPoint = new FlxPoint(0, 0);
	var mouseOffsetCam:FlxPoint = new FlxPoint(0, 0);
	var _single_selectedObject(default, set):SpriteStage = null;

	function set__single_selectedObject(s:SpriteStage):SpriteStage
	{
		_single_selectedObject = s;
		camGame.bgColor = _single_selectedObject == null ? FlxColor.BLACK : 0xFF424242;

		return s;
	}

	var _currentObject(default, set):SpriteStage;

	function set__currentObject(n:SpriteStage):SpriteStage
	{
		_currentObject = n;
		label_info_text.text = _currentObject != null ? _currentObject.objectName : "(No sprite selected.)";
		if (_currentObject == null)
		{
			// global shit
			for (o in [
				label_info_pos, stepper_info_posX, stepper_info_posY, stepper_info_alpha, stepper_info_scale, stepper_info_sf, check_antialiasing,
				check_flipX, label_info_alpha, label_info_scale, label_info_sf
			])
			{
				o.visible = false;
			}
			// sparrow shit
			// for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
			//    e.visible = false;
			// }
		}
		else
		{
			for (o in [
				label_info_pos, stepper_info_posX, stepper_info_posY, stepper_info_alpha, stepper_info_scale, stepper_info_sf, check_antialiasing,
				check_flipX, label_info_alpha, label_info_scale, label_info_sf
			])
			{
				o.visible = true;
			}
			stepper_info_posX.value = _currentObject.x;
			stepper_info_posY.value = _currentObject.y;
			stepper_info_alpha.value = _currentObject.alpha;
			stepper_info_scale.value = _currentObject.scale.x;
			stepper_info_sf.value = _currentObject.scrollFactor.x;

			if (character_list.contains(_currentObject.type))
			{
				for (e in [
					stepper_info_alpha, stepper_info_scale,  stepper_info_sf, check_antialiasing,
					       check_flipX,   label_info_alpha, label_info_scale,      label_info_sf
				])
				{
					e.visible = false;
				}
			}
		}

		for (b in __objectButtons_array)
		{
			var buttonName = getButtonName(b.label.text);
			if (_currentObject != null && _currentObject.objectName == b.label.text)
			{
				b.label.text = '> $buttonName <';
			}
			else
			{
				b.label.text = '$buttonName';
			}
		}

		return _currentObject;
	}

	function getButtonName(name:String):String
	{
		if (name.startsWith("> ") && name.endsWith(" <"))
			return name.substr(2, name.length - 4);
		else
			return name;
	}

	public var _objectMoved:SpriteStage = null;

	// POSITIONS //
	var _BF_POS:FlxPoint = new FlxPoint(770, 100);
	var _DAD_POS:FlxPoint = new FlxPoint(100, 100);
	var _GF_POS:FlxPoint = new FlxPoint(400, 130);

	// CAMERAS //
	public var camHUD:FlxCamera;

	var camGame:FlxCamera;

	// BOXES//
	var uiBox:FlxUITabMenu;
	var uiBox_visible:FlxUIButton;

	var tab_stage_info:FlxUI;
	var tab_stage_spr:FlxUI;
	var tab_stage_config:FlxUI;

	// CHARACTERS //
	var dad:Character;
	var gf:Character;
	var bf:Character;

	// MISC //
	var tweenCam:FlxTween;

	public var normalAnim_sprites:Array<BeatSprite> = [];
	public var beatHit_sprites:Array<BeatSprite> = [];
	public var beatHit_force_sprites:Array<BeatSprite> = [];

	var stageList:Array<String> = [];

	var unsaved:Bool = false;

	public var stageDropDown:UIDropDown;

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();
		__init_cameras();
		__init_stageJson();
		_init_Characters();
		loadCharDropDown();
		loadStageDropDown();
		__init_uiBox();

		__init_followCam();

		FlxG.mouse.visible = true;

		// _update_uiBox_data();
		updateStageElements();

		var stageLabel:FlxText = new FlxText(10, FlxG.height - 30, 0, "Current Stage", 8);
		stageDropDown = new UIDropDown(stageLabel.x + stageLabel.width + 10, stageLabel.y, UIDropDown.makeStrIdLabelArray(stageList, true),
			function(stage:String)
			{
				stageToLoad = stageList[Std.parseInt(stage)];
				FlxG.resetState();
			});
		stageDropDown.selectedLabel = stageToLoad;
		stageDropDown.dropDirection = Up;
		add(stageLabel);
		add(stageDropDown);
		stageLabel.cameras = [camHUD];
		stageDropDown.cameras = [camHUD];

		stageLabel.scrollFactor.set();
		stageDropDown.scrollFactor.set();

		var saveButton = new FlxUIButton(FlxG.width-50,FlxG.height-20,"",function(){
			save();
		});
		add(saveButton);
		saveButton.resize(50,20);
		saveButton.addIcon(new FlxSprite().loadGraphic(Paths.image("ui/file","shared")));
		saveButton.cameras = [camHUD];
	}

	function __init_stageJson()
	{
		if (stageToLoad != '<NO STAGE>')
		{
			var crapJSON = null;

			#if ALLOW_MODS
			var charFile:String = Paths.modStage(stageToLoad);
			if (FileSystem.exists(charFile))
				crapJSON = File.getContent(charFile);
			#end

			if (crapJSON == null)
			{
				#if ALLOW_MODS
				crapJSON = File.getContent(Paths.stage(stageToLoad));
				#else
				crapJSON = Assets.getText(Paths.stage(stageToLoad));
				#end
			}

			var json:StageJSONData = cast Json.parse(crapJSON);

			if (crapJSON != null)
			{
				__STAGE_JSON = json;
			}
		}
		else
		{
			__STAGE_JSON = Stage.templateJSON;
		}
	}

	function __init_followCam()
	{
		_followCam = new FlxObject(0, 0, 2, 2);
		add(_followCam);

		FlxG.camera.follow(_followCam);
		FlxG.camera.focusOn(_followCam.getPosition());

		FlxCamera.defaultCameras = [camGame];
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);
	}

	function _init_Characters()
	{
		gf = new Character(0, 0, "gf", false, true);
		gf.setPosition(__STAGE_JSON.girlfriendPosition[0], __STAGE_JSON.girlfriendPosition[1]);
		//gf.gfTestBop = true;
		gf.objectName = "Girlfriend";
		gf.type = "gf";
		// __OBJECT_LIST.push(_create_ObjectList_array(gf, "Girlfriend", false, false, 0xFFC00000));

		dad = new Character(0, 0, "dad", false, true);
		dad.setPosition(__STAGE_JSON.opponentPosition[0], __STAGE_JSON.opponentPosition[1]);
		//dad.gfTestBop = true;
		dad.objectName = "Opponent";
		dad.type = "dad";
		// __OBJECT_LIST.push(_create_ObjectList_array(dad, "Opponent", false, false, 0xFF7400CD));

		bf = new Character(0, 0, "bf", true, true);
		bf.setPosition(__STAGE_JSON.boyfriendPosition[0], __STAGE_JSON.boyfriendPosition[1]);
		//bf.gfTestBop = true;
		bf.objectName = "Boyfriend";
		bf.type = "bf";
		// __OBJECT_LIST.push(_create_ObjectList_array(bf, "Boyfriend", false, false, 0xFF0078BD));
	}

	function _create_ObjectList_array(obj:FlxSprite, obj_name:String, removableObj:Bool, locked:Bool, color:Int = -1):StageObject_Array
	{
		return {
			object: obj,
			name: obj_name,
			removable: removableObj,
			locked: locked,
			selected: false,
			color: color
		}
	}

	function __init_cameras()
	{
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
	}

	var show_uiBox:Bool = false;

	function __init_uiBox()
	{
		var tabs = [
			{name: "Stage Config", label: 'Stage Config'},
			{name: "Information", label: 'Information'},
			{name: "Layers", label: 'Layers'}
		];
		uiBox = new FlxUITabMenu(null, tabs, true);
		uiBox.resize(350, 500);
		uiBox.x = FlxG.width - uiBox.width - 60;
		uiBox.y = FlxG.height - uiBox.height;
		uiBox.cameras = [camHUD];
		uiBox.scrollFactor.set();
		add(uiBox);

		_create_uiBox_stageConfig();
		_create_uiBox_layers();
		_create_uiBox_information();
		uiBox.addGroup(tab_stage_spr);

		uiBox_visible = new FlxUIButton(uiBox.x, FlxG.height - 20, "v", function()
		{
			show_uiBox = !show_uiBox;
			uiBox_visible.label.flipY = (show_uiBox ? false : true);
			FlxG.sound.play(Paths.sound("scrollMenu"));
		});
		uiBox_visible.resize(350, 20);
		uiBox_visible.cameras = [camHUD];
		add(uiBox_visible);
	}

	var stepper_cameraZoom:FlxUINumericStepper;
	var stepper_cameraLerp:FlxUINumericStepper;
	var camLerp_label:FlxText;
	var check_useCustomFollowLerp:FlxUICheckBox;

	function _create_uiBox_stageConfig()
	{
		tab_stage_config = new FlxUI(null, uiBox);
		tab_stage_config.name = "Stage Config";

		tab_stage_config.add(new FlxText(10, 10, 490, "Main Config", 12));

		stepper_cameraZoom = new FlxUINumericStepper(10, 50, 0.05, 0.9, 0.1, 50, 2);
		tab_stage_config.add(stepper_cameraZoom);
		tab_stage_config.add(new FlxText(10, stepper_cameraZoom.y - 15, 490, "Camera Zoom", 8));

		check_useCustomFollowLerp = new FlxUICheckBox(10, stepper_cameraZoom.y + 25, null, null, "Use Custom Follow Lerp", 140);
		tab_stage_config.add(check_useCustomFollowLerp);

		stepper_cameraLerp = new FlxUINumericStepper(10, check_useCustomFollowLerp.y + 35, 0.01, 0.03, 0, 1, 2);
		tab_stage_config.add(stepper_cameraLerp);

		camLerp_label = new FlxText(10, stepper_cameraLerp.y - 15, 490, "Camera Follow Lerp", 8);
		tab_stage_config.add(camLerp_label);

		uiBox.addGroup(tab_stage_config);

		stepper_cameraLerp.visible = false;
		camLerp_label.visible = false;
	}

	var charList:Array<String> = [];
	var bfDropDown:UIDropDown;
	var gfDropDown:UIDropDown;
	var opDropDown:UIDropDown;

	var lastPos:FlxPoint = new FlxPoint(0, 0);

	function _create_uiBox_layers()
	{
		tab_stage_spr = new FlxUI(null, uiBox);
		tab_stage_spr.name = "Layers";

		tab_stage_spr.add(new FlxText(10, 10, 490, "Stage Layers / Sprites", 12));
		var selectAllButton:FlxUIButton;
		var removeObject:FlxUIButton;

		selectAllButton = new FlxUIButton(20, uiBox.height - 140, "Select All", function()
		{
			_single_selectedObject = null;
		}, true, false, 0xFF002B63);
		selectAllButton.resize(350 - 40, 20);
		selectAllButton.setLabelFormat(null, 8, FlxColor.WHITE, CENTER);

		removeObject = new FlxUIButton(10, uiBox.height - 110, "Delete Object", function()
		{
			if (_currentObject == null)
			{
				var t = new CDevPopUp("Error", "Select a sprite first!", [
					{
						text: "OK",
						callback: function()
						{
							closeSubState();
						}
					}
				], false, true);
				t.cameras = [camHUD];
				openSubState(t);
				FlxG.camera.zoom = 1;
				return;
			}
			if (character_list.contains(_currentObject.type))
			{
				var t = new CDevPopUp("Error", "You can't delete " + _currentObject.objectName + ".", [
					{
						text: "OK",
						callback: function()
						{
							closeSubState();
						}
					}
				], false, true);
				t.cameras = [camHUD];
				openSubState(t);
				FlxG.camera.zoom = 1;
				return;
			}
			var t = new CDevPopUp("Delete Confirmation",
				"Are you sure you want to delete \"" + _currentObject.objectName + "\"? You can't revert this operation.", [
				{
					text: "Yes",
					callback: function()
					{
						for (s in __STAGE_JSON.sprites)
						{
							if (s.imageVar == _currentObject.objectName)
							{
								__STAGE_JSON.sprites.remove(s);
								_currentObject = null;
								_single_selectedObject = null;
								updateStageElements();
								closeSubState();
								break;
							}
						}
					}
				},
				{
					text: "No",
					callback: function()
					{
						closeSubState();
					}
				}
			], false, true);
			t.cameras = [camHUD];
			openSubState(t);
			FlxG.camera.zoom = 1;
		}, true, false, 0xFFE70000);
		removeObject.resize((350 / 2) - 30, 20);
		removeObject.setLabelFormat(null, 8, FlxColor.WHITE, CENTER);

		var addSpriteButton:FlxUIButton = new FlxUIButton(uiBox.width / 2 + 20, removeObject.y, "Add Sprite", function()
		{
			openSubState(new AddStageSprite(this));
			FlxG.camera.zoom = 1;
		}, true, false, 0xFF00CC18);
		addSpriteButton.resize((350 / 2) - 30, 20);
		addSpriteButton.setLabelFormat(null, 8, FlxColor.WHITE, CENTER);

		tab_stage_spr.add(selectAllButton);
		trace("exist: " + (selectAllButton != null) + " | Pos: " + "x: " + selectAllButton.x + ", y: " + selectAllButton.y);
		tab_stage_spr.add(removeObject);
		trace("exist: " + (removeObject != null) + " | Pos: " + "x: " + removeObject.x + ", y: " + removeObject.y);
		tab_stage_spr.add(addSpriteButton);
		trace("exist: " + (addSpriteButton != null) + " | Pos: " + "x: " + addSpriteButton.x + ", y: " + addSpriteButton.y);

		bfDropDown = new UIDropDown(10, addSpriteButton.y + 35, UIDropDown.makeStrIdLabelArray(charList, true), function(character:String)
		{
			var layer = members.indexOf(bf);
			var char = new Character(0, 0, charList[Std.parseInt(character)], true, true);
			char.setPosition(__STAGE_JSON.boyfriendPosition[0], __STAGE_JSON.boyfriendPosition[1]);
			//char.gfTestBop = true;
			char.objectName = "Boyfriend";
			char.type = "bf";

			if (_currentObject == bf)
				_currentObject = char;
			if (_single_selectedObject == bf)
				_single_selectedObject = char;

			remove(bf);
			bf.destroy();
			bf = char;
			insert(layer, char);

			loadCharDropDown();
			updateStageElements();
		});
		bfDropDown.selectedLabel = bf.curCharacter;
		bfDropDown.dropDirection = Up;
		var bfddText:FlxText = new FlxText(bfDropDown.x, bfDropDown.y - 15, FlxG.width, "Boyfriend", 8);

		gfDropDown = new UIDropDown(10, bfDropDown.y + 35, UIDropDown.makeStrIdLabelArray(charList, true), function(character:String)
		{
			var layer = members.indexOf(gf);
			var char = new Character(0, 0, charList[Std.parseInt(character)], false, true);
			char.setPosition(__STAGE_JSON.girlfriendPosition[0], __STAGE_JSON.girlfriendPosition[1]);
			//char.gfTestBop = true;
			char.objectName = "Girlfriend";
			char.type = "gf";

			if (_currentObject == gf)
				_currentObject = char;
			if (_single_selectedObject == gf)
				_single_selectedObject = char;

			remove(gf);
			gf.destroy();
			gf = char;
			insert(layer, char);

			loadCharDropDown();
			updateStageElements();
		});
		gfDropDown.selectedLabel = gf.curCharacter;
		gfDropDown.dropDirection = Up;
		var gfddText:FlxText = new FlxText(gfDropDown.x, gfDropDown.y - 15, FlxG.width, "Girlfriend", 8);

		opDropDown = new UIDropDown(bfDropDown.x + bfDropDown.width + 10, addSpriteButton.y + 35, UIDropDown.makeStrIdLabelArray(charList, true),
			function(character:String)
			{
				var layer = members.indexOf(dad);
				var char = new Character(0, 0, charList[Std.parseInt(character)], false, true);
				char.setPosition(__STAGE_JSON.opponentPosition[0], __STAGE_JSON.opponentPosition[1]);
				//char.gfTestBop = true;
				char.objectName = "Opponent";
				char.type = "dad";

				if (_currentObject == dad)
					_currentObject = char;
				if (_single_selectedObject == dad)
					_single_selectedObject = char;

				remove(dad);
				dad.destroy();
				dad = char;
				insert(layer, char);

				loadCharDropDown();
				updateStageElements();
			});
		// opDropDown.x = 400 - opDropDown.width - 10;
		opDropDown.selectedLabel = dad.curCharacter;
		opDropDown.dropDirection = Up;
		var opText:FlxText = new FlxText(opDropDown.x, opDropDown.y - 15, FlxG.width, "Opponent", 8);

		var separator:FlxSprite = new FlxSprite(10, selectAllButton.y - 10).makeGraphic(Std.int(uiBox.width - 20), 2, FlxColor.BLACK);
		tab_stage_spr.add(separator);

		tab_stage_spr.add(bfDropDown);
		tab_stage_spr.add(bfddText);
		tab_stage_spr.add(gfDropDown);
		tab_stage_spr.add(gfddText);
		tab_stage_spr.add(opDropDown);
		tab_stage_spr.add(opText);
		var moveUp = new FlxUIButton((uiBox.width / 2)+100, bfDropDown.y, "v", function()
		{
			if (_currentObject != null)
			{
				moveSpriteToLayer(_currentObject, -1);
			}
		}, true, false);
		moveUp.resize(20, 20);
		moveUp.label.angle = 180;
		var moveDown = new FlxUIButton((uiBox.width / 2)+100, gfDropDown.y, "v", function()
		{
			if (_currentObject != null)
			{
				moveSpriteToLayer(_currentObject, 1);
			}
		}, true, false);
		moveDown.resize(20, 20);
		tab_stage_spr.add(moveUp);
		moveUp.cameras = [camHUD];
		tab_stage_spr.add(moveDown);
		moveDown.cameras = [camHUD];
		uiBox.addGroup(tab_stage_spr);
	}

	public var stepper_info_posX:FlxUINumericStepper;
	public var stepper_info_posY:FlxUINumericStepper;

	public var stepper_info_sf:FlxUINumericStepper;
	public var label_info_sf:FlxUIText;
	public var stepper_info_scale:FlxUINumericStepper;
	public var label_info_scale:FlxUIText;
	public var check_antialiasing:FlxUICheckBox;
	public var check_flipX:FlxUICheckBox;
	public var label_info_pos:FlxUIText;
	public var label_info_text:FlxUIText;
	public var stepper_info_alpha:FlxUINumericStepper;
	public var label_info_alpha:FlxUIText;

	function _create_uiBox_information()
	{
		tab_stage_info = new FlxUI(null, uiBox);
		tab_stage_info.name = "Information";

		label_info_text = new FlxUIText(10, 10, 490, "", 12);
		tab_stage_info.add(label_info_text);

		// position
		stepper_info_posX = new FlxUINumericStepper(10, 50, 10, 0, -90000, 90000, 0);
		stepper_info_posX.name = 's_iX';
		stepper_info_posY = new FlxUINumericStepper(80, 50, 10, 0, -90000, 90000, 0);
		stepper_info_posY.name = 's_iY';
		tab_stage_info.add(stepper_info_posX);
		tab_stage_info.add(stepper_info_posY);
		label_info_pos = new FlxUIText(10, stepper_info_posX.y - 15, 500, "Sprite Position (X, Y)");
		tab_stage_info.add(label_info_pos);

		// scale
		stepper_info_scale = new FlxUINumericStepper(10, stepper_info_posX.y + 30, 0.05, 1, 0.01, 9000, 2);
		stepper_info_scale.name = "s_scale";
		tab_stage_info.add(stepper_info_scale);
		label_info_scale = new FlxUIText(10, stepper_info_scale.y - 15, 500, "Sprite Scale");
		tab_stage_info.add(label_info_scale);

		// scroll
		stepper_info_sf = new FlxUINumericStepper(10, stepper_info_scale.y + 30, 0.05, 1, 0.01, 9000, 2);
		stepper_info_sf.name = "s_scroll";
		tab_stage_info.add(stepper_info_sf);
		label_info_sf = new FlxUIText(10, stepper_info_sf.y - 15, 500, "Sprite Scroll Factor");
		tab_stage_info.add(label_info_sf);

		// antialising
		check_antialiasing = new FlxUICheckBox(stepper_info_sf.x, stepper_info_sf.y + 30, null, null, "Antialiasing", 150, [], function()
		{
			_currentObject.antialiasing = check_antialiasing.checked;
		});
		tab_stage_info.add(check_antialiasing);

		// filpX
		check_flipX = new FlxUICheckBox(uiBox.width / 2 + 10, check_antialiasing.y, null, null, "FlipX", 150, [], function()
		{
			_currentObject.flipX = check_flipX.checked;
		});
		tab_stage_info.add(check_flipX);

		// alpha
		stepper_info_alpha = new FlxUINumericStepper(10, check_antialiasing.y + 30, 0.05, 1, 0.01, 9000, 2);
		stepper_info_alpha.name = "s_alpha";
		tab_stage_info.add(stepper_info_alpha);
		label_info_alpha = new FlxUIText(10, stepper_info_alpha.y - 15, 500, "Sprite Alpha");
		tab_stage_info.add(label_info_alpha);

		uiBox.addGroup(tab_stage_info);
	}

	var lastTab:String = "";

	public function updateStageElements()
	{
		var alreadySpawnedSprites:Map<String, SpriteStage> = [];
		var toDelete:Array<SpriteStage> = [];
		for (e in __objectButtons_array)
		{
			remove(e);
			tab_stage_spr.remove(e);
			e.destroy();
		}
		__objectButtons_array = [];
		for (e in members)
		{
			if (Std.isOfType(e, SpriteStage))
			{
				var sprite = cast(e, SpriteStage);
				if (!character_list.contains(sprite.type))
				{
					alreadySpawnedSprites[sprite.objectName] = sprite;
					toDelete.push(sprite);
				}
				remove(sprite);
			}
		}

		for (s in __STAGE_JSON.sprites)
		{
			var spr = alreadySpawnedSprites[s.imageVar];
			if (spr != null)
			{
				toDelete.remove(spr);
				add(spr);
			}
			else
			{
				switch (s.spriteType)
				{
					case "sparrow":
						var daSprite:SpriteStage = new SpriteStage();
						daSprite.antialiasing = s.imageAntialias;
						daSprite.objectName = s.imageVar;
						daSprite.type = "sparrow";
						daSprite.scrollFactor.set(s.imageSF, s.imageSF);
						daSprite.setPosition(s.position[0], s.position[1]);
						daSprite.spritePath = s.imagePath;

						var sparrowAtlas = Paths.getSparrowAtlas(s.imagePath, "shared");
						if (sparrowAtlas != null)
						{
							daSprite.frames = sparrowAtlas;

							if (s.animation != null)
							{
								daSprite.anim = s.animation;
								var animName = "anim";
								var framerate = 24;
								if (s.animation.animPrefix != null)
									animName = s.animation.animPrefix;
								if (s.animation.fpsValue != null)
									framerate = s.animation.fpsValue;
								
								daSprite.animType = s.animType;

								daSprite.animation.addByPrefix(animName, animName, framerate, false);
								daSprite.animation.play(animName);
								daSprite.anim = s.animation;

								var beatSprite_anim:BeatSprite = {
									anim: animName,
									sprite: daSprite
								}
								switch (s.animType.toLowerCase())
								{
									case "beat-force":
										beatHit_force_sprites.push(beatSprite_anim);
									case "beat":
										beatHit_sprites.push(beatSprite_anim);
									case "normal":
										normalAnim_sprites.push(beatSprite_anim);
								}
							}
						}
						add(daSprite);
						spr = daSprite;
					case "bitmap":
						var daSprite:SpriteStage = new SpriteStage();
						daSprite.loadGraphic(Paths.image(s.imagePath), 'shared');
						daSprite.spritePath = s.imagePath;
						daSprite.objectName = s.imageVar;
						daSprite.type = "bitmap";

						daSprite.scale.set(s.imageScale, s.imageScale);
						daSprite.antialiasing = s.imageAntialias;
						daSprite.setPosition(s.position[0], s.position[1]);
						daSprite.scrollFactor.set(s.imageSF, s.imageSF);
						daSprite.alpha = s.imageAlpha;
						add(daSprite);
						spr = daSprite;
					case "bf":
						add(bf);
						spr = bf;
					case "gf":
						add(gf);
						spr = gf;
					case "dad":
						add(dad);
						spr = dad;
				}
			}
			trace(spr);
			if (spr != null)
			{
				var theColor:Int = 0xFFFFFFFF;
				switch (spr.type.toLowerCase())
				{
					case "bf":
						theColor = 0xFF0078BD;
					case "gf":
						theColor = 0xFFC00000;
					case "dad":
						theColor = 0xFF7400CD;
				}
				var button = new FlxUIButton(10, 40 + (25 * __objectButtons_array.length),
					(_currentObject == spr || _objectMoved == spr || _single_selectedObject == spr) ? '> ${spr.objectName} <' : spr.objectName, function()
				{
					if (_single_selectedObject == spr)
					{
						_single_selectedObject = _currentObject = null;
					}
					else
					{
						_currentObject = spr;
						_single_selectedObject = spr;
					}
				}, true, false, theColor);
				button.visible = uiBox.selected_tab_id == "Layers";
				if (character_list.contains(spr.type))
				{
					button.setLabelFormat(null, 8, FlxColor.WHITE, CENTER);
				}
				button.resize(350 - 30, 20);
				tab_stage_spr.add(button);
				__objectButtons_array.push(button);
			}
		}
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Use Custom Follow Lerp':
					stepper_cameraLerp.active = check.checked;
					stepper_cameraLerp.visible = check.checked;
					camLerp_label.visible = check.checked;
					__STAGE_JSON.useCustomFollowLerp = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			switch (wname)
			{
				case "s_iX":
					_currentObject.x = nums.value;
				case "s_iY":
					_currentObject.y = nums.value;
				case "s_scale":
					_currentObject.scale.set(nums.value, nums.value);
				case "s_scroll":
					_currentObject.scrollFactor.set(nums.value, nums.value);
				case "s_alpha":
					_currentObject.alpha = nums.value;
			}
		}
	}

	function _update_uiBox_data()
	{
		// STAGE CONFIG //
		stepper_cameraZoom.value = __STAGE_JSON.stageZoom;
		stepper_cameraLerp.value = __STAGE_JSON.followLerp;
		check_useCustomFollowLerp.checked = __STAGE_JSON.useCustomFollowLerp;

		stepper_cameraLerp.visible = false;
		camLerp_label.visible = false;

		// LAYERS //
	}

	var _uiBox_Y:Float = 0;
	var clicks:Int = 0;
	var time:Float = 0;
	var startCounting:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
		{
			if (FlxG.sound.music.playing)
			{
				Conductor.songPosition = FlxG.sound.music.time;
			}
		}

		_update_keyControls(elapsed);
		_update_mouseControls(elapsed);
		_update_stageJSON_characters();

		for (s in normalAnim_sprites)
		{
			if (s.sprite.animation.curAnim != null)
			{
				if (s.sprite.animation.curAnim.finished)
					s.sprite.animation.play(s.anim);
			}
		}

		if (lastTab != uiBox.selected_tab_id)
		{
			switch (uiBox.selected_tab_id.toLowerCase())
			{
				case "information":
					var s:SpriteStage = _currentObject;
					_currentObject = s;
				case "stage config":
					stepper_cameraZoom.value = __STAGE_JSON.stageZoom;
					stepper_cameraLerp.value = __STAGE_JSON.followLerp;
					check_useCustomFollowLerp.checked = __STAGE_JSON.useCustomFollowLerp;

					stepper_cameraLerp.active = __STAGE_JSON.useCustomFollowLerp;
					stepper_cameraLerp.visible = __STAGE_JSON.useCustomFollowLerp;
					camLerp_label.visible = __STAGE_JSON.useCustomFollowLerp;
			}
			lastTab = uiBox.selected_tab_id;
		}

		/* i'll redo this later
			for (object in __objectButtons_array)
			{
				if (FlxG.mouse.overlaps(object))
				{
					trace("it overlpd");
					for (obj in members)
					{
						if (Std.isOfType(obj, SpriteStage))
						{
							var aa = cast(obj, SpriteStage);
							if (aa.objectName == getButtonName(object.label.text))
							{
								trace("tweenin'");
								tweenToObject(aa.getMidpoint());
								break;
							}
						}
					}
				}
		}*/

		if (show_uiBox)
		{
			_uiBox_Y = FlxG.height - 500 - 19;
		}
		else
		{
			_uiBox_Y = FlxG.height;
		}

		uiBox.y = FlxMath.lerp(_uiBox_Y, uiBox.y, CDevConfig.utils.bound(1 - (elapsed * 12), 0, 1));
	}

	function _update_mouseControls(elapsed:Float)
	{
		var mousePos = FlxG.mouse.getWorldPosition(camGame);

		if (_objectMoved != null)
		{
			camHUD.alpha = FlxMath.lerp(camHUD.alpha, 0.5, CDevConfig.utils.bound(1 - (elapsed * 12), 0, 1));
			if (FlxG.mouse.pressed)
			{
				_objectMoved.x = mousePos.x + mouseOffsetPos.x;
				_objectMoved.y = mousePos.y + mouseOffsetPos.y;

				if (_currentObject != null)
				{
					stepper_info_posX.value = _currentObject.x;
					stepper_info_posY.value = _currentObject.y;
					stepper_info_sf.value = _currentObject.scrollFactor.x;
					stepper_info_scale.value = _currentObject.scale.x;
				}
			}
			else
			{
				setEnableControls(true);
				_objectMoved = null;
				updateJson();
			}
		}
		else
		{
			camHUD.alpha = FlxMath.lerp(camHUD.alpha, 1, CDevConfig.utils.bound(1 - (elapsed * 12), 0, 1));

			if (!(FlxG.mouse.getScreenPosition(camHUD).x >= uiBox.x
				&& FlxG.mouse.getScreenPosition(camHUD).x < uiBox.x + uiBox.width
				&& FlxG.mouse.getScreenPosition(camHUD).y >= uiBox.y
				&& FlxG.mouse.getScreenPosition(camHUD).y < uiBox.y + uiBox.height))
			{
				var i = members.length - 1;
				if (_single_selectedObject != null)
				{
					if (FlxG.mouse.justPressed)
					{
						setEnableControls(false);
						selectSprite(_single_selectedObject, mousePos);
					}
				}
				else
				{
					while (i >= 0)
					{
						var s = members[i];
						if (Std.isOfType(s, SpriteStage))
						{
							s.cameras = [camGame];
							var sprite = cast(s, SpriteStage);
							if (checkOverlap(sprite, mousePos))
							{
								if (FlxG.mouse.justPressed)
								{
									setEnableControls(false);
									selectSprite(sprite, mousePos);
								}
								break;
							}
						}
						i--;
					}
				}
			}
		}

		__STAGE_JSON.stageZoom = stepper_cameraZoom.value;
		__STAGE_JSON.followLerp = stepper_cameraLerp.value;
		// camThingy.scale.x = camThingy.scale.y = camGame.zoom / stage.defaultCamZoom;

		camHUD.scroll.x = FlxMath.lerp(camHUD.scroll.x, show_uiBox ? -300 : 0, 0.30 * 30 * elapsed);
		// camThingy.x = (FlxG.width / 2) + camGame.x - (camThingy.width / 2);
		// dummyHUDCamera.scroll.x = camHUD.scroll.x;

		/*
		if (FlxG.mouse.justPressedRight)
		{
			mouseOffsetCam.x = _followCam.x - mousePos.x;
			mouseOffsetCam.y = _followCam.y - mousePos.y;
		}
		if (FlxG.mouse.pressedRight)
		{
			_followCam.x = mousePos.x + mouseOffsetCam.x;
			_followCam.y = mousePos.y + mouseOffsetCam.y;
		}*/
	}

	function selectSprite(sprite:SpriteStage, mousePos:FlxPoint):Void
	{
		mouseOffsetPos.x = sprite.x - mousePos.x;
		mouseOffsetPos.y = sprite.y - mousePos.y;
		_objectMoved = sprite;
		_currentObject = sprite;
	}

	function checkOverlap(sprite:SpriteStage, mousePos:FlxPoint):Bool
	{
		var pos = {
			x: sprite.x - sprite.offset.x,
			y: sprite.y - sprite.offset.y,
			x2: sprite.x - sprite.offset.x + sprite.width,
			y2: sprite.y - sprite.offset.y + sprite.height
		};
		return mousePos.x >= pos.x && mousePos.x < pos.x2 && mousePos.y >= pos.y && mousePos.y < pos.y2;
	}

	function _update_keyControls(elapsed:Float)
	{
		var camMove:Float = 500 * elapsed;
		var presses:Array<Bool> = [
			FlxG.keys.pressed.A,
			FlxG.keys.pressed.W,
			FlxG.keys.pressed.S,
			FlxG.keys.pressed.D
		];

		if (FlxG.keys.pressed.A)
			_followCam.x -= camMove;
		if (FlxG.keys.pressed.S)
			_followCam.y += camMove;
		if (FlxG.keys.pressed.D)
			_followCam.x += camMove;
		if (FlxG.keys.pressed.W)
			_followCam.y -= camMove;

		if (presses.contains(true))
		{
			if (tweenCam != null)
			{
				tweenCam.cancel();
				tweenCam = null;
			}
		}

		if (FlxG.keys.justPressed.R)
		{
			camGame.zoom = 1;
		}
		var sus:Bool = true;
		for (obj in members)
		{
			if (Std.isOfType(obj, UIDropDown))
			{
				var aa = cast(obj, UIDropDown);
				if (aa.dropPanel.visible)
				{
					sus = false;
					break;
				}
			}
		}
		if (sus)
			camGame.zoom += 0.1 * FlxG.mouse.wheel;
		if (camGame.zoom < 0.1)
			camGame.zoom = 0.1;

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.camera.bgColor = 0xFF000000;
			FlxG.switchState(new meta.modding.ModdingScreen());
		}
	}

	function _update_stageJSON_characters()
	{
		if (bf != null)
			__STAGE_JSON.boyfriendPosition = [bf.x, bf.y];
		if (dad != null)
			__STAGE_JSON.opponentPosition = [dad.x, dad.y];
		if (gf != null)
			__STAGE_JSON.girlfriendPosition = [gf.x, gf.y];
	}

	function updateJson()
	{
		__STAGE_JSON.sprites = [];
		for (e in members)
		{
			if (Std.isOfType(e, SpriteStage))
			{
				var sprite = cast(e, SpriteStage);
				__STAGE_JSON.sprites.push({
					animation: sprite.anim,
					animType: sprite.animType,
					position: [FlxMath.roundDecimal(sprite.x, 2), FlxMath.roundDecimal(sprite.y, 2)],
					imagePath: sprite.spritePath,
					imageScale: sprite.scale.x,
					imageSF: sprite.scrollFactor.x,
					imageAntialias: sprite.antialiasing,
					imageAlpha: sprite.alpha,
					imageFlipX: sprite.flipX,
					imageVar: sprite.objectName,
					spriteType: sprite.type
				});
			}
		}
		__STAGE_JSON.boyfriendPosition = [FlxMath.roundDecimal(bf.x, 2), FlxMath.roundDecimal(bf.y, 2)];
		__STAGE_JSON.girlfriendPosition = [FlxMath.roundDecimal(gf.x, 2), FlxMath.roundDecimal(gf.y, 2)];
		__STAGE_JSON.opponentPosition = [FlxMath.roundDecimal(dad.x, 2), FlxMath.roundDecimal(dad.y, 2)];
		unsaved = true;
	}

	public var controlsEnabled:Bool = true;

	function setEnableControls(enable:Bool)
	{
		if (enable == controlsEnabled)
			return;

		uiBox.active = enable;
		for (i in members)
		{
			if (i == null)
				continue;
			if (i.cameras.contains(camHUD))
			{
				i.active = enable;
			}
		}

		controlsEnabled = enable;
	}

	function tweenToObject(thisObjectPos:FlxPoint)
	{
		if (tweenCam != null)
			tweenCam.cancel();

		tweenCam = FlxTween.tween(_followCam, {x: thisObjectPos.x, y: thisObjectPos.y}, 1, {ease: FlxEase.sineInOut});
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

	override function beatHit()
	{
		gf.dance(false, curBeat);
		dad.dance(false, curBeat);
		bf.dance(false, curBeat);

		for (s in beatHit_sprites)
		{
			s.sprite.animation.play(s.anim);
		}
		for (s in beatHit_force_sprites)
		{
			s.sprite.animation.play(s.anim, true);
		}
	}

	function moveSpriteToLayer(sprite:SpriteStage, layer:Int)
	{
		for (i => s in __STAGE_JSON.sprites)
		{
			if (s.imageVar == sprite.objectName)
			{
				if (i + layer < 0 || i + layer > __STAGE_JSON.sprites.length)
					break;
				__STAGE_JSON.sprites.remove(s);
				__STAGE_JSON.sprites.insert(i + layer, s);
				updateStageElements();
				break;
			}
		}
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

		stageList.push('<NO STAGE>');
		#end
	}

	function save()
	{
		updateJson();
		var path = 'cdev-mods/${Paths.curModDir[0]}/data/stages/${stageToLoad}';

		if (FileSystem.exists(path + ".json"))
		{
			try
			{
				File.saveContent('$path.json', Json.stringify(__STAGE_JSON));
				var t = new CDevPopUp("Info", "File saved sucessfully on:\n" + path + ".json", [
					{
						text: "OK",
						callback: function()
						{
							closeSubState();
						}
					}
				], false, true);
				t.cameras = [camHUD];
				openSubState(t);
				FlxG.camera.zoom = 1;
			}
			catch (e)
			{
				trace(e);
				var t = new CDevPopUp("Error", "An error occured while saving stage file:\n" + path + ".json.\n\nError: " + e, [
					{
						text: "OK",
						callback: function()
						{
							closeSubState();
						}
					}
				], false, true);
				t.cameras = [camHUD];
				openSubState(t);
				FlxG.camera.zoom = 1;
			}
		}
		else
		{
			var t = new StageSaveDialog(__STAGE_JSON, this);
			t.cameras = [camHUD];
			openSubState(t);
			FlxG.camera.zoom = 1;
		}

		unsaved = false;
	}
}

class StageSaveDialog extends MusicBeatSubstate
{
	var box:FlxSprite;
	var exitButt:FlxSprite;
	var daData:StageJSONData;
	var sa:Better_StageEditor;
	public function new(stage:StageJSONData, state:Better_StageEditor)
	{
		super();
		sa = state;
		this.daData = stage;
		var bgBlack:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF909090);
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
		bgBlack.scrollFactor.set();
		box.scrollFactor.set();

		// cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		exitButt.scrollFactor.set();
	}

	var input_stageBName:FlxUIInputText;
	var butt_saveChar:FlxSprite;
	var txtBs:FlxText;
	var txtCn:FlxText;

	function createBoxUI()
	{
		var header:FlxText = new FlxText(box.x, box.y + 10, 800, "Save Dialog", 40);
		header.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header);

		input_stageBName = new FlxUIInputText(box.x + 50, box.y + 100, 500, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_stageBName.font = "VCR OSD Mono";
		add(input_stageBName);

		txtCn = new FlxText(input_stageBName.x, input_stageBName.y - 25, 500, "Stage File Name", 20);
		txtCn.font = "VCR OSD Mono";
		add(txtCn);

		butt_saveChar = new FlxSprite(865, 510).makeGraphic(150, 32, FlxColor.fromRGB(70, 70, 70));
		add(butt_saveChar);

		txtBs = new FlxText(865, 515, 150, "Save", 18);
		txtBs.font = "VCR OSD Mono";
		txtBs.alignment = CENTER;
		add(txtBs);

		input_stageBName.scrollFactor.set();
		txtCn.scrollFactor.set();
		txtBs.scrollFactor.set();
		butt_saveChar.scrollFactor.set();
		header.scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		if (input_stageBName.hasFocus)
		{
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && Clipboard.text != null)
			{
				input_stageBName.text = CDevConfig.utils.pasteFunction(input_stageBName.text);
				input_stageBName.caretIndex = input_stageBName.text.length;
			}

			if (FlxG.keys.justPressed.ENTER)
			{
				saveChar();
				close();
				kill();
			}
		}

		if (input_stageBName.hasFocus)
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
				if (input_stageBName.text != '')
				{
					saveChar();
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
		var containsForbiddenCharacters:Bool = false;
		var forbiddenASCIICharacters:Array<String> = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"];
		var theThing:String = "";
		var susp:Array<String> = input_stageBName.text.split("");

		for (w in susp)
		{
			for (c in forbiddenASCIICharacters)
			{
				if (w == c)
				{
					containsForbiddenCharacters = true;
					theThing = c;
				}
			}
		}
		if (containsForbiddenCharacters)
		{
			var t = new CDevPopUp("Error", "The file name contains forbidden character: \n" + theThing + "\"", [
				{
					text: "OK",
					callback: function()
					{
						closeSubState();
					}
				}
			], false, true);
			t.cameras = [sa.camHUD];
			openSubState(t);
			FlxG.camera.zoom = 1;
		}
		else
		{
			if (data.length > 0)
			{
				File.saveContent('cdev-mods/' + Paths.curModDir[0] + '/data/stages/' + input_stageBName.text + '.json', data);
				FlxG.sound.play(game.Paths.sound('confirmMenu'));
				close();
				sa.stageDropDown.selectedLabel = input_stageBName.text;
				Better_StageEditor.stageToLoad = input_stageBName.text;
			}
		}
	}
}
