package cdev.objects.play;

import cdev.backend.scripts.Script;
import flixel.math.FlxPoint;
import cdev.graphics.shaders.BorderShader;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSort;
import cdev.states.PlayState;

enum abstract StageSpriteType(String) from String to String {
    var PLAYER = "player";
    var OPPONENT = "opponent";
    var SPECTATOR = "spectator";
    var STATIC = "static";
    var ANIMATED = "animated";
}

typedef StageSprite = {
    name:String,
    path:String,
    type:StageSpriteType,
    position:Axis2D,
    scroll:Axis2D,
    scale:Axis2D,
    ?alpha:Float,
    ?angle:Float,
    ?zIndex:Int,
    animation:Animation
}

typedef StageData = {
    zoom:Float,
    useCharacterOffsets:Bool,
    objects:Array<StageSprite>
}

typedef StageCharacter = {player:String, opponent:String, spectator:String}

class Stage extends SpriteGroup {
    public static final DEFAULT_CHAR_DATA:StageCharacter = {
        player: "bf", opponent: "dad", spectator: "gf"
    };
    static final DEFAULT_BORDER_GRAPHIC_KEY:String = "cdev.objects.play.stage.border";
    /**
     * Defines current stage's name.
     */
    public var name:String = "";

    /**
     * List of Character objects added in this stage
     */
    public var characters:Array<Character> = [];

    public var sprites:Array<Sprite> = [];


    /**
     * Player object in this stage.
     */
    public var player:Character;

    /**
     * Opponent object in this stage.
     */
    public var opponent:Character;

    /**
     * Spectator object in this stage.
     */
    public var spectator:Character;

    public var script:Script;
    public var data:StageData;

    public var charData:StageCharacter = DEFAULT_CHAR_DATA;

    var _inEditor:Bool = false;
    var _highlightSprite:Sprite;

    /**
     * Creates a new stage object.
     * @param name Stage name, will load stage config based on this.
     * @param charData Character names.
     */
    public function new(name:String = "Stage", charData:StageCharacter = null, _inEditor:Bool = false) {
        super();
        this.name = name;
        this._inEditor = _inEditor;
        if (charData != null) 
            this.charData = charData;

        script = Script.fromFile(Assets._STAGE_PATH + "/" + name + ".hx");
        script?.setParent(this);
        initStage();

        script?.callMethod("create");
        Conductor.instance.onBeatTick.add(onBeatTick);
    }

    public function initStage() {
        spectator = addCharacter(400, 130, charData.spectator, false);
        player = addCharacter(770, 100, charData.player, true);
        opponent = addCharacter(100, 100, charData.opponent, false);

        data = Json.parse(Assets.stage(name));
        if (data == null) {
            trace("Could not initialize stage, data is null.");
            return; //just incase something went wrong lolz.
        }

        for (obj in data.objects) {
            trace(obj.type);
            switch (obj.type) {
                case PLAYER:
                    applyProp(player, obj);
                    if (data.useCharacterOffsets) 
                        player.applyOffset();
                case OPPONENT:
                    applyProp(opponent, obj);
                    if (data.useCharacterOffsets) 
                        opponent.applyOffset();
                case SPECTATOR:
                    applyProp(spectator, obj);
                    if (data.useCharacterOffsets) 
                        opponent.applyOffset();
                case STATIC:
                    createSprite(obj);
                default:
                    // hi
            }
        }
        group.sort((_,a, b) -> {
            return a.zIndex - b.zIndex;
        });    

        if (_inEditor) {
            _highlightSprite = new Sprite().makeGraphic(1,1,0xFFFFFFFF);
            _highlightSprite.alpha = 0.2;
            add(_highlightSprite);
        }
    }

    public function createSprite(data:StageSprite) {
        var spr:Sprite = new Sprite().loadGraphic(Assets.image(data.path));
        applyProp(spr, data);
        addSprite(spr);
    }

    public inline function applyProp(char:Sprite, obj:StageSprite) {
        if (obj.name != null) 
            char.name = obj.name;
        if (obj.position != null)
            char.setPosition(obj.position.x, obj.position.y);
        if (obj.scroll != null)
            char.scrollFactor.set(obj.scroll.x, obj.scroll.y);
        if (obj.scale != null) {
            char.scale.set(obj.scale.x, obj.scale.y);
            char.updateHitbox();
        }
        char.alpha = obj.alpha ?? 1;
        char.angle = obj.angle ?? 0;
        char.zIndex = obj.zIndex ?? 0;
    }

    var _lastObj:Sprite;
    function _updateHighlightSprite(obj:Sprite) {
        if (!_inEditor) return;
        if (_lastObj != obj) {
            _lastObj = obj;
            remove(_highlightSprite);
            insert(members.indexOf(obj), _highlightSprite);
        }
        _highlightSprite.scale.set(obj.width, obj.height);
        _highlightSprite.updateHitbox();
        _highlightSprite.scrollFactor = obj.scrollFactor;
        _highlightSprite.setPosition(obj.x, obj.y);
    }

    var _offset:FlxPoint;
    var _focusedObject:Sprite;
    override function update(elapsed:Float) {
        super.update(elapsed);
        script?.callMethod("update", [elapsed]);
        if (_inEditor) {
            if (_focusedObject == null) {
                for (i in group) {
                    if (i == _highlightSprite) 
                        continue;
                    if (FlxG.mouse.overlaps(i)) {
                        _updateHighlightSprite(i);
                        if (FlxG.mouse.justPressed) {
                            _offset = FlxPoint.get(FlxG.mouse.x - i.x, FlxG.mouse.y - i.y);
                            _focusedObject = i;
                        }
                    }
                }
            } else {
                _updateHighlightSprite(_focusedObject);
                if (FlxG.mouse.pressed)
                    _focusedObject.setPosition(FlxG.mouse.x - _offset.x, FlxG.mouse.y - _offset.y);
                if (FlxG.mouse.justReleased) 
                    _focusedObject = null;
            }
        }
    } 

    public function addCharacter(x:Float, y:Float, name:String, isPlayer:Bool = false) {
        var char:Character = new Character(x,y,name,isPlayer);
        add(char);
        characters.push(char);
        return char;
    }

    override function preAdd(sprite:Sprite):Void {
        sprite.x += x;
        sprite.y += y;
        sprite.alpha *= alpha;
        // This prevents the `scroll` stage sprite data from working
        // sprite.scrollFactor.copyFrom(scrollFactor); im so angy
        sprite.cameras = _cameras;

        if (clipRect != null)
            clipRectTransform(sprite, clipRect);
    }

    public function addSprite(spr:Sprite) {
        sprites.push(spr);
        add(spr);
    }

    override function destroy() {
        Conductor.instance.onBeatTick.remove(onBeatTick);
        for (char in characters) {
            remove(char);
            char.destroy();
        }
        characters = null;
        super.destroy();
    }

    public function dance(force:Bool = false) {
        for (char in characters) {
            char.dance(force);
        }
    }

    public function onBeatTick(beat:Int) {
        dance();
    }
}