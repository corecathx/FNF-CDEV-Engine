package game.cdev.script;

import meta.states.PlayState;
import game.cdev.script.CDevScript.CDevModScript;
import game.Paths;

class ScriptData
{
	public var scripts:Array<CDevScript> = [];
	public var scriptModScripts:Array<CDevModScript> = [];

	public function new(scripts:Array<CDevModScript>, song:String, state:PlayState)
	{
		ScriptSupport.typedScripts = null;
		var traced:Array<CDevScript> = [];
		for (s in scripts)
		{
			var pth:String = s.daPath;
			var sc = CDevScript.create(pth);
			if (sc == null)
				continue;
			ScriptSupport.setScriptDefaultVars(sc, s.daMod, song, state);
			this.scripts.push(sc);
			scriptModScripts.push(s);
		}

		ScriptSupport.typedScripts = this.scripts;
	}

	public function loadFiles()
	{
		for (k => sc in scripts)
		{
			var s = scriptModScripts[k];
			sc.loadFile('${s.daPath}');
		}
	}

	public function executeFunc(funcName:String, ?args:Array<Any>, ?defaultReturnVal:Any)
	{
		var a = args;
		if (a == null)
			a = [];
		for (script in scripts)
		{
			var returnVal = script.executeFunc(funcName, a);
			if (returnVal != defaultReturnVal && defaultReturnVal != null)
			{
				trace("found");
				return returnVal;
			}
		}
		return defaultReturnVal;
	}
	
	public function setVariable(name:String, val:Dynamic)
	{
		for (script in scripts)
			script.setVariable(name, val);
	}

	public function getVariable(name:String, defaultReturnVal:Any)
	{
		for (script in scripts)
		{
			var variable = script.getVariable(name);
			if (variable != defaultReturnVal)
			{
				return variable;
			}
		}
		return defaultReturnVal;
	}

	public function destroy()
	{
		for (script in scripts)
			script.destroy();
		scripts = null;
	}
}
