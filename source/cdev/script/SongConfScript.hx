package cdev.script;

import cdev.script.CDevScript.CDevModScript;
import cdev.script.HScript;
import states.PlayState;
import game.Paths;
import lime.utils.Assets;
import mod_support_stuff.*;
import haxe.Json;
import sys.FileSystem;
import song.Song.SwagSong;

using StringTools;

typedef SongConfResult =
{
	var scripts:Array<CDevModScript>;
}

typedef Aaaaaaaaaaaaa =
{
	var scripts:Array<String>;
}

class SongConfScript
{
	public static function parse(mod:String, song:String):SongConfResult
	{
		var scripts:Array<CDevModScript> = [];
		var folder:String = '';

		if (mod == "BASEFNF"){
			trace("it's assets");
			folder = "assets/data/charts/"+song+"/";
		} else{
			trace("it's cdev-mods");
			folder = 'cdev-mods/$mod/data/charts/$song/';
		}

		scripts = getScript(folder, mod);
		

		if (scripts.length == 0)
		{
			trace('script was null. uh huh');
			scripts = [
				{
					daPath: 'cdev-mods/FNF Test Mod/data/charts/mod-test/unknown.hx',
					daMod: mod
				}
			];
		}

		return {
			scripts: scripts,
		};
	}

	public static function getScript(folder:String, mod:String){
		var scripts:Array<CDevModScript> = [];
		var insideTheThing:Array<String> = FileSystem.readDirectory(folder);

		var notAllowed:Array<String> = ["unknown", "intro", "outro"];
		if (insideTheThing != null)
		{
			for (object in insideTheThing)
			{
				trace(object);
				if (!FileSystem.isDirectory(folder + object))
				{
					if (object.endsWith('.hx'))
					{
						var objName:String = object.substr(0, object.length - 3);
						trace(objName);
						if (notAllowed.contains(objName))
						{
							trace(object + " can't be used as song script. skipping...");
							// insideTheThing.remove(object);
							continue;
						}
						else
						{
							trace("found " + object);
							scripts.push({
								daMod: mod,
								daPath: folder + object
							});
						}
					}
				}
			}
			return scripts;
		}
		return [];
	}

	public static function getScriptShit(mod:String, sus:String):CDevModScript
	{
		var p:String = 'cdev-mods/FNF Test Mod/data/charts/mod-test/unknown.hx';
		var exist:Bool = false;
		// classic script method
		for (ext in CDevScript.haxeExts)
		{
			if (FileSystem.exists('cdev-mods/$mod/data/charts/$sus/script.$ext'))
			{
				p = 'cdev-mods/$mod/data/charts/$sus/script.$ext';
				exist = true;
				break;
			}
		}

		if (exist)
		{
			trace('\n\nwe found the file bois\n$p');
			return {
				daMod: mod,
				daPath: p
			}
		}
		return {
			daMod: "FNF Test Mod",
			daPath: "cdev-mods/FNF Test Mod/data/charts/mod-test/unknown.hx"
		}
	}
}
