package game.objects;

import meta.modding.chart_editor.ChartEditor;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import game.cdev.script.HScript;
import flixel.FlxSprite;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class ChartEvent extends FlxSprite
{
	// Put your codes here incase you want to hardcode your song events
	public static var builtInEvents:Array<Dynamic> = [
		[
			"Change Camera Focus",
			"Set the camera's focus target.\n\nValue 1: Character (dad, bf, gf)"
		],
		[
			"Change BPM",
			"Set current song's BPM.\n\nValue 1: New BPM (Float)"
		],
		[
			'Add Camera Zoom',
			"Change how much does the camera zoom should\nbe added (like M.I.L.F's \"banger\" part)\n\n Value 1: Camera to zoom (gameCam or hudCam)\nValue 2: Zoom to add to the camera (Float)"
		],
		[
			'Force Camera Position',
			"Move the camera position to a specific position\n(The camera position will be locked to your position values, leave the value 1 and 2 blank to unlock the camera)\n\nValue 1: Position X\nValue 2: Position Y"
		],
		[
			'Play Animation',
			"Playing an animation for a character\n\nValue 1: Character (dad, gf, bf)\nValue 2: Animation prefix to play"
		],
		[
			'Change Scroll Speed',
			"Change your song scroll speed\n\nValue 1: New Scroll Speed\nValue 2: Leave it blank"
		],
		[
			'Screen Shake',
			'Shaking a camera object for specific seconds.\n\nValue 1: Shake Properties\nValue 2: Camera Object (gameCam or hudCam)\n\nUsage Example:\nValue 1: 1, 0.05 (Duration, Intensity)\nValue 2: gameCam (this will shake the main camera)'
		],
		[
			"Play Sound",
			"Just like it's name, it plays a sound.\n\nValue 1: Sound File Name\nValue 2: Volume ranging from 0 to 1 (Default is 1)"
		],
		[
			"Idle Suffix",
			"Whether to set a specified suffix after the idle animation name.\nThe animation will be called when Alternate Animation is true.\n\nValue 1: Character to set the prefix (dad, bf, gf)\nValue 2: New Suffix (Default is \"-alt\")"
		]
	];

	public var EVENT_NAME:String = '';
	public var time:Float = 0;
	public var data:Int = 0;

	public var value1:String = '';
	public var value2:String = '';

	public var mod:String = '';

	var chartMode:Bool = false;

	public function new(strumTime:Float, noteData:Int, ?charting:Bool = false)
	{
		super(x, y);
		time = strumTime;
		data = noteData;
		chartMode = charting;
	}

	public function prepare(info:Array<Dynamic>) {
		if (info == null) {
			Log.warn("Initializing ChartEvent object with null data, what??");
			return;
		}
		EVENT_NAME = info[0];
		data = info[1];
		time = info[2];
		value1 = info[3];
		value2 = info[4];

		if (chartMode){
			var graphicy = Paths.image("ui/event/"+EVENT_NAME, "shared");
			if (graphicy == null) 
				graphicy = Paths.image("ui/event/Default", "shared");

			loadGraphic(graphicy);
			setGraphicSize(ChartEditor.grid_size,ChartEditor.grid_size);
			updateHitbox();
		}

	}

	public static function getEventNames():Array<String>
	{
		var eventNames:Array<String> = [];
		#if sys
		var path:Array<String> = [];
		var canDoShit = false;
		if (FileSystem.exists(Paths.modFolders("events/"))){ //support for older cdev engine version
			path = FileSystem.readDirectory(Paths.modFolders("events/"));
			canDoShit = true;
		}
		if (canDoShit){
			if (path.length >= 0)
				{
					for (i in 0...path.length)
					{
						var event:String = path[i];
						if (event.endsWith(".txt"))
						{
							event = event.substr(0, event.length - 4);
							eventNames.push(event);
							trace("loaded " + event);
						}
					}
				}
				else
				{
					return ["No Events Found."];
				}
		} else{
			return ["No Events Found."];
		}
		#else
		trace("This is not a sys target, could not get event names.");
		return ["No Events Found."];
		#end

		return eventNames;
	}

	// the variable "event" is the event's name.
	public static function getEventDescription(event:String = ""):String
	{
		var eventDescription:String = "";
		#if sys
		var path:Array<String> = [];
		var canDoShit = false;
		if (FileSystem.exists(Paths.modFolders("events/"))){ //support for older cdev engine version
			path = FileSystem.readDirectory(Paths.modFolders("events/"));
			canDoShit = true;
		}
		if (canDoShit){
			if (path.length >= 0)
			{
				for (i in 0...path.length)
				{
					var file:String = path[i];
					var desc:String = "";
					if (file.substr(0, file.length - 4) == event)
					{
						if (file.endsWith(".txt"))
						{
							desc = File.getContent(Paths.modFolders("events/" + file));
							eventDescription = desc;
							// trace("desc " + event); nah man
						}
					}
				}
			}
		}
		#else
		trace("This is not a sys target, could not get event description for "+event+".");
		#end
		return eventDescription;
	}
}