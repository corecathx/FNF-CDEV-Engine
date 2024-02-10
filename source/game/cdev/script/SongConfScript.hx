package game.cdev.script;

import game.cdev.script.CDevScript.CDevModScript;
import game.cdev.script.HScript;
import meta.states.PlayState;
import game.Paths;
import lime.utils.Assets;
import mod_support_stuff.*;
import haxe.Json;
import sys.FileSystem;
import game.song.Song.SwagSong;

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
			folder = "assets/data/charts/"+song+"/";
		} else{
			folder = 'cdev-mods/$mod/data/charts/$song/';
		}

		scripts = getScript(folder, mod);

		var additScript:Array<CDevModScript> = getScript("cdev-mods/"+mod+"/scripts/", mod);
		
		if (scripts.length == 0)
		{
			scripts = [
				{
					daPath: 'cdev-mods/Funkin Mod/data/charts/mod-test/unknown.hx',
					daMod: mod
				}
			];
		}

		for (i in additScript){
			scripts.push(i);
		}

		return {
			scripts: scripts,
		};
	}

	public static function getScript(folder:String, mod:String){
		var scripts:Array<CDevModScript> = [];
		var insideTheThing:Array<String> = FileSystem.readDirectory(folder);

		var notAllowed:Array<String> = ["unknown", "intro", "outro"];
		//if (isScripts) notAllowed = ["unknown"];
		if (insideTheThing != null)
		{
			for (object in insideTheThing)
			{
				var joint:String = folder + object;
				if (!FileSystem.isDirectory(joint))
				{
					if (object.endsWith('.hx'))
					{
						var objName:String = object.substr(0, object.length - 3);
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
								daPath: joint
							});
						}
					}
				} else{
					if (object != "modules" && FileSystem.isDirectory(joint)){
						var addScr:Array<CDevModScript> = getScript(joint, mod);
						for (i in addScr){
							scripts.push(i);
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
		var p:String = 'cdev-mods/Funkin Mod/data/charts/mod-test/unknown.hx';
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
			daMod: "Funkin Mod",
			daPath: "cdev-mods/Funkin Mod/data/charts/mod-test/unknown.hx"
		}
	}
}
