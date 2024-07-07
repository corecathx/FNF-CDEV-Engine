package meta.modding.chart_editor;

import game.objects.ChartEvent;
import game.cdev.objects.CDevList;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import meta.substates.StageListSubstate;
import meta.substates.CharacterListSubstate;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUIButton;
import game.cdev.UIDropDown;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIGroup;
import flixel.group.FlxGroup;
import game.cdev.objects.CDevInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.util.FlxSort;
import game.cdev.objects.CDevTooltip;
import game.cdev.objects.CDevChartUI;
import flixel.graphics.frames.FlxAtlasFrames;
import game.objects.Note;
import game.objects.StrumArrow;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import meta.modding.char_editor.CharacterData.CharData;
import sys.io.File;
import sys.FileSystem;
import game.objects.FunkinBar;
import game.objects.HealthIcon;
import meta.states.PlayState;
import flixel.group.FlxSpriteGroup;
import game.song.Song;
import game.cdev.song.CDevChart;
import game.cdev.SongPosition;

using StringTools;

// I might add more event editing modes sooner if i got ideas lol
enum abstract EventEditMode(Int) {
    //var SIDEBAR = 0;
    var HIDDEN = 0;
    var VISIBLE = 1;
}

class ChartEditor extends MusicBeatState {
    // Public stuffs
    public static var current:ChartEditor = null;
    public static var grid_size:Int = 40;
    public static var separator_width:Int = 4;
    public static var note_texture:FlxAtlasFrames = null;

    // Sound Objects.
    var playerVoice:FlxSound;
    var opponentVoice:FlxSound; 
    
    // Chart related stuffs.
    public var chart:CDevChart;
    public var chart_difficulty:String = "normal"; // Set "normal" by default.

	var _inital_state_song:CDevChart; // first state of your song before it gets modified.
	var _every_action_save:CDevChart; // hell

    var fileSaved:Bool = true; // checking if the player has saved the chart or not
	var everyAction_autosave:Bool = false;
	var autosave_overlay:FlxText;

    // Keyboard input fix
    var writing_enabled:Bool = false;

    // Used for Reflect in CharacterList & StageList Substate.
    var character_opponent:String = "dad";
    var character_player:String = "bf";
    var character_thirdchar:String = "gf";
    var current_stage:String = "stage";

    // Things that's visible to da human eye:
    var grid:ChartingArea;
    var hitLine:FlxSprite;
    var bgArt:FlxSprite;
    var beatDividers:FlxSpriteGroup;
    var infoTxt:FlxText;
    var timeBar:FunkinBar;

    var opStrum:FlxTypedGroup<StrumArrow>;
    var plStrum:FlxTypedGroup<StrumArrow>;

    var opIcon:HealthIcon;
    var plIcon:HealthIcon;

    var menu_ui:CDevChartUI;
    var tooltip_overlay:CDevTooltip;

    var menu_tooltip:Array<Dynamic> = [];
    var metronome_icon:FlxSprite;

    // Groups like the note group and other stuffs
    var rendered_notes:FlxTypedGroup<ChartNote>;
    var rendered_events:FlxTypedGroup<ChartEvent>;

    var note_sus_lengths:Array<ChartNote> = [];
    var flash_on_step:Array<Bool> = [ // erm
        false,false,false,false,
        false,false,false,false
    ];
    var hitted_notes:Array<ChartNote> = [];

    // Used by Player's interactions.
    var dummyNote:ChartNote;
    var groupSelSprite:FlxUI9SliceSprite;

    //// Note Editing 
    // Time, Data, Sustain, Type, Args. (Only modify Type and Args (dumb))
    var _noteTypes:Array<String> = [];
    var _spawn_noteType:String = "Default Note";
    var _spawn_noteType_id:Int = 0;
    var _spawn_noteArgs:Array<String> = ["",""];

    //// Event Editing
    var _event_mode:EventEditMode = HIDDEN;

    public function new(?fnfChart:CDevChart, ?difficulty:String){
        if (fnfChart == null) fnfChart = CDevConfig.utils.CDEV_CHART_TEMPLATE;//CDevConfig.utils.CHART_TEMPLATE;
        loadChart(fnfChart, difficulty);
        super();
    }

    function loadChart(fnfChart:CDevChart, ?diff:String){
        chart = fnfChart;
        if (diff != null)
            chart_difficulty = diff;

        character_opponent = chart.data.opponent;
        character_player = chart.data.player;
        character_thirdchar = chart.data.third_char; 
        current_stage = chart.data.stage;
    }
    
    override function create(){
        current = this;
        note_texture = Paths.getSparrowAtlas("notes/NOTE_assets"); // cache the note texture first
        FlxG.mouse.visible = true;
        persistentUpdate = false;

        loadNTList(); // Load every note type first.

        loadSong(chart.info.name);
        loadUI();
        loadNotes();

        FlxG.camera.follow(hitLine, LOCKON);
        FlxG.camera.targetOffset.y = 150;
        super.create();
    }

    function loadNTList() {
		_noteTypes = [];
		for (i in Note.default_notetypes) _noteTypes.push(i);
		for (i in Note.getNoteList()) _noteTypes.push(i);
    }



    function loadSong(sogn:String){
        if (FlxG.sound.music != null)
        {
            FlxG.sound.music.stop();
            if (playerVoice != null) playerVoice.stop();
        }

        FlxG.sound.playMusic(Paths.inst(sogn));
        FlxG.sound.music.pause();

        playerVoice = CDevConfig.utils.loadVoice(sogn);
        opponentVoice = CDevConfig.utils.loadVoice(sogn, "opponent");

        Conductor.changeBPM(chart.info.bpm);
        Conductor.changeTimeSignature(chart.info.time_signature[0], chart.info.time_signature[1]);
        setAllSoundTime(0);
    }

    function setAllSoundTime(time:Float = 0) {
        playerVoice.time = opponentVoice.time = FlxG.sound.music.time = Conductor.songPosition = time;
    }

    function loadUI(){
        bgArt = new FlxSprite().loadGraphic(Paths.image("aboutMenu"));
        bgArt.color = CDevConfig.utils.CDEV_ENGINE_BLUE;
        bgArt.scale.set(1,1);
        bgArt.antialiasing = CDevConfig.saveData.antialiasing;
        bgArt.screenCenter();
        bgArt.scrollFactor.set(0,0);
        bgArt.active = false;
        bgArt.alpha = 0.3;
        add(bgArt);

        grid = new ChartingArea();
        grid.init();
        grid.screenCenter(X);
        grid.alpha = 1;
        grid.height = getYFromTime(FlxG.sound.music.length);
        add(grid);

        createBeatDividers();

        rendered_notes = new FlxTypedGroup<ChartNote>();
        add(rendered_notes);

        rendered_events = new FlxTypedGroup<ChartEvent>();
        add(rendered_events);

        hitLine = new FlxSprite().makeGraphic(Std.int(grid.width),5,FlxColor.WHITE);
        hitLine.y = getYFromTime(0);
        hitLine.x = grid.x;
        hitLine.active = false;
        add(hitLine);

        dummyNote = new ChartNote();
        dummyNote.asDummyNote = true; // wow, so smart
        dummyNote.init([0,0,0,"Default Note", ["",""]],false);
        dummyNote.alpha = 0.7;
        add(dummyNote);

        groupSelSprite = new FlxUI9SliceSprite(0,0,Paths.image("ui/select_block","shared"),new openfl.geom.Rectangle(0,0,16,16), [3, 3, 10, 10]);
		groupSelSprite.visible = false;
        groupSelSprite.alpha = 0.5;
		add(groupSelSprite);

        createStrumNotes();

        opIcon = new HealthIcon(chart.data.opponent);
        opIcon.scrollFactor.set(0, 0);
        add(opIcon);

		plIcon = new HealthIcon(chart.data.player);
		plIcon.scrollFactor.set(0, 0);
		add(plIcon);
        plIcon.flipX = true;

        updateIconProperties();

        infoTxt = new FlxText(0,0,-1,"",14);
        infoTxt.setFormat(FunkinFonts.CONSOLAS, 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        infoTxt.scrollFactor.set();
        add(infoTxt);

        timeBar = new FunkinBar(0,0,"healthBar", ()->{return (Conductor.songPosition / FlxG.sound.music.length);}, 0, 1);
        timeBar.setColors(0xFF005FAD, 0xFF242424);
        timeBar.angle = 90;
        timeBar.scrollFactor.set();
        add(timeBar);

        metronome_icon = new FlxSprite();
        metronome_icon.frames = Paths.getSparrowAtlas("ui/metronome", "shared");
        metronome_icon.animation.addByPrefix("left","beatLeft",24,false);
        metronome_icon.animation.addByPrefix("right","beatRight",24,false);
        metronome_icon.animation.play("left",true);
        metronome_icon.scrollFactor.set();
        metronome_icon.antialiasing = CDevConfig.saveData.antialiasing;
        metronome_icon.scale.set(0.8,0.8);
        metronome_icon.updateHitbox();
        add(metronome_icon);

        menu_ui = new CDevChartUI(0,0, [
            ["file", "Access file-related actions.", menu_createFileUI], 
            ["edit", "Chart editing related actions.", menu_createEditUI], 
            ["view", "Adjust the editor's interface.", menu_createViewUI], 
            ["playtest", "Test your chart.", menu_createPlaytestUI], 
            ["help", "Keybinds / Editor controls.", menu_createHelpUI]
        ]);
        menu_ui.scrollFactor.set();
        menu_ui.setPosition((FlxG.width - menu_ui.width)-20,(FlxG.height - menu_ui.height)-20);
        add(menu_ui);

		autosave_overlay = new FlxText(10, FlxG.height - 25, -1, "Autosaving...", 22);
		autosave_overlay.setFormat(FunkinFonts.CONSOLAS, 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		autosave_overlay.alpha = 0;
		autosave_overlay.scrollFactor.set();
		autosave_overlay.borderSize = 2;
		add(autosave_overlay);

        for (i in menu_ui.getListStuff()) menu_tooltip.push(i);

        tooltip_overlay = new CDevTooltip();
        tooltip_overlay.scrollFactor.set();
        add(tooltip_overlay);
    }

    // Save Button
    var buttn_new:FlxUIButton;
    var buttn_open:FlxUIButton;
    var buttn_save:FlxUIButton;
    var buttn_saveAs:FlxUIButton;
    // Song Name
    var label_songname:FlxText;
    var input_songname:CDevInputText;
    // Composer
    var label_composer:FlxText;
    var input_composer:CDevInputText;
    // BPM
    var label_bpm:FlxText;
    var stepr_bpm:FlxUINumericStepper;
    // Scroll Speed
    var label_scrspd:FlxText;
    var stepr_scrspd:FlxUINumericStepper;
    // Character: DAD (buttn = Button)
    var label_dadchar:FlxText;
    var buttn_dadchar:FlxUIButton;
    // Character: BF
    var label_bfchar:FlxText;
    var buttn_bfchar:FlxUIButton;
    // Character: GF / 3rdChar
    var label_thirdchar:FlxText;
    var buttn_thirdchar:FlxUIButton;
    // Stage
    var label_stage:FlxText;
    var buttn_stage:FlxUIButton;
    // Note Skin
    var label_noteskin:FlxText;
    var input_noteskin:CDevInputText;
    // Reload Music
    var buttn_reloadMusic:FlxUIButton;
    // Reload Chart File
    var buttn_reloadChart:FlxUIButton;
    // Load Autosave
    var buttn_autosave:FlxUIButton;
    function menu_createFileUI(parent:FlxSpriteGroup){
        var grp:FlxSpriteGroup = new FlxSpriteGroup();
        var font = FunkinFonts.CONSOLAS;

        var text:FlxText = new FlxText(0,0,-1,"File", 18);
        text.font = FunkinFonts.CONSOLAS;
        grp.add(text);

        buttn_new = new FlxUIButton(text.x, text.y + text.height + 2, "New", function()
        {
            CDevPopUp.open(this, "Prompt", "Are you sure? Any unsaved progress will be lost.", [
                {text: "CANCEL", callback:()->closeSubState()},
                {text: "OK", callback:()->FlxG.switchState(new ChartEditor())}
            ], false, true);
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_new.resize(((360/2)-47), 20);
        buttn_new.label.size = 14;
        buttn_new.label.font = font;
        buttn_new.label.color = FlxColor.WHITE;
        grp.add(buttn_new);

        buttn_open = new FlxUIButton(buttn_new.x + buttn_new.width + 47, buttn_new.y, "Open", function()
        {
            saveUsingFReference();
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_open.resize(((360/2))-47, 20);
        buttn_open.label.size = 14;
        buttn_open.label.font = font;
        buttn_open.label.color = FlxColor.WHITE;
        grp.add(buttn_open);

        buttn_save = new FlxUIButton(text.x, buttn_new.y + buttn_new.height + 2, "Save", function()
        {
            var path:String = Paths.mods('${Paths.currentMod}/data/charts/${chart.info.name}/');
            trace("Save Path:" + path);
            if (FileSystem.exists(path) && FileSystem.isDirectory(path)){
                CDevPopUp.open(this, "Info", "Are you sure?\nSave path: "+path, [
                    {
                        text: "OK", 
                        callback:()->{
                            var jString:String = Json.stringify(chart, "\t");
                            File.saveContent(path+chart.info.name+".cdc", jString);
                        }
                    },
                    {
                        text:"CANCEL",
                        callback:()->{
                            closeSubState();
                        }
                    }
                ], false, true);
            } else {
                CDevPopUp.open(this, "Info", "We couldn't find existing chart folder for this song: "+path+"\nWe'll continue saving your chart but please specify where to save this song's chart.", [{text: "OK", callback:()->{saveUsingFReference();}}], false, true);
            }
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_save.resize(((360/2)-47), 20);
        buttn_save.label.size = 14;
        buttn_save.label.font = font;
        buttn_save.label.color = FlxColor.WHITE;
        grp.add(buttn_save);

        buttn_saveAs = new FlxUIButton(buttn_save.x + buttn_save.width + 47, buttn_save.y, "Save As", function()
        {
            saveUsingFReference();
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_saveAs.resize(((360/2))-47, 20);
        buttn_saveAs.label.size = 14;
        buttn_saveAs.label.font = font;
        buttn_saveAs.label.color = FlxColor.WHITE;
        grp.add(buttn_saveAs);

        // Straight up copypasted

        // Song Name //
        label_songname = new FlxText(0,buttn_saveAs.y + buttn_saveAs.height + 10,100,"Song Name",14);
        label_songname.font = font;

        input_songname = new CDevInputText(0, label_songname.y+label_songname.height+2, Std.int((360/2) - 47), chart.info.name, 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
        input_songname.font = font;
        input_songname.size = label_songname.size;
        input_songname.onTextChanged = (nText:String) -> {
            chart.info.name = nText;
        }

        // Composer //
        label_composer = new FlxText(0,input_songname.y + input_songname.height + 2,100,"Composer",14);
        label_composer.font = font;

        input_composer = new CDevInputText(0, label_composer.y+label_composer.height+2, Std.int((360/2) - 47), chart.info.composer, 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
        input_composer.font = font;
        input_composer.size = label_composer.size;
        input_composer.onTextChanged = (nText:String) -> {
            chart.info.composer = nText;
        }

        // BPM // 
        label_bpm = new FlxText(label_songname.x+input_songname.width+20,label_songname.y,100,"BPM",14);
        label_bpm.font = font;
        
        var tinpt_bpm = new CDevInputText(0, 0, Std.int((360/2) - 47)-label_composer.size*2, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
        tinpt_bpm.font = font;
        tinpt_bpm.size = label_composer.size;
        tinpt_bpm.onTextChanged = (nText:String) -> {
            chart.info.bpm = Std.parseFloat(nText);
        }

        stepr_bpm = new FlxUINumericStepper(label_bpm.x, label_bpm.y + label_bpm.height + 2, 1, chart.info.bpm, 0, 999, 1,1,
            tinpt_bpm);
		stepr_bpm.value = chart.info.bpm;

        // Scroll Speed // 
        label_scrspd = new FlxText(label_composer.x+input_composer.width+20,label_composer.y,100,"Scroll Speed",14);
        label_scrspd.font = font;
        
        var temp_cdii = new CDevInputText(0, 0, Std.int((360/2) - 47)-label_composer.size*2, "", 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
        temp_cdii.font = font;
        temp_cdii.size = label_composer.size;
        temp_cdii.onTextChanged = (nText:String) -> {
            chart.info.speed = Std.parseFloat(nText);
        }

        stepr_scrspd = new FlxUINumericStepper(label_scrspd.x, label_scrspd.y + label_scrspd.height + 2, 0.1, chart.info.speed, 0.1, 9999.0, 1,1,
            temp_cdii);
        stepr_scrspd.value = chart.info.speed;

        // New Divider Label For Chart Data Section //
        var charPart:FlxText = new FlxText(0,input_composer.y+input_composer.height+10,-1,"Chart Data", 16);
        charPart.font = font;

        // Opponent Button //
        label_dadchar = new FlxText(charPart.x,charPart.y+charPart.height+2,100,"Opponent",14);
        label_dadchar.font = font;

        buttn_dadchar = new FlxUIButton(label_dadchar.x, label_dadchar.y + label_dadchar.height + 2, "Change", function()
        {
            openSubState(new CharacterListSubstate(this,"character_opponent"));
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_dadchar.resize(input_composer.width, 20);
        buttn_dadchar.label.size = 14;
        buttn_dadchar.label.font = font;
        buttn_dadchar.label.color = FlxColor.WHITE;

        // Player Button //
        label_bfchar = new FlxText(label_scrspd.x,label_dadchar.y,100,"Player",14);
        label_bfchar.font = font;

        buttn_bfchar = new FlxUIButton(label_bfchar.x, label_bfchar.y + label_bfchar.height + 2, "Change", function()
        {
            openSubState(new CharacterListSubstate(this,"character_player"));
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_bfchar.resize(input_composer.width, 20);
        buttn_bfchar.label.size = 14;
        buttn_bfchar.label.font = font;
        buttn_bfchar.label.color = FlxColor.WHITE;

        // Spectator Button //
        label_thirdchar = new FlxText(buttn_dadchar.x,buttn_dadchar.y+buttn_dadchar.height+2,100,"Spectator",14);
        label_thirdchar.font = font;

        buttn_thirdchar = new FlxUIButton(label_thirdchar.x, label_thirdchar.y + label_thirdchar.height + 2, "Change", function()
        {
            openSubState(new CharacterListSubstate(this,"character_thirdchar"));
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_thirdchar.resize(input_composer.width, 20);
        buttn_thirdchar.label.size = 14;
        buttn_thirdchar.label.font = font;
        buttn_thirdchar.label.color = FlxColor.WHITE;

        // Stage Button //
        label_stage = new FlxText(buttn_bfchar.x,label_thirdchar.y,100,"Stage",14);
        label_stage.font = font;

        buttn_stage = new FlxUIButton(label_stage.x, label_stage.y + label_stage.height + 2, "Change", function()
        {
            openSubState(new StageListSubstate(this,"current_stage"));
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_stage.resize(input_composer.width, 20);
        buttn_stage.label.size = 14;
        buttn_stage.label.font = font;
        buttn_stage.label.color = FlxColor.WHITE;

        // Note Skin //
        label_noteskin = new FlxText(0,buttn_stage.y + buttn_stage.height + 5,180,"Note Skin Path",14);
        label_noteskin.font = font;

        input_noteskin = new CDevInputText(0, label_noteskin.y+label_noteskin.height+2, Std.int((360) - 47), chart.data.note_skin, 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
        input_noteskin.font = font;
        input_noteskin.size = label_noteskin.size;
        input_noteskin.onTextChanged = (nText:String) -> {
            chart.data.note_skin = nText;
        }

        buttn_reloadMusic = new FlxUIButton(text.x, input_noteskin.y + input_noteskin.height + 4, "Reload Music", function()
        {
            loadSong(chart.info.name);
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_reloadMusic.resize(((360/2)-47), 20);
        buttn_reloadMusic.label.size = 14;
        buttn_reloadMusic.label.font = font;
        buttn_reloadMusic.label.color = FlxColor.WHITE;
        grp.add(buttn_reloadMusic);

        buttn_reloadChart = new FlxUIButton(text.x + buttn_save.width + 47, buttn_reloadMusic.y, "Reload Chart", function()
        {
            loadChartFile(chart.info.name);
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_reloadChart.resize(((360/2)-47), 20);
        buttn_reloadChart.label.size = 14;
        buttn_reloadChart.label.font = font;
        buttn_reloadChart.label.color = FlxColor.WHITE;
        grp.add(buttn_reloadChart);

        buttn_autosave = new FlxUIButton(text.x, buttn_reloadMusic.y + buttn_reloadMusic.height + 4, "Load Autosave", function()
        {
            var autosave:String = loadAutosave();
            if (autosave != ""){
                FlxG.switchState(new ChartEditor(Song.parseCDC(autosave), chart_difficulty));
                //loadChartFile(chart.info.name);
            }

        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_autosave.resize(360-47, 20);
        buttn_autosave.label.size = 14;
        buttn_autosave.label.font = font;
        buttn_autosave.label.color = FlxColor.WHITE;
        grp.add(buttn_autosave);

        // Assign onBoxChangedFocus to onFocus //
        input_songname.onFocus = input_composer.onFocus = tinpt_bpm.onFocus = temp_cdii.onFocus = input_noteskin.onFocus = onBoxChangedFocus;

        // this is terrible
        //grp.add(text);
        grp.add(label_songname);
        grp.add(label_composer);

        grp.add(input_songname);
        grp.add(input_composer);

        grp.add(label_bpm);
        grp.add(stepr_bpm);

        grp.add(label_scrspd);
        grp.add(stepr_scrspd);

        grp.add(charPart);

        grp.add(label_dadchar);
        grp.add(buttn_dadchar);

        grp.add(label_bfchar);
        grp.add(buttn_bfchar);

        grp.add(label_thirdchar);
        grp.add(buttn_thirdchar);
        
        grp.add(label_stage);
        grp.add(buttn_stage);

        grp.add(label_noteskin);
        grp.add(input_noteskin);

        parent.add(grp);
    }

    // Note Type Lists
    var drop_noteTypes:CDevList;
    // Arguments 1
    var label_notearg1:FlxText;
    var input_notearg1:CDevInputText;
    // Arguments 2
    var label_notearg2:FlxText;
    var input_notearg2:CDevInputText;
    function menu_createEditUI(parent:FlxSpriteGroup){
        var grp:FlxSpriteGroup = new FlxSpriteGroup();
        var font = FunkinFonts.CONSOLAS;

        // # HEADER # //
        var text:FlxText = new FlxText(0,0,-1,"Edit", 18);
        text.font = FunkinFonts.CONSOLAS;
        grp.add(text);

        // # NOTE STUFFS # //
        var text2:FlxText = new FlxText(text.x,text.y+text.height+10,-1,"Note Info", 16);
        text2.font = FunkinFonts.CONSOLAS;
        grp.add(text2);

        // Note Type List
        drop_noteTypes = new CDevList(text2.x, text2.y+text2.height + 25, 360 - 47,30,_noteTypes,(nNote:String)->{
            dummyNote.noteType = _spawn_noteType = nNote;
            _spawn_noteType_id = _spawn_noteType.indexOf(nNote);
        });
        drop_noteTypes.bgLabel.text = _spawn_noteType;

        var tempLabel:FlxText = new FlxText(drop_noteTypes.x, drop_noteTypes.y - 18, -1, "Note Type", 14);
        tempLabel.font = font;
        grp.add(tempLabel);

        // Arguments
        var tempLabel:FlxText = new FlxText(drop_noteTypes.x, drop_noteTypes.y+drop_noteTypes.sizes.height + 10, -1, "Arguments", 14);
        tempLabel.font = font;
        grp.add(tempLabel);

        // Arg1
        label_notearg1 = new FlxText(tempLabel.x,tempLabel.y + tempLabel.height + 2,100,"Value 1",14);
        label_notearg1.font = font;
        grp.add(label_notearg1);

        input_notearg1 = new CDevInputText(0, label_notearg1.y+label_notearg1.height+2, 360 - 47, _spawn_noteArgs[0], 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
        input_notearg1.font = font;
        input_notearg1.size = label_notearg1.size;
        input_notearg1.onTextChanged = (nText:String) -> {
            _spawn_noteArgs[0] = nText;
        }
        input_notearg1.onFocus = onBoxChangedFocus;
        grp.add(input_notearg1);
   
        // Arg2
        label_notearg2 = new FlxText(tempLabel.x,input_notearg1.y + input_notearg1.height + 2,100,"Value 2",14);
        label_notearg2.font = font;
        grp.add(label_notearg2);

        input_notearg2 = new CDevInputText(0, label_notearg2.y+label_notearg2.height+2, 360 - 47, _spawn_noteArgs[1], 16, FlxColor.WHITE, FlxColor.fromRGB(70, 70, 70));
        input_notearg2.font = font;
        input_notearg2.size = label_notearg2.size;
        input_notearg2.onTextChanged = (nText:String) -> {
            _spawn_noteArgs[1] = nText;
        }
        input_notearg2.onFocus = onBoxChangedFocus;
        grp.add(input_notearg2);

        grp.add(drop_noteTypes);
   
        parent.add(grp);
    }

    function onBoxChangedFocus(focus:Bool) {
        writing_enabled = focus;
        trace("Writing: "+writing_enabled);
    }

    function menu_createViewUI(parent:FlxSpriteGroup){
        var text:FlxText = new FlxText(0,0,-1,"View", 18);
        text.font = FunkinFonts.CONSOLAS;
        parent.add(text);

        var text:FlxText = new FlxText(0,20,-1,"UI related stuffs for the chart editor here.", 14);
        text.font = FunkinFonts.CONSOLAS;
        parent.add(text);
    }

    function menu_createPlaytestUI(parent:FlxSpriteGroup){
        var text:FlxText = new FlxText(0,0,-1,"Playtest", 18);
        text.font = FunkinFonts.CONSOLAS;
        parent.add(text);

        var text:FlxText = new FlxText(0,20,-1,"Things to add:\n- From start.\n- From current time.\n\nmake playtest works in the chart editor", 14);
        text.font = FunkinFonts.CONSOLAS;
        parent.add(text);
    }

    function menu_createHelpUI(parent:FlxSpriteGroup){
        var text:FlxText = new FlxText(0,0,-1,"Help", 18);
        text.font = FunkinFonts.CONSOLAS;
        parent.add(text);

        var textThing:String = ""
        + "#[Space]#\n- Play / Resume song.\n"
        + "#[W/S], [Up/Down], [Mouse Wheel]#\n- Adjust time position.\n"
        + "#[A/D] or [Right/Left]#\n- Change current beat.\n"
        + "#Hold [Shift]#\n- Multiply / Unlock mouse from grid.\n"
        + "#[LMB]#\n- Add / Select Note.\n"
        + "#[LMB] + Drag#\n- Multi Select Notes."
        + "\n#[RMB]#\n- Remove Note.";
        var actualHelp:FlxText = new FlxText(0,20,-1,"", 14);
        var laWawa = new FlxTextFormat(0xFF00CCFF);
        actualHelp.applyMarkup(textThing, [new FlxTextFormatMarkerPair(laWawa, "#")]);
        actualHelp.font = FunkinFonts.CONSOLAS;
        parent.add(actualHelp);
    }

    function createStrumNotes(){
        opStrum = new FlxTypedGroup<StrumArrow>();
        add(opStrum);
        plStrum = new FlxTypedGroup<StrumArrow>();
        add(plStrum);

        var bros:Array<Dynamic> = [
            ["static", "arrow<A>"],
            ["confirm", "<a> confirm"],
        ];
        var tex = note_texture;
        for (i in 0...2){
            for (ind => dir in ["left", "down", "up", "right"]){
                var spr:StrumArrow = new StrumArrow(grid.x+(grid_size*ind),0);
                spr.inEditor = true;
                spr.frames = tex;
                for (anim in bros){
                    var formattedAnim:String = StringTools.replace(anim[1],"<A>", dir.toUpperCase());
                    formattedAnim = StringTools.replace(formattedAnim, "<a>", dir);
                    spr.animation.addByPrefix(anim[0], formattedAnim, 24, false);
                }
                spr.playAnim(bros[0][0], true);
                spr.animation.finishCallback = (name:String) -> {
                    if (name == "confirm") spr.playAnim(bros[0][0], true);
                }
                spr.antialiasing = CDevConfig.saveData.antialiasing;
                spr.setGraphicSize(grid_size,grid_size);
                spr.updateHitbox();
                spr.y = hitLine.y;
                switch(i){
                    case 0:
                        opStrum.add(spr);
                    case 1:
                        spr.x += (grid_size*4) + separator_width;
                        plStrum.add(spr);
                }
            }
        }
    }

    function createBeatDividers(){
        beatDividers = new FlxSpriteGroup(grid.x);
        add(beatDividers);

        for (i in 0...Std.int(FlxG.sound.music.length / Conductor.stepCrochet)) {
            if (i % 16 == 0 || i % 4 == 0) {
                var curTime:Float = Conductor.stepCrochet * i;
                var spr:FlxSprite = new FlxSprite();
                spr.makeGraphic(Std.int(grid.width), (i % 16 == 0 ? 5 : 2), (i % 16 == 0 ? 0xA4000000 : 0xA4FFFFFF));
                spr.y = getYFromTime(curTime);
                spr.active = false;
                beatDividers.add(spr);
            }
        }        
    }

    override function update(elapsed:Float){
        if (FlxG.sound.music != null){
            if (FlxG.sound.music.playing)
                Conductor.songPosition = FlxG.sound.music.time;
        }

        keyboardControls(elapsed);
        infoTextUpdate();

        if (!FlxG.mouse.pressedMiddle){
            if (FlxG.sound.music.playing){
                hitLine.y = getYFromTime(Conductor.songPosition);
            } else{
                hitLine.y = FlxMath.lerp(getYFromTime(Conductor.songPosition), hitLine.y, 1-(elapsed*15));
            }
        }

        updateIconProperties();
        metronomeLogic();
        super.update(elapsed);
        mouseControls(elapsed);
        simulateStepBeat();
        updateFlashLogic();
        updateChartData();

        eventsUpdateLogic();

        checkChartFile(elapsed);
    }

    function updateChartData(){
        chart.data.opponent = character_opponent;
        chart.data.player = character_player;
        chart.data.third_char = character_thirdchar;
        chart.data.stage = current_stage;

        if (buttn_dadchar != null)
            buttn_dadchar.label.text = chart.data.opponent;
        if (buttn_bfchar != null)
            buttn_bfchar.label.text = chart.data.player;
        if (buttn_thirdchar != null)
            buttn_thirdchar.label.text = chart.data.third_char;
        if (buttn_stage != null)
            buttn_stage.label.text = chart.data.stage;
    }

    var currentMeasure:Float = 0;
    function infoTextUpdate(){
        currentMeasure = getMeasureFromTime(Conductor.songPosition);
        var sig:String = '${Conductor.time_signature[0]}/${Conductor.time_signature[1]}';
        var dur:String = '\nTime: ${SongPosition.getCurrentDuration(Conductor.songPosition)} / ${SongPosition.getCurrentDuration(FlxG.sound.music.length)}';
        infoTxt.text = '-=Song Info=-'
        + '\nName: ${chart.info.name} ${fileSaved ? "" : "*"}'
        + '\nComposer: ${chart.info.composer}'
        + '\nBPM: ${chart.info.bpm}'
        + '\nScroll Speed: ${chart.info.speed}'
        + '\nTime Signature: ${sig}'
        + '\n\n-=Song Data=-'
        + '\nPlayer: ${chart.data.player}'
        + '\nOpponent: ${chart.data.opponent}'
        + '\nSpectator: ${chart.data.third_char}'
        + '\nStage: ${chart.data.stage}'
        + '\nNote Skin: ${chart.data.note_skin}'
        + '\n\n-=Editor=-'
        + '\nBeats: ${currentBeat}'
        + '\nSteps: ${currentStep}'
        + '\nMeasures: ${FlxMath.roundDecimal(currentMeasure, 2)}'
        + '\nBPM: ${chart.info.bpm}'
        + dur;

        infoTxt.setPosition(30+timeBar.height,FlxG.height-(infoTxt.height+20));
        timeBar.setPosition(-(timeBar.width * 0.46),0);
        timeBar.screenCenter(Y);
        timeBar.alpha = FlxG.mouse.overlaps(timeBar) ? 1 : 0.9;
        metronome_icon.setPosition(grid.x - (metronome_icon.width + 20), FlxG.height - (metronome_icon.height+20));
    }

    function updateFlashLogic(){
        if (FlxG.sound.music.playing){
            for (note in rendered_notes){
                if (note == null) continue;
                if (hitLine.y > note.y && !hitted_notes.contains(note)){
                    var nData:Int = note.noteData;
                    var curStrum:FlxTypedGroup<StrumArrow> = (nData > 3 ? plStrum : opStrum);
                    curStrum.members[nData % 4].playAnim("confirm", true);

                    note.alpha = 0.6;
                    hitted_notes.push(note);
                }
            }

            for (sus in note_sus_lengths) {
                if (sus == null) continue;
                if (Conductor.songPosition > sus.strumTime
                    && Conductor.songPosition < sus.strumTime + sus.holdLength){
                    flash_on_step[sus.noteData] = true;
                }
            }
        } else {
            for (note in rendered_notes){
                if (note == null) continue;
                if (hitLine.y < note.y && hitted_notes.contains(note)){
                    note.alpha = 1;
                    hitted_notes.remove(note);
                }
            }
        }
        for (spr in 0...opStrum.members.length){
            var playerObject:StrumArrow = plStrum.members[spr];
            var opponentObject:StrumArrow = opStrum.members[spr];
            opponentObject.y = playerObject.y = hitLine.y;
            opponentObject.alpha = playerObject.alpha = (FlxG.sound.music.playing ? 1 : 0.5);
        }

    }

    var passedStep:Int = 0;
    var passedBeat:Int = 0;
    var passedMeasure:Int = 0;
    var currentStep:Int = 0;
    var currentBeat:Int = 0;
    function simulateStepBeat(){
        if (passedStep != currentStep) virtualStepHit();
        if (passedBeat != currentBeat) virtualBeatHit();
        if (passedMeasure != Std.int(currentMeasure)) measureChanging();
        currentStep = Std.int(Conductor.songPosition / Conductor.stepCrochet);
        currentBeat = Std.int(currentStep / Conductor.time_signature[0]);
    }

    function virtualStepHit(){
        passedStep = currentStep;

        if (FlxG.sound.music.playing){
            for (ind => yes in flash_on_step){
                if (!yes) continue;
                var curStrum:FlxTypedGroup<StrumArrow> = (ind > 3 ? plStrum : opStrum);
                curStrum.members[ind % 4].playAnim("confirm", true);

                flash_on_step[ind] = false;
            }
        }
    }

    function virtualBeatHit(){
        passedBeat = currentBeat;
    }

    function measureChanging(){
        passedMeasure = Std.int(currentMeasure);
        noteSpawnLogic();
    }

    function eventsUpdateLogic() {
        var currentStatus:String = grid.target_isPlayer ? "bf" : "dad"; //"dad";
        rendered_events.forEachAlive((event:ChartEvent)->{
            if (event.EVENT_NAME == "Change Camera Focus") {
                if (Conductor.songPosition > event.time) {
                    currentStatus = event.value1.toLowerCase().trim();
                    return;
                }
            }
        });

        grid.changeTarget((currentStatus == "bf"));
    }

    function noteSpawnLogic(){
        var intMeasure:Int = Std.int(currentMeasure);
    
        // Helper function to kill notes and events
        inline function killItem(item:Dynamic, listToRemoveFrom:FlxTypedGroup<Dynamic>){
            item.destroy();
            listToRemoveFrom.remove(item, true);
        }
    
        // Destroy Logic
        var measureThresholdLow = intMeasure - 2;
        var measureThresholdHigh = intMeasure + 2;
    
        rendered_notes.forEachAlive((note:ChartNote) -> {
            var noteMeasure = getMeasureFromTime(note.strumTime);
            if (noteMeasure <= measureThresholdLow || noteMeasure >= measureThresholdHigh) {
                killItem(note, rendered_notes);
            }
        });
    
        rendered_events.forEachAlive((event:ChartEvent) -> {
            var eventMeasure = getMeasureFromTime(event.time);
            if (eventMeasure <= measureThresholdLow || eventMeasure >= measureThresholdHigh) {
                killItem(event, rendered_events);
            }
        });
    
        // Add Logic -- Load notes and events from the next section
        var fullSection = (Conductor.crochet * Conductor.time_signature[0]);
        var startTime = (fullSection * (intMeasure + 1));
    
        for (note in getNoteListFromMeasure(startTime)) addNote(note, true);
        for (event in getEventListFromMeasure(startTime)) addEvent(event, true);
    
        // Sort notes and events
        chart.notes.sort((n1:Dynamic, n2:Dynamic) -> FlxSort.byValues(FlxSort.ASCENDING, n1[0], n2[0]));
        chart.events.sort((n1:Dynamic, n2:Dynamic) -> FlxSort.byValues(FlxSort.ASCENDING, n1[2], n2[2]));
    }

    function metronomeLogic(){
        metronome_icon.animation.play(Math.floor(Conductor.songPosition / Conductor.crochet) % 2 == 0 ? "left" : "right", true);
        if (metronome_icon.animation.curAnim != null)
            metronome_icon.animation.curAnim.curFrame = Std.int(((Conductor.songPosition % (Conductor.crochet)) / (Conductor.crochet))*metronome_icon.animation.curAnim.numFrames);
    }

    function keyboardControls(elapsed:Float){
        FlxG.sound.muteKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.volumeUpKeys = [];
        if (writing_enabled) return;

        var dropDowns:Array<Bool> = [
            drop_noteTypes != null ? drop_noteTypes.opened : false
        ];

        var wheel:Int = dropDowns.contains(true) ? 0 : FlxG.mouse.wheel;
        var upScrollControl = [FlxG.keys.pressed.W, FlxG.keys.pressed.UP,wheel > 0];
        var downScrollControl = [FlxG.keys.pressed.S, FlxG.keys.pressed.DOWN, wheel < 0];
        var skipNextControl = [FlxG.keys.justPressed.D, FlxG.keys.justPressed.RIGHT];
        var skipBackControl = [FlxG.keys.justPressed.A, FlxG.keys.justPressed.LEFT];
        var largeMode = FlxG.keys.pressed.SHIFT; // ...lol

        // Main Controls, such as Return to PlayState, Playtest, etc
		if (FlxG.keys.justPressed.ENTER) {
            PlayState.SONG = chart;
            FlxG.switchState(new PlayState());
        }

        // Play & Pause controls
        if (FlxG.keys.justPressed.SPACE){
            if (FlxG.sound.music.playing){
                setAllSoundTime(FlxG.sound.music.time);
                FlxG.sound.music.pause();
                playerVoice.pause();
                opponentVoice.pause();
            } else {
                setAllSoundTime(FlxG.sound.music.time);
                FlxG.sound.music.play();
                playerVoice.play();
                opponentVoice.play();
            }
        }

        // Scrolling controls
        if (upScrollControl.contains(true) || downScrollControl.contains(true)){
            var div:Int = (largeMode ? 1 : 2);
            var scroll:Float = Conductor.stepCrochet/div;
            scroll *= (FlxG.mouse.wheel != 0 ? 4: 1);
            Conductor.songPosition += (downScrollControl.contains(true) ? scroll : -scroll) / 2;
            setAllSoundTime(Conductor.songPosition);
        }

        // Skipping controls 
        if (skipNextControl.contains(true) || skipBackControl.contains(true)){
            if (FlxG.sound.music.playing) {
                FlxG.sound.music.pause();
                playerVoice.pause();
                opponentVoice.pause();
            }
            var ad:Int = largeMode ? 2 : 1;
            var toThisBeat:Float = Conductor.crochet * (Std.int(FlxG.sound.music.time/Conductor.crochet) + (skipNextControl.contains(true) ? ad : -ad));
            setAllSoundTime(toThisBeat);
        }
        FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
    }

    var recently_added_note:Array<Dynamic>;
    var new_noteObject:ChartNote = null;
    var last_hold_addition = 0;
    
    var lastMousePoint:FlxPoint = new FlxPoint();
    var lastPos:Float = 0;

    var dragPosStart:FlxPoint = new FlxPoint();

    var currentSelectedNotes:Array<ChartNote> = [];

    var control_overlap = {
        notes: {
            status: false,
            object: null
        },
        selected_notes: false, // When mouse overlaps selected notes
        grid_empty_space: false, // Overlaps empty space in grid (used for note addition)
        block_select: false, // Used for the selection mode / lmb drag
        note_adjust: false
    };

    var noteYPositions:Array<Float> = [];

    function mouseControls(elapsed:Float) {
        if (curMouse != openfl.ui.MouseCursor.ARROW)
            curMouse = openfl.ui.MouseCursor.ARROW; // set this by default

        if (!FlxG.mouse.pressed) {
            dragPosStart.set(FlxG.mouse.x, FlxG.mouse.y);
        }

        // Note overlap check
        control_overlap.notes.status = false;
        control_overlap.notes.object = null;  
        for (note in rendered_notes.members) {
            if (note == null) continue;
            if (!FlxG.mouse.overlaps(note)) continue;
            control_overlap.notes.status = true;
            control_overlap.notes.object = note;  
            break;   
        }

        // Controls if there's any note selected
        control_overlap.selected_notes = false;
        if (currentSelectedNotes.length > 0) {
            // Overlap checking
            for (note in currentSelectedNotes) {
                if (note == null) continue;

                try {
                    if (FlxG.mouse.overlaps(note)) {
                        control_overlap.selected_notes = true;
                        break; // Exit loop early if an overlap is found
                    }
                } catch (e:Dynamic) {
                    Log.warn("Caught error: " + e.toString());
                }
            }

            // If Delete key is pressed, remove every selected note.
            if (FlxG.keys.justPressed.DELETE) {
                for (note in currentSelectedNotes) {
                    removeNote(note);
                }
                clearSelectedNotes();
            }

            // If mouse overlaps one of the notes...
            if (!control_overlap.block_select) {
                if (control_overlap.selected_notes) {
                    curMouse = openfl.ui.MouseCursor.AUTO;
    
                    if (FlxG.mouse.pressed) {
                        control_overlap.note_adjust = true;
                    }
                }
                    // When starting the drag, store the initial y-positions of the notes
                if (control_overlap.note_adjust && FlxG.mouse.justPressed) {
                    noteYPositions = [];
                    for (note in currentSelectedNotes) {
                        noteYPositions.push(note.y);
                    }
                }

                if (control_overlap.note_adjust) {               
                    curMouse = openfl.ui.MouseCursor.HAND;
                
                    if (FlxG.mouse.pressed) {
                        for (i in 0...currentSelectedNotes.length) {
                            var note = currentSelectedNotes[i];
                            var initialY = noteYPositions[i];
                            
                            var newX = grid.x + (note.noteData * grid_size) + (FlxG.mouse.x - dragPosStart.x);
                            var newY = initialY + (FlxG.mouse.y - dragPosStart.y);
                    
                            note.setPosition(newX, newY);
                            note.x = FlxMath.bound(note.x, grid.x, grid.x + (grid_size * 7) + separator_width);
                            note.animData = Math.floor((note.x - grid.x) / grid_size);
                        }
                    }


                    if (FlxG.mouse.justReleased) {
                        control_overlap.note_adjust = false;
                        var newNotes:Array<Dynamic> = [];
                        var firstNote:ChartNote = currentSelectedNotes[0];
    
                        for (index => note in currentSelectedNotes) {
                            var fNoteTime:Float = Math.round(getTimeFromY(firstNote.y) / Conductor.stepCrochet) * Conductor.stepCrochet;
                        
                            var fNoteOffset:Float = firstNote.strumTime - fNoteTime;
                            var timeOffset:Float = (note == firstNote ? 0 : (note.strumTime - fNoteOffset - fNoteTime));
                            final nTime:Float = fNoteTime + timeOffset;
                            final nData:Int = Math.floor((note.x - grid.x) / grid_size) % 8;
                            final nHold:Float = note.holdLength;
                            final nType:String = note.noteType;
                            final nArgs:Array<String> = note.noteArgs;
                            var data:Array<Dynamic> = [nTime, nData, nHold, nType, nArgs];
                        
                            newNotes.push(data);
                            removeNote(note);
                        }
                        
    
                        clearSelectedNotes();
    
                        for (i in newNotes) {
                            addNote(i);
                        }
                    }
                }
            }

            if (!control_overlap.note_adjust) {
                if (FlxG.mouse.justPressed) {
                    if (control_overlap.selected_notes) {
                        // Open note properties thing...
                        trace("selected twice");
                    } else {
                        clearSelectedNotes();
                    }
                }
            }

        }

        // Basic Charter Controls, Add & Remove notes, drag note sustain, and dummy note / preview note
        if (mouseOnGrid()) {
            dummyNote.visible = !FlxG.mouse.pressed && !FlxG.mouse.pressedRight;
            
            var divY = Math.floor(FlxG.mouse.y / grid_size);
            var divX = Math.floor((FlxG.mouse.x - grid.x) / grid_size); // offset.
            var event_area:Bool = divX > 7;
            var player_area:Bool = divX > 3;
            
            var gridXOffset = (event_area ? separator_width*2 : (player_area ? separator_width : 0));
            var nX:Float = grid.x + gridXOffset + divX * grid_size;
            
            dummyNote.x = nX;
            
            if (FlxG.keys.pressed.SHIFT)
                dummyNote.y = FlxG.mouse.y - (grid_size / 2);
            else
                dummyNote.y = divY * grid_size;
            
            dummyNote.animData = dummyNote.noteData = divX % 4;

            /**
             * No note hovered: Add a new note
             * Note hovered: set as selected
             * clicked on that selected note: Open note properties window
             */
            control_overlap.grid_empty_space = false;
            if (FlxG.mouse.justPressed && !control_overlap.selected_notes){
                for (n in rendered_notes.members){
                    if (!FlxG.mouse.overlaps(n)) continue;
                    control_overlap.grid_empty_space = true;
                    n.isSelected = true;
                    break;
                }
                if (!control_overlap.grid_empty_space){
                    addNote([getTimeFromY(dummyNote.y) ,divX%8, 0 ,_spawn_noteType, _spawn_noteArgs]);
                }
            }

            if (FlxG.mouse.pressedRight){
                for (n in rendered_notes.members){
                    if (!FlxG.mouse.overlaps(n)) continue;
                    removeNote(n);
                }
            }

            if (!control_overlap.selected_notes) {
                if (FlxG.mouse.pressed && recently_added_note != null && new_noteObject != null){
                    var supposedlyY:Float = Math.floor(getYFromTime(recently_added_note[0]));
                    recently_added_note[2] = Math.max(Conductor.stepCrochet * Math.floor(((FlxG.mouse.y - supposedlyY)) / grid_size),0);
                    if (recently_added_note[2] != last_hold_addition) {
                        new_noteObject.holdLength = last_hold_addition = recently_added_note[2];
                    }
                } else{
                    last_hold_addition = 0;
                } 
            } else{
                last_hold_addition = 0;
                recently_added_note = null;
                new_noteObject = null;
            } 
        } else {
            dummyNote.visible = false;
        }

        // Note selection thing (lmb drag) //
        if (!control_overlap.note_adjust) {
            if (FlxG.mouse.pressed) {
                if (Math.abs(dragPosStart.x - FlxG.mouse.x) > 5 && Math.abs(dragPosStart.y - FlxG.mouse.y) > 5)
                    control_overlap.block_select = true;
            } else {
                control_overlap.block_select = false;
            }
            
            if (control_overlap.block_select) {
                var mousePos = {
                    x: FlxG.mouse.x,
                    y: FlxG.mouse.y
                };
            
                groupSelSprite.visible = true;
                groupSelSprite.setPosition(
                    Math.min(mousePos.x, dragPosStart.x),
                    Math.min(mousePos.y, dragPosStart.y)
                );
            
                if (FlxG.mouse.justMoved) {
                    groupSelSprite.resize(
                        Std.int(Math.abs(mousePos.x - dragPosStart.x)),
                        Std.int(Math.abs(mousePos.y - dragPosStart.y))
                    );
                }
            
                for (note in rendered_notes.members) {
                    if (note != null) note.isSelected = groupSelSprite.overlaps(note);
                }
            } else {
                groupSelSprite.visible = false;
            }        
        } else {
            control_overlap.block_select = false;
        }


        // Charter Dragging Controls //
        if (FlxG.mouse.justPressedMiddle){
            FlxG.sound.music.pause();
            playerVoice.pause();
            opponentVoice.pause();
            lastMousePoint.set(FlxG.mouse.screenX,FlxG.mouse.screenY);
            lastPos = hitLine.y;
        }
        if (FlxG.mouse.pressedMiddle){
            curMouse = openfl.ui.MouseCursor.HAND;
            if (FlxG.mouse.justMoved){
                hitLine.y = lastPos + (lastMousePoint.y - FlxG.mouse.screenY);
                setAllSoundTime(getTimeFromY(hitLine.y));
            }
        }
        if (FlxG.mouse.justReleasedMiddle)
            setAllSoundTime(getTimeFromY(hitLine.y));

        // Selected Note List update //
        currentSelectedNotes = [];
        for (i in rendered_notes.members){
            if (!i.isSelected) continue;
            currentSelectedNotes.push(i);
        }

        // Tooltip thing // 
        updateTooltip(elapsed);
    }

    var showTimer:Float = 0;
    var hoveredSomething:Bool = false;
    function updateTooltip(elapsed:Float) {
        var tooltip_objects:Array<Dynamic> = []; // [Object, Title, Description]
    
        rendered_notes.forEachAlive((note:ChartNote) -> {
            if (note == null) return;
            var haveArgs:Bool = note.noteArgs != null && !(note.noteArgs[0] == "" && note.noteArgs[1] == "");
            var isSustain:Bool = note.holdLength > 0;
            
            tooltip_objects.push([note, note.noteType,
                "Data: " + note.noteData % 4 + (note.noteData > 3 ? " (Player)" : " (Opponent)") +
                "\nTime: " + note.strumTime +
                (haveArgs ? "\nArguments: " + note.noteArgs : "") +
                (isSustain ? "\nSustain Length: " + note.holdLength : "")
            ]);
        });

        rendered_events.forEachAlive((event:ChartEvent) -> {
            tooltip_objects.push([event, event.EVENT_NAME,
                "Value 1: " + event.value1
                +"\nValue 2: " + event.value2
            ]);
        });
    
        for (butt in menu_tooltip) tooltip_objects.push(butt);
    
        hoveredSomething = false;
    
        for (obj in tooltip_objects) {
            if (FlxG.mouse.overlaps(obj[0]) && Math.round(obj[0].alpha) != 0) {
                hoveredSomething = true;
            }
        }
    
        if (hoveredSomething) {
            showTimer += elapsed;
            curMouse = openfl.ui.MouseCursor.BUTTON;
            if (showTimer > 0.3) {
                for (stuff in tooltip_objects) {
                    if (FlxG.mouse.overlaps(stuff[0]) && Math.round(stuff[0].alpha) != 0) {
                        tooltip_overlay.show(stuff[0], stuff[1], stuff[2], true);
                    }
                }
            }
        } else {
            showTimer = 0;
            tooltip_overlay.hide();
        }
    }
    
    
    function clearSelectedNotes(){
        while (currentSelectedNotes.length>0){
            for (i in currentSelectedNotes){
                if (i != null) {
                    i.isSelected = false;
                }
                currentSelectedNotes.remove(i);
            }
        }
    }

    function updateIconProperties()
    {
        var sizeUpdate = 0.8-(((Conductor.songPosition % (Conductor.crochet))/Conductor.crochet)*0.2);
        opIcon.scale.set(sizeUpdate, sizeUpdate);
        opIcon.updateHitbox();
        opIcon.setPosition(grid.x - (150 / 2) - ((150 / 2) * opIcon.scale.x)-20, 145);

        plIcon.scale.set(sizeUpdate, sizeUpdate);
        plIcon.updateHitbox();
        plIcon.setPosition((grid.x + (grid_size*4)) + (150 / 2) + ((150 / 2) * plIcon.scale.x) + 40, 145);
        updateHeads();
    }

    var haventdoneityet:Bool = true;
    function updateHeads():Void
    {
        var p1Icon:String = getIconFromCharJSON(chart.data.player);
        var p2Icon:String = getIconFromCharJSON(chart.data.opponent);
        if (opIcon.getChar() != p2Icon || plIcon.getChar() != p1Icon) haventdoneityet = true;
        
        if (!haventdoneityet) return;
        Log.info("Icon Update..");

        opIcon.changeDaIcon(p2Icon);
        plIcon.changeDaIcon(p1Icon);
        haventdoneityet = false;
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

    function loadNotes(){
        for (i in 0...15) rendered_notes.add(new ChartNote()).kill();
        for (i in 0...15) rendered_events.add(new ChartEvent(0,0,true)).kill();

        // Notes
        for (i in getNoteListFromMeasure(0)){
            addNote(i, true);
        }
        for (i in getNoteListFromMeasure((Conductor.crochet*Conductor.time_signature[0]))){
            addNote(i, true);
        }

        // Events
        for (i in getEventListFromMeasure(0)){
            addEvent(i, true);
        }
        for (i in getEventListFromMeasure((Conductor.crochet*Conductor.time_signature[0]))){
            addEvent(i, true);
        }
    }

    function addNote(data:Array<Dynamic>, ?onlyVisual:Bool = false) {
        if (data == null) return;
        if (data[1] < 0 || data[1] > 8) return;
        if (!onlyVisual) {
            chart.notes.push(data);
            recently_added_note = chart.notes[chart.notes.length-1];
        }

        var gridXOffset = data[1] > 3 ? (ChartEditor.grid_size * 4) + separator_width : 0;
        var nX:Float = grid.x + gridXOffset + (grid_size * (data[1] % 4));
        var n:ChartNote = rendered_notes.recycle(ChartNote);
        n.setPosition(nX, getYFromTime(data[0]));
        n.init(data, false);
        rendered_notes.add(n);

        new_noteObject = n;

        if (n.holdLength > 0){
            note_sus_lengths.push(n);
        }
    }

    function addEvent(data:Array<Dynamic>, ?onlyVisual:Bool = false) {
        if (data == null) return;
        if (!onlyVisual) {
            chart.events.push(data);
        }

        var gridXOffset = data[1] > 3 ? (ChartEditor.grid_size * 4) + separator_width : 0;
        var nX:Float = grid.x + gridXOffset + (grid_size * (data[1] % 4));
        var n:ChartEvent = rendered_events.recycle(ChartEvent,()->{return new ChartEvent(0,0,true);});
        n.prepare(data);
        n.setPosition(nX, getYFromTime(n.time));
        rendered_events.add(n);
    }

    function removeNote(note:ChartNote){
        if (note == null) return;
        var rem:Array<Dynamic> = getDataFromNote(note);
        if (rem == null) {
            Log.warn("Failed removing note, can't find similar note data.");
            note.destroy();
            rendered_notes.remove(note,true);
            return;
        }
        chart.notes.remove(rem);
        note.destroy();
        rendered_notes.remove(note,true);
    }

    function getDataFromNote(note:ChartNote):Array<Dynamic> {
        for (n in chart.notes){
            if (n == note.rawData) return n;
        }
        return null;
    }

    function getNoteListFromMeasure(time:Float):Array<Dynamic> {
        var getThis:Array<Dynamic> = [];
        for (i in chart.notes){
            var startPoint:Float = time;
            var endPoint:Float = startPoint + (Conductor.crochet*Conductor.time_signature[0]);
            if (i[0] >= startPoint && i[0] <= endPoint) {
                getThis.push(i);
            }

        }
        return getThis;
    }

    function getEventListFromMeasure(time:Float):Array<Dynamic> {
        var getThis:Array<Dynamic> = [];
        for (i in chart.events){
            var startPoint:Float = time;
            var endPoint:Float = startPoint + (Conductor.crochet*Conductor.time_signature[0]);
            if (i[2] >= startPoint && i[2] <= endPoint) {
                getThis.push(i);
            }
        }
        return getThis;
    }

    inline function getMeasureFromTime(time:Float):Float {
        return time / (Conductor.crochet*Conductor.time_signature[0]);
    }

    inline function getYFromTime(t:Float):Float {
        return ((grid_size * 16) * ((t)/(Conductor.crochet*Conductor.time_signature[0])));
    }

    inline function getTimeFromY(y:Float):Float {
        return (y / ((grid_size * 16) / (Conductor.crochet * Conductor.time_signature[0])));
    }
    
    inline function mouseOnGrid():Bool {
        return FlxG.mouse.x > grid.x
        && FlxG.mouse.x < grid.x + grid.width
        && FlxG.mouse.y > grid.y
        && FlxG.mouse.y < grid.y + grid.height;
    }

    inline function saveUsingFReference(){
        var jString:String = Json.stringify(chart, "\t");
        if (jString != null && jString.length > 0){
            var fr:FileReference = new FileReference();
            fr.addEventListener(Event.COMPLETE, (_)->{
                CDevPopUp.open(this, "Info", "File saved successfully.", [{text: "OK", callback:()->{closeSubState();}}], false, true);
            });
			fr.addEventListener(Event.CANCEL, (_)->{
                CDevPopUp.open(this, "Info", "File save process cancelled.", [{text: "OK", callback:()->{closeSubState();}}], false, true);
            });
			fr.addEventListener(IOErrorEvent.IO_ERROR, (a)->{
                CDevPopUp.open(this, "Error", "Failed saving chart data, " + a.toString(), [{text: "OK", callback:()->{closeSubState();}}], false, true);
            });
			fr.save(jString.trim(), chart.info.name + ".cdc");
        } else {
            CDevPopUp.open(this, "Error", "An error occured while generating JSON data for your chart.", [{text: "OK", callback:()->{closeSubState();}}], false, true);
        }
    }

    function loadChartFile(sName:String) {
        var diffMod:String = (chart_difficulty != "" ? "-"+chart_difficulty : "");
        var chartName:String = chart.info.name+diffMod;
        var chartFile:CDevChart = Song.load(chart.info.name+diffMod,chart.info.name);
        if (chartFile == null) {
            CDevPopUp.open(this, "Failed", "An error occured while trying to loading \""+chartName+"\", file does not exists.",[
                {text:"OK",callback:()->closeSubState()}
            ], false, true);
            return;
        }
        FlxG.switchState(new ChartEditor(chartFile, chart_difficulty));
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
			autosave_overlay.alpha = alphaA;
			textTween = FlxTween.tween(autosave_overlay, {alpha: alphaX}, 1, {
				onComplete: function(e:FlxTween)
				{
					textTween = null;
					autosave_overlay.alpha = alphaX;
				}
			});
		}
	}

    var hitted:Bool = false;
	function checkChartFile(elapsed:Float)
	{
        if (!CDevConfig.saveData.autosaveChart) return;
        if (Paths.currentMod == "BASEFNF") return;

        var time:Float = CDevConfig.saveData.autosaveChart_interval;
        if (time != -1 && !(lastTime >= time))
            lastTime += elapsed;
        if (time == -1)
        {
            everyAction_autosave = true;
            if (_every_action_save != chart) createAutoSave();
        }
        else
        {
            everyAction_autosave = false;
            if (lastTime >= time)
            {
                lastCount += elapsed;
                if (!hitted)
                {
                    hitted = true;
                    tweened = false;
                    autosave_overlay.text = "Autosaving...";
                    autosave_overlay.color = FlxColor.WHITE;
                    tweenTheText(0, 1);
                    tweened = true;
                }

                if (lastCount > 3) createAutoSave();
            }
        }

		fileSaved = _inital_state_song == chart;
	}

	function createAutoSave()
	{
		hitted = false;
		_every_action_save = chart;
		lastTime = 0;
		lastCount = 0;

		var data:String = Json.stringify(chart);

		if ((data != null) && (data.length > 0))
		{
			tweened = false;
            var path:String = Paths.modChartPath(chart.info.name + "/");
			if (FileSystem.exists(path))
			{
				File.saveContent(path + "~autosave.cdc", data);
				autosave_overlay.text = "Saved.";
				autosave_overlay.color = FlxColor.CYAN;
			}
			else
			{
				tweened = false;
				autosave_overlay.text = "Failed to perform autosave.";
				autosave_overlay.color = FlxColor.RED;
			}
			autosave_overlay.alpha = 1;
			new FlxTimer().start(1, function(e:FlxTimer)
			{
				tweenTheText(1, 0);
				tweened = true;
			});
		}
	}

	function loadAutosave():String
	{
		var stringJSON:String = "";
		var path:String = Paths.modChartPath(chart.info.name + "/");
		if (FileSystem.exists(path + "~autosave.cdc"))
		{
			stringJSON = File.getContent(path + "~autosave.cdc");
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
		openSubState(new CDevPopUp("Error", "Couldn't find \"~autosave.cdc\" file on path: \"" + path + "\".", butt));
		return "";
	}

    public function getNoteTypePos(nt:String = ""):Int
    {
        if (nt == "Default Note")
            return -1;

        var l:Int = 0;
        for (i in _noteTypes)
        {
            if (i == nt)
            {
                return l;
            }
            l++;
        }
        return -1;
    }
}