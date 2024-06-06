package game.cdev;

import game.cdev.song.CDevChart;
import game.song.Song;
import flixel.input.FlxPointer;
import meta.states.InitState;
import sys.io.File;
import haxe.Json;
import game.song.Song.SwagSong;
import meta.substates.CustomSubstate;
import flixel.sound.FlxSound;
import game.settings.data.SettingsProperties;
import meta.states.TitleState;
import flixel.addons.transition.FlxTransitionableState;
import meta.states.CustomState;
import flixel.FlxObject;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import haxe.io.Path;
import flixel.util.FlxAxes;
import game.Conductor;
import game.Conductor.BPMChangeEvent;
import flixel.ui.FlxButton;
import lime.system.Clipboard;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import sys.FileSystem;
import flixel.math.FlxMath;
import openfl.Assets;
import flixel.FlxG;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import game.Paths;

using StringTools;

enum TemplateData
{
	CHART;
	DISCORD;
}

typedef DiscordJson =
{
	var clientID:String; // client id, take it from discord developer portal
	var imageKey:String; // big image
	var imageTxt:String; // idk
}

/**
 * Utilization class for CDEV Engine.
 */
class CDevUtils
{
	public var CDEV_ENGINE_BLUE:Int = 0xff0088ff; // blueueue

	/**
	 * Chart Template, like, just a template.
	 */
	public final CHART_TEMPLATE:SwagSong = {
		song: 'Your Song',
		notes: [],
		songEvents: [],
		bpm: 150,
		needsVoices: true,
		player1: 'bf',
		player2: 'dad',
		gfVersion: 'gf',
		stage: 'stage',
		speed: 1,
		offset: 0,
		validScore: false
	};

	public final CDEV_CHART_TEMPLATE:CDevChart = {
		data: {
			player: "bf",
			opponent: "dad",
			third_char: "gf",
			stage: "stage",
			note_skin: "notes/NOTE_assets"
		},
		info: {
			name: "Your Song",
			composer: "Kawai Sprite",
			bpm: 120,
			speed: 1.5,
			time_signature: [4, 4], // since most of fnf songs are charted in 4/4 time signature, set this by default.
			version: CDevConfig.engineVersion
		},
		notes: [],
		events: []
	}

	/**
	 * Discord RPC Template
	 */
	public var RPC_TEMPLATE:DiscordJson = {
		clientID: CDevConfig.RPC_ID,
		imageKey: 'icon',
		imageTxt: 'CDEV Engine v' + CDevConfig.engineVersion
	};

	/**
	 * Contains bunch of blacklisted names for a folder / file in Windows.
	 */
	public var BLACKLISTED_NAMES:Array<String> = [
		"CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6",
		"LPT7", "LPT8", "LPT9"
	];

	/**
	 * Contains bunch of blacklisted names for a folder / file in Windows.
	 */
	public var BLACKLISTED_SYMBOLS:Array<String> = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"];

	public function getTemplate(type:TemplateData):Dynamic
	{
		switch (type)
		{
			case CHART:
				return CHART_TEMPLATE;
			case DISCORD:
				return RPC_TEMPLATE;
		}
		return null;
	}

	/**
	 * New Class instance.
	 */
	public function new()
	{
	}

	/**
	 * Returns total notes in a chart.
	 * @param chart Your chart file.
	 */
	public function getNotesTotal(chart:SwagSong)
	{
		var total:Int = 0;
		for (i in chart.notes)
		{
			for (j in i.sectionNotes)
				total++;
		}
		return total;
	}

	/**
	 * Reads the `songname`'s JSON files and returns the Difficulty names.
	 * @param songname 	The song's name.
	 * @param mod 		Whether if it's a mod or not.
	 * @return Array<String> 
	 */
	public function readChartJsons(songname:String, mod:Bool = false):Array<String>
	{
		// difficulties are created based on the file's filename, ex: tutorial-hard.json , the difficulty is "hard";
		var diffs:Array<String> = [];
		var fe:Array<String> = [];
		var p:String = "";
		if (!mod)
		{
			p = Paths.chartPath(songname);
			fe = FileSystem.readDirectory(Paths.chartPath(songname));
		}
		else
		{
			p = Paths.modChartPath(songname);
			fe = FileSystem.readDirectory(Paths.modChartPath(songname));
		}
		if (fe == null)
			return diffs;
		if (fe.length > 0) // my stupid ass put ">=" on the older version of the engine.
		{
			for (i in 0...fe.length)
			{
				if (fe[i].endsWith(".json"))
				{
					var a:String = fe[i].replace(songname, "");
					if (a.contains("-"))
					{
						var splittedName:Array<String> = a.replace(".json", "").split("-");

						// taking the last array
						diffs.push(splittedName[splittedName.length - 1]);
					}
					else
					{
						diffs.push("normal+");
					}
				}
			}
		}

		return diffs;
	}

	/**
	 * Sets `object` pitch to `pitch`
	 * @param object	FlxSound object.
	 * @param pitch		Pitch value for `object`.
	 */
	public function setSoundPitch(object:FlxSound, pitch:Float)
	{
		object.pitch = pitch;
	}

	/**
	 * Checks if `str` contains anything inside `CDevUtils.BLACKLISTED_SYMBOLS` array.
	 * @param str String to check. 
	 * @return Result.
	 */
	public function containsBlockedSymbol(str:String):Bool
	{
		for (i in BLACKLISTED_SYMBOLS)
		{
			if (str.contains(i))
				return true;
		}
		return false;
	}

	/**
	 * Auto-Capitalizing every words in a string.
	 * @param str Your String.
	 * @return Capitalized string.
	 */
	public function capitalize(str:String):String
	{
		var words = str.split(" ");
		for (i in 0...words.length)
		{
			var word = words[i];
			words[i] = word.substring(0, 1).toUpperCase() + word.substring(1);
		}
		return words.join(" ");
	}

	/**
	 * Checks if `str` matches anything inside `CDevUtils.BLACKLISTED_NAMES` array.
	 * @param str String to check. 
	 * @return Result.
	 */
	public function isBlockedWord(str:String):Bool
	{
		for (i in BLACKLISTED_NAMES)
		{
			if (i.toLowerCase() == str.toLowerCase())
				return true;
		}
		return false;
	}

	/**
	 * Bounds `toConvert` to `min` and `max`, shortcut to `FlxMath.bound`
	 * @param toConvert 
	 * @param min 
	 * @param max 
	 * @return Float
	 */
	public function bound(toConvert:Float, min:Float, max:Float):Float
	{
		return FlxMath.bound(toConvert, min, max); // ye
	}

	/**
	 * Custom RPC ID based on `mod`
	 * @return DiscordJson
	 */
	public function getRpcJSON():DiscordJson
	{
		var path:String = Paths.modsPath + "/" + Paths.currentMod + "/data/game/Discord.json";
		if (FileSystem.exists(path))
		{
			trace("Found RPC JSON.");
			var a:DiscordJson = cast Json.parse(File.getContent(path));
			return a;
		}
		trace("Couldn't find any.");
		return getTemplate(DISCORD);
	}

	/**
	 * Removes Symbols from a string.
	 * @param input		String that will be used for filtering.
	 * @return String	New string without the symbols.
	 */
	public function removeSymbols(input:String):String
	{
		var symbolsToRemove = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
		var ee = '';
		for (i in 0...input.length)
		{
			var char = input.charAt(i);
			if (symbolsToRemove.indexOf(char) == -1)
			{
				ee += char;
			}
		}
		return ee;
	}

	/**
	 * Checks if `defaultState` is exists on the priority mod, if it exists, then it will open
	 * CustomState.hx with the state script.
	 * @param defaultState		State's name
	 * @param enableTransit 	Whether to enable the transition between states.
	 */
	public function getStateScript(defaultState:String, ?enableTransit:Bool = true)
	{
		if (Paths.curModDir.length == 1 && Paths.currentMod != "BASEFNF")
		{
			var tempCurMod = Paths.currentMod;
			Paths.currentMod = Paths.curModDir[0];
			var scriptPath:String = Paths.modFolders("ui/" + defaultState + ".hx");
			trace(scriptPath);
			if (FileSystem.exists(scriptPath))
			{
				FlxTransitionableState.skipNextTransIn = enableTransit;
				FlxTransitionableState.skipNextTransOut = true;
				trace("Switching to custom state for " + defaultState);
				FlxG.switchState(new CustomState(defaultState));
			}
			Paths.currentMod = tempCurMod;
		}
	}

	/**
	 * Checks if `defaultState` is exists on the priority mod, if it exists, then it will open
	 * CustomSubstate.hx with the substate script.
	 * @param currentState		Current MusicBeatState that calls this function.
	 * @param defaultState		State's name
	 * @param arguments			Arguments that will be passed to the custom substate.
	 */
	public function getSubStateScript(currentState:MusicBeatState, defaultState:String, ?arguments:Array<Any>)
	{
		if (Paths.curModDir.length == 1 && Paths.currentMod != "BASEFNF")
		{
			var tempCurMod = Paths.currentMod;
			Paths.currentMod = Paths.curModDir[0];
			var scriptPath:String = Paths.modFolders("ui/" + defaultState + ".hx");
			trace(scriptPath);
			if (FileSystem.exists(scriptPath))
			{
				trace("Switching to custom substate for " + defaultState);
				currentState.openSubState(new CustomSubstate(defaultState, arguments));
			}
			Paths.currentMod = tempCurMod;
		}
	}

	/**
	 * Converts bytes int to formatted sizes. (ex: 10 MB, 100 GB, 1000 TB, etc)
	 * @param bytes		Bytes number that will be converted
	 * @return String	Formatted size of the bytes
	 */
	public function convert_size(bytes:Float):String
	{
		if (bytes == 0)
			return "0 B";

		var size_name:Array<String> = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
		var digit:Int = Std.int(Math.log(bytes) / Math.log(1024));
		return FlxMath.roundDecimal(bytes / Math.pow(1024, digit), 2) + " " + size_name[digit];
	}

	/**
	 * Checks if current priority mod has a state script.
	 * @param stateName 	State's name that will be checked
	 * @return Bool			Does it exists?
	 */
	public function hasStateScript(stateName:String):Bool
	{
		var ret = false;
		if (Paths.curModDir.length == 1 && Paths.currentMod != "BASEFNF")
		{
			var tempCurMod = Paths.currentMod;
			Paths.currentMod = Paths.curModDir[0];
			var scriptPath:String = Paths.modFolders("ui/" + stateName + ".hx");
			trace(scriptPath);
			ret = FileSystem.exists(scriptPath);
			Paths.currentMod = tempCurMod;
		}
		return ret;
	}

	/**
	 * Call this to fully restart the game.
	 */
	public function restartGame()
	{
		CDevConfig.storeSaveData();
		@:privateAccess {
			TitleState.initialized = false;
			TitleState.closedState = false;
			TitleState.isLoaded = false;
			InitState.status.loadedSaves = false;
		}
		SettingsProperties.reset();
		FlxG.resetGame();
	}

	/**
	 * checks WIP. might break?
	 * @param returnMod 
	 * @return Dynamic
	 */
	public function isPriorityMod(returnMod:Bool = false):Dynamic
	{
		if (Paths.curModDir.length == 1)
		{
			return (returnMod ? Paths.curModDir[0] : true);
		}
		return (returnMod ? "" : false);
	}

	/**
	 * CTRL + V thing, idk lol
	 * @param prefix 
	 * @return String
	 */
	public function pasteFunction(prefix:String = ''):String
	{
		if (prefix.toLowerCase().endsWith('v'))
			prefix = prefix.substring(0, prefix.length - 1);

		var txt:String = prefix + Clipboard.text.replace('\n', '');
		return txt;
	}

	/**
	 * Moving the `obj1` to `obj2`'s center position
	 * @param obj1 
	 * @param obj2 
	 * @param useFrameSize 
	 */
	public function moveToCenterOfSprite(obj1:FlxSprite, obj2:FlxSprite, ?useFrameSize:Bool)
	{
		if (useFrameSize)
		{
			obj1.setPosition((obj2.x + (obj2.frameWidth / 2) - (obj1.frameWidth / 2)), (obj2.y + (obj2.frameHeight / 2) - (obj1.frameHeight / 2)));
		}
		else
		{
			obj1.setPosition((obj2.x + (obj2.width / 2) - (obj1.width / 2)), (obj2.y + (obj2.height / 2) - (obj1.height / 2)));
		}
	}

	/**
	 * Centering `object` to screen
	 * (This is different from FlxSprite.screenCenter())
	 * @param object 			The object that you want to move
	 * @param pos				X or Y (FlxAxes)
	 */
	public function objectScreenCenter(object:FlxSprite, ?pos:FlxAxes = null)
	{
		if (pos == null)
		{
			object.x = (FlxG.width / 2) - ((object.frameWidth * object.scale.x) / 2);
			object.y = (FlxG.height / 2) - ((object.frameHeight * object.scale.y) / 2);
		}

		if (pos == X)
			object.x = (FlxG.width / 2) - ((object.frameWidth * object.scale.x) / 2);

		if (pos == Y)
			object.y = (FlxG.height / 2) - ((object.frameHeight * object.scale.y) / 2);
	}

	/**
	 * Sets `object` label offset to `x` and `y`
	 * @param object 
	 * @param x 
	 * @param y 
	 */
	public function setFlxButtonLabelOffset(object:FlxButton, x:Float, y:Float)
	{
		for (offset in object.labelOffsets)
		{
			offset.set(x, y);
		}
	}

	// hi :) credit: Shadow Mario#9396
	public function fileIsExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		if (FileSystem.exists(Paths.mods(Paths.currentMod + "/" + key)) || OpenFlAssets.exists(Paths.getPath(key, type)))
			return true;

		return false;
	}

	public function getColor(sprite:FlxSprite):FlxColor
	{
		var color:Map<Int, Int> = [];

		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var pixelColor:Int = sprite.pixels.getPixel32(col, row);
				if (pixelColor != 0)
				{
					if (color.exists(pixelColor))
					{
						color[pixelColor] = color[pixelColor] + 1;
					}
					else if (color[pixelColor] != 13520687 - (2 * 13520687))
					{
						color[pixelColor] = 1;
					}
				}
			}
		}

		color[FlxColor.BLACK] = 0;

		var maxCount = 0;
		var maxKey:Int = 0;

		for (key in color.keys())
			if (color[key] >= maxCount)
			{
				maxCount = color[key];
				maxKey = key;
			}

		return FlxColor.fromInt(maxKey);
	}

	public function cacheUISounds()
	{
		if (!Assets.cache.hasSound(Paths.sound('cancelMenu', 'preload')))
		{
			FlxG.sound.cache(Paths.sound('cancelMenu', 'preload'));
		}

		if (!Assets.cache.hasSound(Paths.sound('scrollMenu', 'preload')))
		{
			FlxG.sound.cache(Paths.sound('scrollMenu', 'preload'));
		}
		if (!Assets.cache.hasSound(Paths.sound('confirmMenu', 'preload')))
		{
			FlxG.sound.cache(Paths.sound('confirmMenu', 'preload'));
		}
	}

	public function openURL(url:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	public function openFolder(folder:String, useAbsolutePath:Bool = false)
	{
		var path:String = folder;
		if (!useAbsolutePath)
			path = Sys.getCwd() + '$folder';

		path = Path.normalize(path);
		path = path.replace('/', '\\');

		if (path.endsWith('/'))
			path.substr(0, path.length - 1);

		Sys.command("explorer.exe", [path]);
	}

	/**
		* Checks to see if a point in 2D world space overlaps this `FlxObject`.
		*
		* @param   point           The point in world space you want to check.
		* @param   inScreenSpace   Whether to take scroll factors into account when checking for overlap.
		* @param   camera          Specify which game camera you want.
		*                          If `null`, it will just grab the first global camera.
		* @return  Whether or not the point overlaps this object.

		public function mouseOverlap(point:FlxPoint, inScreenSpace = false, ?camera:FlxCamera):Bool
		{
			if (camera == null)
				camera = FlxG.camera;

			var xPos:Float = point.x - camera.scroll.x;
			var yPos:Float = point.y - camera.scroll.y;
			FlxPointer.getScreenPosition(_point, camera);
			point.putWeak();
			return (xPos >= _point.x) && (xPos < _point.x + width) && (yPos >= _point.y) && (yPos < _point.y + height);
	}*/
	public function mouseOverlap(obj:FlxSprite, ?camera:FlxCamera)
	{
		if (camera == null)
			camera = FlxG.camera;

		var objX:Float = obj.x - camera.scroll.x;
		var objY:Float = obj.y - camera.scroll.y;
		var fpPoint:FlxPoint = new FlxPoint(0, 0);
		@:privateAccess {
			fpPoint = FlxPointer._cachedPoint;
		}
		FlxG.mouse.getScreenPosition(camera, fpPoint);
		fpPoint.putWeak();
		return ((fpPoint.x >= objX)
			&& (fpPoint.x < objX + (obj.width * obj.scale.x))
			&& (fpPoint.y >= objY)
			&& (fpPoint.y < objY + (obj.height * obj.scale.y)));
	}

	/**
	 * Caching sounds. just input the filename, and the library.
	 */
	public function doSoundCaching(sound:String, ?library:String = null):Void
	{
		if (!Assets.cache.hasSound(Paths.sound(sound, library)))
		{
			FlxG.sound.cache(Paths.sound(sound, library));
		}
	}

	/**
	 * Sets your `sprite` object to fit the screen.
	 * @param sprite 
	 */
	public function setFitScale(sprite:FlxSprite, xAdd:Float = 0, yAdd:Float = 0)
	{
		sprite.scale.x = (FlxG.width / sprite.width) + xAdd;
		sprite.scale.y = (FlxG.height / sprite.height) + yAdd;
	}

	/**
	 * Converts a base FNF chart to CDEV Engine's chart format.
	 * @param json The JSON of your FNF Chart 
	 * @return New CDEV Chart Object
	 */
	public function fnftocdev_chart(json:SwagSong):CDevChart
	{
		var notes:Array<Dynamic> = [];
		var events:Array<Dynamic> = [];
		var safeJSON:SwagSong = json;

		for (i in safeJSON.notes)
		{
			for (j in i.sectionNotes)
			{
				if (i.mustHitSection)
				{ // swap the section if it's a player section.
					var note = j;
					note[1] = (note[1] + 4) % 8;
					j = note;
				}
				notes.push([
					j[0],
					j[1],
					j[2],
					(j[3] == null ? "Default Note" : j[3]),
					(j[4] == null ? ['', ''] : j[4])
				]);
			}
			if (Reflect.hasField(i, "sectionEvents"))
			{ // bruh
				for (k in i.sectionEvents)
				{
					events.push([k[0], k[1], k[2], k[3], k[4]]);
				}
			}
		}
		var cdev:CDevChart = {
			data: {
				player: safeJSON.player1,
				opponent: safeJSON.player2,
				third_char: (safeJSON.gfVersion == null ? "gf" : safeJSON.gfVersion),
				stage: safeJSON.stage,
				note_skin: "notes/NOTE_assets"
			},
			info: {
				name: safeJSON.song,
				composer: "Kawai Sprite",
				bpm: safeJSON.bpm,
				speed: safeJSON.speed,
				time_signature: [4, 4], // since most of fnf songs are charted in 4/4 time signature, set this by default.
				version: CDevConfig.engineVersion
			},
			notes: notes,
			events: events
		}

		return cdev;
	}
}
