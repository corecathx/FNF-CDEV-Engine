package flixel.system.ui;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
#end

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * Helps display the volume bars on the sound tray.
	 */
	var _bars:Array<Bitmap>;

	/**
	 * How wide the sound tray background is.
	 */
	var _width:Int = 80;

	var _defaultScale:Float = 2.0;

	/**The sound used when increasing the volume.**/
	public var volumeUpSound:String = "flixel/sounds/beep";

	/**The sound used when decreasing the volume.**/
	public var volumeDownSound:String = 'flixel/sounds/beep';

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;

    /**Text object of the Sound Tray.**/
    public var text:TextField;

	/**Tweening handler since it's better imo**/
    public var tween:FlxTween;
    public var calledTween:Bool = false;

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	@:keep
	public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 30, true, 0x7F000000));
		screenCenter();
		addChild(tmp);

		text = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		var dtf:TextFormat = new TextFormat("VCR OSD Mono", 10, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
        text.text = "MASTER";
		//text.text = "VOLUME";
		text.y = 16;

		var bx:Int = 10;
		var by:Int = 14;
		_bars = new Array();

		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4, i + 1, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = by;
			addChild(tmp);
			_bars.push(tmp);
			bx += 6;
			by--;
		}

		y = -height;
		visible = false;
	}

	/**
	 * This function updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		// Animate sound tray thing
        if (_timer > 0)
        {
            _timer -= MS/1000;
            calledTween = false;
        } else {
            if (!calledTween){
                calledTween = true;

                if (tween != null) tween.cancel();
                tween = FlxTween.tween(this, {y:-height, alpha: 0}, 1,{ease:FlxEase.backInOut, onComplete:function(elwawa){
                    visible = false;
                    active = false;
    
                    #if FLX_SAVE
                    // Save sound preferences
                    if (FlxG.save.isBound)
                    {
                        FlxG.save.data.mute = FlxG.sound.muted;
                        FlxG.save.data.volume = FlxG.sound.volume;
                        FlxG.save.flush();
                    }
                    #end
                    tween = null;
                }});
            }

        }

		/* backup
        if (_timer > 0)
		{
			_timer -= (MS / 1000);
		}
		else if (y > -height)
		{
			y -= (MS / 1000) * height * 0.5;

			if (y <= -height)
			{

			}
		}*/
	}

	/**The sound used by CDEV Engine when increasing the volume.**/
	public var volumeUpSFX:String = "volumeUp";

	/**The sound used by CDEV Engine when decreasing the volume.**/
	public var volumeDownSFX:String = 'volumeDown';

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	up Whether the volume is increasing.
	 */
	public function show(up:Bool = false):Void
	{
		if (!silent)
		{
			//var sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
            var sound = Paths.sound(up ? volumeUpSFX : volumeDownSFX);
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		_timer = 1.5;
        calledTween = false;
        if (tween != null) tween.cancel();
        tween = FlxTween.tween(this, {y:0, alpha:1}, 0.5,{ease:FlxEase.cubeOut, onComplete:function(elwawa){
            tween = null;
        }});

		visible = true;
		active = true;

		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);
		if (FlxG.sound.muted) globalVolume = 0;

        text.text = FlxG.sound.muted ? "MUTED" : "MASTER";

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
			{
				_bars[i].alpha = 1;
			}
			else
			{
				_bars[i].alpha = 0.5;
			}
		}
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}
}
#end
