package modding;

import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef WeekFile =
{
    var weekTxtImgPath:String;
    var weekName:String;
    var weekCharacters:Array<String>; //[dad,bf,gf]
    var tracks:Array<String>; //[1,2,3];
    var charSetting:Array<WeekChar>;
}

typedef WeekChar = 
{
    var position:Array<Float>;
    var scale:Float;
    var flipX:Bool;
}

class WeekData
{
	public function new()
	{
	}
}
