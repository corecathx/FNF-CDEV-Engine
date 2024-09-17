package cdev.objects.notes;

import openfl.display.BitmapData;
import flixel.addons.display.FlxTiledSprite;

class Sustain extends Sprite {
    public var parent:Note = null;
    public function new(parent:Note) {
        super(0,0);
        this.parent = parent;
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
    }
}