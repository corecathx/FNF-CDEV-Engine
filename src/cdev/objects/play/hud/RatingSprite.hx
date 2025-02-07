package cdev.objects.play.hud;



enum abstract Rating(String) from String to String {
    var SICK = "sick";
    var GOOD = "good";
    var BAD = "bad";
    var SHIT = "shit";
}

/**
 * That little pop up sprite that shows up when you hit a note.
 */
class RatingSprite extends Sprite {
    public var scaling:Float = 0.5;
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

    override function draw() {
        super.draw();
        forEachCombo((spr,index) -> {
            spr.alpha = alpha;
            spr.draw();
        });
    }

    var _fadeTime:Float = 0;
    override function update(elapsed:Float) {
        forEachCombo((spr,index) -> {
            spr.update(elapsed);
        });
        if (!visible) return;
    
        _fadeTime += elapsed;
        if (_fadeTime >= (Conductor.instance.beat_ms * 2)/1000) {
            alpha -= (1/0.2) * elapsed;
            if (alpha <= 0) {
                alpha = 0;
                _fadeTime = 0;
                visible = false;
                destroyAllCombos();
            }
        }
    
        super.update(elapsed);
    }
    

    /**
     * Shows the rating sprite.
     * @param rating Rating
     */
    public function show(rating:Rating, combo:Int) {
        _fadeTime = 0;
        updateProperty(true);

        var _castRating:String = cast rating;
        loadGraphic(Assets.image('hud/ratings/$_castRating'));
        updateProperty();
        setPosition(startPos.x - (width * 0.5), startPos.y - (height * 0.5));
        
        showCombo(combo);
    }

    public function showCombo(combo:Int) {
        destroyAllCombos();
        var comboSegments:Array<String> = Std.string(combo).split("");
        var wholeWidth:Float = 0;
        for (index => _combo in comboSegments){
            var spr:Sprite = new Sprite().loadGraphic(Assets.image('hud/ratings/num${_combo}'));
            spr.x = this.x + wholeWidth;
            spr.y = this.y + height;
            spr.cameras = this.cameras;

            spr.scale.set(scaling-0.15,scaling-0.15);
            spr.updateHitbox();

            spr.acceleration.y = FlxG.random.int(200, 300);
            spr.velocity.y -= FlxG.random.int(140, 160);
            spr.velocity.x = FlxG.random.float(-5, 5);

            combos.push(spr);
            wholeWidth += spr.width;
        }
        forEachCombo((spr,index)->{
            spr.x -= wholeWidth*0.5;
        });
    }

    public function destroyAllCombos() {
        forEachCombo((spr,index)->{
            combos.remove(spr);
            spr.destroy();
        });

        combos = [];
    }

    public function forEachCombo(callback:(Sprite, Int)->Void) {
        for (index => spr in combos) {
            if (spr == null) {
                if (Preferences.verboseLog)
                    trace("Combo at "+index+" is null.");
                continue;
            }
            callback(spr,index);
        }
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
        scale.set(scaling,scaling);
        updateHitbox();
    }
}