package meta.modding;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import game.Paths;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class ModIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new(x:Float, y:Float, mod:String)
	{
		super(x,y);

		changeDaIcon(mod);
		scrollFactor.set();
	}
    var iconExist:Bool = false;
	public function changeDaIcon(mod:String) {
		//bruh.
		var name:String = 'icon';
        
        if (FileSystem.exists('cdev-mods/$mod/icon.png')){
            iconExist = true;
            name = 'cdev-mods/$mod/icon.png';
        } else{
            name = 'noIconMod';
        }

		var file:Dynamic = Paths.modImage(name,iconExist);
		//trace(file);

		loadGraphic(file);
        setGraphicSize(80,80); //keep the image size to 80x80.
        updateHitbox();

		antialiasing = CDevConfig.saveData.antialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 5);
	}

    function checkFile(key:String,mod:String, type:AssetType)
    {
        #if ALLOW_MODS
        if (FileSystem.exists(Paths.mods(mod + '/' + key)) || FileSystem.exists(Paths.mods(key)))
           return true;
        #end
    
        if (OpenFlAssets.exists(Paths.getPath(key, type)))
        {
            return true;
        }
        return false;
    }
    
}
