package game.system;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;

class FunkinMacro {
	public static function includeClasses() {
		for(inc in [

			"flixel.util", "flixel.ui", "flixel.tweens", "flixel.tile", "flixel.text",
			"flixel.system", "flixel.sound", "flixel.path", "flixel.math", "flixel.input",
			"flixel.group", "flixel.graphics", "flixel.effects", "flixel.animation",

			"flixel.addons.api", "flixel.addons.display", "flixel.addons.effects", "flixel.addons.ui",
			"flixel.addons.plugin", "flixel.addons.text", "flixel.addons.tile", "flixel.addons.transition",
			"flixel.addons.util",

			"DateTools", "EReg", "Lambda", "StringBuf", "haxe.crypto", "haxe.display", "haxe.exceptions", "haxe.extern", "scripting"
		]) Compiler.include(inc);

		if(Context.defined("sys")) {
			for(inc in ["sys", "openfl.net"]) {
				Compiler.include(inc);
			}
		}

	}
}
#end