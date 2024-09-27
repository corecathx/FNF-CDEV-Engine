package cdev.objects.notes;

import flixel.graphics.FlxGraphic;

class Sustain extends Sprite {
    public var parent:Note = null;
    public function new(parent:Note) {
        super(0,0);
        this.parent = parent;
        this.frames = parent.frames;
    }

    public function init() {
        var _colorData:String = Note.animColor[parent.data];
        addAnim("idle", _colorData + " hold piece", 24);
        var bit:FlxGraphic = new FlxGraphic();
        // playAnim("idle",true);
    }

    override function draw() {
        super.draw();
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
    }
}