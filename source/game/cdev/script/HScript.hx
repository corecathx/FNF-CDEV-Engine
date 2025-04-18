package game.cdev.script;


import meta.states.PlayState;
import flixel.FlxG;
import sys.FileSystem;
import haxe.io.Path;
import game.Paths;
import hscript.Interp;

using StringTools;

class HScript extends CDevScript
{
	public var fileNameShit:String = "";

	public function new()
	{
		hscript = new Interp();
		super();
	}

	public override function executeFunc(funcName:String, ?args:Array<Any>):Dynamic
	{
		if (hscript == null)
		{
			this.trace("HScript is null");
			return null;
		}
		if (hscript.variables.exists(funcName))
		{
			var f = hscript.variables.get(funcName);
			if (args == null)
			{
				var result = null;
				try
				{
					result = f();
				}
				catch (e)
				{
					errorLog('$e');
					error = true;
				}
				return result;
			}
			else
			{
				var result = null;
				try
				{
					result = Reflect.callMethod(null, f, args);
				}
				catch (e)
				{
					errorLog('$e');
					error = true;
				}
				return result;
			}
			if (CDevConfig.DEPRECATED_STUFFS.exists(funcName)){
				Log.warn('Function \"$funcName\" is deprecated since CDEV Engine v.${CDevConfig.DEPRECATED_STUFFS.get(funcName)}.');
			}
		}
		return null;
	}

	public override function loadFile(path:String)
	{
		if (path.trim() == "")
			return;
		fileName = Path.withoutDirectory(path);
		fileName = fileName.substr(0, fileName.length-3);
		fileAsClass = fileName; //dumbshit
		fileNameShit = fileName;
		var paath = path;
		//trace(paath);
		if (Path.extension(paath) == "")
		{
			var haxeExts = ["hx", "hsc", "hscript"];
			for (ext in haxeExts)
			{
				if (FileSystem.exists('$paath.$ext'))
				{
					paath = '$paath.$ext';
					fileName += '.$ext';
					break;
				}
			}
		}
		try
		{
			hscript.execute(ScriptSupport.getExprFromPath(paath, false, this));
		}
		catch (e)
		{
			return;
			//already traced before
			//errorLog('${e.message}');
		}
		CDevMods.script_instances.push(this);
	}

	public override function trace(text:String)
	{
		var posInfo = hscript.posInfos();
		posInfo.className = "HScript - "+fileName+".hx";

		// var fileName = posInfo.fileName;
		var lineNumber = Std.string(posInfo.lineNumber);
		var methodName = posInfo.methodName;
		var className = posInfo.className;
		Log.script('$fileName:$lineNumber: $text', posInfo);

		if (!CDevConfig.saveData.testMode)
			return;
	}

	public override function errorLog(text:String){
		var posInfo = hscript.posInfos();

		// var fileName = posInfo.fileName;
		var lineNumber = Std.string(posInfo.lineNumber);
		var methodName = posInfo.methodName;
		var className = posInfo.className;
		//trace('$fileName:$methodName:$lineNumber: $text');
		Log.error('$fileName:$lineNumber: $text');
	}

	public override function setVariable(name:String, val:Dynamic)
	{
		hscript.variables.set(name, val);
	}

	public override function getVariable(name:String):Dynamic
	{
		return hscript.variables.get(name);
	}
}