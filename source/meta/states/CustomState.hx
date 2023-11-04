package meta.states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import game.objects.Alphabet;
import game.cdev.script.CDevScript;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.FlxCamera;
import openfl.filters.ShaderFilter;
import openfl.display.GraphicsShader;
import meta.states.MusicBeatState;
import sys.FileSystem;
import game.cdev.CDevMods.CDEV_FlxAxes;
import flixel.addons.display.FlxBackdrop;
import game.cdev.CDevMods.CDEV_BlendMode;
import openfl.display.BlendMode;
import game.cdev.CDevMods.CDEV_FlxTextBorderStyle;
import game.cdev.CDevMods.CDEV_FlxTextAlign;
import game.cdev.CDevMods.CDEV_FlxColor;
import meta.modding.ModPaths;
import lime.app.Application;
import game.CoolUtil;
import game.objects.BackgroundGirls;
import game.objects.BackgroundDancer;
import game.objects.Boyfriend;
import game.Conductor;
import game.objects.Note;
import game.objects.Character;
import game.Paths;
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
import meta.states.PlayState;
import hscript.Expr;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class CStateStatics{
	public static var statics:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var mod:String = "";

	public static function get(key:String){
		if (!statics.exists(key)) return null;
		return statics.get(key);
	}

	public static function set(key:String, val:Dynamic){
		return statics.set(key, val);
	}

	
	public static function exists(key:String){
		return statics.exists(key);
	}

	public static function __RESET(){
		statics.clear();
		mod = "";
	}
}

class CustomState extends MusicBeatState
{
	public static var lastMod:String = "";
	public static var current:CustomState = null;

	var script:CDevScript = null;
	var gotScript = false;

	public function getProperty(key:String = ""):Dynamic
	{
		if (Reflect.hasField(this, key))
		{
			return Reflect.getProperty(this, key);
		}
		return null;
	}

	public function setProperty(key:String = "", value:Dynamic)
	{
		Reflect.setProperty(this, key, value);
	}

	public function changeState(state:FlxState){
		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;
		FlxG.switchState(state);
	}

	function setStuff()
	{
		if (lastMod != Paths.currentMod){
			CStateStatics.__RESET();
		}
		CStateStatics.mod = Paths.currentMod;
		script.setVariable("static", CStateStatics);

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
					script.setVariable(splitClassName[splitClassName.length - 1], cl);
				}
			}
		});
		var curState:Dynamic = FlxG.state;
		current = curState;
		script.setVariable("current", current);
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
			current.add(obj);
		});
		script.setVariable("remove", function(obj)
		{
			current.remove(obj);
		});
		script.setVariable("insert", function(pos, obj)
		{
			current.insert(pos, obj);
		});
		script.setVariable("Alphabet", Alphabet);
		script.setVariable("controls", current.controls);
		script.setVariable("FlxSprite", FlxSprite);
		script.setVariable("BitmapData", BitmapData);
		script.setVariable("FlxG", FlxG);
		script.setVariable("Paths", new ModPaths(Paths.currentMod));
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
		script.setVariable("CDevConfig", CDevConfig);
		script.setVariable("GraphicsShader", GraphicsShader);
		script.setVariable("FlxGraphicsShader", FlxGraphicsShader);
		script.setVariable("ShaderFilter", ShaderFilter);
		script.setVariable("FlxCamera", FlxCamera);

		// states for switchstate
		script.setVariable("CustomState", CustomState);
		script.setVariable("TitleState", TitleState);
		script.setVariable("MainMenuState", MainMenuState);
		script.setVariable("StoryMenuState", StoryMenuState);
		script.setVariable("FreeplayState", FreeplayState);
		script.setVariable("PlayState", PlayState);

		lastMod = Paths.currentMod;
	}

	var state:String = "";

	public function new(state:String = "")
	{
		super();
		this.state = state;
	}

	override function create()
	{
		trace("yay");
		super.create();
		if (state != "")
		{
			if (Paths.curModDir.length == 1){
				Paths.currentMod = Paths.curModDir[0];
			}
			var scriptPath = Paths.modFolders("ui/" + state + ".hx");
			trace(scriptPath);
			if (FileSystem.exists(scriptPath))
			{
				trace("load");
				script = CDevScript.create(scriptPath);
				gotScript = true;
				script.loadFile(scriptPath);
				setStuff();
			}
		}
		if (gotScript)
			script.executeFunc("create", []);

		if (gotScript)
			script.executeFunc("postCreate", []);
	}

	override function update(e:Float)
	{
		if (gotScript)
			script.executeFunc("update", [e]);
		super.update(e);

		if (gotScript && script.error && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.ESCAPE)
		{
			var newState = new MainMenuState();
			newState.disableSwitching = true;
			FlxG.switchState(newState);
		}

		if (gotScript)
			script.executeFunc("postUpdate", [e]);
	}

	override function onFocus()
	{
		super.onFocus();
		if (gotScript)
			script.executeFunc("onFocus", []);
	}

	override function onFocusLost()
	{
		super.onFocusLost();
		if (gotScript)
			script.executeFunc("onFocusLost", []);
	}

	override function onResize(width:Int, height:Int)
	{
		super.onResize(width, height);
		if (gotScript)
			script.executeFunc("onResize", [width, height]);
	}

	override function stepHit()
	{
		super.stepHit();
		if (gotScript)
			script.executeFunc("stepHit", [curStep]);
	}

	override function beatHit()
	{
		super.beatHit();
		if (gotScript)
			script.executeFunc("beatHit", [curBeat]);
	}
}
