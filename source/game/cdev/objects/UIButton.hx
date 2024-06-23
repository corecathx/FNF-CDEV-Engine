package game.cdev.objects;

class UIButton extends FlxSprite {
    public var icon:FlxSprite;
    public var callback:Void->Void;
    public function new(nX:Float, nY:Float, name:Array<String>, callback:Void->Void) {
        super(nX,nY);
        this.callback = callback;
        makeGraphic(70,70);
        color = 0xFF000000;
     
        icon = new FlxSprite();
        icon.frames = Paths.getSparrowAtlas("ui/icon_stuffs","shared");
        for (i in name) {
            icon.animation.addByPrefix(i, i, 24);
            icon.animation.play(i, true);
        }
        //icon.antialiasing = CDevConfig.saveData.antialiasing;
    }

    override function draw() {
        super.draw();

        icon.x = x+((70*0.5)-(icon.frameWidth*0.5));
        icon.y = y+((70*0.5)-(icon.frameHeight*0.5));
        icon.draw();
    }

    override function update(elapsed:Float) {
        if (FlxG.mouse.overlaps(this)){
            alpha = 1;
            if (FlxG.mouse.justPressed) {
                callback();
            }
        } else {
            alpha = 0.3;
        }
        super.update(elapsed);
    }
}