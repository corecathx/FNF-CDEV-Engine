package game.cdev;

import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import meta.substates.MusicBeatSubstate;
import flixel.group.FlxSpriteGroup;

typedef PopUpButton = {
    var text:String;
    var callback:Void->Void;
}
class CDevPopUp extends MusicBeatSubstate
{
	var box:FlxSprite;
	var exitButt:FlxSprite;
    var bgBlack:FlxSprite;

    var buttons:Array<PopUpButton> = [];
    var titleT:String = "";
    var bodyT:String = "";

    var _hideBG:Bool = false;
    var _hideCloseButton:Bool = false;
	public function new(title:String, body:String, buttons:Array<PopUpButton>, ?hideBG:Bool = false,?hideCloseButton:Bool = false)
	{
		super();
        this.buttons = buttons;
        titleT = title;
        bodyT = body;
        _hideBG = hideBG;
        _hideCloseButton = hideCloseButton;
        if (!hideBG){
            bgBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            bgBlack.alpha = 0.5;
            add(bgBlack);
            bgBlack.scrollFactor.set();
        }


		box = new FlxSprite().makeGraphic(800, 400, FlxColor.BLACK);
		box.alpha = 0.7;
		box.screenCenter();
		add(box);
        box.scrollFactor.set();

        if (!hideCloseButton){
            exitButt = new FlxSprite().makeGraphic(30, 20, FlxColor.RED);
            exitButt.alpha = 0.7;
            exitButt.x = ((box.x + box.width) - 30) - 10;
            exitButt.y = (box.y + 20) - 10;
            add(exitButt);
            exitButt.scrollFactor.set();
        }


		createBoxUI();

        if (!hideBG){
            bgBlack.alpha = 0;
            FlxTween.tween(bgBlack, {alpha: 0.5},0.3,{ease: FlxEase.linear});
        }

		box.alpha = 0;

        FlxSpriteUtil.drawRoundRect(box,0,0,800,400,50,50, FlxColor.BLACK);
        box.alpha = 0;
		FlxTween.tween(box, {alpha: 0.7},0.3,{ease: FlxEase.linear});
        if (!hideCloseButton){
            exitButt.alpha = 0;
            FlxTween.tween(exitButt, {alpha: 0.7},0.3,{ease: FlxEase.linear});
        }
	}

    var bodyText:FlxText;
    var buttonsCrap:Array<CDevPopUpButton> = [];
	function createBoxUI()
	{
		var header:FlxText = new FlxText(box.x, box.y + 10, 800, titleT, 40);
		header.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(header);
        header.scrollFactor.set();
		bodyText = new FlxText(box.x+30, box.y + 40, 550, bodyT, 20);
		bodyText.font = "VCR OSD Mono";
		add(bodyText);
        bodyText.scrollFactor.set();
    
        for (i in 0...buttons.length){
            var button:CDevPopUpButton = new CDevPopUpButton(0,0,buttons[i].text, buttons[i].callback);
            button.x = box.x + 20 + (button.bWidth * i);//((box.width / 2)-(button.bWidth/2))-(button.bWidth*i);
            button.y = (box.y - button.bHeight) - 20;
            add(button);
            button.scrollFactor.set();
            buttonsCrap.push(button);
        }

        for (i in 0...buttonsCrap.length){
            buttonsCrap[i].x = (box.x+(box.width / 2)-(buttonsCrap[i].bWidth/2))-20-(buttonsCrap[i].bWidth*i);
            buttonsCrap[i].y = (box.y+box.height - buttonsCrap[i].bHeight) - 20;
        }
	}

	override function update(elapsed:Float) {

        if (!_hideCloseButton){
            if (FlxG.mouse.overlaps(exitButt))
                {
                    exitButt.alpha = 1;
                    if (FlxG.mouse.justPressed)
                        close();
                }
                else
                {
                    exitButt.alpha = 0.7;
                }
        
        }
		super.update(elapsed);
	}
}

class CDevPopUpButton extends FlxSpriteGroup{
    var buttBG:FlxSprite;
    var txt:FlxText;

    var callb:Void->Void;
    public var bWidth:Int = 150;
    public var bHeight:Int = 32;
    public function new(x:Float,y:Float,text:String, callback:Void->Void){
        super(x,y);
        this.callb = callback;
        buttBG = new FlxSprite().makeGraphic(150, 32, FlxColor.fromRGB(70, 70, 70));
		add(buttBG);

		txt = new FlxText(20,20, 0, text, 18);
		txt.font = "VCR OSD Mono";
		txt.alignment = CENTER;
		add(txt);
        buttBG.setGraphicSize(Std.int(txt.width+20), Std.int(txt.height+20));
        bWidth = Std.int(buttBG.width);
        bHeight = Std.int(buttBG.height);

        CDevConfig.utils.moveToCenterOfSprite(txt, buttBG);
        txt.scrollFactor.set();
        buttBG.scrollFactor.set();
    }

    override function update(elapsed:Float){
        super.update(elapsed);
        if (FlxG.mouse.overlaps(this))
        {
            this.alpha = 1;

            if (FlxG.mouse.justPressed){
                callb();
            }
		}
		else
		{
            this.alpha = 0.7;
       }
    }
}