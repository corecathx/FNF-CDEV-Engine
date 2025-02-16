package cdev.objects.ui;

class Button extends Panel {
    public var label:Text;
    public var toggled:Bool = true;

    public var isToggle:Bool = false;
    public var onClick:Bool->Void = (status:Bool = false)->{};
    public function new(nX:Float, nY:Float, text:String, onClick:Bool->Void) {
        super(nX, nY, 20, 20);
        this.onClick = onClick;
        label = new Text(0,0,text,CENTER,14);
        label.font = Constants.UI_FONT;

        setSize(label.width + 2, label.height + 2);
    }

    override function draw():Void {
        label.setPosition(
            x + (width - label.width) * 0.5,
            y + (height - label.height) * 0.5
        );

        if (isToggle) {
            label.alpha = toggled ? 1 : 0.5;
        }

        if (isToggle)
            alpha = toggled ? 1 : 0.5;
        else
            alpha = 0.7;
        if (FlxG.mouse.overlaps(this)) {
            alpha = FlxG.mouse.pressed ? 0.7 : 1;
            if (FlxG.mouse.justReleased) {
                if (isToggle) toggled = !toggled; // Toggle state
                onClick(toggled);
            }
        }
        
        super.draw();
        label.draw();
    }
}