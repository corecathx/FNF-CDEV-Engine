package game.objects;

import game.cdev.script.ScriptSupport;
import game.cdev.script.CDevScript;
import game.Stage.SpriteStage;
import meta.states.PlayState;
import game.cdev.engineutils.Highscore;
import flixel.util.FlxSort;
import game.song.Song;
import game.song.Section.SwagSection;
import meta.modding.char_editor.CharacterData.CharData;
import meta.modding.char_editor.CharacterData.AnimationArray;
import lime.utils.Assets;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends SpriteStage {
    /** Animation offsets. **/
    public var animOffsets:Map<String, Array<Dynamic>>;
	
	/** Used for character editor. **/
    public var debugMode:Bool = false;

    /** Current script instance of this Character. **/
    public var script:CDevScript;
    public var gotScript:Bool = false;

	/** Current character. **/
    public var curCharacter:String = 'bf';
	/** Whether to set the current running animation as a special anim. **/
    public var specialAnim:Bool = false;

	/** Sing animation alt prefix. **/
    public var singAltPrefix:String = "-alt";
	/** Idle animation alt prefix. **/
    public var idleAltPrefix:String = "-alt";
	/** Current character idle speed when `forceDance` is true (in beats). **/
    public var idleSpeed:Int = 2;
    /** Whether to just force the idle playing on certain beats. **/
    public var forceDance:Bool = false;

    /** Lock character informations, used in Week Editor. **/
    public var lockedChar:Bool = false;

	/** Hold Timer for animation (usually for sustain notes). **/
    public var holdTimer:Float = 0;

    // Character properties //
    public var imgFile:String = ''; // Sprite path
    public var jsonScale:Float = 1; // Character scale
    public var charXYPos:Array<Float> = [0, 0]; // Character XY offset
    public var charCamPos:Array<Float> = [0, 0]; // Camera XY position
    public var charHoldTime:Float = 4; // Sing hold time
    public var healthBarColors:Array<Int> = [0, 0, 0]; // Health bar color
    public var animArray:Array<AnimationArray> = []; // Animations
    public var healthIcon:String = 'face'; // Icon name
    public var isPlayer:Bool = false; // Is player character
    public var previousFlipX:Bool = false;
    public var usingAntiAlias:Bool = false;

    // Array for animation notes (specific for pico-speaker)
    public var animNotes:Array<Dynamic> = [];
    // Whether to allow the character to dance
    public var canDance:Bool = true;

    // Default animations
    public var defaultAnims:Array<String> = [
        'idle', 'danceLeft', 'danceRight', 'singRIGHT', 'singLEFT', 'singDOWN', 'singUP',
        'singRIGHT-alt', 'singLEFT-alt', 'singDOWN-alt', 'singUP-alt',
    ];

    // Dance state variables
    private var danced:Bool = false;
    var idleDance:Bool = false;
    var danceShit:Bool = false;

    public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?usedForStoryChar:Bool = false) {
        super(x, y);
        animOffsets = new Map<String, Array<Dynamic>>();
        
        curCharacter = character;
        this.isPlayer = isPlayer;

        if (!debugMode) initScript();

        executeFunc("create", []);

        antialiasing = CDevConfig.saveData.antialiasing;

        initializeCharacter(curCharacter, usedForStoryChar);

        previousFlipX = flipX;

        if (isPlayer) {
            flipX = !flipX;
        }

        defineIdleDance();
        dance(false, 1);

        if (!usedForStoryChar) {
            switch (curCharacter) {
                case 'pico-speaker':
                    canDance = false;
                    loadMappedAnims();
                    playAnim("shoot1");
            }
        }

        executeFunc("postCreate", []);
    }

    private function initializeCharacter(character:String, usedForStoryChar:Bool):Void {
        var path:String = Paths.modChar(character);
        if (!FileSystem.exists(path))
            path = Paths.char(character);
        if (!FileSystem.exists(path))
            path = Paths.char('bf');

        var daRawJSON:String = File.getContent(path);
        var parsedJSON:CharData = cast Json.parse(daRawJSON);

        var spritePath:String = 'images/' + parsedJSON.spritePath + '.txt';
        frames = Assets.exists(Paths.getPath(spritePath, TEXT)) ?
                 Paths.getPackerAtlas(parsedJSON.spritePath, 'shared') :
                 Paths.getSparrowAtlas(parsedJSON.spritePath, 'shared');

        imgFile = parsedJSON.spritePath;
        jsonScale = parsedJSON.charScale;
        charXYPos = parsedJSON.charXYPosition;
        charCamPos = parsedJSON.camXYPos;
        charHoldTime = parsedJSON.singHoldTime;
        healthBarColors = parsedJSON.healthBarColor;
        animArray = parsedJSON.animations;
        healthIcon = parsedJSON.iconName;
        usingAntiAlias = parsedJSON.usingAntialiasing;

        setGraphicSize(Std.int(width * jsonScale));
        updateHitbox();

        flipX = parsedJSON.flipX;
        antialiasing = parsedJSON.usingAntialiasing && CDevConfig.saveData.antialiasing;

        if (animArray != null && animArray.length > 0) {
            var shouldInclude:Array<String> = ['idle', 'danceLeft', 'danceRight'];
            for (anim in animArray) {
                if (usedForStoryChar && !shouldInclude.contains(anim.animPrefix)) 
                    continue;

                var animPrefix:String = anim.animPrefix;
                var animName:String = anim.animName;
                var animFpsVal:Int = anim.fpsValue;
                var animLooping:Bool = anim.looping;
                var animIndices:Array<Int> = anim.indices;

                if (animIndices != null && animIndices.length > 0)
                    animation.addByIndices(animPrefix, animName, animIndices, "", animFpsVal, animLooping);
                else
                    animation.addByPrefix(animPrefix, animName, animFpsVal, animLooping);

                if (anim.offset != null && anim.offset.length > 1) 
                    addOffset(anim.animPrefix, anim.offset[0], anim.offset[1]);
            }
        }
    }

    public function initScript():Void {
        if (debugMode) return;
        var scriptPath:String = Paths.modFolders("data/characters/" + curCharacter + ".hx");
        if (!FileSystem.exists(scriptPath)) return;

        script = CDevScript.create(scriptPath);
        gotScript = true;
        script.setVariable("current", this);
        ScriptSupport.setScriptDefaultVars(script, PlayState.fromMod, PlayState.SONG.song);
        script.loadFile(scriptPath);
    }

    override function update(elapsed:Float):Void {
        executeFunc("update", [elapsed]);
        if (debugMode && gotScript) {
            gotScript = false;
            script.destroy();
        }

        if (!debugMode && animation.curAnim != null) {
            handleSpecialAnimations(elapsed);
            handleCharacterSpecificAnimations(elapsed);
            handleAnimationFinish();
        }

        super.update(elapsed);
        executeFunc("postUpdate", [elapsed]);
    }

    private function handleSpecialAnimations(elapsed:Float):Void {
        if (specialAnim) {
            if (defaultAnims.contains(animation.curAnim.name)) {
                specialAnim = false;
                dance();
            }
            if (animation.curAnim.finished) {
                specialAnim = false;
                dance();
            }
        }
    }

    private function handleCharacterSpecificAnimations(elapsed:Float):Void {
        switch (curCharacter) {
            case 'pico-speaker':
                handlePicoSpeakerAnimations();
        }
        if (!isPlayer && animation.curAnim.name.startsWith('sing')) {
            holdTimer += elapsed;
            if (holdTimer >= Conductor.stepCrochet * 0.001 * charHoldTime) {
                dance(animation.curAnim.name.endsWith(singAltPrefix), 1);
                holdTimer = 0;
            }
        }
    }

    private function handlePicoSpeakerAnimations():Void {
        if (animNotes.length > 0 && Conductor.songPosition > animNotes[0][0]) {
            var noteData:Int = animNotes[0][1] > 2 ? 3 : 1;
            noteData += FlxG.random.int(0, 1);
            playAnim('shoot' + noteData, true);
            animNotes.shift();
        }
        if (animation.curAnim.finished) {
            playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
        }
    }

    private function handleAnimationFinish():Void {
        if (animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-looping') != null) {
            playAnim(animation.curAnim.name + '-looping');
        }
    }

    public function curAnimStartsWith(prefix:String):Bool {
        if (animation.curAnim == null) return false;
        return animation.curAnim.name.startsWith(prefix);
    }

    public function dance(?alt:Bool = false, ?beat:Int = 1):Void {
        executeFunc("onDance", [alt, beat]);
        if (!canDance || debugMode || specialAnim || (forceDance && beat % idleSpeed == 0)) return;

        var dRight:String = "danceRight" + (alt ? idleAltPrefix : "");
        var dLeft:String = "danceLeft" + (alt ? idleAltPrefix : "");
        var aIdle:String = "idle" + (alt ? idleAltPrefix : "");

        if (animation.getByName(dLeft) != null && animation.getByName(dRight) != null) {
            danced = !danced;
            playAnim(danced ? dRight : dLeft, forceDance);
        } else if (animation.getByName(aIdle) != null) {
            playAnim(aIdle, forceDance);
        }

        executeFunc("onPostDance", [alt, beat]);
    }

    public function defineIdleDance():Void {
        idleDance = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);
    }

    public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
        executeFunc("onPlayAnim", [animName, force, reversed, frame]);
        specialAnim = false;

        animation.play(animName, force, reversed, frame);

        if (animOffsets.exists(animName)) {
            var offset = animOffsets.get(animName);
            this.offset.set(offset[0], offset[1]);
        } else {
            this.offset.set(0, 0);
        }

        handleGfAnimation(animName);

        executeFunc("onPostPlayAnim", [animName, force, reversed, frame]);
    }

    private function handleGfAnimation(animName:String):Void {
        if (curCharacter == 'gf') {
            switch (animName) {
                case 'singLEFT':
                    danced = true;
                case 'singRIGHT':
                    danced = false;
                case 'singUP', 'singDOWN':
                    danced = !danced;
            }
        }
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0):Void {
        animOffsets[name] = [x, y];
    }

    private function loadMappedAnims():Void {
        var sections:Array<SwagSection> = Song.loadFromJson('picoGunMap', PlayState.SONG.song.toLowerCase().replace(' ', '-')).notes;
        for (section in sections) {
            for (note in section.sectionNotes) {
                animNotes.push(note);
            }
        }
        BackgroundTankmen.animNotes = animNotes;
        animNotes.sort(sortByValue);
    }

    private function sortByValue(obj1:Array<Dynamic>, obj2:Array<Dynamic>):Int {
        return FlxSort.byValues(FlxSort.ASCENDING, obj1[0], obj2[0]);
    }

    private function executeFunc(name:String, data:Array<Dynamic>):Void {
        if (gotScript) script.executeFunc(name, data);
    }
}
