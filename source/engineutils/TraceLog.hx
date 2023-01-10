package engineutils;

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

class TraceLog extends FlxGroup
{
	public static var TRACE_LOG_DATA:Array<String> = [
		'This is a trace log window, use "trace(_message);" function on your hscript',
		"file and the message will appear in here.",
		'(Replace the "_message" with your message)',
		''
	];

	var window_title:String = 'CDEV Engine Trace Log';
	static var isItVisible:Bool = false;

	public var PANEL_BG:FlxSprite;

	var panel_title:FlxSprite;
	var text:FlxText;

	public static var LogText:FlxText;
	var __x:Float = 0;
	var __y:Float = 0;
    
	public function new(x:Float, y:Float, width:Int, height:Int)
	{
		super();
		__x = x;
		__y = y;
		killed = false;

		PANEL_BG = new FlxSprite(x, y).makeGraphic(width, height, FlxColor.BLACK);
		PANEL_BG.alpha = 0.5;
		add(PANEL_BG);

		panel_title = new FlxSprite(x, y).makeGraphic(width, 20, FlxColor.BLACK);
		add(panel_title);
		text = new FlxText(panel_title.x, panel_title.y, PANEL_BG.width - 2, window_title, 10);
		add(text);

		if (LogText == null){
			LogText = new FlxText(x + 2, y + 20 + 10, 0, '', 10);
			add(LogText);
		}
        
        addLogData('This is a trace log window, use "trace(_message);" function on your hscript');
		addLogData('file and the message will appear in here.');
		addLogData('Press F5 to Hide / Show this window.');

		addLogData('');

		visible = isItVisible;
	}

	override function update(elapsed:Float)
	{
		if (!killed){
			isItVisible = visible;
			if (text.text != window_title)
				{
					text.text = window_title;
				}
		
				panel_title.setPosition(PANEL_BG.x, PANEL_BG.y);
				text.setPosition(panel_title.x, panel_title.y);
		
				if (FlxG.keys.justPressed.F5) {
					this.visible = !this.visible;
				}

				if (LogText != null){
					LogText.setPosition(PANEL_BG.x + 2, PANEL_BG.y + 20 + 10);
				}
		} else{
			if (members.contains(LogText)){
				remove(LogText);
			}
		}
	}
	public static var killed:Bool = false;
	public static function resetLogText()
	{
		if (LogText != null){
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
		LogText.text = '';
	}

	public static function addLogData(Data:Dynamic)
	{
        if (LogText != null){
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
}
