package cdev.objects.play.hud;

import flixel.graphics.FlxGraphic;

enum abstract Rating(String) from String to String {
    var SICK = "sick";
    var GOOD = "good";
    var BAD = "bad";
    var SHIT = "shit";
    var MISS = "miss";
}

/**
 * That little pop up sprite that shows up when you hit a note.
 */
class RatingSprite extends Sprite {
    public var startPos:{x:Float,y:Float} = {x:0,y:0};
    public var combos:Array<Sprite> = [];

    /**
     * Initializes the rating sprite.
     */
    public function new(startX:Float = 0, startY:Float = 0) {
        super();
        startPos.x = startX;
        startPos.y = startY;
    }

    var _fadeTime:Float = 0;
    override function update(elapsed:Float) {
        if (!visible) return;
    
        _fadeTime += elapsed;
        if (_fadeTime >= (Conductor.current.beat_ms * 2)/1000) {
            alpha -= (1/0.2) * elapsed;
            if (alpha <= 0) {
                alpha = 0;
                _fadeTime = 0;
                visible = false;
            }
        }
    
        super.update(elapsed);
    }
    

    /**
     * Shows the rating sprite.
     * @param rating Rating
     */
    public function show(rating:Rating) {
        _fadeTime = 0;
        updateProperty(true);

        var _castRating:String = cast rating;
        loadGraphic(Assets.image('ratings/$_castRating'));
        updateProperty();

        setPosition(startPos.x - (width * 0.5), startPos.y - (height * 0.5));
    }

    public function updateProperty(reset:Bool = false) {
        if (reset) {
            acceleration.y = 0;
            velocity.set();
        } else {
            acceleration.y = 550;
            velocity.y -= FlxG.random.int(140, 175);
            velocity.x -= FlxG.random.int(0, 10);
        }
        visible = true;
        alpha = 1;
        scale.set(0.6,0.6);
    }
}