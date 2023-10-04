package cdev;

import states.MusicBeatState;
import substates.GameOverSubstate;
import substates.PauseSubState;
import states.FreeplayState;
import states.StoryMenuState;
import states.MainMenuState;

import cdev.script.HScript;
import sys.FileSystem;
import cdev.script.CDevScript;

import sys.FileSystem;
import cdev.CDevMods.CDEV_FlxAxes;
import flixel.addons.display.FlxBackdrop;
import cdev.CDevMods.CDEV_BlendMode;
import openfl.display.BlendMode;
import cdev.CDevMods.CDEV_FlxTextBorderStyle;
import cdev.CDevMods.CDEV_FlxTextAlign;
import cdev.CDevMods.CDEV_FlxColor;
import modding.ModPaths;
import lime.app.Application;
import game.CoolUtil;
import game.BackgroundGirls;
import game.BackgroundDancer;
import game.Boyfriend;
import game.Conductor;
import game.Note;
import game.Character;
import game.Paths;
import engineutils.FlxColor_Util;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.util.FlxAxes;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import haxe.Json;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import lime.utils.Assets;
import flixel.system.FlxAssets;
import flixel.math.FlxMath;
import openfl.display.BitmapData;
import states.PlayState;
import hscript.Expr;
import flixel.FlxG;
import flixel.FlxSprite;
import cdev.script.CDevScript.CDevModScript;

using StringTools;

typedef StuffForUI = {
    var name:String;
    var object:Dynamic;
}

//STATESCRIPT WIP!!1
class StateUIScript {
    public var script:CDevScript = null;
    public var type:String = "";
    public var mod:String = "";
    public var state:MusicBeatState = null;

    public var stateObjects:Array<StuffForUI> = [];
    var gotScript:Bool = false;
    public function new(type:String, mod:String, state:MusicBeatState){
        this.type = type;
        this.mod = mod;
        this.state = state;

        var scriptPath = Paths.modFolders("ui/"+this.type+".hx");
        if (FileSystem.exists(scriptPath))
	    {
            script = CDevScript.create(scriptPath);
            gotScript = true;
            script.loadFile(scriptPath);

            if (gotScript)
                script.executeFunc("create", []);
        }
    }

    public function addObject(obj:Dynamic, name:String) {
        stateObjects.push({
            name: name,
            object: obj
        });
    }

    public function executeFunc(name:String,?args:Array<Any>):Dynamic {
        if (gotScript) return script.executeFunc(name,args);
        return null;
    }

    public function load_supports() {
        var superVar = {};
		if (Std.isOfType(script, HScript))
		{
			var hscript:HScript = cast script;
			for (k => v in hscript.hscript.variables)
			{
				Reflect.setField(superVar, k, v);
			}
		}
		script.setVariable("super", superVar);
		script.setVariable("mod", mod);

        //brUH
        switch (type) {
            case StateUIType.MAIN_MENU:
                script.setVariable(type, cast(state, MainMenuState));
            case StateUIType.STORY_MENU:
                script.setVariable(type, cast(state, StoryMenuState));
            case StateUIType.FREEPLAY:
                script.setVariable(type, cast(state, FreeplayState));
        }

		script.setVariable("import", function(className:String)
		{
			var splitClassName = [for (e in className.split(".")) e.trim()];
			var realClassName = splitClassName.join(".");
			var cl = Type.resolveClass(realClassName);
			var en = Type.resolveEnum(realClassName);
			if (cl == null && en == null)
			{
				trace('Class / Enum at $realClassName does not exist.');
			}
			else
			{
				if (en != null)
				{
					var enumThingy = {};
					for (c in en.getConstructors())
					{
						Reflect.setField(enumThingy, c, en.createByName(c));
					}
					script.setVariable(splitClassName[splitClassName.length - 1], enumThingy);
				}
				else
				{
					// CLASS!!!!
					script.setVariable(splitClassName[splitClassName.length - 1], cl);
				}
			}
		});
		var curState:Dynamic = FlxG.state;
		var state:MusicBeatState = curState;
		script.setVariable("trace", function(text)
		{
			try
			{
				script.trace(text);
			}
			catch (e)
			{
				trace(e);
			}
		});
		script.setVariable("add", function(obj)
		{
			state.add(obj);
		});
		script.setVariable("remove", function(obj)
		{
			state.remove(obj);
		});
		script.setVariable("insert", function(pos, obj)
		{
			state.insert(pos, obj);
		});
		script.setVariable("PlayState", PlayState);
		script.setVariable("FlxSprite", FlxSprite);
		script.setVariable("BitmapData", BitmapData);
		script.setVariable("FlxG", FlxG);
		script.setVariable("Paths", new ModPaths(mod));
		script.setVariable("Std", Std);
		script.setVariable("Math", Math);
		script.setVariable("FlxMath", FlxMath);
		script.setVariable("FlxAssets", FlxAssets);
		script.setVariable("Assets", Assets);
		script.setVariable("Note", Note);
		script.setVariable("Character", Character);
		script.setVariable("Conductor", Conductor);
		script.setVariable("StringTools", StringTools);
		script.setVariable("FlxSound", FlxSound);
		script.setVariable("FlxEase", FlxEase);
		script.setVariable("FlxTween", FlxTween);
		script.setVariable("FlxColor", CDEV_FlxColor);
		script.setVariable("BlendMode", CDEV_BlendMode);
		script.setVariable("FlxBackdrop", FlxBackdrop);
		script.setVariable("Boyfriend", Boyfriend);
		script.setVariable("FlxTypedGroup", FlxTypedGroup);
		script.setVariable("BackgroundDancer", BackgroundDancer);
		script.setVariable("BackgroundGirls", BackgroundGirls);
		script.setVariable("FlxTimer", FlxTimer);
		script.setVariable("Json", Json);
		script.setVariable("CoolUtil", CoolUtil);
		script.setVariable("FlxTypeText", FlxTypeText);
		script.setVariable("FlxText", FlxText);
		script.setVariable("FlxTextAlign", CDEV_FlxTextAlign);
		script.setVariable("FlxTextBorderStyle", CDEV_FlxTextBorderStyle);
		script.setVariable("FlxAxes", CDEV_FlxAxes);
		script.setVariable("Rectangle", Rectangle);
		script.setVariable("Point", Point);
		script.setVariable("Window", Application.current.window);
		script.setVariable("CDevConfig", CDevConfig.saveData);
    }
}

class StateUIType{
    //states
    public static var MAIN_MENU(default,never):String = "MainMenuState";
    public static var STORY_MENU(default,never):String = "StoryMenuState";
    public static var FREEPLAY(default,never):String = "FreeplayState";

    //substates
    public static var PAUSE_MENU(default,never):String = "PauseSubState";
    public static var GAMEOVER_MENU(default,never):String = "GameOverSubState";
}