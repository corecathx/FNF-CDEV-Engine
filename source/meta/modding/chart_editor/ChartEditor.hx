package meta.modding.chart_editor;

import game.cdev.engineutils.Discord.DiscordClient;
import meta.modding.char_editor.CharacterData.CharData;
import flixel.math.FlxMath;
import game.cdev.CDevPopUp;
import game.cdev.CDevPopUp.PopUpButton;
import sys.io.File;
import haxe.Json;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import game.song.Section.SwagSection;
import game.objects.HealthIcon;
import game.cdev.UIDropDown;
import game.objects.ChartEvent;
import game.objects.Note;
import game.Conductor;
import game.song.Song.SwagSong;
import game.cdev.log.GameLog;
import game.CoolUtil;

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.sound.FlxSound;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;

import meta.states.MusicBeatState;
import meta.states.PlayState;

import sys.FileSystem;

import haxe.io.Path;

import openfl.net.FileReference;

using StringTools;

// my attempt of making my own chart editor :))
// corecat from the future: i hate this.
class ChartEditor extends MusicBeatState {
    // Editor stuffs
    var grid_size:Int = 40;
    var curSection:Int = 0;
    var vocals:FlxSound;
    var noteNames:Array<String> = [];
    var _fileR:FileReference;
    var notSaved:Bool = false;

    // Main Editor usage
    var gridGroups:FlxSpriteGroup;
    //var gridBG:FlxSprite;
    var gridDivider:FlxSprite;
    var _song:SwagSong;
    var _last_song_state:SwagSong;

    // Strum Notes
    var opStrumGroup:FlxSpriteGroup;
    var plStrumGroup:FlxSpriteGroup;

    // Objects like notes, events, and sus
    var noteGroup:FlxTypedGroup<Note>;
    var noteSustains:FlxTypedGroup<Note>;
    var eventGroup:FlxTypedGroup<ChartEvent>;
    var noteLabels:FlxTypedGroup<FlxText>;

    var opIcon:HealthIcon;
    var plIcon:HealthIcon;

    var camFollow:FlxObject;

    // Main UI objects
    var infoText:FlxText;
    var strumLine:FlxSprite;
    var noteHighlight:FlxSprite;
    var uiBox:FlxUITabMenu;
    var evntInf:EventInformation;
    var autoSaveText:FlxText;

    var tipTextList:Array<FlxText> = [];

    // Main UI Box stuffs, idk //
    var vocVol:Float = 1;
	var insVol:Float = 0.7;

    // SONG UI [BOX]
    var player1DropDown:UIDropDown;
	var player2DropDown:UIDropDown;
	var gfDropDown:UIDropDown;
	var stageDropDown:UIDropDown;
	var songTitleUI:FlxUIInputText;

    // SECTION UI [BOX]
    var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;
	var check_altAnim2:FlxUICheckBox;
	var check_bangerPart:FlxUICheckBox;

    // NOTE UI [BOX]
	var stepperSusLength:FlxUINumericStepper;
	var noteDropDown:UIDropDown;
	var selectedNoteType:String = "Default Note";
	var selectedNotePos:Int = -1;
	var noteParam1:FlxUIInputText;
	var noteParam2:FlxUIInputText;

    // EVENT UI [BOX]
	var eventDropDown:UIDropDown;
	var jsonEvents:Array<String> = [];
	var input_event_firstText:FlxUIInputText;
	var input_event_secondText:FlxUIInputText;
	var desc:FlxText;
	var curSelectedEvent:String = '';

    // CHARTING UI [BOX]
    var muteInst:Bool = false;
	var muteVocal:Bool = false;
	var muteHitsound:Bool = true;
	var usingDownscroll:Bool = false;
	var speedMod:Float = 1;
    
    public function new(?chart:SwagSong){
		super();
		if (chart != null) {
			_song = chart;
		}
	}

    override function create(){
        Paths.destroyLoadedImages(false);
		DiscordClient.changePresence("Chart Editor", null, null, true);

		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;

        var bgShit:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('aboutMenu'));
		bgShit.alpha = 0.1;
		bgShit.scrollFactor.set();
		bgShit.screenCenter();
		bgShit.color = FlxColor.CYAN;
		add(bgShit);

        createMainUI();

        camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

        if (_song == null && PlayState.SONG != null) {
			_song = PlayState.SONG;
		} else if (_song == null && PlayState.SONG == null) {
			_song = CDevConfig.utils.CHART_TEMPLATE;
		}
        _last_song_state = _song;

        addSection();
        loadSong(_song.song);
        checkSectionEvent(true);
        
        createSecUI();

        noteNames = [];
		var tempLoaded:Array<String> = Note.getNoteList();

		for (i in Note.default_notetypes) noteNames.push(i);
		for (i in tempLoaded) noteNames.push(i);

        addBoxUIs();

        loadDaNotes();

		FlxG.camera.follow(camFollow);
        super.create();
    }

    var warnOnce:Bool = false;
    function createMainUI(){
        gridGroups = new FlxSpriteGroup();
        gridGroups.alpha = 0.7;
        add(gridGroups);

		var stuffs:Int = 0;
		var createThese:Array<FlxSprite> = [];
        var last:FlxSprite = null;
		for (i in 0..._song.notes.length){
			var lis:Dynamic = _song.notes[i].lengthInSteps;
			if (lis == null){
				lis = 16;
				if (!warnOnce)
					GameLog.warn("JSON of this chart doesn't have lengthInSteps.");
				warnOnce = true;
			} else if (lis == 0){
				lis = 16;
			}

			stuffs += lis;
            var ea:FlxSprite = FlxGridOverlay.create(grid_size, grid_size, grid_size * 8, Std.int(grid_size * lis));
            ea.y = (last == null ? 0 : last.y+last.height);
            gridGroups.add(ea);
            last = ea;

            var newS:FlxSprite = new FlxSprite(0,ea.y + ea.height).makeGraphic(Std.int(grid_size * 8), 2, FlxColor.BLACK);
			createThese.push(newS);
		}

        opStrumGroup = new FlxSpriteGroup();
        opStrumGroup.visible = false;

        plStrumGroup = new FlxSpriteGroup();
		plStrumGroup.visible = false;

		gridDivider = new FlxSprite(gridGroups.x + gridGroups.width / 2).makeGraphic(2, Std.int(gridGroups.height), FlxColor.BLACK);
		add(gridDivider);

		for (o in createThese){
			add(o);
		}
        noteGroup = new FlxTypedGroup<Note>();
        add(noteGroup);
		noteSustains = new FlxTypedGroup<Note>();
        add(noteSustains);
		eventGroup = new FlxTypedGroup<ChartEvent>();
        add(eventGroup);
		noteLabels = new FlxTypedGroup<FlxText>();
        add(noteLabels);

        opIcon = new HealthIcon(_song.player1);
        opIcon.scrollFactor.set(1, 0);
        add(opIcon);

		plIcon = new HealthIcon(_song.player2);
		plIcon.scrollFactor.set(1, 0);
		add(plIcon);
        plIcon.flipX = true;

        updateIconProperties();
        
        for (i in 0...4)
        {
            var theStrum:StrumNote = new StrumNote(gridGroups.x + (40 * i), 50, grid_size, grid_size, i);
            theStrum.updateHitbox();
            opStrumGroup.add(theStrum);
        }
        for (i in 0...4)
        {
            var theStrum:StrumNote = new StrumNote(gridGroups.x + 160 + (40 * i), 50, grid_size, grid_size, i);
            theStrum.updateHitbox();
            plStrumGroup.add(theStrum);
        }
        
        add(noteGroup);
        add(noteSustains);
        add(eventGroup);
        add(noteLabels);
        add(opStrumGroup);
        add(plStrumGroup);

        evntInf = new EventInformation(0, 0, "", "", "");
		evntInf.scrollFactor.set();
        add(evntInf);

		autoSaveText = new FlxText(10, FlxG.height - 25, -1, "Autosaving...", 22);
		autoSaveText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		autoSaveText.alpha = 0;
		autoSaveText.scrollFactor.set();
		autoSaveText.borderSize = 2;
		add(autoSaveText);
	}

    function createSecUI(){
		infoText = new FlxText(20, 50, -1, "", 16);
		infoText.setFormat('VCR OSD Mono', 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 1;
		infoText.scrollFactor.set();
		add(infoText);

        strumLine = new FlxSprite(0, 50).makeGraphic(grid_size * 8, 4);
		add(strumLine);

        noteHighlight = new FlxSprite().makeGraphic(grid_size, grid_size);
		add(noteHighlight);

        uiBox = new FlxUITabMenu(null, [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Events", label: 'Events'},
			{name: "Note", label: 'Note'},
			{name: "Charting", label: 'Charting'}
		], true);
		uiBox.resize(300, 400);
		uiBox.x = FlxG.width - 320;
		uiBox.y = 20;

		var splittedTextArray:Array<String> = "Charting Controls:
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
		\nALT + SHIFT + [R] - Clear all events in this chart.".split('\n');

		for (i in 0...splittedTextArray.length)
		{
			var tipsTxt:FlxText = new FlxText(20, uiBox.y + uiBox.height + -30, 0, splittedTextArray[i], 16);
			tipsTxt.y += i * 12;
			tipsTxt.setFormat('VCR OSD Mono', 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			tipsTxt.scrollFactor.set();
			tipsTxt.borderSize = 2;
			add(tipsTxt);
			tipTextList.push(tipsTxt);
		}
		add(uiBox);
    }

    function addBoxUIs(){
        addSongUI();
		addSectionUI();
		addNoteUI();
		addChartingUI();
		addEventUI();
    }

	function addSongUI():Void
	{
		songTitleUI = new FlxUIInputText(10, 10, 70, _song.song, 8);

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

		var tab_group_song = new FlxUI(null, uiBox);
		tab_group_song.name = "Song";
		tab_group_song.add(songTitleUI);

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

		uiBox.addGroup(tab_group_song);
		uiBox.scrollFactor.set();
	}

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, uiBox);
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
				//updateGrid();
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

		uiBox.addGroup(tab_group_section);
	}

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, uiBox);
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

		noteParam1 = new FlxUIInputText(10, noteDropDown.y + 70, 200, "");
		noteParam2 = new FlxUIInputText(10, noteDropDown.y + 100, 200, "");
		tab_group_note.add(noteParam1);
		tab_group_note.add(noteParam2);
		tab_group_note.add(new FlxText(10, noteParam1.y - 15, uiBox.width - 20, 'Value 1', 8));
		tab_group_note.add(new FlxText(10, noteParam2.y - 15, uiBox.width - 20, 'Value 2', 8));
		tab_group_note.add(new FlxText(10, noteParam1.y - 30, uiBox.width - 20, '===Parameters===', 8).setFormat(null, 8, FlxColor.WHITE, CENTER));

		tab_group_note.add(ivText);
		tab_group_note.add(steppersusTxt);
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(noteDropDown);

		uiBox.addGroup(tab_group_note);
	}

	function addEventUI():Void
	{
		var tab_group_charting = new FlxUI(null, uiBox);
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
		tab_group_charting.add(new FlxText(10, input_event_firstText.y - 15, uiBox.width - 20, 'Value 1', 8));
		tab_group_charting.add(new FlxText(10, input_event_secondText.y - 15, uiBox.width - 20, 'Value 2', 8));

		desc = new FlxText(10, input_event_secondText.y + input_event_secondText.height + 15, FlxG.width, "", 8);
		tab_group_charting.add(desc);

		tab_group_charting.add(eventDropDown);
		uiBox.addGroup(tab_group_charting);
	}

	function addChartingUI():Void
	{
		var tab_group_charting = new FlxUI(null, uiBox);
		tab_group_charting.name = 'Charting';

		var stepperVoicesVol:FlxUINumericStepper = new FlxUINumericStepper(10, 30, 0.1, 1, 0.0, 1.0, 1);
		stepperVoicesVol.value = vocVol;
		stepperVoicesVol.name = 'voices_Vol';

		var vvText:FlxText = new FlxText(stepperVoicesVol.x + 60, stepperVoicesVol.y, FlxG.width, "Vocal Volume", 8);

		var stepperInstVol:FlxUINumericStepper = new FlxUINumericStepper(10, 45, 0.1, 0.7, 0.0, 1.0, 1);
		stepperInstVol.value = insVol;
		stepperInstVol.name = 'inst_Vol';

		var ivText:FlxText = new FlxText(stepperInstVol.x + 60, stepperInstVol.y, FlxG.width, "Instrumental Volume", 8);

		var sliderSpeed:FlxUISlider = new FlxUISlider(this, "speedMod", 10, 60, 0.1, 5, Std.int(uiBox.width - 30), 20, 5, FlxColor.WHITE, FlxColor.WHITE);
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

			//updateGrid(true);
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
			opStrumGroup.visible = check_show_strum.checked;
			plStrumGroup.visible = check_show_strum.checked;
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

		uiBox.addGroup(tab_group_charting);
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
        
        vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
        FlxG.sound.list.add(vocals);

        FlxG.sound.music.pause();
        vocals.pause();

        Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);
        /*FlxG.sound.music.onComplete = function()
            {
                vocals.pause();
                vocals.time = 0;
                FlxG.sound.music.pause();
                FlxG.sound.music.time = 0;
                changeSection();
        };*/
    }

    function clearSection():Void
    {
        _song.notes[curSection].sectionNotes = [];
    }

	function checkSectionEvent(checkAll:Bool = false)
    {
        var maxLength:Int = _song.notes.length;
        for (e in 0...maxLength){
            var index:Int = (checkAll?e:curSection);
            var nd = _song.notes[index];
            var n  = nd.sectionEvents;
            if (n == null){
                var sec:SwagSection = {
                    lengthInSteps: nd.lengthInSteps,
                    bpm: _song.bpm,
                    changeBPM: nd.changeBPM,
                    mustHitSection: nd.mustHitSection,
                    banger: nd.banger,
                    sectionNotes: nd.sectionNotes,
                    sectionEvents: [],
                    typeOfSection: nd.typeOfSection,
                    altAnim: nd.altAnim,
                    p1AltAnim: nd.p1AltAnim
                };
                _song.notes[index] = sec;
            }
            if (!checkAll) break;
        }

        for (i in 0..._song.notes.length)
		{
            for (o in 0..._song.notes[i].sectionNotes.length){
                if (!_song.notes[i].mustHitSection) continue;
    			var note = _song.notes[i].sectionNotes[o];
			    note[1] = (note[1] + 4) % 8;
			    _song.notes[i].sectionNotes[o] = note;       
            }

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
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        var upScrollControl = [FlxG.keys.pressed.W, FlxG.keys.pressed.UP];
        var downScrollControl = [FlxG.keys.pressed.S, FlxG.keys.pressed.DOWN];

        if (FlxG.sound.music != null){
            if (FlxG.sound.music.playing)
                Conductor.songPosition = FlxG.sound.music.time;

            if (FlxG.keys.justPressed.SPACE){
                if (FlxG.sound.music.playing){
                    vocals.time = FlxG.sound.music.time;
                    FlxG.sound.music.pause();
                    vocals.pause();
                }else {
                    FlxG.sound.music.play();
                    vocals.play();
                }
            }
        }
        updateHeads();
        curSection = Math.floor(curBeat / 4);

        strumLine.y = ((grid_size * 16) * ((Conductor.songPosition)/(Conductor.crochet*4)));
        updateIconProperties();

        if (upScrollControl.contains(true) || downScrollControl.contains(true)){
            Conductor.songPosition += (downScrollControl.contains(true) ? Conductor.stepCrochet : -Conductor.stepCrochet) / 4;
            FlxG.sound.music.time = Conductor.songPosition;
            vocals.time = FlxG.sound.music.time;
        }

        if (FlxG.mouse.x > gridGroups.x
			&& FlxG.mouse.x < gridGroups.x + gridGroups.width
			&& FlxG.mouse.y > gridGroups.y
			&& FlxG.mouse.y < gridGroups.y + gridGroups.height)
		{
			noteHighlight.visible = true;
			noteHighlight.x = Math.floor(FlxG.mouse.x / grid_size) * grid_size;
			if (FlxG.keys.pressed.SHIFT)
				noteHighlight.y = FlxG.mouse.y;
			else
				noteHighlight.y = Math.floor(FlxG.mouse.y / grid_size) * grid_size;
		}
		else
		{
			noteHighlight.visible = false;
		}

		if (FlxG.keys.justPressed.ENTER) FlxG.switchState(new PlayState());

		updateTheText();

		camFollow.setPosition((gridGroups.x + gridGroups.width) / 2, strumLine.y);
    }

    function updateIconProperties()
    {
        var sizeUpdate = 0.8-((Conductor.songPosition % (Conductor.crochet))/Conductor.crochet)*0.2;
        opIcon.scale.set(sizeUpdate, sizeUpdate);
        opIcon.updateHitbox();
        opIcon.setPosition(gridGroups.x - (150 / 2) - ((150 / 2) * opIcon.scale.x) - 40, gridGroups.y - 10);

        plIcon.scale.set(sizeUpdate, sizeUpdate);
        plIcon.updateHitbox();
        plIcon.setPosition((gridGroups.x + (grid_size * 4)) + (150 / 2) + ((150 / 2) * plIcon.scale.x) + 40, gridGroups.y - 10);
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
	function updateHeads():Void
    {
        var p1Icon:String = getIconFromCharJSON(_song.player1);
        var p2Icon:String = getIconFromCharJSON(_song.player2);
        opIcon.changeDaIcon(p2Icon);
        plIcon.changeDaIcon(p1Icon);
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

	function updateTheText()
	{
		infoText.text = '-=Song Info=-'
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

    function loadDaNotes(){
        var virtSec:Int = 0;
        for (oo in 0..._song.notes.length){
            var sectionInfo:Array<Dynamic> = _song.notes[oo].sectionNotes;
            var sectionEv:Array<Dynamic> = _song.notes[oo].sectionEvents;
    
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
                note.rawNoteData = daNoteInfo;
                note.sustainLength = daSus;
                note.setGraphicSize(grid_size, grid_size);
                note.updateHitbox();
                note.disableScript();
                note.x = Math.floor(daNoteInfo * grid_size);
                //var eae = FlxMath.remapToRange(((daStrumTime) % (Conductor.stepCrochet * _song.notes[oo].lengthInSteps)), 0, 16 * Conductor.stepCrochet, gridGroups.y + gridGroups.height, gridGroups.y);
                note.y = Math.floor(((grid_size) * ((daStrumTime)/(Conductor.stepCrochet))));//Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
                noteGroup.add(note);
    
                /*var typePos:Int = getNoteTypePos(daType);
    
                if (typePos != -1)
                {
                    var newShit:FlxText = new FlxText(0, 0, 0, Std.string(typePos), 32);
                    newShit.setFormat("VCR OSD Mono", 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
                    // newShit.setGraphicSize(GRID_SIZE);
                    newShit.borderSize = 1.5;
                    add(newShit);
                    noteLabels.add(newShit);
                    CDevConfig.utils.moveToCenterOfSprite(newShit, note);
                }*/
    
                if (daSus > 0)
                {
                    var nSus:Note = new Note(daStrumTime+Conductor.stepCrochet,daNoteInfo%4, null, true);
                    nSus.noteType = daType;
                    nSus.rawNoteData = daNoteInfo;
                    nSus.setGraphicSize(grid_size/2.5, Std.int(grid_size*((daSus-(Conductor.stepCrochet*2)) / Conductor.stepCrochet)));
                    nSus.updateHitbox();
                    nSus.disableScript();
                    nSus.x = Math.floor(daNoteInfo * grid_size) + ((grid_size/2)-(nSus.width/2));
                    nSus.y = Math.floor(note.y + grid_size);
                    noteSustains.add(nSus);
                    var susold = nSus;
                    var nSus:Note = new Note(Conductor.stepCrochet,daNoteInfo%4, null, true);
                    nSus.noteType = daType;
                    nSus.rawNoteData = daNoteInfo;
                    switch (daNoteInfo%4)
                    {
                        case 2:
                            nSus.animation.play('greenholdend');
                        case 3:
                            nSus.animation.play('redholdend');
                        case 1:
                            nSus.animation.play('blueholdend');
                        case 0:
                            nSus.animation.play('purpleholdend');
                    }
                    nSus.scale.y = 1;
                    nSus.flipY = false;
                    nSus.setGraphicSize(grid_size/2.6, Std.int(grid_size/1.8));
                    nSus.updateHitbox();
                    nSus.disableScript();
                    nSus.x = Math.floor(daNoteInfo * grid_size) + ((grid_size/2)-(nSus.width/2));
                    nSus.y = Math.floor(susold.y + susold.height);
                    noteSustains.add(nSus);
                }
            }
            virtSec += 1;
        }
    }

	function loadJson(songg:String):Void
    {
        /*if (notSaved)
        {
            warningNotSaved(function()
            {
                PlayState.SONG = game.song.Song.loadFromJson(songg.toLowerCase(), songg.toLowerCase());
                FlxG.resetState();
            });
        }
        else*/
        {
            _song = game.song.Song.loadFromJson(songg.toLowerCase(), songg.toLowerCase());
            FlxG.switchState(new ChartEditor(_song));
            //FlxG.resetState();
        }
    }

    function loadAutosave():Void
    {
        /*if (notSaved)
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
        else*/
        {
            if (!CDevConfig.saveData.autosaveChart)
            {
                _song = game.song.Song.parseJSONshit(FlxG.save.data.autosave);
                FlxG.switchState(new ChartEditor(_song));
            }
            else
            {
                var json = loadAutosaveJSON();
                if (json != "")
                {
                    _song = game.song.Song.parseJSONshit(json);
                    FlxG.switchState(new ChartEditor(_song));
                }
            }
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

    private function saveLevel()
    {
        notSaved = false;
        var json = {
            "song": _song
        };

        var data:String = Json.stringify(json, "\t");

        if ((data != null) && (data.length > 0))
        {
            _fileR = new FileReference();
            _fileR.addEventListener(Event.COMPLETE, onSaveComplete);
            _fileR.addEventListener(Event.CANCEL, onSaveCancel);
            _fileR.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _fileR.save(data.trim(), _song.song.toLowerCase() + ".json");
        }
    }

    function onSaveComplete(_):Void
    {
        notSaved = false;
        _last_song_state = _song;
        _fileR.removeEventListener(Event.COMPLETE, onSaveComplete);
        _fileR.removeEventListener(Event.CANCEL, onSaveCancel);
        _fileR.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _fileR = null;
        FlxG.log.notice("Successfully saved LEVEL DATA.");
    }

    function onSaveCancel(_):Void
    {
        _fileR.removeEventListener(Event.COMPLETE, onSaveComplete);
        _fileR.removeEventListener(Event.CANCEL, onSaveCancel);
        _fileR.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _fileR = null;
    }

    function onSaveError(_):Void
    {
        _fileR.removeEventListener(Event.COMPLETE, onSaveComplete);
        _fileR.removeEventListener(Event.CANCEL, onSaveCancel);
        _fileR.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _fileR = null;
        FlxG.log.error("Problem saving Level data");
    }
}