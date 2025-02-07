package cdev.backend.modding.scripting;

import haxe.PosInfos;
import haxe.Exception;
import haxe.Constraints.Function;

/**
 * Base scripting API.
 */
class Script {
    /**
     * Default class imports for scripts.
     */
    public static var default_imports:Map<String, Dynamic> = [
        "Std"         => Std,
        "Math"        => cdev.backend.modding.classes.ScriptMath,
        "Reflect"     => Reflect,
        "StringTools" => StringTools,
        "Json"        => haxe.Json
    ];

    /**
     * Static variables available in all scripts.
     */
    public static var staticVariables:Map<String, Dynamic> = [];

    /**
     * Loads a new script from the given path.
     * @param path Script's path without extension.
     */
    public static inline function load(path:String) {
        return new HScript(path); // For now, only HScript is supported.
    }

    /**
     * Script's name.
     */
    public var name:String;

    public function new(path:String) {
        name = path;
        try {
            initialize(path);
            loadDefaults();
            execute();
        } catch (e:Exception) {
            if (Preferences.verboseLog)     
                Log.warn("Script initialization error: " + e.toString());
        }
    }

    /**
     * Initializes the script. Override this.
     * @param path Script's path.
     */
    public function initialize(path:String):Void {}

    /**
     * Executes the script. Override this.
     */
    public function execute():Void {}

    /**
     * Loads default variables into the script.
     */
    private function loadDefaults():Void {
        for (key in default_imports.keys()) 
            set(key, default_imports.get(key));

        set("exit", destroy);
    }

    /**
     * Calls a function in the script, passing optional arguments.
     * @param name Function's name.
     * @param args Arguments to pass to the function.
     * @return Result of the function call.
     */
    public function call(name:String, ?args:Array<Dynamic>):Dynamic {
        var func:Function = get(name);
        if (func == null) {
            return null;
        }

        try {
            return if (args == null) func() else Reflect.callMethod(null, func, args);
        } catch (e:Exception) {
            Log.error('Method ${name} failed: ${getError(e.message)} at line ${getPosInfos(e).lineNumber}');
            return null;
        }
    }

    /**
     * Sets a variable in the script.
     * @param name Variable's name.
     * @param val Variable's value.
     */
    public function set(name:String, val:Dynamic):Dynamic {
        return val; // Implement this on other subclasses.
    }

    /**
     * Gets a variable's value from the script.
     * @param name Variable's name.
     */
    public function get(name:String):Dynamic {
        return null; // Implement this on other subclasses.
    }

    /**
     * Checks if a variable exists in the script.
     * @param name Variable's name.
     * @return Returns whether if the variable exists or not.
     */
    public function exists(name:String):Bool {
        return false; // Implement this on other subclasses.
    }

    /**
     * Logs a message.
     * @param text Message to log.
     */
    public function log(text:String):Void {
        if (Preferences.verboseLog)
            trace("Script >> " + text);
    }

    /**
     * Destroys the script, cleaning up any resources.
     */
    public function destroy():Void {
        log("Script destroyed.");
    }

    /**
     * Gets positional information about an exception.
     * @param exception The exception thrown.
     * @return Positional information.
     */
    public function getPosInfos(exception:Exception):PosInfos {
        return null; // Implement this on other subclasses.
    }

    /**
     * Extracts an error message from an exception, Override this.
     * @param exception The exception thrown.
     * @return A formatted error message.
     */
    public function getError(exception:String):String {
        return exception;
    }
}
