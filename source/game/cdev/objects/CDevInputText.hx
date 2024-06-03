package game.cdev.objects;

import flixel.addons.ui.FlxInputText;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.addons.ui.FlxUIInputText;

/**
 * Textbox Object for CDEV Engine since FlxInputText sometimes buggy
 */
class CDevInputText extends FlxInputText {
    public var onTextChanged:String->Void = (nT:String)->{}; //what to do when text changed
    override function set_text(Text:String):String {
        if (onTextChanged != null)
            onTextChanged(Text);
        return super.set_text(Text);
    }

    public var onFocus(default,set):Bool->Void = (nF:Bool)->{}; //what to do when textbox focused
    function set_onFocus(newStuff:Bool->Void):Bool->Void{
        focusGained = ()->{
            newStuff(true);
        }
        focusLost = ()->{
            newStuff(false);
        }
        return onFocus = newStuff;
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ENTER && hasFocus){
            hasFocus = false;
            if (focusLost != null)
                focusLost();
        }
        super.update(elapsed);
    }

    override private function drawSprite(Sprite:FlxSprite):Void
    {
        if (Sprite == null) return;
        if (Sprite.shader == null && Sprite.graphic.isDestroyed) return;

        Sprite.scrollFactor = scrollFactor;
        Sprite._cameras = _cameras;
        Sprite.alpha = alpha;
        Sprite.draw();
    }
}