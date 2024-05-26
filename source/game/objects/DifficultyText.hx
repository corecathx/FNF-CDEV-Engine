package game.objects;

class DifficultyText extends FlxText {
    var lAXpos:Float = 0;
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;
    public function new(nX:Float,nY:Float){
        super(nX,nY,-1,"",44);
        var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
        leftArrow = new FlxSprite();
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
        leftArrow.scale.set(0.7, 0.7);
        leftArrow.updateHitbox();

        setFormat(FunkinFonts.DIFF, 44, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);

        rightArrow = new FlxSprite();
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', "arrow right");
		rightArrow.animation.addByPrefix('press', "arrow push right");
		rightArrow.animation.play('idle');
        rightArrow.scale.set(0.7, 0.7);
        rightArrow.updateHitbox();
        changeDiff("easy");
    }

    public function changeDiff(diff:String) {
        text = diff;
        var c = FlxColor.WHITE;
		switch (text.toLowerCase()){ //i'm stupid 🙏
			case "easy":
				c = FlxColor.LIME;
			case "normal":
				c = FlxColor.YELLOW;
			case "hard":
				c = FlxColor.RED;
            case "fucked" | "night":
                c = FlxColor.PURPLE;
            case "erect":
                c = FlxColor.MAGENTA;
		}
		color = c;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (active && visible){
            if (FlxG.keys.pressed.RIGHT)
                rightArrow.animation.play('press',true);
            else
                rightArrow.animation.play('idle',true);

            if (FlxG.keys.pressed.LEFT)
                leftArrow.animation.play('press',true);
            else
                leftArrow.animation.play('idle',true);
        }
    }

    override function draw() {
        super.draw();
        leftArrow.x = x - (leftArrow.width+20);
        leftArrow.y = y+(leftArrow.height-height)*0.5;
        leftArrow.draw();

        rightArrow.x = x + width + 20;
        rightArrow.y = y+(rightArrow.height-height)*0.5;
        rightArrow.draw();

        leftArrow.visible = rightArrow.visible = visible;
    }
}