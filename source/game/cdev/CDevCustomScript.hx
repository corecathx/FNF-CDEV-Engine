package game.cdev;

import meta.states.PlayState;
import game.cdev.engineutils.TraceLog;
import game.cdev.script.HScript;
import game.cdev.script.CDevScript;

class CDevCustomScript
{
	var script:HScript = null;
	var variables:Map<String, Dynamic> = [];

	// no
	public function new(scriptTL:CDevScript)
	{
		this.script = cast scriptTL;
		variables = script.hscript.variables;
	}

	public function getVariable(key:String):Dynamic
	{
		if (variables.exists(key))
		{
			return variables.get(key);
		}
		return null;
	}

	public function setVariable(key:String, value:Dynamic)
	{
		return variables.set(key, value);
	}

	public function executeFunction(funcName:String, ?args:Array<Any>):Dynamic
	{
		if (variables.exists(funcName))
		{
			var f = variables.get(funcName);
			if (args == null)
			{
				var result = null;
				try
				{
					result = f();
				}
				catch (e)
				{
					this.trace('$e');
					TraceLog.addLogData('$e');
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
					this.trace('$e');
					TraceLog.addLogData('$e');
				}
				return result;
			}
			// f();
		}
		return null;
	}

	/*public function setAllVariables(scripp:CDevScript)
	{
		var s:HScript = cast scripp;
		var n:String = s.fileName;
		var nc:String = n+"."
		for (i in variables){
			scripp.
		}
	}*/

	//IDK???
	public function trace(text:String)
	{
		var posInfo = script.hscript.posInfos();

		var fileName = script.fileName;
		var lineNumber = Std.string(posInfo.lineNumber);
		var methodName = posInfo.methodName;
		var className = posInfo.className;
		trace('$fileName:$methodName:$lineNumber: $text');
		PlayState.addNewTraceKey('$fileName:$methodName:$lineNumber: $text');

		if (!CDevConfig.saveData.testMode)
			return;
	}
}
