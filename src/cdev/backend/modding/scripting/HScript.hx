package cdev.backend.modding.scripting;

import haxe.PosInfos;
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;
import sys.io.File;
import sys.FileSystem;

/**
 * Haxe Script handler.
 */
class HScript extends Script {
    public static var FILE_EXT:Array<String> = ["hx", "hxs", "hscript"];
    public var interp:Interp;

    private var __FILE:Null<String>;

    /**
     * Initializes a new HScript object.
     * @param path Script's path without extension, starts from the game's root folder.
     */
    override function initialize(path:String):Void {
        var file:String = getValidFile(path);
        if (file == null) {
            log("Script not found at path: " + path);
            return;
        }

        __FILE = file;
        interp = new Interp();
        interp.allowPublicVariables = interp.allowStaticVariables = true;
        interp.staticVariables = Script.staticVariables;

        log("Script loaded: " + file);
    }

    public function setScriptParent(wa:Dynamic) {
        if (interp == null) return;
        interp.scriptObject = wa;
    }

    /**
     * Executes the script.
     */
    override function execute():Void {
        if (__FILE == null) {
            log("Execution failed: no script file loaded.");
            return;
        }

        try {
            var ast = parse(__FILE);
            interp.execute(ast);
            log("Executed: " + __FILE);
        } catch (e:Dynamic) {
            log("Execution error: " + Std.string(e));
        }
    }

    override public function set(name:String, val:Dynamic):Dynamic {
        interp.setVar(name, val);
        return val;
    }

    override public function get(name:String):Dynamic {
        return interp?.variables.get(name);
    }

    override public function exists(name:String):Bool {
        return interp?.variables.exists(name);
    }

    /**
     * Finds the first valid script file with a supported extension.
     * @param path Script's base path.
     * @return The full path of the valid file or null.
     */
    private function getValidFile(path:String):Null<String> {
        for (ext in FILE_EXT) {
            var _path:String = '$path.$ext';
            if (FileSystem.exists(_path)) return _path;
        }
        return null;
    }

    /**
     * Parses an HScript file.
     * @param path Full path to the script file.
     * @return The parsed expression (AST).
     */
    private function parse(path:String):Expr {
        var parser = new Parser();
        parser.allowTypes = parser.allowMetadata = parser.allowJSON = true;

        try {
            return parser.parseString(File.getContent(path));
        } catch (e:Dynamic) {
            var errMsg = Std.string(e);
            log('Parsing error in $path: $errMsg at line ${parser.line}');
            throw e; // Re-throw for upstream handling.
        }
    }

    override function getPosInfos(_):PosInfos {
        if (interp == null) return null;
        var pos:PosInfos = interp.posInfos();
        pos.fileName = name.replace('./','');
        return pos;
    }

    override function destroy() {
        interp = null;
        super.destroy();
    }

    override function loadDefaults() {
        super.loadDefaults();
        set("trace", Reflect.makeVarArgs(function(el) {
			var inf = getPosInfos(null);
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
            Log.script(v,inf);
		}));
    }
}
