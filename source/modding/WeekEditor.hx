package modding;

import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import lime.ui.FileDialog;
import flixel.FlxObject;
import game.Character;
import substates.MusicBeatSubstate;
import openfl.desktop.Clipboard;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import modding.WeekData.WeekFile;
import flixel.tweens.FlxEase;
#if desktop
import engineutils.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import game.Paths;
import game.Conductor;
import game.MenuItem;
import states.PlayState;

using StringTools;

class WeekEditor extends states.MusicBeatState
{
	var uiBox:FlxUITabMenu;
	var weekJSON:WeekFile;

	var txtWeekTitle:FlxText;

	var txtTracklist:FlxText;
	var charInfo:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<Character>;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var weekToLoad:String = '';
	var spriteBoxPos:FlxSprite;

	public static var weekFilename:String = 'week0';

	public function new(weekFileToLoad:String)
	{
		super();
		this.weekToLoad = weekFileToLoad;
	}

	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.2);
		loadWeekFile();
		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = 32;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFF000000);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<Character>();

		trace("Line 70");

		#if desktop
		// Updating Discord Rich Presence
		if (Main.discordRPC)
			DiscordClient.changePresence("Creating a new week", null);
		#end

		var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, 0, weekJSON.weekTxtImgPath);
		weekThing.moddedWeek = true;
		weekThing.y += ((weekThing.height + 20) * 0);
		weekThing.targetY = 0;
		grpWeekText.add(weekThing);

		weekThing.screenCenter(X);
		weekThing.antialiasing = FlxG.save.data.antialiasing;

		trace("Line 96");

		add(yellowBG);
		add(grpWeekCharacters);

		changeCharacters();

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(txtWeekTitle);

		charInfo = new FlxText(0, 0, FlxG.width, "", 20);
		charInfo.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(charInfo);
		charInfo.alpha = 0.8;

		createUIBOX();
		createSpriteUI();
		createOptionsUI();
		updateText();
		updateChar();
		updateInformations();

		trace("Line 165");

		super.create();
	}

	function changeCharacters()
	{
		for (a in grpWeekCharacters.members)
		{
			a.kill();
			grpWeekCharacters.remove(a);
			remove(a);
		}
		for (b in 0...3)
		{
			var no:Bool = (b == 2);
			grpWeekCharacters.add(new Character(weekJSON.charSetting[b].position[0], weekJSON.charSetting[b].position[1], weekJSON.weekCharacters[b], no, true));
			var char:Character = grpWeekCharacters.members[b];
			char.scale.set(weekJSON.charSetting[b].scale, weekJSON.charSetting[b].scale);
			char.flipX = weekJSON.charSetting[b].flipX;

			if (weekJSON.weekCharacters[b] == '')
			{
				char.visible = false;
			}
			else
			{
				char.visible = true;
			}
		}
	}

	function createUIBOX()
	{
		var tabs = [
			{
				name: "Week",
				label: 'Week'
			},
			{
				name: "Options",
				label: "Options"
			}
		];
		uiBox = new FlxUITabMenu(null, tabs, true);
		uiBox.resize(400, 200);
		uiBox.x = FlxG.width - uiBox.width - 20;
		uiBox.y = FlxG.height - uiBox.height - 20;
		uiBox.scrollFactor.set();
		add(uiBox);

		spriteBoxPos = new FlxSprite(uiBox.x, uiBox.y).makeGraphic(400, 20, FlxColor.WHITE);
		spriteBoxPos.alpha = 0;
		add(spriteBoxPos);
	}

	var jsonWasNull:Bool = false;

	function loadWeekFile()
	{
		if (weekToLoad != '')
		{
			var crapJSON = null;

			#if ALLOW_MODS
			var charFile:String = Paths.modWeek(weekToLoad);
			if (FileSystem.exists(charFile))
				crapJSON = File.getContent(charFile);
			#end
			var isItNull:Bool = false;
			if (crapJSON == null)
			{
				isItNull = true;
			}
			var json:WeekFile = null;
			if (!isItNull)
				json = cast Json.parse(crapJSON);

			if (!isItNull)
			{
				jsonWasNull = false;
				weekJSON = json;
			}
			else
			{
				jsonWasNull = true;
			}
		}
		else
		{
			weekJSON = {
				weekTxtImgPath: 'week0',
				weekName: 'Your week name here.',
				weekCharacters: ['dad', 'bf', 'gf'],
				tracks: ['tutorial'],
				charSetting: [
					{
						position: [0, 100],
						scale: 0.5,
						flipX: false
					},
					{
						position: [450, 25],
						scale: 0.9,
						flipX: false
					},
					{
						position: [850, 100],
						scale: 0.5,
						flipX: false
					}
				]
			}
		}
	}

	var flxuitexts:Array<Bool> = [];
	var inputThingy:Array<FlxUIInputText> = [];
	var input_spritePath:FlxUIInputText;
	var input_weekName:FlxUIInputText;
	var input_weekCharacters:FlxUIInputText;
	var input_weekTracks:FlxUIInputText;

	function createSpriteUI()
	{
		var tab_group_week = new FlxUI(null, uiBox);
		tab_group_week.name = "Week";

		input_spritePath = new FlxUIInputText(10, 20, 200, '', 8);
		input_spritePath.name = 'i_sp';
		tab_group_week.add(input_spritePath);
		var opText:FlxText = new FlxText(input_spritePath.x, input_spritePath.y - 15, FlxG.width, "Week sprite path", 8);
		tab_group_week.add(opText);

		input_weekName = new FlxUIInputText(10, 50, 200, '', 8);
		input_weekName.name = 'i_wn';
		tab_group_week.add(input_weekName);

		var opText:FlxText = new FlxText(input_weekName.x, input_weekName.y - 15, FlxG.width, "Week Name", 8);
		tab_group_week.add(opText);

		input_weekCharacters = new FlxUIInputText(10, 80, 200, '', 8);
		input_weekCharacters.name = 'i_wc';
		tab_group_week.add(input_weekCharacters);
		var opText:FlxText = new FlxText(input_weekCharacters.x, input_weekCharacters.y - 15, FlxG.width,
			"Week Characters (Separate each character with the \",\" symbol)", 8);
		tab_group_week.add(opText);

		input_weekTracks = new FlxUIInputText(10, 110, 200, '', 8);
		input_weekTracks.name = 'i_wt';
		tab_group_week.add(input_weekTracks);
		var opText:FlxText = new FlxText(input_weekTracks.x, input_weekTracks.y - 15, FlxG.width, "Week Tracks (Separate each tracks with the \",\" symbol)",
			8);
		tab_group_week.add(opText);

		uiBox.addGroup(tab_group_week);
		uiBox.scrollFactor.set();
	}

	var currentCharacter:Int = 0;
	var dialog:FileDialog;

	function createOptionsUI()
	{
		var tab_group_options = new FlxUI(null, uiBox);
		tab_group_options.name = "Options";
		//var buttt:FlxButton = new FlxButton(10, 40, 'Freeplay', function()
		//{
		//	trace('aaaaaa');
		//});
		//tab_group_options.add(buttt);
		var butt2:FlxButton = new FlxButton(10, 50, 'Load Week', function()
		{
			loadWeek();
		});
		tab_group_options.add(butt2);
		var butt:FlxButton = new FlxButton(10, butt2.y + butt2.height + 10, 'Save Week', function()
		{
			var jsonShit:WeekFile = weekJSON;
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new WeekEditorSaveDialogue(jsonShit));
		});
		tab_group_options.add(butt);

		uiBox.addGroup(tab_group_options);
		uiBox.scrollFactor.set();
	}

	var dontCheck:Bool = false;
	var mXPos:Float = 0;
	var mYPos:Float = 0;

	function check_BoxPressed()
	{
		if (FlxG.mouse.overlaps(spriteBoxPos) && FlxG.mouse.justPressed)
		{
			if (!dontCheck)
			{
				mXPos = FlxG.mouse.x;
				mYPos = FlxG.mouse.y;
				dontCheck = true;
			}
		}
		if (FlxG.mouse.overlaps(spriteBoxPos) && FlxG.mouse.pressed && !selectedThing)
		{
			if (FlxG.mouse.x != mXPos && FlxG.mouse.y != mYPos)
			{
				spriteBoxPos.x = (FlxG.mouse.x - (spriteBoxPos.frameWidth / 2));
				spriteBoxPos.y = (FlxG.mouse.y - (spriteBoxPos.frameHeight / 2));

				uiBox.setPosition(spriteBoxPos.x, spriteBoxPos.y);
			}
			selectedThing = true;
			curSelectedObj = null;
		}
		else
		{
			dontCheck = false;
		}
	}

	function updateInfoText()
	{
		var obj:Character = grpWeekCharacters.members[currentCharacter];
		var aaaaaaaa:String = '';
		switch (currentCharacter)
		{
			case 0:
				aaaaaaaa = '[LEFT CHARACTER]';
			case 1:
				aaaaaaaa = '[MIDDLE CHARACTER]';
			case 2:
				aaaaaaaa = '[RIGHT CHARACTER]';
		}
		charInfo.text = '$aaaaaaaa\n[LMB] - Position: ${weekJSON.charSetting[currentCharacter].position}\n[Q / E] - Scale: ${weekJSON.charSetting[currentCharacter].scale}\n[F] - Flip X: ${weekJSON.charSetting[currentCharacter].flipX}\n[Z] - Lock Character: ${obj.lockedChar}\n\n[A / D] Change Current Character';
		charInfo.setPosition(10, FlxG.height - charInfo.height - 10);
	}

	var msize:Float = 0;
	function checkThing()
	{
		if (!flxuitexts.contains(true))
			{
				if (FlxG.keys.justPressed.A){
					currentCharacter -= 1;
					FlxG.sound.play(Paths.sound('scrollMenu'),0.6);
				} else if (FlxG.keys.justPressed.D){
					currentCharacter += 1;
					FlxG.sound.play(Paths.sound('scrollMenu'),0.6);
				}

				if (currentCharacter >= grpWeekCharacters.members.length)
					currentCharacter = 0;
				if (currentCharacter < 0)
					currentCharacter = grpWeekCharacters.members.length - 1;
			}
		var obj:Character = grpWeekCharacters.members[currentCharacter];
		var set = weekJSON.charSetting[currentCharacter];

		if (!flxuitexts.contains(true))
		{
			msize = (FlxG.keys.pressed.SHIFT?0.1:0.05);
			if (!obj.lockedChar){
				if (FlxG.keys.justPressed.Q)
					{
						if (set.scale >= 0.1)
						{
							set.scale -= msize;
						}
						else
						{
							set.scale = 0.1;
						}
					}
					else if (FlxG.keys.justPressed.E)
					{
						if (set.scale < 10)
						{
							set.scale += msize;
						}
						else
						{
							set.scale = 10;
						}
					}
					if (FlxG.keys.justPressed.F)
					{
						set.flipX = !set.flipX;
						obj.flipX = set.flipX;
					}
			}

			if (FlxG.keys.justPressed.Z){
				obj.lockedChar = !obj.lockedChar;
				FlxG.sound.play(Paths.sound('confirmMenu'),0.6);
			}
		}
		set.scale = FlxMath.roundDecimal(set.scale, 2);
		obj.scale.set(set.scale, set.scale);

		set.position = [obj.x, obj.y];

		weekJSON.charSetting[currentCharacter] = set;
	}

	var curSelectedObj:Dynamic;
	var selectedThing:Bool = false;
	var hmm:Bool = false;
	function charUpdate()
	{
		hmm = FlxG.mouse.overlaps(uiBox);
		if (FlxG.mouse.overlaps(grpWeekCharacters.members[0]) && grpWeekCharacters.members[0] != null)
		{
			if (!hmm && FlxG.mouse.pressed && !grpWeekCharacters.members[0].lockedChar && selectedThing != true)
			{
				selectedThing = true;
				curSelectedObj = grpWeekCharacters.members[0];
				currentCharacter = 0;
			}
		}

		if (FlxG.mouse.overlaps(grpWeekCharacters.members[1]) && !hmm && grpWeekCharacters.members[1] != null)
		{
			if (!hmm && FlxG.mouse.pressed && !grpWeekCharacters.members[1].lockedChar && selectedThing != true)
			{
				selectedThing = true;
				curSelectedObj = grpWeekCharacters.members[1];
				currentCharacter = 1;
			}
		}

		if (FlxG.mouse.overlaps(grpWeekCharacters.members[2]) && !hmm && grpWeekCharacters.members[2] != null)
		{
			if (!hmm && FlxG.mouse.pressed && !grpWeekCharacters.members[2].lockedChar && selectedThing != true)
			{
				selectedThing = true;
				curSelectedObj = grpWeekCharacters.members[2];
				currentCharacter = 2;
			}
		}
		if (!FlxG.mouse.pressed)
		{
			selectedThing = false;
			//curSelectedObj = null;
		}

		if (FlxG.mouse.pressed && selectedThing && curSelectedObj != null)
		{
			if (!grpWeekCharacters.members[currentCharacter].lockedChar){
				curSelectedObj.x = FlxG.mouse.x - curSelectedObj.frameWidth / 2;
				curSelectedObj.y = FlxG.mouse.y - curSelectedObj.frameHeight / 2;
			}

		}
	}

	override function update(elapsed:Float)
	{
		check_BoxPressed();
		charUpdate();
		updateInfoText();
		checkThing();
		updateCharAlpha();
		txtWeekTitle.text = weekJSON.weekName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.ESCAPE && !movedBack)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new ModdingScreen());
		}

		flxuitexts = [
			input_spritePath.hasFocus,
			input_weekName.hasFocus,
			input_weekCharacters.hasFocus,
			input_weekTracks.hasFocus
		];
		inputThingy = [input_spritePath, input_weekName, input_weekCharacters, input_weekTracks];

		for (i in 0...inputThingy.length)
		{
			if (inputThingy[i].hasFocus)
			{
				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && lime.system.Clipboard.text != null)
				{
					inputThingy[i].text = cdev.CDevConfig.utils.pasteFunction(inputThingy[i].text);
					inputThingy[i].caretIndex = inputThingy[i].text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, inputThingy[i], null, []);
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				if (FlxG.keys.justPressed.ENTER)
					inputThingy[i].hasFocus = false;
			}
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
		}
		else if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			if (sender == input_spritePath)
			{
				grpWeekText.members[0].changeGraphic(input_spritePath.text);
				weekJSON.weekTxtImgPath = input_spritePath.text;
			}
			else if (sender == input_weekName)
			{
				weekJSON.weekName = input_weekName.text;
			}
			else if (sender == input_weekCharacters)
			{
				updateChar();
				var sex:Array<String> = input_weekCharacters.text.trim().split(',');
				weekJSON.weekCharacters = [sex[0],sex[1],sex[2]];
			}
			else if (sender == input_weekTracks)
			{
				updateText();
				weekJSON.tracks = input_weekTracks.text.trim().split(',');
			}
		}
	}
	function updateCharAlpha(){
		for (i in 0...grpWeekCharacters.members.length){
			if (i != currentCharacter){
				grpWeekCharacters.members[i].alpha = 0.5;
			}else{
				grpWeekCharacters.members[i].alpha = 1;
			}
		}
	}

	function updateChar()
	{
		changeCharacters();
	}

	function updateText()
	{
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = input_weekTracks.text.trim().split(',');

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";
	}

	override function beatHit()
	{
		super.beatHit();

		grpWeekCharacters.members[0].dance();
		grpWeekCharacters.members[1].dance();
		grpWeekCharacters.members[2].dance();
	}

	function updateInformations(){
		input_spritePath.text = weekJSON.weekTxtImgPath;
		var str:String = weekJSON.weekCharacters.toString();
		input_weekCharacters.text = str.substr(1, str.length - 2);
		input_weekName.text = weekJSON.weekName;
		var strr:String = weekJSON.tracks.toString();
		input_weekTracks.text = strr.substr(1, strr.length - 2);
	}

	private static var _file:FileReference;

	function loadWeek()
	{
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	public static var loadedWeek:WeekFile = null;
	public static var loadError:Bool = false;

	function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		var fullPath:String = null;
		var jsonLoaded = cast Json.parse(Json.stringify(_file));
		if (jsonLoaded.__path != null)
			fullPath = jsonLoaded.__path;

		if (fullPath != null)
		{
			var rawJson:String = File.getContent(fullPath);
			if (rawJson != null)
			{
				loadedWeek = cast Json.parse(rawJson);
				if (loadedWeek.weekCharacters != null && loadedWeek.weekName != null)
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					loadError = false;

					weekFilename = cutName;
					_file = null;
					weekJSON = loadedWeek;
					updateInformations();
					changeCharacters();
					updateText();
					grpWeekText.members[0].changeGraphic(input_spritePath.text);
					
					return;
				}
			}
		}
		loadError = true;
		loadedWeek = null;
		_file = null;
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}
 function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
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
		FlxG.log.error("Problem saving file");
	}
}

// originally from character editor.

class WeekEditorSaveDialogue extends MusicBeatSubstate
{
	var box:FlxSprite;
	var exitButt:FlxSprite;
	var daData:WeekFile;
	public function new(characterData:WeekFile)
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
		FlxTween.tween(bgBlack, {alpha: 0.5},0.3,{ease: FlxEase.linear});
		box.alpha = 0;
		FlxTween.tween(box, {alpha: 0.7},0.3,{ease: FlxEase.linear});
		exitButt.alpha = 0;
		FlxTween.tween(exitButt, {alpha: 0.7},0.3,{ease: FlxEase.linear});
		
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	var input_charName:FlxUIInputText;
	var butt_saveChar:FlxSprite;
	var txtBs:FlxText;
	var txtCn:FlxText;
	function createBoxUI()
	{
		var header:FlxText = new FlxText(box.x, box.y + 10, 800, "Save Week File", 40);
		header.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header);

		input_charName = new FlxUIInputText(box.x + 50, box.y + 100, 500, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
		input_charName.font = "VCR OSD Mono";
		add(input_charName);
		txtCn = new FlxText(input_charName.x, input_charName.y - 25, 500, "Week File Name", 20);
		txtCn.font = "VCR OSD Mono";
		add(txtCn);

		butt_saveChar = new FlxSprite(865, 510).makeGraphic(150, 32, FlxColor.fromRGB(70, 70, 70));
		add(butt_saveChar);

		txtBs = new FlxText(865, 515, 150, "Save", 18);
		txtBs.font = "VCR OSD Mono";
		txtBs.alignment = CENTER;
		add(txtBs);
	}

	override function update(elapsed:Float) {
		if (input_charName.hasFocus)
		{
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && lime.system.Clipboard.text != null)
			{
				input_charName.text = cdev.CDevConfig.utils.pasteFunction(input_charName.text);
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

	function saveChar(){
		var data:String = Json.stringify(daData, "\t");
    
		if (data.length > 0)
			File.saveContent('cdev-mods/' + Paths.curModDir[0] + '/data/weeks/'+ input_charName.text +'.json' ,data);
	}
}
