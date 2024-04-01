package game.cdev.engineutils;

import flixel.FlxSubState;
import openfl.display3D.Context3D;
import flixel.FlxG;

import sys.io.Process;
import lime.system.System as LSystem;
import lime.app.Application;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

using StringTools;

class CDevInfoTxt extends TextField
{
	public static var current:CDevInfoTxt = null;

    public var wholeSystem:String = "";

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000)
	{
		super();
		x = inX;
		y = inY;
		current = this;

		selectable = false;
		var mobileMulti:Float = #if mobile 1.5; #else 1; #end
		defaultTextFormat = new TextFormat(FunkinFonts.VCR, Std.int(14*mobileMulti), inCol, false);
        visible = false;
        background = true;
        backgroundColor = 0x69000000;

	    addEventListener(Event.ENTER_FRAME, onEnter);
		autoSize = LEFT;

        wholeSystem = getSystem();
	}

	private function onEnter(_)
	{
        if (FlxG.keys.justPressed.F2) visible = !visible;
        if (!visible) return;
        y = (CDevFPSMem.current!=null?CDevFPSMem.current.y+CDevFPSMem.current.height : 0) + 20;
        text = getText();
	}

    public function getText(){
        return getFormatted([wholeSystem,getConductor(),getFlixel(),getLibVersion()]);
    }

    public function getFormatted(array:Array<String>){
        var out:String = "";
        var l:Int = 0;
        for (i in array){
            out+='$i${l>array.length?"":"\n\n"}';
            l++;
        }
        return out;
    }

    // i want to check how bad is my pc lmao
    // also you might already know which engine was this code inspired by
    public function getSystem():String {
        var os:String = "Failed to get OS data.";
        var cpu:String = "Failed to get CPU data.";
        var pgpu:String = "Failed to get GPU data.";
        var vram:String = "Failed to get VRAM data.";

        if (LSystem.platformLabel != null && LSystem.platformLabel != "" &&
            LSystem.platformVersion != null && LSystem.platformVersion != ""){
            os = '${LSystem.platformLabel.replace(LSystem.platformVersion, "").trim()} ${LSystem.platformVersion}';
        }

        try {
            var p = new Process("wmic", ["cpu","get","name"]);
            if (p.exitCode() == 0) {
                cpu = p.stdout.readAll().toString().trim().split("\n")[1].trim();
            }
        } catch (e:Dynamic){GameLog.error("Init Error: Can't get System CPU data, "+e.toString());}

        @:privateAccess{
            if (FlxG.stage.context3D != null && FlxG.stage.context3D.gl != null){
                pgpu = Std.string(FlxG.stage.context3D.gl.getParameter(FlxG.stage.context3D.gl.RENDERER)).split("/")[0].trim();
                if(Context3D.__glMemoryTotalAvailable != -1) {
					var vRAMBytes:Float = cast(FlxG.stage.context3D.gl.getParameter(openfl.display3D.Context3D.__glMemoryTotalAvailable), Float)*1024;
                    trace(vRAMBytes);
					if (vRAMBytes == 1000 || vRAMBytes == 1 || vRAMBytes <= 0)
						GameLog.error("Init Error: Can't get VRAM data.");
					else{
						vram = CDevConfig.utils.convert_size(vRAMBytes); // bro
                    }

				}
            }
        }

        var format:String = "// System //"
            + '\n- Current OS       : $os'
            + '\n- CPU Info         : $cpu'
            + '\n- GPU Info         : $pgpu'
            + '\n- VRAM Info        : $vram'
            + '\n- Max Texture Size : ${FlxG.bitmap.maxTextureSize+"x"+FlxG.bitmap.maxTextureSize}';
        return format;
    }

	public function getConductor():String {
		var con:String = "// Conductor //"
			+ '\n- Song Position : ${Conductor.songPosition}'
			+ '\n- Beats         : ${Conductor.curBeat}'
            + '\n- Steps         : ${Conductor.curStep}'
            + '\n- BPM           : ${Conductor.bpm}';

        return con;
	}
    var how:Int = 0;
    public function getFlixel():String {
        how = 0;
        var bmp:Int = 0;
        @:privateAccess{
            for (a in FlxG.bitmap._cache.keys())
                bmp++;
        }
        var e = getSubstate(FlxG.state.subState);
        var sub:String = (e != null ? '\n| - Substate : ${Type.getClassName(Type.getClass(e))} ${how>0?'(Nested: $how)' : ''}':'');
        var fli:String = "// Flixel //"
            + '\n- Version  : ${FlxG.VERSION}'
            + '\n- State    : ${Type.getClassName(Type.getClass(FlxG.state))}'
            + sub
            + '\n- Sounds   : ${FlxG.sound.list.length}'
            + '\n- Bitmaps  : ${bmp}'
            + '\n- Objects  : ${FlxG.state.members.length}';
        return fli;
    }

    public function getLibVersion():String {
        var haxeVer = haxe.macro.Compiler.getDefine("haxe");
        var flixVer = haxe.macro.Compiler.getDefine("flixel");
        var limeVer = haxe.macro.Compiler.getDefine("lime");
        var openVer = haxe.macro.Compiler.getDefine("openfl");
        var lib:String = "// Versions //"
            + '\n- Haxe     : ${haxeVer}'
            + '\n- Flixel    : ${flixVer}'
            + '\n- Lime     : ${limeVer}'
            + '\n- OpenFL   : ${openVer}';
        return lib;
    }

    public function getSubstate(wa:FlxSubState):FlxSubState {
        if (wa != null && wa.subState != null){
            how++;
            return getSubstate(wa.subState);
        } else{
            return wa;
        }
    }
}