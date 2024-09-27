package cdev.objects;

import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;

typedef SpriteGroup = FlxTypedSpriteGroup<Sprite>;

/**
 * Sprite is just FlxSprite but with additional helper functions.
 */
class Sprite extends FlxSprite {
    /**
     * Contains an animation specific offsets.
     */
    public var animOffsets:Map<String,Array<Float>> = [];

    public function new(nX:Float = 0, nY:Float = 0, ?nGraphic:FlxGraphicAsset) {
        super(nX,nY);
        if (nGraphic != null) 
            loadGraphic(nGraphic);

        antialiasing = EnginePrefs.antialiasing;
    }

    /**
     * A shortcut to `animation.addByPrefix`.
     */
    public function addAnim(name:String, prefix:String, frameRate:Float = 30.0, looped:Bool = true, flipX:Bool = false, flipY:Bool = false) {
        animation.addByPrefix(name,prefix,frameRate,looped,flipX,flipY);
    }

    /**
     * Add a custom offset for specific animation.
     * @param anim Your animation's name.
     * @param offsetX The X offset.
     * @param offsetY The Y offset.
     */
    public function addOffset(anim:String,offsetX:Float,offsetY:Float) {
        animOffsets[anim] = [offsetX, offsetY];
    }

    /**
     * A shortcut to `animation.play`, also applies custom offsets.
     * @param animName Animation's name that will be played.
     * @param force Whether to force the animation to play.
     * @param reversed Whether to play the animation backwards.
     * @param frame Whether to start the animation at specific frame.
     */
    public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
        animation.play(animName, force, reversed, frame);

        if (animOffsets.exists(animName)) {
            var savedOffset = animOffsets.get(animName);
            offset.set(savedOffset[0], savedOffset[1]);
        } else {
            offset.set(0, 0);
        }
    }

    override function makeGraphic(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):Sprite {
        return cast super.makeGraphic(Width, Height, Color, Unique, Key);
    }

    override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):FlxSprite {
        return cast super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
    }
}