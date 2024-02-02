package meta.states;

import game.cdev.log.GameLog;
import flixel.addons.display.FlxRuntimeShader;
import meta.modding.ModdingState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
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
import game.cdev.CDevMods.CDEV_Json;
import meta.modding.ModPaths;
import lime.app.Application;
import game.objects.*;
import game.*;
import game.cdev.*;
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
import game.cdev.engineutils.custom_states.CStateStatics;

using StringTools;

class CustomState extends MusicBeatState
{
	public static var lastMod:String = "";
	public static var current:CustomState = null;

	// trace window stuffs
	public var camGame:FlxCamera;

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

	public function changeState(state:FlxState)
	{
		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxG.switchState(state);
	}

	function setStuff()
	{
		if (lastMod != Paths.currentMod)
		{
			CStateStatics.__RESET();
		}
		CStateStatics.mod = Paths.currentMod;
		script.setVariable("_static", CStateStatics);

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
		script.setVariable("current", this);
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
			add(obj);
		});
		script.setVariable("remove", function(obj)
		{
			remove(obj);
		});
		script.setVariable("insert", function(pos, obj)
		{
			insert(pos, obj);
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
		script.setVariable("Json", CDEV_Json);
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
		script.setVariable("FlxRuntimeShader", FlxRuntimeShader);
		script.setVariable("ShaderFilter", ShaderFilter);
		script.setVariable("FlxCamera", FlxCamera);

		// states for switchstate
		script.setVariable("CustomState", CustomState);
		script.setVariable("TitleState", TitleState);
		script.setVariable("MainMenuState", MainMenuState);
		script.setVariable("StoryMenuState", StoryMenuState);
		script.setVariable("FreeplayState", FreeplayState);
		script.setVariable("PlayState", PlayState);
		script.setVariable("OptionsState", OptionsState);
		script.setVariable("ModdingState", ModdingState);
		script.setVariable("AboutState", AboutState);
		lastMod = Paths.currentMod;
	}

	var state:String = "";
	var args:Array<Any> = []; //aa

	public function new(state:String = "", ?argh:Array<Any>)
	{
		super();
		this.state = state;
		args = (argh == null ? [] : argh);
	}

	override function create()
	{
		super.create();

		if (state != "")
		{
			if (Paths.curModDir.length == 1)
			{
				Paths.currentMod = Paths.curModDir[0];
			}
			var scriptPath = Paths.modFolders("ui/" + state + ".hx");
			trace(scriptPath);
			if (FileSystem.exists(scriptPath))
			{
				trace("load");
				script = CDevScript.create(scriptPath);
				gotScript = true;
				setStuff();
				script.loadFile(scriptPath);
			}
		}
		if (gotScript)
			script.executeFunc("create", args);

		if (gotScript)
			script.executeFunc("postCreate", []);
	}

	var offsetX:Float = 0;
	var pressed = false;

	var isErrorBefore = false;

	override function update(e:Float)
	{
		if (gotScript)
			script.executeFunc("update", [e]);
		super.update(e);

		if (gotScript && script.error){
			if (isErrorBefore != script.error){
				FlxG.sound.play(Paths.sound("cancelMenu"));
				GameLog.error("An error occured on the script. If you're stuck on this Custom State, press Shift + Escape.");
				isErrorBefore = script.error;
			}
		}

		if (gotScript && script.error && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.ESCAPE)
		{
			var newState = new MainMenuState();
			newState.disableSwitching = true;
			changeState(newState);
		}

		if (gotScript)
			script.executeFunc("postUpdate", [e]);
	}

	override function destroy() {
		super.destroy();
		if (gotScript)
			script.executeFunc("onDestroy", []);	
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
