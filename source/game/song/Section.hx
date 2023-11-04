package game.song;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>; // strumtime, notedata, sustain, //new: notetype
	var sectionEvents:Array<Dynamic>; // eventName, data, strumtime, val1, val2
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var banger:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
	var p1AltAnim:Bool;
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];
	public var sectionEvents:Array<Dynamic> = [];
	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;
	public var banger:Bool = false;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}
