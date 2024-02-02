package game.cdev.log;

import flixel.system.frontEnds.LogFrontEnd;
import haxe.PosInfos;
import haxe.Log;
import lime.app.Application;
import openfl.Lib;
import flixel.FlxG;
import openfl.events.Event;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;

import haxe.iterators.ArrayIterator;

using StringTools;

class GameLogType {
    public static var LOG:String = "[LOG]";
    public static var WARNING:String = "[WARNING]";
    public static var ERROR:String = "[ERROR]";
	public static var GAME:String = "[GAME]";
}

class GameLogData {
	public var text:String = "[LOG]";
	public var color:Int = 0xFFFFFF;

	public function new(text:String, color:Int){
		this.text = text;
		this.color = color;
	}
}

/**
 * Trace Log, but better.
 */
class GameLog extends Sprite
{
	/** Log data array **/
	public var logData:Array<String> = [];

	public var texts:Map<String, GameLogData> = [
		GameLogType.LOG => new GameLogData(GameLogType.LOG, 0xFFFFFF),
		GameLogType.WARNING => new GameLogData(GameLogType.WARNING, 0xFFFF00),
		GameLogType.ERROR => new GameLogData(GameLogType.ERROR, 0xFF0000),
		GameLogType.GAME => new GameLogData(GameLogType.GAME, 0x00B7FF),
	];

	/** Background of this class. **/
	public var bg:Bitmap;

	/** Title text object of this class. **/
	public var title:TextField;

	/** "thing" of this class. **/
	public var thing:TextField;

	/** Log text object of this class. **/
	public var logText:TextField;

	/** Log text object of this class. **/
	public var logTextSize:Int = 15;

	/** Static visible tracker for this class. **/
	public static var isVisible:Bool = false;

	/** Current instance of GameLog **/
	public static var current:GameLog = null;

    public static var initialized:Bool = false;

	public static var defaultHaxeFunction:Dynamic = null;

	//baseText + spacing + errorText + spacing + warningText;
	public var baseText:String = "CDEV Engine v" + CDevConfig.engineVersion + " - Game Log";
	public var errorCounter:Int = 0;
	public var errorText:String = "0 Errors";
	public var spacing:String = " // ";
	public var warningCounter:Int = 0;
	public var warningText:String = "0 Warnings";

	public var bottomBar:Bitmap = null;
	public var topBar:Bitmap = null;

	public static function startInit(){
		if (initialized) return;
		defaultHaxeFunction = Log.trace;
		Log.trace = function(v:Dynamic, ?infos:PosInfos):Void {
			var split:Array<String> = infos.className.split(".");
			defaultHaxeFunction(v, infos);
			GameLog.game(split[split.length-1]+".hx: "+infos.lineNumber+": " + Std.string(v));
		}

		initialized = true;
	}

	public function new()
	{
		super();

		current = this;

		bg = new Bitmap(new BitmapData(FlxG.width, FlxG.height*2, true, 0x95000000));
		addChild(bg);

		topBar = new Bitmap(new BitmapData(FlxG.width, 22, true, 0x90000000));
		addChild(topBar);

		bottomBar = new Bitmap(new BitmapData(Application.current.window.width, 22, true, 0x90000000));
		bottomBar.y = Application.current.window.height-22;
		addChild(bottomBar);

		title = createText(0, 2, {width: FlxG.width, height: 20}, "CDEV Engine v" + CDevConfig.engineVersion + " - Game Log // 0 Errors - 0 Warnings", 16);
		title.x = (FlxG.width / 2) - (title.width / 2);
		addChild(title);

		thing = createText(0, 2, {width: 450, height: 20}, "[R] Clear the Log // [F5] Hide / Show this log window", 16);
		thing.defaultTextFormat.align = LEFT;
		thing.x = 10;
		thing.y = Application.current.window.height - 22;
		addChild(thing);

		logText = createText(10, 40, {width: FlxG.width - 20, height: FlxG.height - 34}, "", logTextSize, LEFT);
		logText.multiline = true;
		logText.autoSize = LEFT;
		addChild(logText);

		this.visible = isVisible;
		addEventListener(Event.ENTER_FRAME, onFrameUpdate);
		FlxG.stage.window.onResize.add(onStageResized);
	}

    private function onStageResized(newWidth:Int, newHeight:Int):Void{
		title.width = Application.current.window.width;
        title.x = (Application.current.window.width/2) - (title.width / 2);
		bg.width = Application.current.window.width;
		bg.height = Application.current.window.height;
		logText.height = Application.current.window.height - 94;

		thing.x = 10;
		thing.y = Application.current.window.height - 22;

		bottomBar.y = Application.current.window.height-22;
		bottomBar.width = topBar.width = Application.current.window.width;
    }

    public static function error(data:Dynamic){
        if (GameLog.current != null){
            GameLog.current.addLog(data, GameLogType.ERROR);
			GameLog.current.errorCounter++;
            GameLog.current.changeActive(true);
        }
    }

    public static function warn(data:Dynamic){
        if (GameLog.current != null){
            GameLog.current.addLog(data, GameLogType.WARNING);
			GameLog.current.warningCounter++;
		}
    }

    public static function log(data:Dynamic){
        if (GameLog.current != null)
            GameLog.current.addLog(data, GameLogType.LOG);
    }

	public static function game(data:Dynamic){
        if (GameLog.current != null)
            GameLog.current.addLog(data, GameLogType.GAME);
    }

	public function addLog(Data:Dynamic, ?logType:String)
	{
		if (logText != null)
		{
			if (Data == null)
				return;

			var textt:String = "";
            var dataThing:String = Std.string(Data);

			if (logData.length <= 0)
				logText.text = "";

			var info:GameLogData = texts.get(logType);

			textt = (info != null ? info.text + " " : "") + dataThing;
			logData.push(textt);

			if (logData.length > 45)
				logData.shift();

            var colorThese:Array<Dynamic> = []; //[start,end,color];
            var newText:String = "";
            for (i in 0...logData.length)
            {
				var kys:Array<String> = [];

				for (keys in texts)
					kys.push(keys.text);

				for (val in kys){
					if (logData[i].startsWith(val)){
						var formatData:GameLogData = texts.get(val);
						if (formatData!=null){
							var colorFormat:Int = formatData.color;
							var stringIndex:Array<Int> = [
								newText.length,
								newText.length+logData[i].length
							];
		
							colorThese.push([stringIndex[0], stringIndex[1], colorFormat]);
						}
					}
				}

                newText += logData[i] + '\n';
            }

            logText.text = newText;

            for (i in colorThese) logText.setTextFormat(createTextFormat(i[2], logTextSize), i[0], i[1]);

            logText.defaultTextFormat.align = LEFT;
			if (logText != null)
				logText.scrollV = Std.int(logText.maxScrollV);
		}
	}

	var lastMouseWasActive:Bool = false;

	private function onFrameUpdate(_):Void
	{
		// this is pretty much acts like update() function
		if (FlxG.keys.justPressed.F5)
            changeActive(!isVisible);

		if (isVisible){
			if (FlxG.keys.justPressed.R){
				logData = [];
				logText.text = "";
				errorCounter = 0;
				warningCounter = 0;
			}
			
			errorText = errorCounter + " Errors";
			warningText = warningCounter + " Warnings";

			var errorColor:Array<Int> = [
				baseText.length + spacing.length,
				baseText.length + spacing.length + errorText.length
			];

			var warnColor:Array<Int> = [
				baseText.length + spacing.length + errorText.length + spacing.length,
				baseText.length + spacing.length + errorText.length + spacing.length + warningText.length
			];

			title.text = baseText + spacing + errorText + spacing + warningText;

			title.setTextFormat(createTextFormat(0xFF0000, 16), errorColor[0], errorColor[1]);
			title.setTextFormat(createTextFormat(0xFFFF00, 16), warnColor[0], warnColor[1]);
		}
	}

    public function changeActive(toThis:Bool){
        if (CDevConfig.saveData.showTraceLogAt==1){
            if (!this.visible){
                lastMouseWasActive = FlxG.mouse.visible;
                FlxG.mouse.visible = true;
            }
            else
                FlxG.mouse.visible = lastMouseWasActive;
            isVisible = toThis;
            this.visible = isVisible;
        } else{
            isVisible = false;
        }
        this.visible = isVisible;
    }

	public function createText(_x:Float, _y:Float, _sizeData:Dynamic, _text:String, _size:Int, _textAlign:TextFormatAlign = CENTER, ?_color:Int = 0xFFFFFF)
	{
		var object:TextField = new TextField();
		object.width = _sizeData.width;
		object.height = _sizeData.height;
		object.multiline = true;
		object.wordWrap = true;
		object.selectable = false;

		#if flash
		object.embedFonts = true;
		object.antiAliasType = AntiAliasType.NORMAL;
		object.gridFitType = GridFitType.PIXEL;
		#end

		var dtf:TextFormat = new TextFormat("VCR OSD Mono", _size, _color);
		dtf.align = _textAlign;
		object.defaultTextFormat = dtf;
		object.text = _text;

		object.x = _x;
		object.y = _y;

		return object;
	}

    public function createTextFormat(_color:Int = 0xFFFFFF, _size:Int = 10){
        return new TextFormat("VCR OSD Mono", _size, _color);
    }
}
