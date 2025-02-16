package cdev.objects.ui;

import cdev.graphics.MaterialIcon;

class Checkbox extends Sprite {
    var check:Sprite;
    public var checked:Bool = false;
    public var label:Text;
    public var onCheckChanged:Bool->Void = (_)->{}
    public function new(nX:Float, nY:Float, text:String, ?onCheckChanged:Bool->Void):Void {
        super(nX,nY);
        if (onCheckChanged != null)
            this.onCheckChanged = onCheckChanged;

        loadGraphic(Assets.image('ui/rectangle'));
        setGraphicSize(20,20);
        updateHitbox();

        check = new Sprite().loadGraphic(Assets.image("ui/icons/check"));
        check.setGraphicSize(width,height);
        check.updateHitbox();

        label = new Text(0,0,text,LEFT,14);
        label.font = Constants.UI_FONT;
    }

    override function draw() {
        super.draw();

        alpha = 0.7;
        if (FlxG.mouse.overlaps(this)) {
            alpha = FlxG.mouse.pressed ? 0.5 : 1;

            if (FlxG.mouse.justReleased) {
                checked = !checked;
                onCheckChanged(checked);
            }
        }

        check.setPosition(
            x + (width - check.width) * 0.5,
            y + (height - check.height) * 0.5
        );
        if (checked)
            check.draw();

        label.setPosition(
            x + width + 10,
            y + (height - label.height) * 0.5
        );
        label.draw();
    }
}