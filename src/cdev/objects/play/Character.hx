package cdev.objects.play;

class Character extends Sprite {
    /**
     * This character's configuration data.
     */
    public var data:CharacterData = null;
    
    /**
     * Defines whether this character is currently singing.
     */
    public var singing(get,never):Bool;
    function get_singing():Bool {
        if (animation.curAnim == null) return false;
        return animation.curAnim.name.startsWith("sing");
    }

    public var holdTimer:Float = 0;

    public function new(nX:Float, nY:Float, name:String, player:Bool) {
        super(nX,nY);
        var _data:CharacterAssets = Assets.character(name);
        if (_data.atlas != null)
            frames = _data.atlas;
        flipX = player;
        if (_data.data == null) return;
        data = _data.data;
        loadAnimations(data);
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

    override function update(elapsed:Float) {
        if (singing) {
            holdTimer += elapsed;
            if (holdTimer > (Conductor.current.beat_ms * data.hold_time)/1000) {
                holdTimer = 0;
                dance(true);
            }
        }
        super.update(elapsed);
    }

    public function dance(?force:Bool = false) {
        if (singing && !force) return;
        playAnim("idle");
    }

    override function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
        holdTimer = 0;
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