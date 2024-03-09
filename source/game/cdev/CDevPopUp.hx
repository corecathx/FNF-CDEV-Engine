package game.cdev;

import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.math.FlxMath;
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

    var titleS:FlxSprite;
	var iconS:FlxSprite;
	var titleTextS:FlxText;

    var buttons:Array<PopUpButton> = [];
    var titleT:String = "";
    var bodyT:String = "";

    var _hideBG:Bool = false;
    var _hideCloseButton:Bool = false;
    var lastMouseWasVisible:Bool = false;
	public function new(title:String, body:String, buttons:Array<PopUpButton>, ?hideBG:Bool = false,?hideCloseButton:Bool = false)
	{
		super();
        lastMouseWasVisible = FlxG.mouse.visible;
        FlxG.mouse.visible = true;//nu
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

		var tempbodyText = new FlxText(0,0, -1, bodyT, 18);
		tempbodyText.font = "VCR OSD Mono";
        tempbodyText.fieldWidth = FlxMath.bound(tempbodyText.fieldWidth,0,780);
        @:privateAccess tempbodyText.regenGraphic();
        tempbodyText.drawFrame(true);
        tempbodyText.scrollFactor.set();

        var wee:Int = Std.int(tempbodyText.width +70);
        var hee:Int = Std.int(70 + tempbodyText.height+ 50);
		box = FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(wee,hee, FlxColor.TRANSPARENT), 0, 0, wee,  hee, 15, 15, FlxColor.BLACK);
		box.screenCenter();
        box.scrollFactor.set();
		box.alpha = 0;

        //i tried FlxOutlineEffect, the results are ass
        var newEffect = FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(wee+4,hee+4, FlxColor.TRANSPARENT), 0, 0, wee+4, hee+4, 15, 15, 0xFF006EFF);
        newEffect.setPosition(box.x-2,box.y-2);
        newEffect.antialiasing=CDevConfig.saveData.antialiasing;
        newEffect.alpha = 0;
        add(newEffect);
        newEffect.scrollFactor.set();
        add(box);

        createBoxUI();

        if (!hideBG){
            bgBlack.alpha = 0;
            FlxTween.tween(bgBlack, {alpha: 0.5},0.15,{ease: FlxEase.linear});
        }

        if (!hideCloseButton){
            exitButt = new FlxSprite().makeGraphic(30, 20, FlxColor.RED);
            exitButt.alpha = 0.7;
            exitButt.x = ((box.x + box.width) - 30) - 10;
            exitButt.y = box.y+9;
            add(exitButt);
            exitButt.scrollFactor.set();
        }
        
        FlxTween.tween(box, {alpha: 1},0.15,{ease: FlxEase.linear});
		FlxTween.tween(newEffect, {alpha: 0.2},0.15,{ease: FlxEase.linear});
        if (!hideCloseButton){
            exitButt.alpha = 0;
            FlxTween.tween(exitButt, {alpha: 0.7},0.15,{ease: FlxEase.linear});
        }
	}

    var bodyText:FlxText;
    var buttonsCrap:Array<CDevPopUpButton> = [];
	function createBoxUI()
	{
        titleS = FlxSpriteUtil.drawRoundRectComplex(new FlxSprite().makeGraphic(Std.int(box.width), 32, FlxColor.TRANSPARENT), 0, 0, Std.int(box.width), 32, 5,
            5, 0, 0, FlxColor.fromRGB(64, 62, 60, 255));
        titleS.setPosition(box.x, box.y);
        titleS.alpha = 0.9;
        add(titleS);

        iconS = new FlxSprite().loadGraphic(Paths.image("icon16", "shared"));
        iconS.setPosition(titleS.x + 9, titleS.y + 9);
        add(iconS);

        titleTextS = new FlxText(iconS.x + iconS.width + 8, 0, -1, titleT, 14);
        titleTextS.setFormat("VCR OSD Mono", 14, FlxColor.WHITE);
        titleTextS.y = iconS.y + ((iconS.width / 2) - (titleTextS.height / 2));
        add(titleTextS);

        titleS.scrollFactor.set();
        iconS.scrollFactor.set();
        titleTextS.scrollFactor.set();

		bodyText = new FlxText(box.x+30, box.y + 50, -1, bodyT, 18);
        bodyText.fieldWidth = FlxMath.bound(bodyText.fieldWidth,0,780);
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
            //(box.x+(box.width / 2)-(buttonsCrap[i].bWidth/2))-20-(buttonsCrap[i].bWidth*i);
            var oldButtWidth = (buttonsCrap[i-1] == null ? 0 : buttonsCrap[i-1].bWidth);
            buttonsCrap[i].x = box.x + ((box.width-(buttonsCrap[i].bWidth + (oldButtWidth + 20))));
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
        buttBG.setGraphicSize(Std.int(txt.width+20), Std.int(txt.height+12));
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