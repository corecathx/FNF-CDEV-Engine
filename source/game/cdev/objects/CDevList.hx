package game.cdev.objects;

import flixel.math.FlxRect;
import flixel.group.FlxSpriteGroup;

class CDevList extends FlxSpriteGroup {
    public var bgSprite:FlxSprite;
    public var bgLabel:FlxText;
    public var bgArrow:FlxSprite;

    var colors = {
        outline: 0xFF006EFF,
        bg: 0xFF121825
    }

    public var sizes = {
        width: 1,
        height: 1
    }

    public var buttons:Array<CDevListSprite> = [];

    public var list:Array<String> = [];

    public var callBack:String->Void = (str:String)->{};

    public var opened:Bool = false;
    public var curY:Float = 0;

    public function new(nX:Float, nY:Float, nWidth:Int, nHeight:Int, data:Array<String>, callBack:String->Void){
        super();
        list = data;
        sizes.width = nWidth;
        sizes.height = nHeight;
        this.callBack = callBack;
        x = nX;
        y = nY;
        changeColor(0xFF121825, 0xFF006EFF);
        init();
    }

    public function init(){
        bgSprite = new FlxSprite(0,0).makeGraphic(sizes.width,sizes.height,0xFFFFFFFF);
        bgSprite.color = colors.bg;
        add(bgSprite);

        bgLabel = new FlxText(0,0,sizes.width-30,"", 14);
        bgLabel.font = FunkinFonts.CONSOLAS;
        add(bgLabel);

        bgArrow = new FlxSprite(bgLabel.x + bgLabel.width + 10, 10).loadGraphic(Paths.image("ui/dropdown","shared"));
        bgArrow.scale.set(0.5,0.5);
        bgArrow.updateHitbox();
        add(bgArrow);

        var yAdd:Float = sizes.height;
        for (name in list) {
            var spr:CDevListSprite = new CDevListSprite(0,yAdd,sizes.width, sizes.height, name, callBack);
            spr.active = spr.visible = false;
            spr.parent = this;
            add(spr);

            buttons.push(spr);
            yAdd += sizes.height;
        }
        curY = y+sizes.height;
    }

    override function update(elapsed:Float) {
        bgLabel.setPosition(bgSprite.x + 10, bgSprite.y + (bgSprite.height-bgLabel.height)*0.5);

        bgArrow.alpha = bgSprite.alpha = 0.7;
        if (FlxG.mouse.overlaps(bgSprite)) {
            if (FlxG.mouse.justPressed) {
                opened = !opened;
                onListPressed(opened);
            } 
            if (!FlxG.mouse.pressed){
                bgArrow.alpha = bgSprite.alpha = 1;  
            }
        }

        if (opened) {
            var totalHeight = sizes.height * buttons.length;
            
            if (totalHeight > sizes.height) {
                if (FlxG.mouse.wheel != 0) {
                    var maxY = y + sizes.height - totalHeight;
                    curY += FlxG.mouse.wheel * (sizes.height * 0.5);
                    curY = Math.max(maxY, Math.min(y + sizes.height, curY));
                }
            } else {
                curY = y + sizes.height;
            }
        } else {
            curY = y + sizes.height;
        }
        

        for (index=>i in buttons) {
            i.y = FlxMath.lerp(curY+(sizes.height*index), i.y, 1-(elapsed*32));
            i.selected = bgLabel.text == i.label.text;

            var rect:FlxRect = i.clipRect != null ? i.clipRect : new FlxRect(0,0,sizes.width,sizes.height);

            if (i.y < y+sizes.height) {
                rect.y = (y+sizes.height - i.y);
                rect.height = (i.height) - rect.y;
            } else {
                rect.y = 0;
                rect.height = sizes.height;
            }

            i.clipRect = rect;
        }
        super.update(elapsed);
    }

    public function onListPressed(open:Bool) for (i in buttons) i.active = i.visible = open;

    public function changeColor(bg:FlxColor, outline:FlxColor){
        colors.bg = bg;
        colors.outline = outline;
    }
}

class CDevListSprite extends FlxSprite {
    public var parent:CDevList = null;
    public var selected:Bool = false;
    private var colors = {
        hover: 0xFF132853,
        idle: 0xFF121825
    };
    public var label:FlxText;
    public var callback:String->Void = (str:String)->{};
    public function new(nX:Float, nY:Float, nWidth:Int, nHeight:Int, text:String, callb:String->Void) {
        super(nX,nY);
        callback = callb;
        makeGraphic(nWidth, nHeight, FlxColor.WHITE);
        color = colors.hover;

        label = new FlxText(0,0,-1,text, 12);
        label.font = FunkinFonts.CONSOLAS;
        label.scrollFactor.set();
    }

    override function draw() {
        super.draw();
        label.clipRect = clipRect;
        label.setPosition(x + 15, y + (height-label.height)*0.5);
        label.draw();
    }

    override function update(elapsed:Float) {
        if (visible && active) {
            color = selected ? 0xFF162F64 : colors.idle;
            if (FlxG.mouse.overlaps(this)){
                if (FlxG.mouse.justPressed){
                    callback(label.text);
                    if (parent != null) parent.bgLabel.text = label.text;
                } 
                
                if (!FlxG.mouse.pressed) {
                    color = selected ? 0xFF184AAD : colors.hover;
                }
            }
        }
        super.update(elapsed);
    }
}