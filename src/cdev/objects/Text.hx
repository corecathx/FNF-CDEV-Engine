package cdev.objects;

import flixel.util.FlxColor;
import flixel.text.FlxText;

class Text extends FlxText {
	public function new(nX:Float, nY:Float, nText:String, ?align:FlxTextAlign = LEFT, ?nSize:Int = 16) {
		super(nX, nY, -1, nText, nSize);
		setFormat(Assets.fonts.VCR, nSize, FlxColor.WHITE, align, OUTLINE, FlxColor.BLACK);
        active = false;
	}
}
