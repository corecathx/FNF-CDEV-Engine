package game.cdev.engineutils;

import flixel.FlxCamera;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
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

	// these two sucks
	public var RENDERED_DATA:Array<String> = [];

	public function set_TRACE_LOG_DATA(val:Array<Dynamic>)
	{
		_clearData();
		return val;
	}

	var window_title:String = 'Trace Log Window';

	static var isItVisible:Bool = false;

	public var PANEL_BG:FlxSprite;

	var panel_title:FlxSprite;
	var text:FlxText;

	var closeButton:FlxGroup;

	public var logText:FlxText;

	var __x:Float = 0;
	var __y:Float = 0;

	var sprClose:FlxSprite;
	var sprCloseX:FlxSprite;

	var sprSave:FlxSprite;
	var sprSaveI:FlxSprite;
	var widthThis:Int = 0;
	var heightThis:Int = 0;

	public var mainCameraObject:FlxCamera = null;

	public static var instance:TraceLog = null;

	public function new(x:Float, y:Float, width:Int, height:Int)
	{
		super();
		__x = x;
		__y = y;
		killed = false;
		heightThis = height;
		widthThis = width;
		instance = this;

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

		logText = new FlxText(x + 2.5, y + 20 + 10, PANEL_BG.width - 20, '', 10);
		add(logText);

		if (!CDevConfig.saveData.traceLogMessage)
		{
			addLog('This is a trace log window, use "trace(_message);" function on your hscript');
			addLog('file and the message will appear in here.');
			addLog('Press F5 to Hide / Show this window.');

			addLog('');
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

			// sprSave.setPosition(panel_title.x + widthThis - 40, panel_title.y);
			// sprSaveI.setPosition(sprSave.x + (sprSave.width / 2) - 5, sprSave.y + (sprSave.height / 2) - 5);

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
			}
			else
			{
				sprClose.alpha = 0;
			}

			if (FlxG.mouse.getScreenPosition(mainCameraObject).x > PANEL_BG.x
				&& FlxG.mouse.getScreenPosition(mainCameraObject).x < PANEL_BG.x + PANEL_BG.width
				&& FlxG.mouse.getScreenPosition(mainCameraObject).y > PANEL_BG.y
				&& FlxG.mouse.getScreenPosition(mainCameraObject).y < PANEL_BG.y + PANEL_BG.height)
			{
				if (logText != null && logText.textField != null)
				{
					if (FlxG.mouse.wheel < 0)
					{
						trace("scroll up");
						logText.textField.scrollV -= 1;
					}
					else if (FlxG.mouse.wheel > 0)
					{
						trace("scroll down");
						logText.textField.scrollV += 1;
					}
				}
			}

			if (FlxG.keys.justPressed.F5)
			{
				this.visible = !this.visible;
				FlxG.mouse.visible = this.visible;
			}

			if (logText != null)
			{
				logText.setPosition(PANEL_BG.x + 2, PANEL_BG.y + 20 + 10);
			}
		}
		else
		{
			if (members.contains(logText))
			{
				remove(logText);
			}
		}
	}

	public static var killed:Bool = false;

	override function destroy()
	{
		_resetText();
		this.kill();
		super.destroy();

	}

	public function _resetText()
	{
		if (logText != null)
		{
			logText.destroy();
			logText.kill();
			if (members.contains(logText))
				remove(logText);
			logText = null;

			killed = true;
		}
	}

	public function _clearData()
	{
		RENDERED_DATA = [
			'This is a trace log window, use "trace(_message);" function on your hscript file and the message will appear in here.',
			'(Replace the "_message" with your message)',
			''
		];

		if (!CDevConfig.saveData.traceLogMessage) RENDERED_DATA = [];

		if (logText != null) logText.text = '';
	}

	public function _addData(Data:Dynamic)
	{
		if (logText != null)
		{
			if (Data == null) return;

			var textt:String = '';
			textt = Std.string(Data);

			if (RENDERED_DATA.length <= 0)
			{
				logText.text = "";
			}

			RENDERED_DATA.push(textt);

			if (RENDERED_DATA.length > 15)
			{
				RENDERED_DATA.shift();
				var newText:String = "";
				for (i in 0...RENDERED_DATA.length)
				{
					newText += RENDERED_DATA[i] + '\n';
				}

				logText.text = newText;
			}
			else
			{
				logText.text += textt + "\n";
			}

			if (logText.textField != null)
				logText.textField.scrollV = Std.int(logText.textField.maxScrollV);
		}
	}

	/**
	 *  shortcut functions
	 */
	public static function addLog(text:Dynamic)
	{
		if (TraceLog.instance != null) TraceLog.instance._addData(text);
	}

	public static function clearLog()
	{
		if (TraceLog.instance != null) TraceLog.instance._clearData();
	}

	public static function resetLog()
	{
		// basically clearLog()
		if (TraceLog.instance != null) TraceLog.instance._clearData();
	}
}
