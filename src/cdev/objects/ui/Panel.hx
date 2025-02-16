package cdev.objects.ui;

import flixel.addons.display.FlxSliceSprite;

class Panel extends FlxSliceSprite {
    public function new(x:Float, y:Float, width:Float, height:Float, suffix:String = '') {
        super(Assets.image("ui/rectangle" + (suffix.trim() != '' ? '-$suffix' : '')), new FlxRect(5, 5, 20, 20), width, height);
        setPosition(x, y);

        // this solved my memory leak problems :pray: :pray:
        stretchLeft = stretchTop = stretchRight = stretchBottom = stretchCenter = true;
    }
}
