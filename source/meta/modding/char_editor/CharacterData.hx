package meta.modding.char_editor;

import flixel.input.keyboard.FlxKey;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef CharData =
{
    //animations
	var animations:Array<AnimationArray>; 
	var charXYPosition:Array<Float>;
	var camXYPos:Array<Float>;
	var usingAntialiasing:Bool;
	var singHoldTime:Float;
	var charScale:Float;

    //spritesheets
    var spritePath:String;
    var iconName:String;
    var healthBarColor:Array<Int>;
    var flipX:Bool;
}

typedef AnimationArray =
{
	var animPrefix:String;
	var animName:String;
	var fpsValue:Null<Int>;
	var looping:Null<Bool>;
	var indices:Array<Int>;
	var offset:Array<Int>;
}

class CharacterData
{
   //animations
   public var animations:Array<AnimationArray> = []; 
   public var charXYPosition:Array<Float> = [0,0];
   public var camXYPos:Array<Float> = [0,0];
   public var usingAntialiasing:Bool = false;
   public var singHoldTime:Float = 4;
   public var charScale:Float = 1;

   //spritesheets
   public var spritePath:String = "characters/BOYFRIEND";
   public var iconName:String = "bf";
   public var healthBarColor:Array<Int> = [30,149,179];
   public var flipX:Bool = false;

	public function new()
	{
	}
}
