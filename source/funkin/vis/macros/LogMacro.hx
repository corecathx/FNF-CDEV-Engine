package funkin.vis.macros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.PositionTools;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using StringTools;
#end

class LogMacro {
	#if macro
	public static function init() {
		#if !display
		if(Context.defined("display")) return;
		//Compiler.addGlobalMetadata("funkin.vis", "@:build(funkin.vis.macros.LogMacro.build())");
		#end
	}

	private static function hasMeta(meta:Metadata, name:String) : Bool {
		for (m in meta) {
			if (m.name == name) return true;
		}
		return false;
	}

	public static function build() {
		var fields = Context.getBuildFields();
		var clRef = Context.getLocalClass();
		var module = Context.getLocalModule();
		var cl = clRef != null ? clRef.get() : null;
		for (field in fields) {
			switch (field.kind) {
				case FFun(func):
					var name = cl != null ? {
						cl.module + "." + cl.name + ":";
					} : module + ".<?>:";
					name += field.name;

					var shouldAddPos = true;
					if(hasMeta(field.meta, ":to")) {
						shouldAddPos = false;
					} else if(hasMeta(field.meta, ":from")) {
						shouldAddPos = false;
					} else if(hasMeta(field.meta, ":op")) {
						shouldAddPos = false;
					} else if(hasMeta(field.meta, ":arrayAccess")) {
						shouldAddPos = false;
					} else if(field.name.startsWith("get_")) {
						shouldAddPos = false;
					} else if(field.name.startsWith("set_")) {
						shouldAddPos = false;
					} else if(field.name.startsWith("new")) {
						shouldAddPos = false;
					} else if (field.name == "keyValueIterator") {
						shouldAddPos = false;
					} else if (field.access.contains(AInline)) {
						shouldAddPos = false;
					}

					if(shouldAddPos) {
						func.args.push({
							name: "log____pos",
							opt: true,
							type: macro : haxe.PosInfos
						});
						func.expr = macro {
							@:pos(func.expr.pos) trace($v{name}, log____pos);
							${func.expr};
						};
					} else {
						func.expr = macro {
							@:pos(func.expr.pos) trace($v{name});
							${func.expr};
						};
					}

					/*
					trace($v{name}, $v{{
							fileName: field.pos.getInfos().file,
							lineNumber: 0,
							methodName: "",
							className: "",
							customParams: []
						}});
						*/
				default:
			}
		}
		return fields;
	}
	#end
}