package cdev.graphics.shaders;

import flixel.addons.display.FlxRuntimeShader;

class BorderShader extends FlxRuntimeShader {
    public var borderWidth(default, set):Float;
    public var borderVisible(default, set):Bool;

    public function new() {
        super(Assets.frag('border'));
        borderWidth = 0.1;
        borderVisible = true; 
    }

    function set_borderWidth(value:Float):Float {
        setFloat('borderWidth', borderWidth = value);
        return borderWidth;
    }

    function set_borderVisible(value:Bool):Bool {
        setBool('borderVisible', borderVisible = value);
        return borderVisible;
    }

    override public function toString():String {
        return 'BorderShader(${this.borderWidth}, ${this.borderVisible})';
    }
}
