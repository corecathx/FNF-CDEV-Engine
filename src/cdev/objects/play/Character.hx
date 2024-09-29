package cdev.objects.play;

class Character extends Sprite {
    public function new(nX:Float, nY:Float, name:String, player:Bool) {
        super(nX,nY);
        var _data:CharacterAssets = Assets.character(name);
        if (_data.atlas != null)
            frames = _data.atlas;
        flipX = player;
        loadAnimations(_data.data);
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

    public function dance() {
        if (animation.curAnim != null && animation.curAnim.name.startsWith("sing")) return;
        playAnim("idle");
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
}

typedef AnimationData = {
    var loop:Bool;
    var offset:{x:Float,y:Float};
    var name:String;
    var fps:Int;
    var prefix:String;
    var indices:Array<Int>;
}