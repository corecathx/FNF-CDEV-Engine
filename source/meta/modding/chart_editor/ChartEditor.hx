package meta.modding.chart_editor;

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

class ChartEditor extends MusicBeatState {
    public static var grid_size:Int = 40;
    public static var separator_width:Int = 4;
    public static var note_texture:FlxAtlasFrames = null;

    var voiceAudio:FlxSound;
    var chart:CDevChart;

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

    var tooltip_objects:Array<Dynamic> = [];

    var metronome_icon:FlxSprite;

    var rendered_notes:FlxTypedGroup<ChartNote>;
    var note_sus_lengths:Array<ChartNote> = [];
    var flash_on_step:Array<Bool> = [ // erm
        false,false,false,false,
        false,false,false,false
    ];

    var hitted_notes:Array<ChartNote> = [];
    var dummyNote:ChartNote;

    var writing_enabled:Bool = false;

    public function new(?fnfChart:CDevChart){
        if (fnfChart == null) fnfChart = CDevConfig.utils.CDEV_CHART_TEMPLATE;//CDevConfig.utils.CHART_TEMPLATE;
        loadChart(fnfChart);
        note_texture = Paths.getSparrowAtlas("notes/NOTE_assets", "shared"); // cache the note texture first
        super();
    }

    function loadChart(fnfChart:CDevChart){
        chart = fnfChart;
        character_opponent = chart.data.opponent;
        character_player = chart.data.player;
        character_thirdchar = chart.data.third_char; 
        current_stage = chart.data.stage;
    }
    
    override function create(){
        FlxG.mouse.visible = true;
        persistentUpdate = false;
        loadSong(chart.info.name);
        loadUI();
        loadNotes();

        FlxG.camera.follow(hitLine, LOCKON);
        FlxG.camera.targetOffset.y = 150;
        super.create();
    }

    function loadSong(sogn:String){
        if (FlxG.sound.music != null)
        {
            FlxG.sound.music.stop();
            if (voiceAudio != null) voiceAudio.stop();
        }

        FlxG.sound.playMusic(Paths.inst(sogn));
        
        voiceAudio = new FlxSound().loadEmbedded(Paths.voices(sogn));
        FlxG.sound.list.add(voiceAudio);

        FlxG.sound.music.pause();
        voiceAudio.pause();

        Conductor.changeBPM(chart.info.bpm);
        Conductor.changeTimeSignature(chart.info.time_signature[0], chart.info.time_signature[1]);
        voiceAudio.time = FlxG.sound.music.time = Conductor.songPosition = 0;
        //Conductor.mapBPMChanges(_song);
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
            ["edit", "Editing current song's info.", menu_createEditUI], 
            ["view", "Adjust the editor's interface.", menu_createViewUI], 
            ["playtest", "Test your chart.", menu_createPlaytestUI], 
            ["help", "Keybinds / Editor controls.", menu_createHelpUI]
        ]);
        menu_ui.scrollFactor.set();
        menu_ui.setPosition((FlxG.width - menu_ui.width)-20,(FlxG.height - menu_ui.height)-20);
        add(menu_ui);

        for (i in menu_ui.getListStuff()) tooltip_objects.push(i);

        tooltip_overlay = new CDevTooltip();
        tooltip_overlay.scrollFactor.set();
        add(tooltip_overlay);
    }

    // Save Button
    var buttn_new:FlxUIButton;
    var buttn_save:FlxUIButton;
    var buttn_saveAs:FlxUIButton;
    function menu_createFileUI(parent:FlxSpriteGroup){
        var grp:FlxSpriteGroup = new FlxSpriteGroup();
        var font = FunkinFonts.CONSOLAS;

        var text:FlxText = new FlxText(0,0,-1,"File", 18);
        text.font = FunkinFonts.CONSOLAS;
        grp.add(text);

        buttn_new = new FlxUIButton(text.x, text.y + text.height + 2, "New", function()
        {
            FlxG.switchState(new ChartEditor());
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_new.resize(((360) - 47), 20);
        buttn_new.label.size = 14;
        buttn_new.label.font = font;
        buttn_new.label.color = FlxColor.WHITE;
        grp.add(buttn_new);

        buttn_save = new FlxUIButton(text.x, buttn_new.y + buttn_new.height + 2, "Save", function()
        {
            var path:String = Paths.mods('${Paths.currentMod}/data/charts/${chart.info.name}/');
            trace("Save Path:" + path);
            if (FileSystem.exists(path)
                && FileSystem.isDirectory(path)){
                // what to do

            } else {
                CDevPopUp.open(this, "Info", "We couldn't find existing chart folder for this song: "+path+"\nWe'll continue saving your chart but please specify where to save this song's chart.", [{text: "OK", callback:()->{saveUsingFReference();}}], false, true);
            }
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_save.resize(((360/2)), 20);
        buttn_save.label.size = 14;
        buttn_save.label.font = font;
        buttn_save.label.color = FlxColor.WHITE;
        grp.add(buttn_save);

        buttn_saveAs = new FlxUIButton(buttn_save.x + buttn_save.width + 47, buttn_save.y, "Save As", function()
        {
            saveUsingFReference();
        }, true, false, FlxColor.fromRGB(70,70,70));
        buttn_saveAs.resize(((360/2)), 20);
        buttn_saveAs.label.size = 14;
        buttn_saveAs.label.font = font;
        buttn_saveAs.label.color = FlxColor.WHITE;
        grp.add(buttn_saveAs);

        parent.add(grp);
    }

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
    function menu_createEditUI(parent:FlxSpriteGroup){
        var grp:FlxSpriteGroup = new FlxSpriteGroup();
        var font = FunkinFonts.CONSOLAS;

        var text:FlxText = new FlxText(0,0,-1,"Edit", 18);
        text.font = font;

        // Song Name //
        label_songname = new FlxText(0,text.height + 10,100,"Song Name",14);
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

        // Assign onBoxChangedFocus to onFocus //
        input_songname.onFocus = input_composer.onFocus = tinpt_bpm.onFocus = temp_cdii.onFocus = input_noteskin.onFocus = onBoxChangedFocus;


        // this is terrible
        grp.add(text);
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

        var actualHelp:FlxText = new FlxText(0,20,-1,"", 14);
        actualHelp.text = ""
        + "[Space]\n- Play / Resume song.\n"
        + "[W/S], [Up/Down], [Mouse Wheel]\n- Adjust time position.\n"
        + "[A/D] or [Right/Left]\n- Change current beat.\n"
        + "Hold [Shift]\n- Multiply / Unlock mouse from grid.\n"
        + "[LMB]\n- Add / Remove Note.\n"
        + "[RMB]\n- Note Properties.";
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
        + '\nName: ${chart.info.name}'
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
        for (spr in 0...opStrum.members.length)
            opStrum.members[spr].y = plStrum.members[spr].y = hitLine.y;
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
        currentBeat = Std.int(currentStep / 4);
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

    function noteSpawnLogic(){
        var intMeasure:Int = Std.int(currentMeasure);

        inline function kill_me(note:ChartNote){
            note_sus_lengths.remove(note);
            note.destroy();
            rendered_notes.remove(note,true);
        }
        // Destroy Logic
        rendered_notes.forEachAlive((note:ChartNote) -> {
            if (getMeasureFromTime(note.strumTime) <= intMeasure - 2) {
                kill_me(note);
            } else if (getMeasureFromTime(note.strumTime) >= intMeasure + 2){
                kill_me(note);
            }
        });

        // Add Logic -- Load notes from the next section
        var fullSection = (Conductor.crochet*Conductor.time_signature[0]);
        var startTime = (fullSection * (intMeasure+1));
        var new_notelist:Array<Dynamic> = getNoteListFromMeasure(startTime);

        for (note in new_notelist) addNote(note, true);

        chart.notes.sort((n1:Dynamic, n2:Dynamic) ->
        {
            return FlxSort.byValues(FlxSort.ASCENDING, n1[0], n2[0]);
        });
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
        var upScrollControl = [FlxG.keys.pressed.W, FlxG.keys.pressed.UP,FlxG.mouse.wheel > 0];
        var downScrollControl = [FlxG.keys.pressed.S, FlxG.keys.pressed.DOWN, FlxG.mouse.wheel < 0];
        var skipNextControl = [FlxG.keys.justPressed.D, FlxG.keys.justPressed.RIGHT];
        var skipBackControl = [FlxG.keys.justPressed.A, FlxG.keys.justPressed.LEFT];
        var largeMode = FlxG.keys.pressed.SHIFT; // ...lol

        // Main Controls, such as Return to PlayState, Playtest, etc
		if (FlxG.keys.justPressed.ENTER) FlxG.switchState(new PlayState());

        // Play & Pause controls
        if (FlxG.keys.justPressed.SPACE){
            if (FlxG.sound.music.playing){
                voiceAudio.time = FlxG.sound.music.time;
                FlxG.sound.music.pause();
                voiceAudio.pause();
            }else {
                voiceAudio.time = FlxG.sound.music.time;
                FlxG.sound.music.play();
                voiceAudio.play();
            }
        }

        // Scrolling controls
        if (upScrollControl.contains(true) || downScrollControl.contains(true)){
            var div:Int = (largeMode ? 1 : 2);
            var scroll:Float = Conductor.stepCrochet/div;
            scroll *= (FlxG.mouse.wheel != 0 ? 4: 1);
            Conductor.songPosition += (downScrollControl.contains(true) ? scroll : -scroll) / 2;
            voiceAudio.time = FlxG.sound.music.time = Conductor.songPosition;
        }

        // Skipping controls 
        if (skipNextControl.contains(true) || skipBackControl.contains(true)){
            if (FlxG.sound.music.playing) {
                FlxG.sound.music.pause();
                voiceAudio.pause();
            }
            var ad:Int = largeMode ? 2 : 1;
            var toThisBeat:Float = Conductor.crochet * (Std.int(FlxG.sound.music.time/Conductor.crochet) + (skipNextControl.contains(true) ? ad : -ad));
            Conductor.songPosition = FlxG.sound.music.time = voiceAudio.time = toThisBeat;
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

    var currentSelectedNotes:Array<ChartNote> = [];
    function mouseControls(elapsed:Float) {
        curMouse = openfl.ui.MouseCursor.ARROW;

        // Basic Charter Controls, Add & Remove notes, drag note sustain, and dummy note / preview note
        if (mouseOnGrid()) {
            dummyNote.visible = !FlxG.mouse.pressed && !FlxG.mouse.pressedRight;
            
            var divY = Math.floor(FlxG.mouse.y / grid_size);
            var divX = Math.floor(FlxG.mouse.x / grid_size) - 12; // offset.
            
            var gridXOffset = divX > 3 ? separator_width : 0;
            var nX:Float = grid.x + gridXOffset + divX * grid_size;
            
            dummyNote.x = nX;
            
            if (FlxG.keys.pressed.SHIFT)
                dummyNote.y = FlxG.mouse.y - (grid_size / 2);
            else
                dummyNote.y = divY * grid_size;
            
            dummyNote.noteData = divX % 4;

            /**
             * No note hovered: Add a new note
             * Note hovered: set as selected
             * clicked on that selected note: Open note properties window
             */
            if (FlxG.mouse.justPressed){
                var mouseHoveredNote:Bool = false;
                for (n in rendered_notes.members){
                    if (!FlxG.mouse.overlaps(n)) continue;
                    mouseHoveredNote = true;
                    n.isSelected = true;
                    break;
                }
                if (!mouseHoveredNote){
                    addNote([getTimeFromY(dummyNote.y),divX%8,0,"Default Note"]);
                }
            }

            if (FlxG.mouse.pressedRight){
                for (n in rendered_notes.members){
                    if (!FlxG.mouse.overlaps(n)) continue;
                    removeNote(n);
                }
            }

            if (FlxG.mouse.pressed && recently_added_note != null && new_noteObject != null){
                var supposedlyY:Float = Math.floor(getYFromTime(recently_added_note[0]));
                recently_added_note[2] = Math.max(Conductor.stepCrochet * Math.floor(((FlxG.mouse.y - supposedlyY)) / grid_size),0);
                if (recently_added_note[2] != last_hold_addition) {
                    new_noteObject.holdLength = last_hold_addition = recently_added_note[2];
                }
            } else{
                last_hold_addition = 0;
            } 
        } else {
            dummyNote.visible = false;
        }

        // Charter Dragging Controls
        if (FlxG.mouse.justPressedMiddle){
            FlxG.sound.music.pause();
            voiceAudio.pause();
            lastMousePoint.set(FlxG.mouse.screenX,FlxG.mouse.screenY);
            lastPos = hitLine.y;
        }
        if (FlxG.mouse.pressedMiddle){
            curMouse = openfl.ui.MouseCursor.HAND;
            if (FlxG.mouse.justMoved){
                hitLine.y = lastPos + (lastMousePoint.y - FlxG.mouse.screenY);
                FlxG.sound.music.time = voiceAudio.time = Conductor.songPosition = getTimeFromY(hitLine.y);
            }
        }
        if (FlxG.mouse.justReleasedMiddle){
            FlxG.sound.music.time = voiceAudio.time = Conductor.songPosition = getTimeFromY(hitLine.y);
        }   

        currentSelectedNotes = [];
        for (i in rendered_notes.members){
            if (!i.isSelected) continue;
            currentSelectedNotes.push(i);
        }
        if (currentSelectedNotes.length > 0) {
            var hasOverlap:Bool = false;
            for (note in currentSelectedNotes){
                note.isSelected = true;
                if (FlxG.mouse.overlaps(note)) hasOverlap = true;
            }
            if (hasOverlap) curMouse = openfl.ui.MouseCursor.AUTO;
            if (FlxG.mouse.justPressed){
                if (hasOverlap){
                    
                    // open note properties thing...
                } else {
                    clearSelectedNotes();
                }
            }

        }

        // Tooltip Stuffs (Overlap, and such)
        tooltip_overlay.hide();
		
		if (!FlxG.mouse.pressedMiddle) for (stuff in tooltip_objects){
			if (FlxG.mouse.overlaps(stuff[0]) && Math.round(stuff[0].alpha) != 0){
				curMouse = openfl.ui.MouseCursor.BUTTON;
                tooltip_overlay.show(stuff[0], stuff[1], stuff[2], true);
			}
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
        plIcon.setPosition((grid.x + (grid_size * 4)) + (150 / 2) + ((150 / 2) * plIcon.scale.x) + 40, 145);
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

        //dumb code but ehhh
        for (i in getNoteListFromMeasure(0)){
            addNote(i);
        }
        for (i in getNoteListFromMeasure((Conductor.crochet*Conductor.time_signature[0]))){
            addNote(i);
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

    function removeNote(note:ChartNote){
        var rem:Array<Dynamic> = getDataFromNote(note);
        if (rem == null) {
            Log.warn("Failed removing note, can't find similar note data.");
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
        var data = {
            "data": chart.data,
            "info": chart.info,
            "notes": chart.notes,
            "events": chart.events
        };
        var jString:String = Json.stringify(data, "\t");
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
}