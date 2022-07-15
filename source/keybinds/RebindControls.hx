package keybinds;

//the codes are from RozeBud for FPS Plus
//modified by coredev
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.text.FlxText;
import game.*;

class RebindControls extends substates.MusicBeatSubstate
{
	private var curSelected:Int = 0;
	var keyBinds:Array<String> = [
		FlxG.save.data.leftBind,
		FlxG.save.data.downBind,
		FlxG.save.data.upBind,
		FlxG.save.data.rightBind,
		FlxG.save.data.resetBind
	];

	var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT", "RESET"];

	var allowedToPress:Bool = false;
	var daText:FlxText;
	var status:String = "select";
	var tempBind:String = "";
	var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "TAB"];

	public function new(isFromPause:Bool) {
		super();

		var blackBox:FlxSprite = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
		blackBox.alpha = 0.7;
		if (!isFromPause)
        	add(blackBox);

		daText = new FlxText(0,180, FlxG.width, "", 28);
		daText.setFormat('VCR OSD Mono', 36, FlxColor.WHITE,CENTER,OUTLINE,FlxColor.BLACK);
		daText.borderSize = 2.5;
		daText.borderQuality = 3;
		add(daText);

		textUpdate();

		new FlxTimer().start(0.2, function(bruh:FlxTimer){
			allowedToPress = true;
		});

		if (isFromPause)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float) {
		switch (status)
		{
			case 'select':
				if (FlxG.keys.justPressed.UP)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-1);
						textUpdate();
					}
	
					if (FlxG.keys.justPressed.DOWN)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(1);
						textUpdate();
					}
					if (allowedToPress)
						{
							if (FlxG.keys.justPressed.ENTER){
								FlxG.sound.play(Paths.sound('scrollMenu'));
								status = "input";
							}							
						}

					if(FlxG.keys.justPressed.ESCAPE){
						FlxG.sound.play(Paths.sound('cancelMenu'));
						close();
					}
			case 'input':
				tempBind = keyBinds[curSelected];
				keyBinds[curSelected] = "?";
                status = "wait";
				textUpdate();
			case 'wait':
				if(FlxG.keys.justPressed.ESCAPE){
					keyBinds[curSelected] = tempBind;
					status = "select";
					FlxG.sound.play(Paths.sound('confirmMenu'));
					textUpdate();
				}
				else if(FlxG.keys.justPressed.ENTER){
					if (allowedToPress)
						{
							keyBinds[curSelected] = tempBind;
							status = "select";
							FlxG.sound.play(Paths.sound('confirmMenu'));		
							textUpdate();					
						}

				}
				else if(FlxG.keys.justPressed.ANY){
					FlxG.sound.play(Paths.sound('confirmMenu'));		
					addKey(FlxG.keys.getIsDown()[0].ID.toString());
					save();
					status = "select";
					textUpdate();
				}
		}
	}

	function save(){

        FlxG.save.data.upBind = keyBinds[2];
        FlxG.save.data.downBind = keyBinds[1];
        FlxG.save.data.leftBind = keyBinds[0];
        FlxG.save.data.rightBind = keyBinds[3];
		FlxG.save.data.resetBind = keyBinds[4];
        FlxG.save.flush();

		cdev.CDevConfig.saveCurrentKeyBinds();
        engineutils.PlayerSettings.player1.controls.loadKeyBinds();
    }

	function textUpdate()
	{
        daText.text = "\n\n";
        for(i in 0...5){
			var textStart = (i == curSelected) ? "> " : "  ";
			if (i == 5)
				{
					daText.text += textStart + keyText[i] + ": " + ((keyBinds[i] != keyText[i]) ? (keyBinds[i] + " / ") : "" ) + keyText[i] + (curSelected != 5 ? " ARROW\n": "\n");
				} else{
					daText.text += textStart + keyText[i] + ": " + keyBinds[i] + "\n";			
				}
		}
        daText.screenCenter();
    }

	public var lastKey:String = "";

	function addKey(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = [];
        var swapKey:Int = -1;

        for(x in blacklist){
			notAllowed.push(x);
		}

        trace(notAllowed);

        for(x in 0...keyBinds.length)
            {
                var oK = keyBinds[x];
                if(oK == r) {
                    swapKey = x;
                    keyBinds[x] = null;
                }
                if (notAllowed.contains(oK))
                {
                    keyBinds[x] = null;
                    lastKey = oK;
                    return;
                }
            }

        if (notAllowed.contains(r))
        {
            keyBinds[curSelected] = tempBind;
            lastKey = r;
            return;
        }

        lastKey = "";

        if(shouldReturn){
            if (swapKey != -1) {
                keyBinds[swapKey] = tempBind;
            }
            keyBinds[curSelected] = r;
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        else{
            keyBinds[curSelected] = tempBind;
            lastKey = r;
        }

	}

    function changeItem(_amount:Int = 0)
    {
        curSelected += _amount;

		textUpdate();
                
        if (curSelected > 4)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 4;
    }
}