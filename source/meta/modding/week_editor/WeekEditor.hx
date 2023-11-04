package meta.modding.week_editor;

import game.objects.HealthIcon;
import game.objects.Alphabet;
import meta.states.FreeplayState.SongMetadata;
import meta.states.MusicBeatState;
import meta.modding.week_editor.WeekData.FreeplaySong;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import lime.ui.FileDialog;
import flixel.FlxObject;
import game.objects.Character;
import meta.substates.MusicBeatSubstate;
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
import meta.modding.week_editor.WeekData.WeekFile;
import flixel.tweens.FlxEase;
#if desktop
import game.cdev.engineutils.Discord.DiscordClient;
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
import game.objects.MenuItem;
import meta.states.PlayState;

using StringTools;

class WeekEditor extends meta.states.MusicBeatState
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

	var privJson:WeekFile = null;

	public function new(weekFileToLoad:String, ?json:WeekFile)
	{
		super();
		this.weekToLoad = weekFileToLoad;
		privJson = json;
	}

	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.2);
		loadWeekFile((privJson == null ? null : privJson));
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
		weekThing.antialiasing = CDevConfig.saveData.antialiasing;

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
		updateInformations();
		updateText();
		updateChar(); 
		updateFreeplaySongs();

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
			grpWeekCharacters.add(new Character(weekJSON.charSetting[b].position[0], weekJSON.charSetting[b].position[1], weekJSON.weekCharacters[b], no,
				true));
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

	function loadWeekFile(?data:WeekFile = null)
	{
		if (data == null)
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
					weekDifficulties: ["easy", "normal", "hard"],
					tracks: ['tutorial'],
					freeplaySongs: [],
					disableFreeplay: false,
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
		else
		{
			weekJSON = data;
		}
	}

	var flxuitexts:Array<Bool> = [];
	var inputThingy:Array<FlxUIInputText> = [];
	var input_spritePath:FlxUIInputText;
	var input_weekName:FlxUIInputText;
	var input_weekCharacters:FlxUIInputText;
	var input_weekTracks:FlxUIInputText;
	var input_weekDifficulties:FlxUIInputText;

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
		var opText:FlxText = new FlxText(input_weekTracks.x, input_weekTracks.y - 15, FlxG.width, "Week Tracks (Separate each track with the \",\" symbol)",
			8);
		tab_group_week.add(opText);

		input_weekDifficulties = new FlxUIInputText(10, 140, 200, '', 8);
		input_weekDifficulties.name = 'i_wd';
		tab_group_week.add(input_weekDifficulties);
		var opText:FlxText = new FlxText(input_weekDifficulties.x, input_weekDifficulties.y - 15, FlxG.width,
			"Week Difficulties (Separate each difficulty with the \",\" symbol)", 8);
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
		// var buttt:FlxButton = new FlxButton(10, 40, 'Freeplay', function()
		// {
		//	trace('aaaaaa');
		// });
		// tab_group_options.add(buttt);
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

		var butt0:FlxButton = new FlxButton(10, butt.y + butt.height + 10, 'Open Freeplay', function()
		{
			var jsonShit:WeekFile = weekJSON;
			if (CDevConfig.saveData.smoothAF)
			{
				FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.quadOut});
			}
			FlxG.switchState(new FreeplayEditor(jsonShit));
		});
		tab_group_options.add(butt0);

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
			if (FlxG.keys.justPressed.A)
			{
				currentCharacter -= 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
			else if (FlxG.keys.justPressed.D)
			{
				currentCharacter += 1;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
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
			msize = (FlxG.keys.pressed.SHIFT ? 0.1 : 0.05);
			if (!obj.lockedChar)
			{
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

			if (FlxG.keys.justPressed.Z)
			{
				obj.lockedChar = !obj.lockedChar;
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
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
			// curSelectedObj = null;
		}

		if (FlxG.mouse.pressed && selectedThing && curSelectedObj != null)
		{
			if (!grpWeekCharacters.members[currentCharacter].lockedChar)
			{
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
			input_weekTracks.hasFocus,
			input_weekDifficulties.hasFocus
		];
		inputThingy = [
			input_spritePath,
			input_weekName,
			input_weekCharacters,
			input_weekTracks,
			input_weekDifficulties
		];

		for (i in 0...inputThingy.length)
		{
			if (inputThingy[i].hasFocus)
			{
				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && lime.system.Clipboard.text != null)
				{
					inputThingy[i].text = game.cdev.CDevConfig.utils.pasteFunction(inputThingy[i].text);
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
				weekJSON.weekCharacters = [sex[0], sex[1], sex[2]];
			}
			else if (sender == input_weekTracks)
			{
				updateText();
				weekJSON.tracks = input_weekTracks.text.trim().split(',');
				updateFreeplaySongs();
			}
			else if (sender == input_weekDifficulties)
			{
				weekJSON.weekDifficulties = input_weekDifficulties.text.trim().split(',');
			}
		}
	}

	function updateCharAlpha()
	{
		for (i in 0...grpWeekCharacters.members.length)
		{
			if (i != currentCharacter)
			{
				grpWeekCharacters.members[i].alpha = 0.5;
			}
			else
			{
				grpWeekCharacters.members[i].alpha = 1;
			}
		}
	}

	function updateFreeplaySongs()
	{
		var text:Array<String> = input_weekTracks.text.trim().split(',');
		for (i in 0...text.length)
			text[i] = text[i].trim();

		while (text.length < weekJSON.freeplaySongs.length)
			weekJSON.freeplaySongs.pop();

		for (i in 0...text.length)
		{
			if (i >= weekJSON.freeplaySongs.length)
			{
				var free:FreeplaySong = {
					song: text[i],
					character: "dad",
					bpm: 120,
					colors: [150, 120, 255]
				}
				weekJSON.freeplaySongs.push(free);
				trace("can't find one, creating new one");
			}
			else
			{
				weekJSON.freeplaySongs[i].song = text[i];
				// (weekFile.songs[i][1] == null || weekFile.songs[i][1])
				if (weekJSON.freeplaySongs[i].character == null)
				{
					weekJSON.freeplaySongs[i].character = 'dad';
					weekJSON.freeplaySongs[i].colors = [150, 120, 255];
					weekJSON.freeplaySongs[i].bpm = 120;
				}
				trace("find one, editing the existing one");
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

	function updateInformations()
	{
		input_spritePath.text = weekJSON.weekTxtImgPath;
		var str:String = weekJSON.weekCharacters.toString();
		input_weekCharacters.text = str.substr(1, str.length - 2);
		input_weekName.text = weekJSON.weekName;
		var strr:String = weekJSON.tracks.toString();
		input_weekTracks.text = strr.substr(1, strr.length - 2);
		var strrr:String = weekJSON.weekDifficulties.toString();
		input_weekDifficulties.text = strrr.substr(1, strrr.length - 2);
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
					// support for older week json version of cdev engine.
					// also to prevent crash while loading the json.
					checkJSON();

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

	function checkJSON()
	{
		var incompatibleShits:Array<Bool> = [(loadedWeek.weekDifficulties == null), (loadedWeek.freeplaySongs == null)];

		for (i in 0...incompatibleShits.length)
		{
			if (incompatibleShits[i] == true)
			{
				switch (i)
				{
					case 0:
						weekJSON = {
							weekTxtImgPath: loadedWeek.weekTxtImgPath,
							weekName: loadedWeek.weekName,
							weekCharacters: loadedWeek.weekCharacters,
							weekDifficulties: [],
							tracks: loadedWeek.tracks,
							freeplaySongs: loadedWeek.freeplaySongs,
							disableFreeplay: loadedWeek.disableFreeplay,
							charSetting: loadedWeek.charSetting
						}
					case 1:
						weekJSON = {
							weekTxtImgPath: loadedWeek.weekTxtImgPath,
							weekName: loadedWeek.weekName,
							weekCharacters: loadedWeek.weekCharacters,
							weekDifficulties: loadedWeek.weekDifficulties,
							tracks: loadedWeek.tracks,
							freeplaySongs: [],
							disableFreeplay: loadedWeek.disableFreeplay,
							charSetting: loadedWeek.charSetting
						}
				}
			}
		}
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
		FlxTween.tween(bgBlack, {alpha: 0.5}, 0.3, {ease: FlxEase.linear});
		box.alpha = 0;
		FlxTween.tween(box, {alpha: 0.7}, 0.3, {ease: FlxEase.linear});
		exitButt.alpha = 0;
		FlxTween.tween(exitButt, {alpha: 0.7}, 0.3, {ease: FlxEase.linear});

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

	override function update(elapsed:Float)
	{
		if (input_charName.hasFocus)
		{
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && lime.system.Clipboard.text != null)
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
			File.saveContent('cdev-mods/' + Paths.curModDir[0] + '/data/weeks/' + input_charName.text + '.json', data);
	}
}

class FreeplayEditor extends MusicBeatState
{
	var _weekFile:WeekFile = null;

	static var curSelected:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
	private var iconArray:Array<HealthIcon> = [];

	var tween:FlxTween;
	var UI_box:FlxUITabMenu;
	var inputs:Array<Bool> = [];

	var bgColor_stepperR:FlxUINumericStepper;
	var bgColor_stepperG:FlxUINumericStepper;
	var bgColor_stepperB:FlxUINumericStepper;
	var icon_inputText:FlxUIInputText;

	public function new(weekData:WeekFile)
	{
		super();
		_weekFile = weekData;
	}

	override function create()
	{
		bg.alpha = 0.8;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0..._weekFile.freeplaySongs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, _weekFile.freeplaySongs[i].song, true, false);
			songText.isMenuItem = true;
			songText.isFreeplay = true;
			songText.targetY = i;
			songText.ID = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(_weekFile.freeplaySongs[i].character);
			icon.sprTracker = songText;
			icon.ID = i;
			iconArray.push(icon);
			add(icon);
		}

		var scoreBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 66, 0xFF000000);
		scoreBG.alpha = 0.8;
		add(scoreBG);

		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.8;
		add(bottomPanel);

		var bottomPanl:FlxSprite = new FlxSprite(0, FlxG.height - 120).makeGraphic(FlxG.width, 20, 0xFF000000);
		bottomPanl.alpha = 0.8;
		add(bottomPanl);

		// changeSelection();

		if (CDevConfig.saveData.smoothAF)
		{
			FlxG.camera.zoom = 1.5;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.cubeOut});
		}

		FlxG.mouse.visible = true;
		addEditorBox();
		addFreeplayUI();
		changeSelection();
		super.create();
	}

	function addEditorBox()
	{
		var tabs = [{name: 'Freeplay', label: 'Freeplay'},];
		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(250, 200);
		UI_box.x = FlxG.width - UI_box.width - 100;
		UI_box.y = FlxG.height - UI_box.height - 60;
		UI_box.scrollFactor.set();

		UI_box.selected_tab_id = 'Week';
		add(UI_box);
	}

	function addFreeplayUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Freeplay";

		bgColor_stepperR = new FlxUINumericStepper(10, 40, 20, 255, 0, 255, 0);
		bgColor_stepperG = new FlxUINumericStepper(80, 40, 20, 255, 0, 255, 0);
		bgColor_stepperB = new FlxUINumericStepper(150, 40, 20, 255, 0, 255, 0);

		var copyColor:FlxButton = new FlxButton(10, bgColor_stepperR.y + 25, "Copy Color", function()
		{
			lime.system.Clipboard.text = bg.color.red + ',' + bg.color.green + ',' + bg.color.blue;
		});
		var pasteColor:FlxButton = new FlxButton(140, copyColor.y, "Paste Color", function()
		{
			if (lime.system.Clipboard.text != null)
			{
				var leColor:Array<Int> = [];
				var splitted:Array<String> = lime.system.Clipboard.text.trim().split(',');
				for (i in 0...splitted.length)
				{
					var toPush:Int = Std.parseInt(splitted[i]);
					if (!Math.isNaN(toPush))
					{
						if (toPush > 255)
							toPush = 255;
						else if (toPush < 0)
							toPush *= -1;
						leColor.push(toPush);
					}
				}

				if (leColor.length > 2)
				{
					bgColor_stepperR.value = leColor[0];
					bgColor_stepperG.value = leColor[1];
					bgColor_stepperB.value = leColor[2];
					updateBG();
				}
			}
		});

		icon_inputText = new FlxUIInputText(10, bgColor_stepperR.y + 70, 100, '', 8);

		var disableSong:FlxUICheckBox = new FlxUICheckBox(10, icon_inputText.y + 30, null, null, "Hide week songs from freeplay", 100);
		disableSong.checked = _weekFile.disableFreeplay;
		disableSong.callback = function()
		{
			_weekFile.disableFreeplay = disableSong.checked;
		};

		tab_group.add(new FlxText(10, bgColor_stepperR.y - 18, 0, 'Background Color (R, G, B):'));
		tab_group.add(new FlxText(10, icon_inputText.y - 18, 0, 'Song character icon:'));
		tab_group.add(bgColor_stepperR);
		tab_group.add(bgColor_stepperG);
		tab_group.add(bgColor_stepperB);
		tab_group.add(copyColor);
		tab_group.add(pasteColor);
		tab_group.add(icon_inputText);
		tab_group.add(disableSong);
		UI_box.addGroup(tab_group);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			_weekFile.freeplaySongs[curSelected].character = icon_inputText.text;
			iconArray[curSelected].changeDaIcon(icon_inputText.text);
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			if (sender == bgColor_stepperR || sender == bgColor_stepperG || sender == bgColor_stepperB)
			{
				updateBG();
			}
		}
	}

	function updateBG()
	{
		_weekFile.freeplaySongs[curSelected].colors = [
			Math.round(bgColor_stepperR.value),
			Math.round(bgColor_stepperG.value),
			Math.round(bgColor_stepperB.value)
		];
		bg.color = FlxColor.fromRGB(_weekFile.freeplaySongs[curSelected].colors[0], _weekFile.freeplaySongs[curSelected].colors[1],
			_weekFile.freeplaySongs[curSelected].colors[2]);
	}

	var bgX:Float = FlxG.width;
	var vershit:Float = FlxG.height;
	var addedSmthing:Bool = false;

	override function update(elapsed:Float)
	{
		for (icon in iconArray)
		{
			var lerp:Float = FlxMath.lerp(1, icon.scale.x, game.cdev.CDevConfig.utils.bound(1 - (elapsed * 12), 0, 1));
			icon.scale.set(lerp, lerp);

			if (icon.ID == curSelected)
			{
				if (icon.hasWinningIcon)
				{
					icon.animation.curAnim.curFrame = 2;
				}
				else
				{
					icon.animation.curAnim.curFrame = 0;
				}
			}
			else
			{
				iconArray[icon.ID].animation.curAnim.curFrame = 0;
			}
		}

		super.update(elapsed);
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = FlxG.keys.justPressed.ENTER;
		var clicked = false;

		if (icon_inputText.hasFocus)
		{
			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
			if (FlxG.keys.justPressed.ENTER)
			{
				icon_inputText.hasFocus = false;
			}
		}
		else
		{
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
			if (FlxG.keys.justPressed.ESCAPE)
			{
				if (CDevConfig.saveData.smoothAF)
				{
					FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.quadOut});
				}

				FlxG.switchState(new WeekEditor("", _weekFile));
			}
			if (FlxG.mouse.wheel > 0 || upP)
			{
				// up
				changeSelection(-1);
			}
			else if (FlxG.mouse.wheel < 0 || downP)
			{
				// down
				changeSelection(1);
			}
		}
	}

	function updateSettings()
	{
		icon_inputText.text = _weekFile.freeplaySongs[curSelected].character;
		bgColor_stepperR.value = Math.round(_weekFile.freeplaySongs[curSelected].colors[0]);
		bgColor_stepperG.value = Math.round(_weekFile.freeplaySongs[curSelected].colors[1]);
		bgColor_stepperB.value = Math.round(_weekFile.freeplaySongs[curSelected].colors[2]);
		updateBG();
	}

	override function closeSubState()
	{
		super.closeSubState();
		changeSelection();
		FlxG.sound.music.play();
	}

	var toThisColor:Int = 0;

	function changeSelection(change:Int = 0, forceChange:Bool = false)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (!forceChange)
			curSelected += change;
		else
			curSelected = change;
		if (curSelected < 0)
			curSelected = _weekFile.freeplaySongs.length - 1;
		if (curSelected >= _weekFile.freeplaySongs.length)
			curSelected = 0;
		#if desktop
		// Updating Discord Rich Presence
		if (Main.discordRPC)
			DiscordClient.changePresence("Freeplay Editor", "Selected: " + _weekFile.freeplaySongs[curSelected].song, null);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			if (iconArray[curSelected] != null)
				iconArray[i].alpha = 0.6;
		}
		if (iconArray[curSelected] != null)
			iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.selected = false;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.selected = true;
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		updateSettings();
	}
}
