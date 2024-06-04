var hxSprites:Array<Dynamic> = []; //[name, sprite]
function makeSprite(name, x,y,graphic){
    var sprite:FlxSprite = new FlxSprite(x,y).loadGraphic(Paths.image(graphic));
    hxSprites.push([name, sprite]);
    add(sprite);
}