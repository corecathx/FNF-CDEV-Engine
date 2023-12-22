var lerpVal = 0;

function update(e)
{
    lerpVal = FlxMath.lerp(-506.89, lerpVal, 1-(e*20));
    getObject("bg").y = Math.floor(FlxMath.lerp(lerpVal, getObject("bg").y, 1-(e*10)));
}

function beatHit(b){
    lerpVal += 100;

    if (b == 172){
        FlxTween.tween(getObject("bfPixelBox"),{alpha:0}, (Conductor.crochet)/1000, {ease:FlxEase.circInOut});
        FlxTween.tween(getObject("bfPixelBox").scale,{x:0,y:0}, (Conductor.crochet)/1000, {ease:FlxEase.circInOut});
    }
}