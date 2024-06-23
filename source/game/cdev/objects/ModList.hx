package game.cdev.objects;

import flixel.math.FlxRect;
import meta.modding.ModIcon;
import game.cdev.CDevMods.ModFile;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;

class ModList extends FlxSpriteGroup {
    private var cam:FlxCamera;
    private var bg:FlxSprite;
    private var list_group:FlxSpriteGroup;
    private var nPadding:Int = 0;

    public var nWidth:Int = 0;
    public var nHeight:Int = 0;
    public var nX:Float = 0;
    public var nY:Float = 0;
    public var item_list:Array<ModListItem> = [];
    public function new(nX:Float, nY:Float, nWidth:Int, nHeight:Int, nPadding:Int = 10, files:Array<ModFile>):Void {
        super(0,0);
        this.nWidth = nWidth;
        this.nHeight = nHeight;
        this.nPadding = nPadding;
        this.nX = nX;
        this.nY = nY;

        cam = new FlxCamera(nX,nY,nWidth,nHeight,1);
        cam.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(cam, false);

        this.cameras = [cam];

        bg = new FlxSprite().makeGraphic(nWidth+nPadding,nHeight+nPadding, 0xFF000000);
        bg.alpha = 0.7;
        add(bg);

        list_group = new FlxSpriteGroup();
		add(list_group);

        for (index=>mod in files) {
            if (mod == null) continue;
            var item:ModListItem = new ModListItem(nPadding,90*index,nWidth,nHeight);
            item.load(mod,nPadding);
            list_group.add(item);

            item_list.push(item);
        }
    }

    private var currentY:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);

        if (actualOverlap()){
            if (FlxG.mouse.wheel > 0 || FlxG.mouse.wheel < 0){
                currentY += FlxG.mouse.wheel * 50;
            }
        }

        list_group.y = FlxMath.lerp(currentY,list_group.y,1-(elapsed*12));
        for (index=>spr in item_list){
            //spr.y = FlxMath.lerp(currentY+(90*index),spr.y,1-(elapsed*12));
            spr.curOverlap = (actualOverlap() ? FlxG.mouse.overlaps(spr, cam) : false);
            if (spr.curOverlap){
                spr.alpha = 1;
            } else {
                spr.alpha = 0.6;
            }
        }
        
    }

    function actualOverlap():Bool {
        return (FlxG.mouse.x > nX
                && FlxG.mouse.x < nX + nWidth
                && FlxG.mouse.y > nY
                && FlxG.mouse.y < nY + nHeight);
    }

    function updateClip() {
        var tempClip = clipRect != null ? clipRect : new FlxRect(0,0,nWidth,nHeight);
        tempClip.x = tempClip.y = 0;
        tempClip.width = nWidth;
        tempClip.height = nHeight;

        clipRect = tempClip;
    }
}

class ModListItem extends FlxSpriteGroup {
    private var pWidth:Int = 0;
    private var pHeight:Int = 0;
    public function new(nX:Float, nY:Float, nWidth:Int, nHeight:Int):Void {
        super(nX,nY);
        pWidth = nWidth;
        pHeight = nHeight;
    }

    public var curOverlap:Bool = false;

    public var activeMod(default,set):Bool = false;
    function set_activeMod(val:Bool):Bool {
        if (bg != null)
            bg.color = (val ? 0xFF003C96 : 0xFF002763);
        return activeMod = val;
    }

    public var modFile:ModFile;
    public var bg:FlxSprite;
    public var icon:ModIcon;
    public var label:FlxText;
    public function load(file:ModFile, ?padding:Int = 10){
        modFile = file;
        bg = new FlxSprite().makeGraphic(pWidth-padding*2, 80,0xFF555555);
        add(bg);

        Paths.currentMod = file.modName;
        icon = new ModIcon(20,0, file.modName);
        icon.y = ((height-icon.height)*0.5);
        add(icon);

        label = new FlxText(icon.x+icon.width+20,0,pWidth-(((icon.x+icon.width+20)+(padding*2))), file.modName);
        label.setFormat(FunkinFonts.VCR, 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        label.borderQuality = label.borderSize = 2;   
        label.y = (bg.height - label.height)*0.5;
        add(label);
    }
}