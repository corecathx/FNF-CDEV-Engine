package meta.modding.chart_editor;

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

    var metronome_icon:FlxSprite;

    var rendered_notes:FlxTypedGroup<ChartNote>;
    var note_sus_lengths:Array<ChartNote> = [];
    var flash_on_step:Array<Bool> = [ // erm
        false,false,false,false,
        false,false,false,false
    ];

    var hitted_notes:Array<ChartNote> = [];

    var dummyNote:ChartNote;

    public function new(fnfChart:SwagSong){
        chart = CDevConfig.utils.fnftocdev_chart(fnfChart);
        note_texture = Paths.getSparrowAtlas("notes/NOTE_assets", "shared");
        super();
    }
    
    override function create(){
        FlxG.mouse.visible = true;
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

        voiceAudio.time = FlxG.sound.music.time;
        FlxG.sound.music.pause();
        voiceAudio.pause();

        Conductor.changeBPM(chart.info.bpm);
        Conductor.changeTimeSignature(chart.info.time_signature[0], chart.info.time_signature[1]);
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

    function getYFromTime(t:Float):Float {
        return ((grid_size * 16) * ((t)/(Conductor.crochet*4)));
    }

    override function update(elapsed:Float){
        keyboardControls(elapsed);
        infoTextUpdate();

        if (FlxG.sound.music.playing){
            hitLine.y = getYFromTime(Conductor.songPosition);
        } else{
            hitLine.y = FlxMath.lerp(getYFromTime(Conductor.songPosition), hitLine.y, 1-(elapsed*15));
        }

        updateFlashLogic();
        updateIconProperties();
        metronomeLogic();
        super.update(elapsed);
        mouseControls(elapsed);
        simulateStepBeat();
    }

    function infoTextUpdate(){
        var sig:String = '${Conductor.time_signature[0]}/${Conductor.time_signature[1]}';
        var dur:String = '\nTime: ${SongPosition.getCurrentDuration(Conductor.songPosition)} / ${SongPosition.getCurrentDuration(FlxG.sound.music.length)}';
        infoTxt.text = '-=Song Info=-'
        + '\nName: ${chart.info.name}'
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
        + '\nMeasures: ${FlxMath.roundDecimal(Conductor.songPosition / (Conductor.crochet*Conductor.time_signature[0]), 2)}'
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
    var currentStep:Int = 0;
    var currentBeat:Int = 0;
    function simulateStepBeat(){
        if (passedStep != currentStep) virtualStepHit();
        if (passedBeat != currentBeat) virtualBeatHit();
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

    function metronomeLogic(){
        metronome_icon.animation.play(Math.floor(Conductor.songPosition / Conductor.crochet) % 2 == 0 ? "left" : "right", true);
        if (metronome_icon.animation.curAnim != null)
            metronome_icon.animation.curAnim.curFrame = Std.int(((Conductor.songPosition % (Conductor.crochet)) / (Conductor.crochet))*metronome_icon.animation.curAnim.numFrames);
    }

    function keyboardControls(elapsed:Float){
        var upScrollControl = [FlxG.keys.pressed.W, FlxG.keys.pressed.UP,FlxG.mouse.wheel > 0];
        var downScrollControl = [FlxG.keys.pressed.S, FlxG.keys.pressed.DOWN, FlxG.mouse.wheel < 0];
        var skipNextControl = [FlxG.keys.justPressed.D, FlxG.keys.justPressed.RIGHT];
        var skipBackControl = [FlxG.keys.justPressed.A, FlxG.keys.justPressed.LEFT];
        var largeMode = FlxG.keys.pressed.SHIFT; // ...lol

        // Main Controls, such as Return to PlayState, Playtest, etc
		if (FlxG.keys.justPressed.ENTER) FlxG.switchState(new PlayState());

        // Play & Pause controls
        if (FlxG.sound.music != null){
            if (FlxG.sound.music.playing)
                Conductor.songPosition = FlxG.sound.music.time;

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
        }

        // Scrolling controls
        if (upScrollControl.contains(true) || downScrollControl.contains(true)){
            var div:Int = (largeMode ? 1 : 2);
            var scroll:Float = Conductor.stepCrochet/div;
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
    }

    function mouseControls(elapsed:Float) {
        if (FlxG.mouse.x > grid.x
            && FlxG.mouse.x < grid.x + grid.width
            && FlxG.mouse.y > grid.y
            && FlxG.mouse.y < grid.y + grid.height) {
            
            dummyNote.visible = !FlxG.mouse.pressed;
            
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
        } else {
            dummyNote.visible = false;
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
        if (!haventdoneityet) return;
        var p1Icon:String = getIconFromCharJSON(chart.data.player);
        var p2Icon:String = getIconFromCharJSON(chart.data.opponent);
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
        for (i in 0...15){
            rendered_notes.add(new ChartNote()).kill();
        }
        for (note in chart.notes){
            var gridXOffset = note[1] > 3 ? (ChartEditor.grid_size * 4) + separator_width : 0;
            var nX:Float = grid.x + gridXOffset + (grid_size * (note[1] % 4));
            var n:ChartNote = rendered_notes.recycle(ChartNote);
            n.setPosition(nX, getYFromTime(note[0]));
            n.init(note, false);
            rendered_notes.add(n);

            if (note[2] > 0 ){
                note_sus_lengths.push(n);
            }
        }        
    }
}