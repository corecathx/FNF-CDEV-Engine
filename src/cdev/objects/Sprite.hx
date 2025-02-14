package cdev.objects;

import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;

typedef SpriteGroup = FlxTypedSpriteGroup<Sprite>;

/**
 * Sprite is just Sprite but with additional helper functions.
 */
class Sprite extends FlxSprite {
    public var name:String = "";
    public var zIndex:Int = 0; // used on gameplay, that's it.
    /**
     * Contains an animation specific offsets.
     */
    public var animOffsets:Map<String,Axis2D> = [];

    public function new(nX:Float = 0, nY:Float = 0, ?nGraphic:FlxGraphicAsset) {
        super(nX,nY);
        if (nGraphic != null) 
            loadGraphic(nGraphic);

        antialiasing = Preferences.antialiasing;
    }

    /**
     * A shortcut to `animation.addByPrefix`.
     */
    public function addAnim(name:String, prefix:String, frameRate:Float = 30.0, looped:Bool = true, flipX:Bool = false, flipY:Bool = false) {
        // check if any exists
        var exists:Bool = false;
        for (frame in frames.frames) {
            if (frame.name != null && frame.name.startsWith(prefix)){
                exists = true;
                break;
            }
        }
        if (exists)
            animation.addByPrefix(name,prefix,frameRate,looped,flipX,flipY);
        else 
            if (Preferences.verboseLog)
                Log.warn('Could not find animation prefix $prefix for $name.');
    }

    /**
     * Sets XY scaling properties of this sprite equally.
     * @param value The scaling value.
     * @param noHitbox Whether to not update this sprite's hitbox
     */
    public function setScale(value:Float, noHitbox:Bool = false) {
        scale.set(value,value);
        if (!noHitbox)
            updateHitbox();
    }

    /**
     * Add a custom offset for specific animation.
     * @param anim Your animation's name.
     * @param offsetX The X offset.
     * @param offsetY The Y offset.
     */
    public function addOffset(anim:String,offsetX:Float,offsetY:Float) {
        animOffsets[anim] = {
            x: offsetX, 
            y: offsetY
        }
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
            var offsets:Axis2D = {
                x: (savedOffset.x * (flipX ? -1 : 1)) + (flipX ? frameWidth - width : 0),
                y: savedOffset.y
            }

            var radians = angle * Math.PI / 180;
            offset.set(
                offsets.x * Math.cos(radians) - offsets.y * Math.sin(radians),
                offsets.x * Math.sin(radians) + offsets.y * Math.cos(radians)
            );
        }
    }
    
    

    override function makeGraphic(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):Sprite {
        return cast super.makeGraphic(Width, Height, Color, Unique, Key);
    }

    override function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0, unique:Bool = false, ?key:String):Sprite {
        return cast super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
    }
}