package cdev.objects.play;

import flixel.util.FlxColor;

class Character extends Sprite {
    /**
     * If a character is failed to load, we'll use this character.
     */
    public static var fallback_character:String = "bf";
    /**
     * This character's configuration data.
     */
    public var data:CharacterData = null;
    public var icon:FlxGraphic;
    public var isPlayer:Bool = false;
    
    /**
     * Defines whether this character is currently singing.
     */
    public var singing(get,never):Bool;
    function get_singing():Bool {
        if (animation == null || animation.curAnim == null) return false;
        return animation.curAnim.name.startsWith("sing");
    }
    public var name:String = "";
    public var holdTimer:Float = 0;

    public function new(nX:Float, nY:Float, name:String, player:Bool, ?death:Bool = false) {
        super(nX,nY);
        this.name = name;

        var _data:CharacterAssets = getCharacterAssets(name, death);
        if (_data.atlas != null)
            frames = _data.atlas;
        isPlayer = flipX = player;
        if (_data.data == null) 
            return;
        data = _data.data;
        if (data.flip_x)
            flipX = !flipX;
        icon = _data.icon;
        x += (isPlayer ? -data.position_offset.x : data.position_offset.x);
        y += data.position_offset.y;
        loadAnimations(data);
    }

    public function getCharacterAssets(name:String,death:Bool) {
        var _data:CharacterAssets = null;
        try {
            _data = Assets.character(name, death);
        } catch (e) {
            Log.warn("Could not load character file: " + name + ", " + e.toString());
            _data = Assets.character(fallback_character, death);
        }
        return _data;
    }

    public function loadAnimations(data:CharacterData) {
        for (anim in data.animations) {
            if (anim.indices != null && anim.indices.length > 0)
                animation.addByIndices(anim.name, anim.prefix, anim.indices, "", anim.fps, anim.loop);
            else
                addAnim(anim.name, anim.prefix, anim.fps, anim.loop);

            if (anim.offset != null)
                addOffset(anim.name, anim.offset.x, anim.offset.y);
        }
        playAnim("idle");
    }

    public function getBarColor():FlxColor {
        return FlxColor.fromRGB(data.bar_color[0], data.bar_color[1], data.bar_color[2]);
    }

    override function update(elapsed:Float) {
        if (singing) {
            holdTimer += elapsed;
            if (holdTimer > (Conductor.instance.beat_ms * data.hold_time) / 1000) {
                holdTimer = 0;
                dance(true);
            }
        }
        super.update(elapsed);
    }

    var _danceLeft:Bool = false;
    public function dance(?force:Bool = false) {
        if (singing && !force) return;
        if (animOffsets.exists("idle"))
            playAnim("idle");
        else if (animOffsets.exists("danceLeft") && animOffsets.exists("danceRight")) {
            playAnim(_danceLeft ? "danceLeft" : "danceRight");
            _danceLeft = !_danceLeft;
        }
    }

    override function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
        if (animation == null ||!animation.exists(animName)) return;
        holdTimer = 0;
        // If flipX is true, we need to flip the animation names as well.
        if (flipX && (animName == "singLEFT" || animName == "singRIGHT")) 
            animName = (animName == "singLEFT" ? "singRIGHT" : "singLEFT");
        super.playAnim(animName, force, reversed, frame);
    }
}

typedef CharacterData = {
    var animations:Array<AnimationData>;
    var antialiasing:Bool;
    var graphic_path:String;
    var position_offset:{x:Float,y:Float};
    var icon:String;
    var flip_x:Bool;
    var bar_color:Array<Int>;
    var camera_offset:{x:Float,y:Float};
    var char_scale:Float;
    var hold_time:Float;
}

typedef AnimationData = {
    var loop:Bool;
    var offset:{x:Float,y:Float};
    var name:String;
    var fps:Int;
    var prefix:String;
    var indices:Array<Int>;
}