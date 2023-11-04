package game.cdev.engineutils;

import flixel.FlxCamera;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import meta.states.PlayState;
import flixel.graphics.FlxGraphic;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.FlxG;
import openfl.display.Sprite;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import openfl.net.FileReference;

using StringTools;

class TraceLog extends FlxGroup
{
	public static var _file:FileReference;
	public static var TRACE_LOG_DATA:Array<String> = [
	];

	var window_title:String = 'Trace Log Window';

	static var isItVisible:Bool = false;

	public var PANEL_BG:FlxSprite;

	var panel_title:FlxSprite;
	var text:FlxText;

	var closeButton:FlxGroup;

	public static var LogText:FlxText;

	var __x:Float = 0;
	var __y:Float = 0;

	var sprClose:FlxSprite;
	var sprCloseX:FlxSprite;

	var sprSave:FlxSprite;
	var sprSaveI:FlxSprite;
	var widthThis:Int = 0;
	var heightThis:Int = 0;

	public var mainCameraObject:FlxCamera = null;

	public function new(x:Float, y:Float, width:Int, height:Int)
	{
		super();
		__x = x;
		__y = y;
		killed = false;
		heightThis = height;
		widthThis = width;

		PANEL_BG = new FlxSprite(x, y).makeGraphic(width, height, FlxColor.BLACK);
		PANEL_BG.alpha = 0.5;
		add(PANEL_BG);

		panel_title = new FlxSprite(x, y).makeGraphic(width, 20, FlxColor.BLACK);
		add(panel_title);
		text = new FlxText(panel_title.x + 2.5, panel_title.y + 2.5, PANEL_BG.width - 2, window_title, 10);
		add(text);

		sprClose = new FlxSprite(panel_title.x + width - 20, panel_title.y + height - 40).makeGraphic(20, 20, 0xFFFF0000);
		add(sprClose);

		var pointerSprite:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		sprCloseX = new FlxSprite(sprClose.x + (sprClose.width / 2) - 10, sprClose.y + (sprClose.height / 2) - 10).loadGraphic(pointerSprite);
		sprCloseX.setGraphicSize(10, 10);
		sprCloseX.angle = 45;
		sprCloseX.updateHitbox();
		sprCloseX.color = FlxColor.WHITE;
		add(sprCloseX);

		sprSave = new FlxSprite(panel_title.x + width - 40, panel_title.y + height - 40).makeGraphic(20, 20, 0xFFFFFFFF);
		add(sprSave);
		sprSaveI = new FlxSprite().loadGraphic(Paths.image("ui/file", "shared"));
		sprSaveI.setGraphicSize(10, 10);
		sprSaveI.updateHitbox();
		sprSaveI.setPosition(sprSave.x + (sprSave.width / 2) - 10, sprSave.y + (sprSave.height / 2) - 10);
		add(sprSaveI);

		if (LogText == null)
		{
			LogText = new FlxText(x + 2.5, y + 20 + 10, PANEL_BG.width-20, '', 10);
			add(LogText);
		}

		if (!CDevConfig.saveData.traceLogMessage){
			addLogData('This is a trace log window, use "trace(_message);" function on your hscript');
			addLogData('file and the message will appear in here.');
			addLogData('Press F5 to Hide / Show this window.');
	
			addLogData('');
		}


		visible = isItVisible;
	}

	override function update(elapsed:Float)
	{
		if (!killed)
		{
			isItVisible = visible;
			if (text.text != window_title)
			{
				text.text = window_title;
			}

			panel_title.setPosition(PANEL_BG.x, PANEL_BG.y);
			text.setPosition(panel_title.x, panel_title.y);

			sprClose.setPosition(panel_title.x + widthThis - 20, panel_title.y);
			sprCloseX.setPosition(sprClose.x + (sprClose.width / 2) - 5, sprClose.y + (sprClose.height / 2) - 5);

			sprSave.setPosition(panel_title.x + widthThis - 40, panel_title.y);
			sprSaveI.setPosition(sprSave.x + (sprSave.width / 2) - 5, sprSave.y + (sprSave.height / 2) - 5);

			if (FlxG.mouse.getScreenPosition(mainCameraObject).x > sprClose.x
				&& FlxG.mouse.getScreenPosition(mainCameraObject).x < sprClose.x + sprClose.width
				&& FlxG.mouse.getScreenPosition(mainCameraObject).y > sprClose.y
				&& FlxG.mouse.getScreenPosition(mainCameraObject).y < sprClose.y + sprClose.height)
			{
				sprClose.alpha = 0.5;
				if (FlxG.mouse.justPressed)
				{
					visible = false;
				}
			} else{
				sprClose.alpha = 0;
			}

			if (FlxG.mouse.getScreenPosition(mainCameraObject).x > sprSave.x
				&& FlxG.mouse.getScreenPosition(mainCameraObject).x < sprSave.x + sprSave.width
				&& FlxG.mouse.getScreenPosition(mainCameraObject).y > sprSave.y
				&& FlxG.mouse.getScreenPosition(mainCameraObject).y < sprSave.y + sprSave.height)
			{
				sprSave.alpha = 0.5;
				if (FlxG.mouse.justPressed)
				{
					var aw:meta.states.PlayState = null;
					var curState:Dynamic = FlxG.state;
					aw = curState;

					aw.pauseGame();

					saveTraceData();
				}
			}else sprSave.alpha = 0;

			if (FlxG.mouse.getScreenPosition(mainCameraObject).x > PANEL_BG.x
				&& FlxG.mouse.getScreenPosition(mainCameraObject).x < PANEL_BG.x + PANEL_BG.width
				&& FlxG.mouse.getScreenPosition(mainCameraObject).y > PANEL_BG.y
				&& FlxG.mouse.getScreenPosition(mainCameraObject).y < PANEL_BG.y + PANEL_BG.height)
			{
				if (LogText != null && LogText.textField != null)
				{
					if (FlxG.mouse.wheel < 0){
						trace("scroll up");
						LogText.textField.scrollV -= 1;
					} else if (FlxG.mouse.wheel > 0){
						trace("scroll down");
						LogText.textField.scrollV += 1;
					}
				}
			}

			if (FlxG.keys.justPressed.F5)
			{
				this.visible = !this.visible;
			}

			if (LogText != null)
			{
				LogText.setPosition(PANEL_BG.x + 2, PANEL_BG.y + 20 + 10);
			}
		}
		else
		{
			if (members.contains(LogText))
			{
				remove(LogText);
			}
		}
	}

	public static var killed:Bool = false;

	public static function resetLogText()
	{
		if (LogText != null)
		{
			LogText.destroy();
			LogText.kill();
			LogText = null;
			killed = true;
		}
	}

	public static function clearLogData()
	{
		TRACE_LOG_DATA = [
			'This is a trace log window, use "trace(_message);" function on your hscript file and the message will appear in here.',
			'(Replace the "_message" with your message)',
			''
		];

		if (!CDevConfig.saveData.traceLogMessage){
			TRACE_LOG_DATA = [];
		}
		LogText.text = '';
	}

	public static function addLogData(Data:Dynamic)
	{
		if (LogText != null)
		{
			if (Data == null)
			{
				return;
			}

			var textt:String = '';

			textt = Std.string(Data);

			// Actually add it to the textfield
			if (TRACE_LOG_DATA.length <= 0)
			{
				LogText.text = "";
			}

			TRACE_LOG_DATA.push(textt);

			if (TRACE_LOG_DATA.length > 15)
			{
				TRACE_LOG_DATA.shift();
				var newText:String = "";
				for (i in 0...TRACE_LOG_DATA.length)
				{
					newText += TRACE_LOG_DATA[i] + '\n';
				}

				LogText.text = newText;
			}
			else
			{
				LogText.text += textt + "\n";
			}

			if (LogText.textField != null)
				LogText.textField.scrollV = Std.int(LogText.textField.maxScrollV);
		}
	}

	public static function saveTraceData()
	{
		// var data:String = Json.stringify(json);
		var data:String = "";

		for (tr in TRACE_LOG_DATA)
		{
			data += tr + '\n';
		}

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "TraceLog- " + Date.now() +".txt");
		}
	}

	public static function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved trace DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	public static function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	public static function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving trace data");
	}
}
