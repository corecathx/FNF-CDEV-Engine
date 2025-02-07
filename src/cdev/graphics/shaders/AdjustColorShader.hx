package cdev.graphics.shaders;

import flixel.addons.display.FlxRuntimeShader;

class AdjustColorShader extends FlxRuntimeShader {
    public var hue(default, set):Float;
    public var saturation(default, set):Float;
    public var brightness(default, set):Float;
    public var contrast(default, set):Float;

    public function new() {
        super(Assets.frag('adjustColor'));
        hue = 0;
        saturation = 0;
        brightness = 0;
        contrast = 0;
    }

    function set_hue(value:Float):Float {
        setFloat('hue', hue = value);
        return hue;
    }

    function set_saturation(value:Float):Float {
        setFloat('saturation', saturation = value);
        return saturation;
    }

    function set_brightness(value:Float):Float {
        setFloat('brightness', brightness = value);
        return brightness;
    }

    function set_contrast(value:Float):Float {
        setFloat('contrast', contrast = value);
        return contrast;
    }

    override public function toString():String {
        return 'AdjustColorShader(${this.hue}, ${this.saturation}, ${this.brightness}, ${this.contrast})';
    }
}