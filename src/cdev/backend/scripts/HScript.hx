package cdev.backend.scripts;

import hscript.Expr;
import hscript.Parser;
import hscript.Interp;

class HScript extends Script {
    var _interp:Interp;
    var _parser:Parser;
    override function setParent(parent:Any) {
        _interp.scriptObject = parent;
    }
    override function init(script:String) {
        _parser = new Parser();
        _parser.allowJSON = _parser.allowMetadata = _parser.allowTypes = true;

        _interp = new Interp();
        _interp.allowStaticVariables = true;
        _interp.staticVariables = Script.PUBLIC_VARIABLES;
        _interp.importEnabled = true;
        importDefaults();

        var ast:Expr = _parser.parseString(script, name);
        _interp.execute(ast);
    }

    override function set(key:String, value:Any):Any {
        if (_interp == null) return null;
        _interp?.variables.set(key, value);
        return value;
    }

    override function get(key:String):Any
        return _interp?.variables.get(key);

    override function exists(key:String):Bool
        return _interp?.variables.exists(key);
}