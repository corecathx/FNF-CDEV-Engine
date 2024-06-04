function postCreate() {
    trace("loaded");
}
var scaling:Float = 1;
function update(e){
    if (FlxG.keys.pressed.Q){
        PlayState.songSpeed -= 0.001;
    }

    if (FlxG.keys.pressed.E){
        PlayState.songSpeed += 0.001;
    }
    scaling = FlxMath.lerp(1, PlayState.scoreTxt.scale.x, 1-(e*12));
    PlayState.scoreTxt.scale.set(scaling,scaling);
    //PlayState.scoreTxt.size = 18;
}

function p1NoteHit(a, b)
{
    if (!b)
        PlayState.scoreTxt.scale.x += 0.1;
}