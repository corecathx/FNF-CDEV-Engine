package cdev.states;

import flixel.FlxObject;
import cdev.backend.Chart;
import cdev.backend.objects.Camera;
import cdev.objects.play.hud.RatingSprite;
import cdev.objects.play.Character;
import cdev.backend.audio.SoundGroup;
import cdev.objects.play.notes.NoteLoader;
import cdev.objects.play.notes.StrumLine;
import cdev.objects.play.notes.Note;

class DebugState extends State {
    var playerStrums:StrumLine;
    var opponentStrums:StrumLine;
    var sounds:SoundGroup;

    var noteLoader:NoteLoader;

    var playerChar:Character;
    var opponentChar:Character;

    var ratingSprite:RatingSprite;

    var camGame:Camera;
    var camHUD:Camera;

    var chart:Chart;

    var defaultCamZoom:Float = 1;
    var defaultHudZoom:Float = 1;

    var camFollow:FlxObject;
    var followTarget:Character;

    override function create() {    
        initGame();
        initHUD();

        sounds.play();
        super.create();
    }

    function initGame() {
        /// Initialize Camera Objects ///
        camGame = new Camera();
		FlxG.cameras.reset(camGame);

		camHUD = new Camera();
        camHUD.bgColor = 0x00000000;
		FlxG.cameras.add(camHUD, false);

        camFollow = new FlxObject(0,0,1,1);
        add(camFollow);

        camGame.follow(camFollow);
        
        /// Load Song Data, and SoundGroup ///
        var song = Utils.loadSong("Twiddlefinger", "hard");      
        chart = song.chart;  
                
        sounds = new SoundGroup(song.inst,song.voices);
        add(sounds);

        /// Init Conductor ///
        Conductor.current.updateBPM(chart.info.bpm);
        Conductor.current.onBeatTick.add(onBeatHit);

        /// Load Stage ///
        initStage();
    }
    
    function initStage() {
        defaultCamZoom = 0.9;
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Assets.image('stageback'));
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Assets.image('stagefront'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Assets.image('stagecurtains'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        add(stageCurtains);

        playerChar = new Character(770,100,"bf",true);
        add(playerChar);

        opponentChar = new Character(100,100,"dad",false);
        add(opponentChar);
    }

    function initHUD() {
        var _strumCount:Float = 2;
        var _strumWidth:Float = Note.scaleWidth*Note.directions.length;

        var _maxPlayField:Float = FlxG.width / _strumCount;
        var _centerX:Float = (_maxPlayField-_strumWidth)*0.5;

        var up:Float = 70;
        var down:Float = (FlxG.height-Note.scaleWidth)-up;

        /// Load Strums and NoteLoader ///
        opponentStrums = new StrumLine(_centerX,up,true);
        opponentStrums.scrollMult = 1;
        opponentStrums.cameras = [camHUD];
        opponentStrums.characters.push(opponentChar);
        add(opponentStrums);
        
        playerStrums = new StrumLine((FlxG.width*0.5)+_centerX,up,false);
        playerStrums.scrollMult = 1;
        playerStrums.cameras = [camHUD];
        playerStrums.characters.push(playerChar);
        playerStrums.onNoteHit.add(onNoteHit);
        add(playerStrums);

        // Remember to always put NoteLoader after initializing player and opponent strums.
        noteLoader = new NoteLoader([opponentStrums, playerStrums],chart);
        noteLoader.onEventSignal.add(onEvent);
        add(noteLoader);

        ratingSprite = new RatingSprite(FlxG.width*0.5, FlxG.height*0.5);
        ratingSprite.cameras = [camHUD];
        add(ratingSprite);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        _updateCameras(elapsed);
        if (FlxG.keys.justPressed.B) {
            playerStrums.cpu = !playerStrums.cpu;
        }

        if (FlxG.keys.pressed.Z)
            sounds.speed *= 0.99;
        if (FlxG.keys.pressed.X)
            sounds.speed *= 1.01;
    }

    function _updateCameras(elapsed:Float) {
        camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, 1-(elapsed*6));
        camHUD.zoom = FlxMath.lerp(defaultHudZoom, camHUD.zoom, 1-(elapsed*6));

        if (followTarget != null) {
            var followX:Float = (followTarget.getMidpoint().x + 100) + (followTarget.isPlayer ? -followTarget.data.camera_offset.x : followTarget.data.camera_offset.x);
            var followY:Float = (followTarget.getMidpoint().y - 100) + followTarget.data.camera_offset.y;
            camFollow.x = FlxMath.lerp(followX, camFollow.x, 1-(elapsed*6));
            camFollow.y = FlxMath.lerp(followY, camFollow.y, 1-(elapsed*6));    
        }
    }

    public function onEvent(event:ChartEvent) {
        switch (event.name) {
            case "Change Camera Focus":
                switch (event.args[0]){
                    case "dad": followTarget = cast opponentChar;
                    case "bf": followTarget = cast playerChar;
                }
        }
    }

    public function onNoteHit(note:Note) {
        ratingSprite.show(SICK);
    }

    public function onBeatHit(beats:Int) {
        inline function _addZoom(zoom:Float)
        {
            camGame.zoom += (zoom * 0.25) * camGame.zoom;
            camHUD.zoom += (zoom) * camHUD.zoom;
        }
        if (beats % 4 == 0) {
            _addZoom(0.04);
        }
        playerChar.dance();
        opponentChar.dance();
    }
}