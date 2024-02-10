package meta.states.charter;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import lime.media.openal.AL;
import game.cdev.CDevPopUp;
import flixel.addons.ui.FlxUIPopup;
import game.cdev.script.HScript;
import game.cdev.script.CDevScript;
import game.objects.ChartEvent.EventInformation;
import game.objects.ChartEvent.SongEvent;
import lime.ui.Window;
import lime.app.Application;
import game.cdev.CDevConfig;
import lime.tools.Icon;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUISlider;
import flixel.FlxObject;
import haxe.io.Path;
import openfl.desktop.Clipboard;
import meta.modding.char_editor.CharacterData.CharData;
import sys.io.File;
import sys.FileSystem;
import game.JSONFile.JSONDefs;
import game.Conductor.BPMChangeEvent;
import game.song.Section.SwagSection;
import game.song.Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import game.cdev.UIDropDown;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import game.objects.*;
import game.*;

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	// var events:Array<Dynamic> = [];

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;

	public static var curSong:String = 'Dadbattle';

	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var renderedNotesLabel:FlxTypedGroup<FlxText>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedEvents:FlxTypedGroup<ChartEvent>;

	var gridBG:FlxSprite;

	var _song:SwagSong;
	var _inital_state_song:SwagSong; // first state of your song before it gets modified.
	var _every_action_save:SwagSong; // hell

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curNoteObj:Note;
	var curSelectedNote:Array<Dynamic>;
	var flash:Array<ChartEvent> = [];
	var flashes:Array<Note> = [];
	var flashez:Array<Note> = [];
	var claps:Array<Note> = [];
	var claps2:Array<ChartEvent> = [];
	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var vocVol:Float = 1;
	var insVol:Float = 0.7;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var mustHitIsChecked:Bool = false;
	var gridBlackLine:FlxSprite;
	var leftStrum:FlxTypedGroup<StrumNote>;
	var rightStrum:FlxTypedGroup<StrumNote>;

	var crapFollow:FlxObject;

	var eventsBackGround:FlxSprite;

	var evntInf:EventInformation;

	var notSaved:Bool = false; // checking if the player has saved the chart or not
	var autoSaveOnEveryAction:Bool = false;
	var autoSaveText:FlxText;

	var tipTexts:Array<FlxText> = [];

	var tempLoaded:Array<String> = [];
	var noteNames:Array<String> = [];

	override function create()
	{
		CDevConfig.setExitHandler(warningNotSaved);
		crapFollow = new FlxObject(0, 0, 1, 1);
		add(crapFollow);
		var bgShit:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('aboutMenu'));
		bgShit.alpha = 0.1;
		bgShit.scrollFactor.set();
		bgShit.screenCenter();
		bgShit.color = FlxColor.CYAN;
		add(bgShit);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		gridBG.alpha = 0.7;
		add(gridBG);

		eventsBackGround = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(Std.int(gridBG.width), Std.int(gridBG.height), FlxColor.BLACK);
		add(eventsBackGround);
		eventsBackGround.alpha = 0.7;

		leftStrum = new FlxTypedGroup<StrumNote>();
		rightStrum = new FlxTypedGroup<StrumNote>();

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedEvents = new FlxTypedGroup<ChartEvent>();
		renderedNotesLabel = new FlxTypedGroup<FlxText>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = CDevConfig.utils.CHART_TEMPLATE;
		}

		if (_song.song != curSong)
		{
			curSong = _song.song;
			lastSection = 0;
			curSection = 0;
		}
		else
		{
			curSection = lastSection;
		}

		_inital_state_song = _song;
		_every_action_save = _song;

		leftIcon = new HealthIcon(_song.player1);
		rightIcon = new HealthIcon(_song.player2);
		leftIcon.scrollFactor.set(1, 0);
		rightIcon.scrollFactor.set(1, 0);
		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(gridBG.x - (150 * leftIcon.scale.x) - 10, gridBG.y - 10);
		rightIcon.setPosition((gridBG.x + gridBG.width) + (150 * rightIcon.scale.x) + 10, gridBG.y - 10);

		rightIcon.flipX = true;
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;
		FlxG.save.bind('cdev_engine', 'EngineData');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(20, 50, 1000, "", 16);
		bpmTxt.setFormat('VCR OSD Mono', 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		bpmTxt.bold = true;
		bpmTxt.borderSize = 2;
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(GRID_SIZE * 8, 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Events", label: 'Events'},
			{name: "Note", label: 'Note'},
			{name: "Charting", label: 'Charting'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width - 320;
		UI_box.y = 20;
		var daTipsText:String = "Charting Controls:
		\nF1 - Hide this text.
		\nEnter - Play and Test your chart.
		\nSpace - Play / Pause song.
		\n[W], [S] / Mouse Wheel - Scroll the strum line.
		\n[Q] / [E] - Change the current note sustain length.
		\n[A], [D] / Left, Right - Change section.
		\nSHIFT + [W] / [S] - Scroll the strum line 2x faster.
		\nSHIFT + Left Click - Disable grid snapping.
		\nCTRL + Left Click - Select an arrow.
		\n[R] - Reset current section arrows.
		\nALT + [R] - Clear all notes in this chart.
		\nALT + SHIFT + [R] - Clear all events in this chart.";

		var splittedTextArray:Array<String> = daTipsText.split('\n');
		for (i in 0...splittedTextArray.length)
		{
			var tipsTxt:FlxText = new FlxText(20, UI_box.y + UI_box.height + -30, 0, splittedTextArray[i], 16);
			tipsTxt.y += i * 12;
			tipsTxt.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			tipsTxt.scrollFactor.set();
			tipsTxt.borderSize = 2;
			add(tipsTxt);
			tipTexts.push(tipsTxt);
		}
		add(UI_box);

		noteNames = [];
		tempLoaded = Note.getNoteList();

		for (i in Note.default_notetypes)
		{
			noteNames.push(i);
		}

		for (i in tempLoaded)
			noteNames.push(i);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addChartingUI();
		addEventUI();

		for (i in 0...4)
		{
			var xPos:Float = 0;
			switch (Math.abs(i))
			{
				case 0:
					xPos = 0;
				case 1:
					xPos = 40;
				case 2:
					xPos = 80;
				case 3:
					xPos = 120;
			}
			var theStrum:StrumNote = new StrumNote(gridBG.x + xPos, 50, GRID_SIZE, GRID_SIZE, i);
			theStrum.x = gridBG.x + xPos;
			theStrum.updateHitbox();
			leftStrum.add(theStrum);
		}
		for (i in 0...4)
		{
			var xPos:Float = 0;
			switch (Math.abs(i))
			{
				case 0:
					xPos = 0;
				case 1:
					xPos = 40;
				case 2:
					xPos = 80;
				case 3:
					xPos = 120;
			}
			var theStrum:StrumNote = new StrumNote(gridBG.x + 160 + xPos, 50, GRID_SIZE, GRID_SIZE, i);
			theStrum.x = gridBG.x + 160 + xPos;
			theStrum.updateHitbox();
			rightStrum.add(theStrum);
		}
		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedEvents);
		add(renderedNotesLabel);
		add(leftStrum);
		add(rightStrum);
		leftStrum.visible = false;
		rightStrum.visible = false;
		checkSectionEvent(true);

		evntInf = new EventInformation(0, 0, "", "", "");
		add(evntInf);
		evntInf.scrollFactor.set();

		autoSaveText = new FlxText(10, FlxG.height - 25, -1, "Autosaving...", 22);
		autoSaveText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		autoSaveText.alpha = 0;
		autoSaveText.scrollFactor.set();
		autoSaveText.borderSize = 2;
		add(autoSaveText);

		super.create();
	}

	function checkSectionEvent(checkAll:Bool = false)
	{
		if (checkAll)
		{
			for (evns in 0..._song.notes.length)
			{
				if (_song.notes[evns].sectionEvents == null)
				{
					var sec:SwagSection = {
						lengthInSteps: _song.notes[evns].lengthInSteps,
						bpm: _song.bpm,
						changeBPM: _song.notes[evns].changeBPM,
						mustHitSection: _song.notes[evns].mustHitSection,
						banger: _song.notes[evns].banger,
						sectionNotes: _song.notes[evns].sectionNotes,
						sectionEvents: [],
						typeOfSection: _song.notes[evns].typeOfSection,
						altAnim: _song.notes[evns].altAnim,
						p1AltAnim: _song.notes[evns].p1AltAnim
					};
					_song.notes[evns] = sec; // replacc
				}
			}
		}
		else
		{
			if (_song.notes[curSection].sectionEvents == null)
			{
				var sec:SwagSection = {
					lengthInSteps: _song.notes[curSection].lengthInSteps,
					bpm: _song.bpm,
					changeBPM: _song.notes[curSection].changeBPM,
					mustHitSection: _song.notes[curSection].mustHitSection,
					banger: _song.notes[curSection].banger,
					sectionNotes: _song.notes[curSection].sectionNotes,
					sectionEvents: [],
					typeOfSection: _song.notes[curSection].typeOfSection,
					altAnim: _song.notes[curSection].altAnim,
					p1AltAnim: _song.notes[curSection].p1AltAnim
				};
				_song.notes[curSection] = sec; // replacc
			}
		}
	}

	var player1DropDown:UIDropDown;
	var player2DropDown:UIDropDown;
	var gfDropDown:UIDropDown;
	var stageDropDown:UIDropDown;
	var UI_songTitle:FlxUIInputText;

	function addSongUI():Void
	{
		UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var saveEventButton:FlxButton = new FlxButton(110, 8, "Save Event", function()
		{
			// saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var spdText:FlxText = new FlxText(stepperSpeed.x + 60, stepperSpeed.y, FlxG.width, "Scroll Speed", 8);

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var bpmText:FlxText = new FlxText(stepperBPM.x + 60, stepperBPM.y, FlxG.width, "Song BPM", 8);

		var dirs:Array<String> = [];
		#if ALLOW_MODS
		for (i in 0...Paths.curModDir.length)
		{
			dirs.push(Paths.mods(Paths.curModDir[i] + '/data/characters/'));
		}
		dirs.push(Paths.getPreloadPath('data/characters/'));
		#else
		dirs = [Paths.getPreloadPath('data/characters/')];
		#end

		var temporary:Map<String, Bool> = new Map<String, Bool>();

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		for (i in 0...characters.length)
			temporary.set(characters[i], true);

		#if ALLOW_MODS
		for (i in 0...dirs.length)
		{
			var dir:String = dirs[i];
			if (FileSystem.exists(dir))
			{
				for (file in FileSystem.readDirectory(dir))
				{
					var path = haxe.io.Path.join([dir, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
					{
						var charToCheck:String = file.substr(0, file.length - 5);
						if (!charToCheck.endsWith('-dead') && !temporary.exists(charToCheck))
						{
							temporary.set(charToCheck, true);
							characters.push(charToCheck);
						}
					}
				}
			}
		}
		#end

		player1DropDown = new UIDropDown(10, 130, UIDropDown.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;

		player2DropDown = new UIDropDown(140, 130, UIDropDown.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});

		var loadedStages:Map<String, Bool> = new Map();

		var stageList:Array<String> = [];
		var stageListTxt:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));

		for (i in 0...stageListTxt.length)
		{
			stageList.push(stageListTxt[i]);
		}
		#if ALLOW_MODS
		var dirs:Array<String> = [];
		for (mod in Paths.curModDir)
		{
			dirs.push(Paths.mods(mod + '/data/stages/'));
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
						if (!loadedStages.exists(checkChar))
						{
							stageList.push(checkChar);
							loadedStages.set(checkChar, true);
						}
					}
				}
			}
		}
		#end
		stageDropDown = new UIDropDown(140, 170, UIDropDown.makeStrIdLabelArray(stageList, true), function(stage:String)
		{
			_song.stage = stageList[Std.parseInt(stage)];
		});

		gfDropDown = new UIDropDown(10, 170, UIDropDown.makeStrIdLabelArray(characters, true), function(daGFList:String)
		{
			_song.gfVersion = characters[Std.parseInt(daGFList)];
		});

		//var stepperOffset:FlxUINumericStepper = new FlxUINumericStepper(140, 220, 0.1, 0, -5000.0, 5000.0, 1);
		//stepperOffset.value = _song.offset;
		//stepperOffset.name = 'chart_offset';
		//var oftText:FlxText = new FlxText(stepperOffset.x + 60, stepperOffset.y, FlxG.width, "Chart Offset\n(Beta)", 8);

		var player1Text:FlxText = new FlxText(player1DropDown.x, player1DropDown.y - 15, FlxG.width, "Player 1", 8);
		var player2Text:FlxText = new FlxText(player2DropDown.x, player2DropDown.y - 15, FlxG.width, "Player 2", 8);
		var stageText:FlxText = new FlxText(stageDropDown.x, stageDropDown.y - 15, FlxG.width, "Stage", 8);
		var gfText:FlxText = new FlxText(gfDropDown.x, gfDropDown.y - 15, FlxG.width, "Girlfriend", 8);

		player2DropDown.selectedLabel = _song.player2;
		stageDropDown.selectedLabel = _song.stage;
		gfDropDown.selectedLabel = _song.gfVersion;

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		//tab_group_song.add(stepperOffset);
		tab_group_song.add(player1Text);
		tab_group_song.add(player2Text);
		tab_group_song.add(stageText);
		tab_group_song.add(spdText);
		tab_group_song.add(bpmText);
		//tab_group_song.add(oftText);
		tab_group_song.add(stageText);
		tab_group_song.add(gfText);
		tab_group_song.add(stageDropDown);
		tab_group_song.add(gfDropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(crapFollow);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;
	var check_altAnim2:FlxUICheckBox;
	var check_bangerPart:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		var stepperLengthLabel = new FlxText(74, 10, 'Section Length in steps');

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(174, 132, 'Sections');

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});
		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must Hit Section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 200, null, null, "P2 Alternate Animation", 100);
		check_altAnim.name = 'check_altAnim';
		check_altAnim2 = new FlxUICheckBox(10, 230, null, null, "P1 Alternate Animation", 100);
		check_altAnim2.name = 'check_altAnimPlayer';

		check_bangerPart = new FlxUICheckBox(140, 200, null, null, "Zoom for every beats", 100);
		check_bangerPart.name = 'check_bangerPart';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperLengthLabel);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_altAnim2);
		tab_group_section.add(check_bangerPart);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var noteDropDown:UIDropDown;
	var selectedNoteType:String = "Default Note";
	var selectedNotePos:Int = -1;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		var steppersusTxt:FlxText = new FlxText(10, 10, FlxG.width, "Note Sustain Length", 8);
		stepperSusLength = new FlxUINumericStepper(10, 30, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		noteDropDown = new UIDropDown(10, 45 + 20, UIDropDown.makeStrIdLabelArray(noteNames, true), function(mNote:String)
		{
			selectedNoteType = noteNames[Std.parseInt(mNote)];
			selectedNotePos = Std.parseInt(mNote);
		});

		var ivText:FlxText = new FlxText(10, noteDropDown.y - 15, FlxG.width, "Note Types", 8);
		tab_group_note.add(ivText);

		tab_group_note.add(steppersusTxt);
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(noteDropDown);

		UI_box.addGroup(tab_group_note);
	}

	var eventDropDown:UIDropDown;
	var jsonEvents:Array<String> = [];
	var input_event_firstText:FlxUIInputText;
	var input_event_secondText:FlxUIInputText;

	var desc:FlxText;

	var curSelectedEvent:String = '';

	function addEventUI():Void
	{
		var tab_group_charting = new FlxUI(null, UI_box);
		tab_group_charting.name = 'Events';

		var eventNames:Array<String> = []; // ChartEvent.getEventNames();
		// var eventShet:Array<SongEvent> = [];

		for (i in 0...ChartEvent.builtInEvents.length)
		{
			eventNames.push(ChartEvent.builtInEvents[i][0]);
		}

		var uhhItsTemp:Array<String> = ChartEvent.getEventNames();
		for (event in uhhItsTemp)
		{
			eventNames.push(event);
		}

		eventDropDown = new UIDropDown(10, 30, UIDropDown.makeStrIdLabelArray(eventNames, true), function(eventz:String)
		{
			// sorry for this :(
			curSelectedEvent = eventNames[Std.parseInt(eventz)];
			var contain:Bool = false;
			var l:Int = 0;
			for (i in 0...ChartEvent.builtInEvents.length)
			{
				if (ChartEvent.builtInEvents[i][0] == curSelectedEvent)
				{
					contain = true;
					l = i;
				}
			}
			if (!contain)
				desc.text = ChartEvent.getEventDescription(curSelectedEvent);
			else
				desc.text = ChartEvent.builtInEvents[l][1];
			// banana = eventShet[Std.parseInt(eventz)];
		});

		var ivText:FlxText = new FlxText(10, eventDropDown.y - 15, FlxG.width, "Chart Event", 8);
		tab_group_charting.add(ivText);

		input_event_firstText = new FlxUIInputText(10, eventDropDown.y + 50, 200, "");
		input_event_secondText = new FlxUIInputText(10, eventDropDown.y + 80, 200, "");
		tab_group_charting.add(input_event_firstText);
		tab_group_charting.add(input_event_secondText);
		tab_group_charting.add(new FlxText(10, input_event_firstText.y - 15, UI_box.width - 20, 'Value 1', 8));
		tab_group_charting.add(new FlxText(10, input_event_secondText.y - 15, UI_box.width - 20, 'Value 2', 8));

		desc = new FlxText(10, input_event_secondText.y + input_event_secondText.height + 15, FlxG.width, "", 8);
		tab_group_charting.add(desc);

		tab_group_charting.add(eventDropDown);
		UI_box.addGroup(tab_group_charting);
	}

	var muteInst:Bool = false;
	var muteVocal:Bool = false;
	var muteHitsound:Bool = true;
	var usingDownscroll:Bool = false;
	var speedMod:Float = 1;

	function addChartingUI():Void
	{
		var tab_group_charting = new FlxUI(null, UI_box);
		tab_group_charting.name = 'Charting';

		var stepperVoicesVol:FlxUINumericStepper = new FlxUINumericStepper(10, 30, 0.1, 1, 0.0, 1.0, 1);
		stepperVoicesVol.value = vocVol;
		stepperVoicesVol.name = 'voices_Vol';

		var vvText:FlxText = new FlxText(stepperVoicesVol.x + 60, stepperVoicesVol.y, FlxG.width, "Vocal Volume", 8);

		var stepperInstVol:FlxUINumericStepper = new FlxUINumericStepper(10, 45, 0.1, 0.7, 0.0, 1.0, 1);
		stepperInstVol.value = insVol;
		stepperInstVol.name = 'inst_Vol';

		var ivText:FlxText = new FlxText(stepperInstVol.x + 60, stepperInstVol.y, FlxG.width, "Instrumental Volume", 8);

		var sliderSpeed:FlxUISlider = new FlxUISlider(this, "speedMod", 10, 60, 0.1, 5, Std.int(UI_box.width - 30), 20, 5, FlxColor.WHITE, FlxColor.WHITE);
		sliderSpeed.value = 1;
		sliderSpeed.nameLabel.text = "Song Speed Modifier";
		sliderSpeed.callback = function(value:Float)
		{
			speedMod += value;
			if (speedMod >= 5)
				speedMod = 5;
		}

		var spText:FlxText = new FlxText(sliderSpeed.x, sliderSpeed.y - 15, FlxG.width, "Song Speed Modifier", 8);

		var check_mute_inst = new FlxUICheckBox(10, 190, null, null, "Mute Instrumental", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = insVol;
			muteInst = false;

			if (check_mute_inst.checked)
			{
				vol = 0;
				muteInst = true;
			}

			FlxG.sound.music.volume = vol;
		};

		var check_mute_hitsound = new FlxUICheckBox(10, 230, null, null, "Mute Hitsound", 100);
		check_mute_hitsound.checked = true;
		check_mute_hitsound.callback = function()
		{
			muteHitsound = false;
			if (check_mute_hitsound.checked)
				muteHitsound = true;
		};

		var check_downscroll = new FlxUICheckBox(10, 230 + 40, null, null, "Downscroll", 100);
		check_downscroll.checked = false;
		check_downscroll.callback = function()
		{
			usingDownscroll = false;
			if (check_downscroll.checked)
				usingDownscroll = true;

			updateGrid(true);
		};

		var check_mute_vocal = new FlxUICheckBox(140, 190, null, null, "Mute Voices", 100);
		check_mute_vocal.checked = false;
		check_mute_vocal.callback = function()
		{
			var vol:Float = vocVol;
			muteVocal = false;

			if (check_mute_vocal.checked)
			{
				vol = 0;
				muteVocal = true;
			}

			vocals.volume = vol;
		};

		var check_show_strum = new FlxUICheckBox(140, 230, null, null, "Show Strum Notes", 100);
		check_show_strum.checked = false;
		check_show_strum.callback = function()
		{
			leftStrum.visible = check_show_strum.checked;
			rightStrum.visible = check_show_strum.checked;
		};

		tab_group_charting.add(check_mute_inst);
		tab_group_charting.add(check_mute_vocal);
		tab_group_charting.add(sliderSpeed);
		// tab_group_charting.add(spText);
		tab_group_charting.add(check_show_strum);
		tab_group_charting.add(check_mute_hitsound);
		tab_group_charting.add(check_downscroll);
		tab_group_charting.add(stepperInstVol);
		tab_group_charting.add(stepperVoicesVol);
		tab_group_charting.add(vvText);
		tab_group_charting.add(ivText);

		UI_box.addGroup(tab_group_charting);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			if (vocals != null)
				vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong));

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		/*FlxG.sound.music.onComplete = function()
			{
				vocals.pause();
				vocals.time = 0;
				FlxG.sound.music.pause();
				FlxG.sound.music.time = 0;
				changeSection();
		};*/
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must Hit Section':
					_song.notes[curSection].mustHitSection = check.checked;
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "P2 Alternate Animation":
					_song.notes[curSection].altAnim = check.checked;
				case "P1 Alternate Animation":
					_song.notes[curSection].p1AltAnim = check.checked;
				case 'Zoom for every beats':
					_song.notes[curSection].banger = check.checked;
					FlxG.log.add('banger beats shit');
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = FlxMath.roundDecimal(nums.value, 2);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(FlxMath.roundDecimal(nums.value, 2));
			}
			else if (wname == 'chart_offset')
			{
				_song.offset = nums.value;
			}
			else if (wname == 'voices_Vol')
			{
				vocVol = nums.value;
				if (!muteVocal)
					vocals.volume = vocVol;
			}
			else if (wname == 'inst_Vol')
			{
				insVol = nums.value;
				if (!muteInst)
					FlxG.sound.music.volume = insVol;
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote != null) curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var allowScrollSongPosition:Bool = false;
	var dontCheck:Bool = false;
	var p1Lerp:Float = 1;
	var p2Lerp:Float = 1;
	var oldStep:Int = 0;

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	var editingEvents:Bool = false;
	var shouldVisible:Bool = false;

	var curOverlappedEvent:ChartEvent;
	var overlaped:Bool = false;
	var uh:ChartEvent;

	override function update(elapsed:Float)
	{
		oldStep = curStep;
		curStep = recalculateSteps();
		curBeat = Math.floor(curStep / 4);

		if (curStep % 4 == 0 && oldStep != curStep)
		{
			beatHitShit();
		}

		if (oldStep != curStep)
		{
			stepHitShit();
		}

		super.update(elapsed);
		updateHeads();

		if (FlxG.keys.justPressed.F1)
		{
			for (obj in tipTexts)
			{
				obj.visible = !obj.visible;
			}
		}

		//p1Lerp = FlxMath.lerp(0.6, leftIcon.scale.x, CDevConfig.utils.bound(1 - (elapsed * 10), 0, 1));
		//p2Lerp = FlxMath.lerp(0.6, rightIcon.scale.x, CDevConfig.utils.bound(1 - (elapsed * 10), 0, 1));

		p1Lerp = 0.8-((Conductor.songPosition % (Conductor.crochet))/Conductor.crochet)*0.2;
		p2Lerp = 0.8-((Conductor.songPosition % (Conductor.crochet))/Conductor.crochet)*0.2;

		leftIcon.scale.set(p1Lerp, p1Lerp);
		leftIcon.updateHitbox();
		leftIcon.setPosition(gridBG.x - (150 / 2) - ((150 / 2) * leftIcon.scale.x) - 40, gridBG.y - 10);

		rightIcon.scale.set(p2Lerp, p2Lerp);
		rightIcon.updateHitbox();
		rightIcon.setPosition((gridBG.x + (GRID_SIZE * 4)) + (150 / 2) + ((150 / 2) * rightIcon.scale.x) + 40, gridBG.y - 10);

		#if cpp
		if (FlxG.sound.music.playing)
		{
			CDevConfig.utils.setSoundPitch(FlxG.sound.music, speedMod);
			if (_song.needsVoices && vocals.playing)
				CDevConfig.utils.setSoundPitch(vocals, speedMod);
		}
		#end

		if (FlxG.sound.music != null
			&& FlxG.sound.music.playing
			&& FlxG.sound.music.time >= (FlxG.sound.music.length-1))
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection(0);
		}

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = UI_songTitle.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (_song.notes[curSection] != null && _song.notes[curSection].sectionEvents == null)
		{
			checkSectionEvent();
			updateGrid();
		}

		editingEvents = (UI_box.selected_tab == 1);
		eventsBackGround.visible = editingEvents;

		leftStrum.forEachAlive(function(strum:StrumNote)
		{
			// strum.updateHitbox();
			if (!usingDownscroll)
				strum.y = strumLine.y;
			else
				strum.y = strumLine.y - GRID_SIZE;
			if (FlxG.sound.music.playing)
			{
				strum.alpha = 1;
				if (!editingEvents)
				{
					curRenderedNotes.forEach(function(note:Note)
					{
						if (strum.x == note.x && note.overlaps(strumLine) && !flashes.contains(note))
						{
							strum.hitAnim();
							flashes.push(note);
						}
					});
					curRenderedSustains.forEach(function(note:FlxSprite)
					{
						if (note.overlaps(strum))
							strum.hitAnim();
					});
				}
				else
				{
					curRenderedEvents.forEach(function(evnt:ChartEvent)
					{
						if (strum.x == evnt.x && evnt.overlaps(strumLine) && !flash.contains(evnt))
						{
							strum.hitAnim();
							flash.push(evnt);
						}
					});
				}
			}
			else
			{
				strum.alpha = 0.5;
				flashes.splice(0, flashes.length);
			}
		});
		rightStrum.forEachAlive(function(strum:StrumNote)
		{
			// strum.updateHitbox();
			if (!usingDownscroll)
				strum.y = strumLine.y;
			else
				strum.y = strumLine.y - GRID_SIZE;
			if (FlxG.sound.music.playing)
			{
				strum.alpha = 1;
				if (!editingEvents)
				{
					curRenderedNotes.forEach(function(note:Note)
					{
						if (strum.x == note.x && note.overlaps(strumLine) && !flashez.contains(note))
						{
							strum.hitAnim();
							flashez.push(note);
						}
					});
					curRenderedSustains.forEach(function(note:FlxSprite)
					{
						if (note.overlaps(strum))
							strum.hitAnim();
					});
				}
				else
				{
					curRenderedEvents.forEach(function(evnt:ChartEvent)
					{
						if (strum.x == evnt.x && evnt.overlaps(strumLine) && !flash.contains(evnt))
						{
							strum.hitAnim();
							flash.push(evnt);
						}
					});
				}
			}
			else
			{
				strum.alpha = 0.5;
				flashez.splice(0, flashez.length);
			}
		});
		curRenderedNotes.forEach(function(note:Note)
		{
			if (note != curNoteObj)
			{
				if (leftStrum.visible && rightStrum.visible)
				{
					if ((!usingDownscroll ? (note.y < strumLine.y) : (note.y > strumLine.y)))
					{
						note.alpha = 0.3;
					}
					else
					{
						note.alpha = 1;
					}
				}
				else
				{
					// if (note.alpha != 1)
					//	note.alpha = 1;
				}
			}

			note.visible = !editingEvents;
		});
		curRenderedSustains.forEach(function(note:FlxSprite)
		{
			note.visible = !editingEvents;
		});

		crapFollow.setPosition((gridBG.x + gridBG.width) / 2, strumLine.y);

		curRenderedNotes.forEach(function(note:Note)
		{
			if (FlxG.sound.music.playing)
			{
				if (!editingEvents)
				{
					FlxG.overlap(strumLine, note, function(_, _)
					{
						if (!claps.contains(note))
						{
							claps.push(note);
							if (!muteHitsound)
								FlxG.sound.play(Paths.sound('clapsfx'), 0.7);
						}
					});
				}
			}
		});

		if (curSelectedNote != null)
		{
			for (i in curRenderedNotes.members)
			{
				if (i != null && curSelectedNote[0] == i.strumTime && curSelectedNote[1] % 4 == i.noteData)
				{
					curNoteObj = i;
				}
			}
		}
		else
		{
			curNoteObj = null;
		}

		if (curNoteObj != null)
		{
			var colorVal:Float = 0.7 + Math.sin(Math.PI * CDevConfig.elapsedGameTime) * 0.3;
			curNoteObj.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999);
		}

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			// trace(curStep);
			// trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			// trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		if (FlxG.mouse.getPositionInCameraView().y > FlxG.height / 2)
		{
			evntInf.setPosition(FlxG.mouse.getPositionInCameraView().x, FlxG.mouse.getPositionInCameraView().y - evntInf.height);
		}
		else
		{
			evntInf.setPosition(FlxG.mouse.getPositionInCameraView().x, FlxG.mouse.getPositionInCameraView().y);
		}

		evntInf.alpha = (shouldVisible ? 1 : 0);

		if (overlaped)
		{
			shouldVisible = true;
		}
		else
		{
			shouldVisible = false;
		}

		curRenderedEvents.forEach(function(evnt:ChartEvent)
		{
			evnt.visible = editingEvents;

			if (editingEvents)
			{
				FlxG.overlap(strumLine, evnt, function(_, _)
				{
					if (!claps2.contains(evnt))
					{
						claps2.push(evnt);
						if (!muteHitsound)
							FlxG.sound.play(Paths.sound('clapsfx'), 0.7);
					}
				});
			}

			if (FlxG.mouse.overlaps(evnt) && editingEvents)
			{
				if (evntInf.eventName != evnt.EVENT_NAME)
					evntInf.eventName = evnt.EVENT_NAME;
				if (evntInf.eventValue1 != evnt.value1)
					evntInf.eventValue1 = evnt.value1;
				if (evntInf.eventValue2 != evnt.value2)
					evntInf.eventValue2 = evnt.value2;

				if (curOverlappedEvent != evnt)
					evntInf.updateInfo();
				overlaped = true;
				curOverlappedEvent = evnt;
				uh = evnt;
			}
			else
			{
				if (curOverlappedEvent == evnt && evnt != null || uh == evnt && evnt != null)
				{
					curOverlappedEvent = null;
					uh = null;
					overlaped = false;
				}
			}
		});
		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		// preventing vocals not playing when the inst restarts
		if (vocals.playing != FlxG.sound.music.playing)
		{
			dontCheck = false;
		}
		if (!dontCheck)
		{
			if (FlxG.sound.music.playing)
			{
				if (!vocals.playing)
				{
					vocals.play();
					dontCheck = true;
				}
			}
			else
			{
				if (vocals.playing)
				{
					vocals.pause();
					dontCheck = true;
				}
			}
		}

		checkChartFile(elapsed);

		if (FlxG.mouse.justPressed)
		{
			if (!editingEvents)
			{
				if (FlxG.mouse.overlaps(curRenderedNotes))
				{
					curRenderedNotes.forEach(function(note:Note)
					{
						if (FlxG.mouse.overlaps(note))
						{
							if (FlxG.keys.pressed.CONTROL)
							{
								selectNote(note);
							}
							else
							{
								trace('tryin to delete note...');
								deleteNote(note);
							}
						}
					});
				}
				else
				{
					if (FlxG.mouse.x > gridBG.x
						&& FlxG.mouse.x < gridBG.x + gridBG.width
						&& FlxG.mouse.y > gridBG.y
						&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
					{
						FlxG.log.add('added note');
						addNote();
					}
				}
			}
			else
			{
				if (FlxG.mouse.overlaps(curRenderedEvents))
				{
					curRenderedEvents.forEach(function(note:ChartEvent)
					{
						if (FlxG.mouse.overlaps(note))
						{
							deleteEvent(note);
						}
					});
				}
				else
				{
					if (FlxG.mouse.x > gridBG.x
						&& FlxG.mouse.x < gridBG.x + gridBG.width
						&& FlxG.mouse.y > gridBG.y
						&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
					{
						FlxG.log.add('added event');
						addEvent();
					}
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.visible = true;
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}
		else
		{
			dummyArrow.visible = false;
		}

		var shitshithshsdahskjdh:Array<Bool> = [
			UI_songTitle.hasFocus,
			input_event_firstText.hasFocus,
			input_event_secondText.hasFocus
		];
		if (!shitshithshsdahskjdh.contains(true))
		{
			if (FlxG.keys.justPressed.ENTER)
			{
				lastSection = curSection;

				PlayState.SONG = _song;
				FlxG.sound.music.stop();
				vocals.stop();
				FlxG.switchState(new PlayState());
			}

			if (FlxG.keys.justPressed.E)
			{
				changeNoteSustain(Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.Q)
			{
				changeNoteSustain(-Conductor.stepCrochet);
			}

			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.Z && lastNote != null)
				{
					trace(curRenderedNotes.members.contains(lastNote) ? "delete note" : "add note");
					if (curRenderedNotes.members.contains(lastNote))
						deleteNote(lastNote);
					else
						addNote(lastNote);
				}
			}
			if (FlxG.keys.pressed.ALT && FlxG.keys.justPressed.R) {
				if (!FlxG.keys.pressed.SHIFT)
					resetChart();
				else
					resetEvents();
			}
				
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					// vocals.pause();
					claps.splice(0, claps.length);
				}
				else
				{
					// vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();

				updateTheText();
			}

			var dropDownShits:Array<Bool> = [
				player1DropDown.dropPanel.visible,
				player2DropDown.dropPanel.visible,
				gfDropDown.dropPanel.visible,
				stageDropDown.dropPanel.visible
			];

			if (!dropDownShits.contains(true))
				allowScrollSongPosition = true;
			else
				allowScrollSongPosition = false;

			if (FlxG.mouse.wheel != 0 && allowScrollSongPosition)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
				updateTheText();
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if ((!usingDownscroll ? FlxG.keys.pressed.W : FlxG.keys.pressed.S))
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
				updateTheText();
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
				updateTheText();
			}
		}
		else
		{
			for (i in [UI_songTitle, input_event_firstText, input_event_secondText])
			{
				if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.V && lime.system.Clipboard.text != null)
				{
					i.text = pasteFunction(i.text);
					i.caretIndex = i.text.length;
					getEvent(FlxUIInputText.CHANGE_EVENT, i, null, []);
				}
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				if (FlxG.keys.justPressed.ENTER)
					i.hasFocus = false;
			}
		}

		_song.bpm = tempBpm;

		if (!shitshithshsdahskjdh.contains(true))
		{
			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
				changeSection(curSection + shiftThing);
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
				changeSection(curSection - shiftThing);

			updateTheText();
		}
		if (FlxG.sound.music.playing)
		{
			updateTheText();
		}
	}

	function updateTheText()
	{
		bpmTxt.text = '-=Song Info=-'
			+ "\nSong Name: "
			+ _song.song
			+ (notSaved ? "*" : "")
			+ "\nDuration: "
			+ game.cdev.SongPosition.getCurrentDuration(FlxG.sound.music.time)
			+ " / "
			+ game.cdev.SongPosition.getMaxDuration(FlxG.sound.music.length)
			+ "\nSection: "
			+ curSection
			+ " / "
			+ _song.notes.length
			+ "\nSteps: "
			+ curStep
			+ "\nBeats: "
			+ curBeat
			+ "\nSong BPM: "
			+ _song.bpm
			+ "\nScroll Speed: "
			+ _song.speed
			+ "\n"
			+ "\n-=Characters=-"
			+ "\nPlayer1: "
			+ _song.player1
			+ "\nPlayer2: "
			+ _song.player2
			+ "\nGF: "
			+ _song.gfVersion
			+ "\n\n-=Misc=-"
			+ "\nStage: "
			+ _song.stage;
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetChart()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		for (daNotes in 0..._song.notes.length)
		{
			for (i in 0..._song.notes[daNotes].sectionNotes.length)
			{
				_song.notes[daNotes].sectionNotes = [];
			}
		}
		resetSection(true);
	}

	function resetEvents()
	{
		//copied from resetChart!!
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		for (daNotes in 0..._song.notes.length)
		{
			for (i in 0..._song.notes[daNotes].sectionEvents.length)
			{
				_song.notes[daNotes].sectionEvents = [];
			}
		}
		resetSection(true);
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		// trace('changing section' + sec);
		if (_song.notes[sec] != null)
		{
			curSection = sec;

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_altAnim2.checked = sec.p1AltAnim;
		check_changeBPM.checked = sec.changeBPM;
		check_bangerPart.checked = sec.banger;
		stepperSectionBPM.value = sec.bpm;
		mustHitIsChecked = check_mustHitSection.checked;
		updateHeads();

		if (mustHitIsChecked != check_mustHitSection.checked)
		{
			swapShit();
			mustHitIsChecked = check_mustHitSection.checked;
		}
	}

	function updateHeads():Void
	{
		var p1Icon:String = getIconFromCharJSON(_song.player1);
		var p2Icon:String = getIconFromCharJSON(_song.player2);
		if (check_mustHitSection.checked)
		{
			leftIcon.changeDaIcon(p1Icon);
			rightIcon.changeDaIcon(p2Icon);
		}
		else
		{
			leftIcon.changeDaIcon(p2Icon);
			rightIcon.changeDaIcon(p1Icon);
		}
	}

	function getIconFromCharJSON(char:String):String
	{
		var charPath:String = 'data/characters/' + char + '.json';
		var daRawJSON = null;
		#if ALLOW_MODS
		var path:String = Paths.modChar(char);
		if (!FileSystem.exists(path))
			path = Paths.char(char);

		if (!FileSystem.exists(path))
		#else
		var path:String = Paths.getPreloadPath(charPath);
		if (!Assets.exists(path))
		#end
		{
			path = Paths.char('bf');
		}

		if (FileSystem.exists(path))
		{
			#if ALLOW_MODS
			daRawJSON = File.getContent(path);
			#else
			daRawJSON = Assets.getText(path);
			#end
		}
		if (daRawJSON != null)
		{
			var parsedJSON:CharData = cast Json.parse(daRawJSON);
			return parsedJSON.iconName;
		}

		return 'face';
	}

	function swapShit():Void
	{
		for (i in 0..._song.notes[curSection].sectionNotes.length)
		{
			var note = _song.notes[curSection].sectionNotes[i];
			note[1] = (note[1] + 4) % 8;
			_song.notes[curSection].sectionNotes[i] = note;
			updateGrid();
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function getNoteTypePos(nt:String = ""):Int
	{
		if (nt == "Default Note")
			return -1;

		var l:Int = 0;
		for (i in noteNames)
		{
			if (i == nt)
			{
				return l;
			}
			l++;
		}
		return -1;
	}
	function destroyThis(note:FlxSprite){
		//note.graphic.bitmap.dispose(); uhh
		//note.graphic.destroy();
		note.destroy();
	}
	function updateGrid(?justUpdateTheNotes:Bool = false):Void
	{
		curRenderedNotes.forEach(function(note:Note)
		{
			//IDK LOLL
			destroyThis(note);
			curRenderedNotes.remove(note);
		});

		curRenderedSustains.forEach(function(note:FlxSprite)
		{
			destroyThis(note);
			curRenderedSustains.remove(note);
		});

		curRenderedEvents.forEach(function(note:ChartEvent)
		{
			destroyThis(note);
			curRenderedEvents.remove(note);
		});

		renderedNotesLabel.forEach(function(spr:FlxText)
		{
			destroyThis(spr);
			renderedNotesLabel.remove(spr);
		});

		remove(gridBG);
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * _song.notes[curSection].lengthInSteps);
		gridBG.alpha = 0.7;
		add(gridBG);

		remove(gridBlackLine);
		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;
		var sectionEv:Array<Dynamic> = _song.notes[curSection].sectionEvents;
		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			if (usingDownscroll)
				daStrumTime = i[0] + Conductor.stepCrochet;
			var daSus = i[2];
			var daType = "Default Note";

			if (i[3] != null)
				daType = i[3];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4);
			note.noteType = daType;
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
			curRenderedNotes.add(note);

			var typePos:Int = getNoteTypePos(daType);

			if (typePos != -1)
			{
				var newShit:FlxText = new FlxText(0, 0, 0, Std.string(typePos), 32);
				newShit.setFormat("VCR OSD Mono", 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
				// newShit.setGraphicSize(GRID_SIZE);
				newShit.borderSize = 1.5;
				add(newShit);
				renderedNotesLabel.add(newShit);
				CDevConfig.utils.moveToCenterOfSprite(newShit, note);
			}

			if (daSus > 0)
			{
				var color:FlxColor = FlxColor.WHITE;
				switch (daNoteInfo % 4)
				{
					case 3:
						color = FlxColor.RED;
					case 1:
						color = FlxColor.CYAN;
					case 2:
						color = FlxColor.GREEN;
					case 0:
						color = FlxColor.MAGENTA;
				}
				var yPos:Float = note.y + GRID_SIZE;
				if (usingDownscroll)
				{
					yPos = note.y - (GRID_SIZE * (daSus / Conductor.stepCrochet));
				}
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2) - 3,
					yPos).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)), color);
				curRenderedSustains.add(sustainVis);
			}
		}
		remove(eventsBackGround);
		eventsBackGround = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(Std.int(gridBG.width), Std.int(gridBG.height), FlxColor.BLACK);
		add(eventsBackGround);
		eventsBackGround.alpha = 0.7;
		eventsBackGround.visible = false;
		if (sectionEv != null)
		{
			for (i in sectionEv)
			{
				var daName = i[0];
				var daInfo = i[1];
				var daStrumTime = i[2];
				var eventValue1 = i[3];
				var eventValue2 = i[4];

				var eventIcon:ChartEvent = new ChartEvent(daStrumTime, daInfo, true);
				eventIcon.setGraphicSize(GRID_SIZE, GRID_SIZE);
				eventIcon.updateHitbox();
				eventIcon.EVENT_NAME = daName;
				eventIcon.value1 = eventValue1;
				eventIcon.value2 = eventValue2;
				eventIcon.x = Math.floor(daInfo * GRID_SIZE);
				eventIcon.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

				curRenderedEvents.add(eventIcon);
			}
		}
	}

	public var lastTime:Float = 0;

	var lastCount:Float = 0;
	var tweened:Bool = false;
	var textTween:FlxTween;

	function tweenTheText(alphaA:Float, alphaX:Float)
	{
		if (!tweened)
		{
			if (textTween != null)
				textTween.cancel();
			autoSaveText.alpha = alphaA;
			textTween = FlxTween.tween(autoSaveText, {alpha: alphaX}, 1, {
				onComplete: function(e:FlxTween)
				{
					textTween = null;
					autoSaveText.alpha = alphaX;
				}
			});
		}
	}

	var hitted:Bool = false;

	function checkChartFile(elapsed:Float)
	{
		if (CDevConfig.saveData.autosaveChart)
		{
			if (Paths.currentMod != "BASEFNF")
			{
				var time:Float = CDevConfig.saveData.autosaveChart_interval;
				if (time != -1 && !(lastTime >= time))
					lastTime += elapsed;
				if (time == -1)
				{
					autoSaveOnEveryAction = true;
					if (_every_action_save != _song)
					{
						createAutoSave();
					}
				}
				else
				{
					autoSaveOnEveryAction = false;
					if (lastTime >= time)
					{
						lastCount += elapsed;
						if (!hitted)
						{
							hitted = true;
							tweened = false;
							autoSaveText.text = "Autosaving...";
							autoSaveText.color = FlxColor.WHITE;
							tweenTheText(0, 1);
							tweened = true;
						}

						if (lastCount > 3)
						{
							createAutoSave();
						}
					}
				}
			}
		}

		if (_inital_state_song != _song)
		{
			notSaved = true;
		}
		else
		{
			notSaved = false;
		}
	}

	function createAutoSave()
	{
		hitted = false;
		_every_action_save = _song;
		lastTime = 0;
		lastCount = 0;
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			tweened = false;
			var path:String = Paths.modChartPath(_song.song + "/");
			if (FileSystem.exists(path))
			{
				File.saveContent(path + "~autosave.json", data);
				autoSaveText.text = "Saved.";
				autoSaveText.color = FlxColor.CYAN;
			}
			else
			{
				tweened = false;
				autoSaveText.text = "Failed to perform autosave.";
				autoSaveText.color = FlxColor.RED;
			}
			autoSaveText.alpha = 1;
			new FlxTimer().start(1, function(e:FlxTimer)
			{
				tweenTheText(1, 0);
				tweened = true;
			});
		}
	}

	function loadAutosaveJSON():String
	{
		var stringJSON:String = "";
		var path:String = Paths.modChartPath(_song.song + "/");
		if (FileSystem.exists(path + "~autosave.json"))
		{
			stringJSON = File.getContent(path + "~autosave.json");
			return stringJSON;
		}
		var butt:Array<PopUpButton> = [
			{
				text: "OK",
				callback: function()
				{
					closeSubState();
				}
			}
		];
		openSubState(new CDevPopUp("Error", "Couldn't find \"~autosave.json\" file on path: \"" + path + "\".", butt));
		return "";
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			banger: false,
			sectionNotes: [],
			sectionEvents: [],
			typeOfSection: 0,
			altAnim: false,
			p1AltAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		// FlxG.sound.play(Paths.sound('placeNote'), 0.6);
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
				curNoteObj = note;
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	private var lastNote:Note;

	function deleteNote(note:Note):Void
	{
		lastNote = note;
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == note.noteData + (note.mustPress != _song.notes[curSection].mustHitSection ? 0 : 4))
			{
				if(i == curSelectedNote) curSelectedNote = null;
				_song.notes[curSection].sectionNotes.remove(i);
				break;
			}
		}

		updateGrid();
	}

	function deleteEvent(a:ChartEvent):Void
	{
		for (i in _song.notes[curSection].sectionEvents)
		{
			trace(i[2]);
			trace(a.time);
			trace(Std.string((i[2] == a.time)) + '' + Std.string((i[1] % 4 == a.data)));
			if (i[2] == a.time && i[1] == a.data)
			{
				_song.notes[curSection].sectionEvents.remove(i);
			}
		}
		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	var pushed:Bool = false;

	private function addEvent():Void
	{
		var eventTime = getStrumTime(dummyArrow.y) + sectionStartTime();
		var eventData = Math.floor(FlxG.mouse.x / GRID_SIZE);

		_song.notes[curSection].sectionEvents.push([
			curSelectedEvent,
			eventData,
			eventTime,
			input_event_firstText.text,
			input_event_secondText.text
		]);
		updateGrid();
		autosaveSong();
	}

	private function addNote(?n:Note):Void
	{
		// FlxG.sound.play(Paths.sound('placeNote'), 0.3);
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		var noteType = selectedNoteType;

		if (n != null)
			_song.notes[curSection].sectionNotes.push([n.strumTime, n.noteData, n.sustainLength, n.noteType]);
		else
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid(true);
		updateNoteUI();

		autosaveSong();
	}

	var iconScale:Float = 1;

	function beatHitShit()
	{
		// trace(editingEvents);
		/*if (FlxG.sound.music.playing)
		{
			leftIcon.scale.x += 0.2;
			rightIcon.scale.x += 0.2;
			rightIcon.updateHitbox();
			leftIcon.updateHitbox();
		}*/
	}

	function stepHitShit()
	{
		if (FlxG.sound.music.playing)
		{
			if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}
	}

	function getStrumTime(yPos:Float):Float
	{
		if (usingDownscroll)
			return FlxMath.remapToRange(yPos, gridBG.y + gridBG.height, gridBG.y, 0, 16 * Conductor.stepCrochet);

		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		if (usingDownscroll)
			return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y + gridBG.height, gridBG.y);

		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function pasteFunction(prefix:String = ''):String
	{
		if (prefix.toLowerCase().endsWith('v'))
			prefix = prefix.substring(0, prefix.length - 1);

		var txt:String = prefix + lime.system.Clipboard.text.replace('\n', '');
		return txt;
	}

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function warningNotSaved(?call:Void->Void = null)
	{
		var butt:Array<PopUpButton> = [];
		if (call != null)
		{
			butt = [
				{
					text: "Save",
					callback: function()
					{
						saveLevel();
						call();
					}
				},
				{text: "Don't save", callback: call},
				{
					text: "Cancel",
					callback: function()
					{
						closeSubState();
					}
				}
			];
		}
		else
		{
			butt = [
				{text: "Save", callback: saveLevel},
				{
					text: "Don't save",
					callback: function()
					{
					}
				},
				{
					text: "Cancel",
					callback: function()
					{
						closeSubState();
					}
				}
			];
		}
		openSubState(new CDevPopUp("Warning!", "You haven't saved your song chart! If you continue, all your unsaved chart progress will be lost.", butt));
	}

	function loadJson(songg:String):Void
	{
		if (notSaved)
		{
			warningNotSaved(function()
			{
				PlayState.SONG = game.song.Song.loadFromJson(songg.toLowerCase(), songg.toLowerCase());
				FlxG.resetState();
			});
		}
		else
		{
			PlayState.SONG = game.song.Song.loadFromJson(songg.toLowerCase(), songg.toLowerCase());
			FlxG.resetState();
		}
	}

	function loadAutosave():Void
	{
		if (notSaved)
		{
			warningNotSaved(function()
			{
				if (!CDevConfig.saveData.autosaveChart)
				{
					PlayState.SONG = game.song.Song.parseJSONshit(FlxG.save.data.autosave);
					FlxG.resetState();
				}
				else
				{
					var json = loadAutosaveJSON();
					if (json != "")
					{
						PlayState.SONG = game.song.Song.parseJSONshit(json);
						FlxG.resetState();
					}
				}
			});
		}
		else
		{
			if (!CDevConfig.saveData.autosaveChart)
			{
				PlayState.SONG = game.song.Song.parseJSONshit(FlxG.save.data.autosave);
				FlxG.resetState();
			}
			else
			{
				var json = loadAutosaveJSON();
				if (json != "")
				{
					PlayState.SONG = game.song.Song.parseJSONshit(json);
					FlxG.resetState();
				}
			}
		}
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		notSaved = false;
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	/*private function saveEvents()
		{
			notSaved = false;
			var json = {
				"event": _song.songEvents
			};

			var data:String = Json.stringify(json);

			if ((data != null) && (data.length > 0))
			{
				_file = new FileReference();
				_file.addEventListener(Event.COMPLETE, onSaveComplete);
				_file.addEventListener(Event.CANCEL, onSaveCancel);
				_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
				_file.save(data.trim(), _song.song.toLowerCase() + ".json");
			}
	}*/
	function onSaveComplete(_):Void
	{
		notSaved = false;
		_inital_state_song = _song;
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
}
