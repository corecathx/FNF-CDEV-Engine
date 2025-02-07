package cdev.backend.scripts;

import haxe.Constraints.Function;

/**
 * Base script class.
 */
class Script {
    public static var PUBLIC_VARIABLES:Map<String, Any> = [];
    public static final DEFAULT_IMPORTS:Map<String, Any> = [
        "Std" => Std,
        // uh
        "Math" => #if hl cdev.backend.scripts.wrappers.ScriptMath #else Math #end,
        "StringTools" => StringTools,
        "StringBuf" => StringBuf,
        "EReg" => EReg,
        "Lambda" => Lambda,
        "Assets" => Assets
    ];

    /**
     * Loads script from file.
     * @param path Script's file path.
     * @return String
     */
    public static function fromFile(path:String):Script {
        if (!FileSystem.exists(path)) return null;
        return new HScript(File.getContent(path), path.substring(path.lastIndexOf("/") + 1, path.length));
    }

    /**
     * Identifier for this script.
     */
    public var name:String = "";

    /**
     * Creates a new script.
     * @param script Script content.
     */
    public function new(script:String, name:String) {
        try {
            init(script);
        } catch (e) {
            trace("Script error! " + e.toString());
        }
    }

    /**
     * Initializes the script (Override this!)
     * @param script script
     */
    public function init(script:String) {}

    public function get(key:String):Any
        return null;
    public function set(key:String, value:Any):Any
        return value;
    public function exists(key:String):Bool
        return false;

    public function importDefaults() {
        for (i in DEFAULT_IMPORTS.keys()) {
            set(i, DEFAULT_IMPORTS.get(i));
        }
    }

    public function callMethod(f:String, ?args:Array<Any>) {
        if (!exists(f)) return;
        var func:Function = get(f);
        
        try {
            if (args == null) 
                func();
            else 
                Reflect.callMethod(f,func,args);
        } catch(e) {
            trace("Script error: " + name + " - " + e.toString());
        }
    }

    public function setParent(parent:Any) {
    }
}