package modding;

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

// still an w.i.p.
// will be finished soon.
class StageEditor extends states.MusicBeatState
{
	var uiBox:FlxUITabMenu;
	var _file:FileReference;
	var stageJSON:StageJSONData;

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
	var stageObjects:FlxTypedGroup<FlxSprite>;

	var curObject:Dynamic;
	var selectedThing:Bool = false;
	var selectedObj:Int = 0;

	var infos:Array<String> = ['Current Sprite: ', 'Position: '];
	var stageObjID:Array<Dynamic> = [];
	var stageDropDown:UIDropDown;
	var stageList:Array<String> = [];

	override function create()
	{
		FlxG.sound.music.stop();
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

		FlxG.mouse.visible = true;

		stageObjects = new FlxTypedGroup<FlxSprite>();
		add(stageObjects);

		gfGroup = new FlxTypedGroup<FlxSprite>();
		add(gfGroup);

		dadGroup = new FlxTypedGroup<FlxSprite>();
		add(dadGroup);

		bfGroup = new FlxTypedGroup<FlxSprite>();
		add(bfGroup);
		//loadStage();
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

		check_pixelStage = new FlxUICheckBox(120, 20, null, null, "Pixel Stage", 70);
		check_pixelStage.name = 'check_pixelStage';
		tab_group_stgdt.add(check_pixelStage);

		var saveStageButton:FlxButton = new FlxButton(150, stepper_imageScale.y, 'Save Stage', function()
		{
			saveStageShit();
		});
		tab_group_stgdt.add(saveStageButton);

		uiBox.addGroup(tab_group_stgdt);
		uiBox.scrollFactor.set();
	}

	var charList:Array<String> = [];
	var bfDropDown:UIDropDown;
	var gfDropDown:UIDropDown;
	var opDropDown:UIDropDown;

	function addCharUI():Void
	{
		var tab_group_selchar = new FlxUI(null, uiBox);
		tab_group_selchar.name = "Characters";

		bfDropDown = new UIDropDown(10, 30, UIDropDown.makeStrIdLabelArray(charList, true), function(character:String)
		{
			characters[0] = charList[Std.parseInt(character)];
			createChar('bf');
			loadCharDropDown();
		});
		bfDropDown.selectedLabel = characters[0];
		var bfddText:FlxText = new FlxText(bfDropDown.x, bfDropDown.y - 15, FlxG.width, "Boyfriend", 8);

		gfDropDown = new UIDropDown(10, 30, UIDropDown.makeStrIdLabelArray(charList, true), function(character:String)
		{
			characters[1] = charList[Std.parseInt(character)];
			createChar('gf');
			loadCharDropDown();
		});
		gfDropDown.selectedLabel = characters[1];
		gfDropDown.x = 400 - gfDropDown.width - 10;
		var gfddText:FlxText = new FlxText(gfDropDown.x, gfDropDown.y - 15, FlxG.width, "Girlfriend", 8);

		opDropDown = new UIDropDown(10, 70, UIDropDown.makeStrIdLabelArray(charList, true), function(character:String)
		{
			characters[2] = charList[Std.parseInt(character)];
			createChar('dad');
			loadCharDropDown();
		});

		opDropDown.x = 400 - opDropDown.width - 10;
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

		uiBox.addGroup(tab_group_sprite);
		uiBox.scrollFactor.set();
	}

	function addSpriteShit()
	{
		var loopshit:Int = 0;
		for (i in 0...stageObjects.length){
			loopshit++;
		}
		var daSprite:FlxSprite = new FlxSprite();
		daSprite.loadGraphic(Paths.image(input_spritePath.text), 'shared');

		daSprite.scale.set(stepper_imageScale.value, stepper_imageScale.value);
		daSprite.antialiasing = check_imgAntialias.checked;
		daSprite.setPosition(0, 0);
		daSprite.scrollFactor.set(stepper_imageSf.value, stepper_imageSf.value);
		daSprite.alpha = stepper_imageAlpha.value;
		daSprite.ID = loopshit;
		stageObjects.add(daSprite);

		var shit:StageSprite = {
			imagePath: input_spritePath.text,
			imageAlpha: stepper_imageAlpha.value,
			imageScale: stepper_imageScale.value,
			imageSF: stepper_imageSf.value,
			imageAntialias: check_imgAntialias.checked,
			position: [0, 0]
		}
		stageJSON.sprites.push(shit);

		stageObjID.push([daSprite, daSprite.ID]);
	}

	var jsonWasNull:Bool = false;

	function loadStageJSON(stage:String = "")
	{
		if (stageToLoad != '<NO STAGES>'){
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
		} else{
			stageJSON = {
				sprites: [],
				boyfriendPosition: [770, 100],
				girlfriendPosition: [400,130],
				opponentPosition: [100, 100],
				stageZoom: 1,
				pixelStage: false
			}
		}

	}

	function loadStage()
	{
		stageJSON = null;
		for (i in 0...stageObjects.length){
			if (stageObjects.members[i] != null){
				stageObjects.members[i].kill();
				stageObjects.remove(stageObjects.members[i]);
				stageObjects.members[i].destroy();
			}
		}

		for (i in 0...stageObjID.length){
			stageObjID.remove(stageObjID[i]);
		}
		
		loadStageJSON(stageToLoad);
		createChar('bf');
		createChar('gf');
		createChar('dad');
		if (!jsonWasNull)
		{
			check_pixelStage.checked = stageJSON.pixelStage;
			stepper_stageZoom.value = stageJSON.stageZoom;
			for (i in 0...stageJSON.sprites.length)
			{
				var daSprite:FlxSprite = new FlxSprite();
				daSprite.loadGraphic(Paths.image(stageJSON.sprites[i].imagePath), 'shared');

				daSprite.scale.set(stageJSON.sprites[i].imageScale, stageJSON.sprites[i].imageScale);
				daSprite.antialiasing = stageJSON.sprites[i].imageAntialias;
				daSprite.setPosition(stageJSON.sprites[i].position[0], stageJSON.sprites[i].position[1]);
				daSprite.scrollFactor.set(stageJSON.sprites[i].imageSF, stageJSON.sprites[i].imageSF);
				daSprite.alpha = stageJSON.sprites[i].imageAlpha;
				daSprite.ID = i;
				stageObjects.add(daSprite);

				stageObjID.push([daSprite, daSprite.ID]);
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

				bf = new Character(BFXPOS, BFYPOS, characters[0], true);
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

				gf = new Character(GFXPOS, GFYPOS, characters[1], false);
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

				dad = new Character(DADXPOS, DADYPOS, characters[2], false);
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
			curObject.x = FlxG.mouse.x - curObject.frameWidth / 2;
			curObject.y = FlxG.mouse.y - curObject.frameHeight / 2;

			if (curObject != bf && curObject != gf && curObject != dad)
			{
				var idShit:Int = 0;
				var e:Dynamic = [];
				for (i in 0...stageObjID.length)
				{
					if (stageObjID[i][0] == curObject)
					{
						idShit = stageObjID[i][1];
						e = stageObjID[i];
					}
				}
				stageJSON.sprites[idShit].position = [curObject.x, curObject.y];			
			}
		}

		if (curObject != bf && curObject != gf && curObject != dad)
		{
			if (FlxG.keys.justPressed.DELETE && curObject != null)
			{
				trace('\n\nON JSON: ' + stageJSON.sprites.length + '\nON ARRAY: ' + stageObjects.length);
				var idShit:Int = 0;
				var e:Dynamic = [];
				for (i in 0...stageObjID.length)
				{
					if (stageObjID[i][0] == curObject)
					{
						idShit = stageObjID[i][1];
						e = stageObjID[i];
					}
				}
				stageJSON.sprites.remove(stageJSON.sprites[idShit - 1]);
				stageObjects.members[idShit - 1].kill();
				stageObjects.remove(curObject, true);
				stageObjID.remove(e);

				curObject = null;
			}
		}

		var ugh:Bool = (bf == null && gf == null && dad == null);

		if (!jsonWasNull && !ugh) {
			stageJSON.girlfriendPosition = [gf.x, gf.y];
			stageJSON.boyfriendPosition = [bf.x, bf.y];
			stageJSON.opponentPosition = [dad.x, dad.y];
		}

		//for (obj in 0...stageObjects.length){
		//	if (!jsonWasNull && stageObjects.members[obj - 1] != null)
		//		stageJSON.sprites[obj - 1].position = [stageObjects.members[obj].x, stageObjects.members[obj].y];
		//}
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
				case 'Pixel Stage':
					stageJSON.pixelStage = check.checked;
			}
		} else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)){
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			switch (wname)
			{
				case 'step_stgZm':
					stageJSON.stageZoom = nums.value;
			}
		}
	}

	override function update(elapsed:Float)
	{
		checkChars();

		if (bf != null)
			bf.dance();
		if (gf != null)
			gf.dance();
		if (dad != null)
			dad.dance();

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
			"pixelStage": stageJSON.pixelStage,
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
