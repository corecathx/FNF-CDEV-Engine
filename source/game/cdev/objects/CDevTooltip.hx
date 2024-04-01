package game.cdev.objects;

import flixel.input.FlxPointer;
import flixel.group.FlxSpriteGroup;

class CDevTooltip extends FlxSpriteGroup {
    var curTracked:FlxObject = null;

    var headText:FlxText;
    var bodyText:FlxText;

    var bgImageOutline:FlxSprite;
    var bgImage:FlxSprite;

    var colors = {
        outline: 0xFF006EFF,
        bg: 0xFF121825
    }

    var padding(default,set):Int = 10;
    var paddingUpdate:Bool = false;

    var borderSize:Float = 1;

    var isVisible:Bool = false;
    public function new() {
        super();
        init();
        changeColor(0xFF121825, 0xFF006EFF);
    }

    public function init(){
        bgImageOutline = new FlxSprite(x,y).makeGraphic(1,1,0xFFFFFFFF);
        add(bgImageOutline);

        bgImage = new FlxSprite(padding,padding).makeGraphic(1,1,0xFFFFFFFF);
        add(bgImage);

        headText = new FlxText(x,y,-1,"",14);
        headText.setFormat(FunkinFonts.VCR, 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(headText);

        bodyText = new FlxText(x,y,-1,"",14);
        bodyText.setFormat(FunkinFonts.VCR, 14, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(bodyText);

        bodyText.active = headText.active = false;
    }

    public function show(lockObj:FlxObject,head:String, body:String, ?spawnOnMouse:Bool = false){
        if (lockObj == null) return;
        isVisible = true;

        if (spawnOnMouse) {
            var fpPoint:FlxPoint = new FlxPoint(0,0);
            @:privateAccess {
                fpPoint = FlxPointer._cachedPoint;
            }
            FlxG.mouse.getScreenPosition(this.cameras[0], fpPoint);
            fpPoint.putWeak();

            var yFlip:Bool = (FlxG.mouse.y > FlxG.height/2);
            var xFlip:Bool = (FlxG.mouse.x > FlxG.width/2);
            
            var xVal:Float = FlxG.mouse.x + (xFlip ? -(width + 5) : 25);
            var yVal:Float = FlxG.mouse.y + (yFlip ? -(height + 5) : 25);
            setPosition(xVal, yVal);
        }

        curTracked = lockObj;

        headText.text = head;
        bodyText.text = body;

        updateTextPositions();

        var sizeStat = {
            width: Math.max((headText.x - x) + headText.width, (bodyText.x - x) + bodyText.width),
            height: Math.max((headText.y - y) + headText.height, (bodyText.y - y) + bodyText.height),
        }

        bgImageOutline.setGraphicSize(Std.int(sizeStat.width+(borderSize)+(padding)), Std.int(sizeStat.height+(borderSize)+(padding)));
        bgImageOutline.color = colors.outline;

        bgImage.setGraphicSize(Std.int(sizeStat.width-(borderSize)+(padding)), Std.int(sizeStat.height-(borderSize)+(padding)));
        bgImage.color = colors.bg;
    }
    
    public function hide() {
        isVisible = false;
    }
    function updateTextPositions(){
        headText.x = bodyText.x = x + padding;

        headText.y = y + padding;
        bodyText.y = y + padding;
        if (headText.text != "") bodyText.y += headText.height + 5;
    }

    public function changeColor(bg:FlxColor, outline:FlxColor){
        colors.bg = bg;
        colors.outline = outline;
    }

    function set_padding(value:Int):Int {
        paddingUpdate = true;
        show(curTracked, headText.text, bodyText.text);
        return value;
    }

    override function update(elapsed:Float) {
        updateTextPositions();
        bgImage.updateHitbox();
        bgImageOutline.updateHitbox();
        bgImage.setPosition(x + borderSize, y + borderSize);
        bgImageOutline.setPosition(x,y);

        var intendStuff:Float = (isVisible ? 1 : 0);
        alpha = FlxMath.lerp(intendStuff,alpha, 1-(elapsed*20));
        super.update(elapsed);
    }
}