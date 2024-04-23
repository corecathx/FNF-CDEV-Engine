package meta.modding.chart_editor;

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

class ChartEditor extends MusicBeatState {
    public static var grid_size:Int = 40;
    public static var separator_width:Int = 4;

    var voiceAudio:FlxSound;
    var chart:CDevChart;

    // Things that's visible to da human eye:
    var grid:ChartingArea;
    var hitLine:FlxSprite;
    var bgArt:FlxSprite;
    var beatDividers:FlxSpriteGroup;
    var infoTxt:FlxText;
    var timeBar:FunkinBar;

    var opIcon:HealthIcon;
    var plIcon:HealthIcon;

    var rendered_notes:FlxTypedGroup<ChartNote>;

    public function new(fnfChart:SwagSong){
        chart = CDevConfig.utils.fnftocdev_chart(fnfChart);

        super();
    }
    
    override function create(){
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
        timeBar.angle = -90;
        timeBar.scrollFactor.set();
        add(timeBar);
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
        hitLine.y = getYFromTime(Conductor.songPosition);
        updateIconProperties();
        super.update(elapsed);
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
        + '\nBeats: ${curBeat}'
        + '\nSteps: ${curStep}'
        + '\nMeasures: ${FlxMath.roundDecimal(Conductor.songPosition / (Conductor.crochet*Conductor.time_signature[0]), 2)}'
        + '\nBPM: ${chart.info.bpm}'
        + dur;

        infoTxt.setPosition(30+timeBar.height,FlxG.height-(infoTxt.height+20));
        timeBar.setPosition(-((timeBar.width * 0.46)),0);
        timeBar.screenCenter(Y);
    }

    function keyboardControls(elapsed:Float){
        var upScrollControl = [FlxG.keys.pressed.W, FlxG.keys.pressed.UP,FlxG.mouse.wheel > 0];
        var downScrollControl = [FlxG.keys.pressed.S, FlxG.keys.pressed.DOWN, FlxG.mouse.wheel < 0];

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
                    FlxG.sound.music.play();
                    voiceAudio.play();
                }
            }
        }

        // Scrolling controls
        if (upScrollControl.contains(true) || downScrollControl.contains(true)){
            var div:Int = (FlxG.keys.pressed.SHIFT ? 1 : 2);
            var scroll:Float = Conductor.stepCrochet/div;
            Conductor.songPosition += (downScrollControl.contains(true) ? scroll : -scroll) / 4;
            FlxG.sound.music.time = Conductor.songPosition;
            voiceAudio.time = FlxG.sound.music.time;
        }
    }

    function updateIconProperties()
    {
        var sizeUpdate = 0.8-(((Conductor.songPosition % (Conductor.crochet))/Conductor.crochet)*0.2);
        opIcon.scale.set(sizeUpdate, sizeUpdate);
        opIcon.updateHitbox();
        opIcon.setPosition(grid.x - (150 / 2) - ((150 / 2) * opIcon.scale.x)-20, 135);

        plIcon.scale.set(sizeUpdate, sizeUpdate);
        plIcon.updateHitbox();
        plIcon.setPosition((grid.x + (grid_size * 4)) + (150 / 2) + ((150 / 2) * plIcon.scale.x) + 40, 135);
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
        for (note in chart.notes){
            var gridXOffset = note[1] > 3 ? (ChartEditor.grid_size * 4) + separator_width : 0;
            var nX:Float = grid.x + gridXOffset + (grid_size * (note[1] % 4));
            var n:ChartNote = new ChartNote(nX, getYFromTime(note[0]));
            n.init(note, false);
            rendered_notes.add(n);
        }        
    }
}