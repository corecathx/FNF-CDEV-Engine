package cdev.objects;

import flixel.util.FlxColor;
import flixel.text.FlxText;

class Text extends FlxText {
	public var panelBG:Sprite;
	public var bgPadding:Float = 10;
	public var enableBG(default,set):Bool = false;
	function set_enableBG(val:Bool) {
		return enableBG = val;
	}
	public function new(nX:Float, nY:Float, nText:String, ?align:FlxTextAlign = LEFT, ?nSize:Int = 16) {
		super(nX, nY, -1, nText, nSize);
		setFormat(Assets.fonts.VCR, nSize, FlxColor.WHITE, align, OUTLINE, FlxColor.BLACK);
        active = false;
        antialiasing = Preferences.antialiasing;

		panelBG = new Sprite().makeGraphic(1,1,FlxColor.WHITE);
		panelBG.color = FlxColor.BLACK;
		panelBG.active = false;
		panelBG.alpha = 0.4;
	}

	override function draw() {
		if (panelBG != null && enableBG) {
			panelBG.cameras = cameras;
			panelBG.setGraphicSize(width+bgPadding+10,height+bgPadding);
			panelBG.updateHitbox();
			panelBG.setPosition(x - ((bgPadding+10) * 0.5), y - (bgPadding * 0.5));
			panelBG.draw();
		}
		super.draw();
	}

	// Just to make sure the graphic doesn't regenerate when we update the text..
	override function set_text(val:String):String
	{
		if (val == text) return text;
		text = val;
		if (textField != null)
		{
			var ot:String = textField.text;
			textField.text = val;
			_regen = (textField.text != ot) || _regen;
		}
		return text;
	}
}
