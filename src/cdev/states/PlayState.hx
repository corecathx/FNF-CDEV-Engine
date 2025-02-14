package cdev.states;

import cdev.substates.GameOverSubstate;
import cdev.objects.play.Stage;
import cdev.substates.PauseSubstate;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import cdev.graphics.shaders.AdjustColorShader;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import haxe.Json;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.tweens.FlxEase;
import cdev.objects.play.hud.HealthIcon;
import flixel.util.FlxColor;
import cdev.objects.Bar;
import cdev.backend.Chart;
import cdev.backend.objects.Camera;
import cdev.objects.play.hud.RatingSprite;
import cdev.objects.play.Character;
import cdev.backend.audio.SoundGroup;
import cdev.objects.play.notes.NoteLoader;
import cdev.objects.play.notes.StrumLine;
import cdev.objects.play.notes.Note;
import flixel.addons.display.FlxGridOverlay;

/**
 * The state where rhythm gaming happens.
 */
class PlayState extends State {
    public static var current:PlayState = null;
    public static var currentSong:String = "";
    public static var currentDifficulty:String = "";
    public var playerStrums:StrumLine;
    public var opponentStrums:StrumLine;
    public var sounds:SoundGroup;

    public var noteLoader:NoteLoader;

    public var player:Character;
    public var opponent:Character;
    public var spectator:Character;

    public var iconP1:HealthIcon;
    public var iconP2:HealthIcon;

    public var ratingSprite:RatingSprite;

    public var camGame:Camera;
    public var camHUD:Camera;

    public var chart:Chart;

    public var defaultCamZoom:Float = 1;
    public var defaultHudZoom:Float = 1;

    public var camFollow:FlxObject;
    public var followTarget:Character;
    
    public var combo:Int = 0;

    public var healthBar:Bar;
    public var health(default,set):Float = 0.5;

    public var scoreTxt:Text;
    public var timeTxt:Text;
    public var healthLerp:Float = 0.5;

    public var score:Int = 0;
    public var accuracy:Float = 0;
    public var misses:Int = 0;

    public var paused:Bool = false;
    
    public var stage:Stage;

    var totalNotes:{hit:Float,all:Float} = {
        hit: 0.0,
        all: 0.0
    }

    var hitCount:{sick:Int, good:Int, bad:Int, shit:Int} = {
        sick:0, 
        good:0, 
        bad :0, 
        shit:0, 
    }

    public function new(?songName:String, ?difficulty:String) {
        super();
        currentSong = songName ?? currentSong;
        currentDifficulty = difficulty ?? currentDifficulty;
    }

    override function create() {    
        current = this; // Make sure current active PlayState class is this one.

        initGame();
        initHUD();

        startSong();
        super.create();
    }

    function initGame() {
        if (FlxG.sound.music != null) FlxG.sound.music.stop();
        persistentUpdate = true;
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
        var song = Utils.loadSong(currentSong, currentDifficulty);      
        chart = song.chart;  
                
        sounds = new SoundGroup(song.inst,song.voices);
        sounds.onComplete = onSongEnded;
        add(sounds);

        /// Init Conductor ///
        Conductor.instance.updateBPM(chart.info.bpm);

        /// Load Stage ///
        initStage();
    }
    
    function initStage() {
        defaultCamZoom = 0.9;

        // Characters are also handled in this class!
        stage = new Stage("Stage", {
            spectator: chart.data.spectator,
            player: chart.data.player,
            opponent: chart.data.opponent
        });
        defaultCamZoom = stage?.data.zoom;
        add(stage);

        player = stage.player;
        opponent = stage.opponent;
        spectator = stage.spectator;

        followTarget = opponent;
    }

    function initHUD() {
        /// Positioning and stuff ///
        var _strumCount:Float = 2;
        var _strumWidth:Float = Note.scaleWidth*Note.directions.length;

        var _maxPlayField:Float = FlxG.width / _strumCount;
        var _centerX:Float = (_maxPlayField-_strumWidth)*0.5;

        var up:Float = 60;
        var down:Float = (FlxG.height-Note.scaleWidth)-up;

        var _data = {
            strum: {
                yPos: (Preferences.downscroll ? down : up),
                scrollMult: (Preferences.downscroll ? -1 : 1)
            },
            healthBar: {
                y: (Preferences.downscroll ? 70 : FlxG.height - 90)
            },
            timeText: {
                y: (Preferences.downscroll ? FlxG.height - 50 : 40)
            }
        }

        /// Load Strums and NoteLoader ///
        opponentStrums = new StrumLine(_centerX, _data.strum.yPos, true);
        opponentStrums.scrollMult = _data.strum.scrollMult;
        opponentStrums.cameras = [camHUD];
        opponentStrums.addCharacter(opponent);
        add(opponentStrums);
        
        playerStrums = new StrumLine((FlxG.width*0.5)+_centerX, _data.strum.yPos, false, PLAYER);
        playerStrums.scrollMult = _data.strum.scrollMult;
        playerStrums.cameras = [camHUD];
        playerStrums.addCharacter(player);
        playerStrums.onNoteHit.add(onNoteHit);
        playerStrums.onNoteMiss.add(onNoteMiss);
        add(playerStrums);

        // Remember to always put NoteLoader after initializing player and opponent strums.
        noteLoader = new NoteLoader([opponentStrums, playerStrums],chart);
        noteLoader.onEventSignal.add(onEvent);
        add(noteLoader);

        /// Load Health bar and icons ///
        healthBar = new Bar(0,_data.healthBar.y,Assets.image("hud/healthBar"),()->{return healthLerp;});
        healthBar.setColors(opponent.getBarColor(), player.getBarColor());
        healthBar.cameras = [camHUD];
        healthBar.screenCenter(X);
        healthBar.leftToRight = false;
        add(healthBar);
        
        iconP1 = new HealthIcon(player.icon, true);
        iconP1.cameras = [camHUD];
        add(iconP1);

        iconP2 = new HealthIcon(opponent.icon, false);
        iconP2.cameras = [camHUD];
        add(iconP2);

        /// Load Score Text ///
        scoreTxt = new Text(0,healthBar.y + healthBar.height + 20, "");
        scoreTxt.enableBG = true;
        scoreTxt.bgPadding = 5;
        scoreTxt.cameras = [camHUD];
        add(scoreTxt);

        timeTxt = new Text(FlxG.width/2,_data.timeText.y,"",CENTER);
        timeTxt.enableBG = true;
        timeTxt.bgPadding = 5;
        timeTxt.cameras = [camHUD];
        add(timeTxt);

        /// Load Rating Sprite ///
        ratingSprite = new RatingSprite(FlxG.width*0.5, FlxG.height*0.5);
        ratingSprite.cameras = [camHUD];
        add(ratingSprite);
    }

    function startSong() {
        Conductor.instance.time = -5000;
        startCountdown();
    }

    var countdownStarted:Bool = false;
    function startCountdown() {
        countdownStarted = true;
        var _currentTick:Int = 0;
        
        // Preloading the sprite so that when countdown occurs we dont get lagspikes.
        var preloadedSprites:Array<Sprite> = [];
        for (asset in ["ready", "set", "go"]) {
            var sprite:Sprite = new Sprite().loadGraphic(Assets.image("hud/countdown/"+asset));
            sprite.scrollFactor.set();
            sprite.setScale(0.9);
            sprite.screenCenter();
            sprite.y -= 50;
            sprite.cameras = [camHUD];
            preloadedSprites.push(sprite);
        }


        new FlxTimer().start(Conductor.instance.beat_ms/1000, (_)->{
            player.dance();
            opponent.dance();
            spectator.dance();

            if (_currentTick != 0) {
                var sprite:Sprite = preloadedSprites[_currentTick - 1];
                if (sprite != null) {
                    add(sprite);
                    switch (_currentTick) {
                        case 3:
                            sprite.y += 50;
                            sprite.scale.set(sprite.scale.x + 0.2, sprite.scale.y + 0.2);
                            FlxTween.tween(sprite.scale, {x: sprite.scale.x-0.6, y: sprite.scale.y-0.6}, Conductor.instance.beat_ms / 1000, {ease: FlxEase.backInOut});
                            FlxTween.tween(sprite, {alpha:0}, Conductor.instance.beat_ms / 1000, {ease: FlxEase.cubeInOut});
                            new FlxTimer().start((Conductor.instance.beat_ms / 1000)+0.1,(_)->{
                                sprite.destroy();
                                remove(sprite);
                            });
                        default:
                            FlxTween.tween(sprite, {y: sprite.y + 50, alpha: 0}, Conductor.instance.beat_ms / 1000, {ease: FlxEase.cubeInOut,onComplete: (_)->{
                                sprite.destroy();
                                remove(sprite);
                            }});
                    }
                }
            }

            if (_currentTick == 4) {
                sounds.play();
            } else {
                FlxG.sound.play(Assets.sound("play/intro" + (3-_currentTick)), 0.6);
            }

            _currentTick += 1;
        }, 5);
    }

    override function closeSubState() {
        super.closeSubState();
        unpauseGame();
    }

    override function destroy() {
        for (object in [stage, sounds])
            Utils.destroyObject(object);
        super.destroy();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (countdownStarted && Conductor.instance.time < 0) {
            Conductor.instance.time += elapsed*1000;
        }
        _updateCameras(elapsed);
        _updateHUD(elapsed);
        _updateControls(elapsed);

        if (FlxG.keys.justPressed.B) {
            playerStrums.cpu = !playerStrums.cpu;
        }

        if (FlxG.keys.justPressed.Q) {
            banger = !banger;
        }

        if (Controls.RESET) {
            health = 0;
        }
        
        FlxG.timeScale = sounds.speed;

        if (FlxG.keys.pressed.Z)
            sounds.speed *= 0.99;
        if (FlxG.keys.pressed.X)
            sounds.speed *= 1.01;

        if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.SPACE) {
            throw "crash test, wawa :3";
        }
    }

    function _updateControls(elapsed:Float) {
        if (Controls.PAUSE)
            pauseGame();
    }

    /**
     * Pauses the game, also brings you to the pause screen.
     */
    public function pauseGame() {
        if (paused) return;
        persistentUpdate = false;
		paused = true;
        sounds.pause();
        openSubState(new PauseSubstate(this));
    }

    /**
     * Unpauses the game,
     */
    public function unpauseGame() {
        if (!paused) return;
        persistentUpdate = true;
        paused = false;
        sounds.play();
    }

    /**
     * Called when a note gets hit.
     * @param note Hitted note.
     */
    public function onNoteHit(note:Note) {
        combo++;
        switch (note.judgement.rating) {
            case SICK: hitCount.sick++;
            case GOOD: hitCount.good++;
            case BAD:  hitCount.bad++;
            case SHIT: hitCount.shit++;
        }
        appendNoteStatus(note);
        ratingSprite.show(note.judgement.rating,combo);
        totalNotes.all++;
        sounds.setTagVolume("player", 1);
    }

    /**
     * Called when player missed a note.
     * @param note Missed note.
     */
    public function onNoteMiss(note:Note) {
        combo = 0;
        appendNoteStatus(note);
        misses++;
        totalNotes.all++;
        FlxG.sound.play(Assets.sound('play/missnote${FlxG.random.int(0,2)}'),0.3);
        sounds.setTagVolume("player", 0);
    }

    /**
     * Adds the note judgement status to current gameplay stats.
     * @param note Note
     */
    public function appendNoteStatus(note:Note) {
        health += note.judgement.health;
        score += note.judgement.score;
        totalNotes.hit += note.judgement.accuracy;
    }

    /**
     * Called when the song is ended.
     */
    public function onSongEnded() {
        FlxG.switchState(new TitleState());
    }

    var _last_scoreText:String = "";
    function _updateHUD(elapsed:Float) {
        // Update Score Text // 
        accuracy = FlxMath.roundDecimal((totalNotes.hit / totalNotes.all)*100, 2);
        if (Math.isNaN(accuracy)) 
            accuracy = 0;
        var rank = Utils.getAccuracyRank(accuracy);
        var rankText:String = '#${rank.rating}#, ${Utils.getGameplayStatus(hitCount.sick,hitCount.good,hitCount.bad,hitCount.shit,misses)}';
        var scoreText:String = 'Misses: ${misses} // Score: ${Utils.formatNumber(score)} // Accuracy: ${accuracy}% [${Utils.getAccuracyRating(accuracy)} - $rankText]';
        if (_last_scoreText != scoreText) { // just update the score text when a change is detected.
            if (_last_scoreText.length != scoreText.length) {
                scoreTxt.applyMarkup(scoreText, [
                    new FlxTextFormatMarkerPair(new FlxTextFormat(rank.color),"#")
                ]);
                scoreTxt.screenCenter(X);
            } else {
                scoreTxt.text = scoreText.replace("#", '');
            }
            _last_scoreText = scoreText;
        }


        timeTxt.text = '${chart.info.name} // ${Utils.getTimeFormat(Conductor.instance.time)} - ${Utils.getTimeFormat(sounds.inst.length)}';
        timeTxt.screenCenter(X);

        // Update Icons //
        _updateIcons(elapsed);
    } 

    var posVal:Float = 0;
    var moveTime:Float = 0;
    function _updateCameras(elapsed:Float) {
        camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, 1-(elapsed*6));
        camHUD.zoom = FlxMath.lerp(defaultHudZoom, camHUD.zoom, 1-(elapsed*6));

        if (followTarget != null) {
            var mid:FlxPoint = followTarget.getMidpoint();
            var off:Axis2D = {
                x: followTarget.data.camera_offset.x,
                y: followTarget.data.camera_offset.y
            }
            var follow:Axis2D = {
                x: mid.x + (100 + off.x) * (followTarget.isPlayer ? -1 : 1),
                y: mid.y - 100 + off.y
            }
            var lerp:Float = 1 - (elapsed * 6);
            
            camFollow.x = FlxMath.lerp(follow.x, camFollow.x, lerp);
            camFollow.y = FlxMath.lerp(follow.y, camFollow.y, lerp);
        }
        
    }

    var healthBarPercent:Float = 50;
    function _updateIcons(elapsed:Float) {
        healthLerp = FlxMath.lerp(health, healthLerp, 1 - (elapsed * 15));
		// Smooth health bar value
		healthBarPercent = FlxMath.lerp(healthBar.percent, healthBarPercent, 1 - (elapsed * 15));
        
        var zoomAdd:Float = 0.34;
        var beatEase:Float = Conductor.instance.time < 0 ? 0 : (1 - FlxEase.quartOut((Conductor.instance.time % Conductor.instance.beat_ms) / Conductor.instance.beat_ms)) * zoomAdd;
        var scaleLerp:Float = 1 + beatEase;

        if (iconP1.allowBeat)
            iconP1.scale.set(scaleLerp, scaleLerp);
        iconP1.updateHitbox();

        if (iconP2.allowBeat)
            iconP2.scale.set(scaleLerp, scaleLerp);
        iconP2.updateHitbox();

        var iconOffset:Float = 5;
        iconP1.x = (healthBar.progressCenter + (150/2)) - (150/2) + (iconOffset);
        iconP2.x = (healthBar.progressCenter - (150/2)) - (150/2 + iconOffset);

        iconP1.y = healthBar.y + (healthBar.height - 150)*0.5;
        iconP2.y = healthBar.y + (healthBar.height - 150)*0.5;

		var hbp:Float = healthBarPercent;
		var curP1Icon:Int = (hbp > 80) ? (iconP1.hasWinningIcon ? 2 : 0) : (hbp < 20 ? 1 : 0);
		var curP2Icon:Int = (hbp < 20) ? (iconP2.hasWinningIcon ? 2 : 0) : (hbp > 80 ? 1 : 0);

		iconP1.changeFrame(curP1Icon);
		iconP2.changeFrame(curP2Icon);
    }

    public function onEvent(event:ChartEvent) {
        switch (event.name) {
            case "Change Camera Focus":
                var castValue:String = cast event.values[0];
                switch (castValue){
                    case "dad": followTarget = cast opponent;
                    case "bf": followTarget = cast player;
                }
        }
    }

    function onDeath() {
        sounds.stop();
        persistentDraw = false;
        persistentUpdate = false;
        openSubState(new GameOverSubstate(this, player));
    }

    var banger:Bool = false;
    override function beatHit(beats:Int) {
        inline function _addZoom(zoom:Float)
        {
            camGame.zoom += (zoom * 0.5) * camGame.zoom;
            camHUD.zoom += (zoom) * camHUD.zoom;
        }
        if (beats % (banger ? 1 : 4) == 0) {
            _addZoom(0.05);
        }
    }

    ///// GET & SETTERS /////
    function set_health(val:Float) {
        if (val <= 0) {
            onDeath();
        }
        return health = FlxMath.bound(val,0,1);
    }
}