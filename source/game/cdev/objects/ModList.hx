package game.cdev.objects;

import flixel.math.FlxRect;
import meta.modding.ModIcon;
import game.cdev.CDevMods.ModFile;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;

class ModList extends FlxSpriteGroup {
    private var bg:FlxSprite;
    private var list_group:FlxSpriteGroup;
    private var list_group_raw:Array<ModListItem> = [];
    private var nWidth:Int = 0;
    private var nHeight:Int = 0;
    public function new(nX:Float, nY:Float, nWidth:Int, nHeight:Int, nPadding:Int = 10, files:Array<ModFile>):Void {
        super(nX,nY);
        this.nWidth = nWidth;
        this.nHeight = nHeight;

        bg = new FlxSprite().makeGraphic(nWidth+nPadding,nHeight+nPadding, 0xFF000000);
        add(bg);

        list_group = new FlxSpriteGroup();
		add(list_group);

        for (index=>mod in files) {
            if (mod == null) continue;
            var item:ModListItem = new ModListItem(nPadding,90*index,nWidth,nHeight);
            item.load(mod,nPadding);
            list_group.add(item);

            list_group_raw.push(item);
        }
    }

    private var currentY:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);
        updateClip();
        
        if (FlxG.mouse.overlaps(this)){
            if (FlxG.mouse.wheel > 0 || FlxG.mouse.wheel < 0){
                currentY += FlxG.mouse.wheel * 50;
                //currentY = FlxMath.bound(currentY, 0, FlxMath.MAX_VALUE_INT); //dumass
            }
        }

        list_group.y = FlxMath.lerp(currentY,list_group.y,1-(elapsed*12));
        for (index=>spr in list_group_raw){
            //spr.y = FlxMath.lerp(currentY+(90*index),spr.y,1-(elapsed*12));
            if (FlxG.mouse.overlaps(spr)){
                spr.alpha = 1;
            } else {
                spr.alpha = 0.6;
            }
        }
        
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

    public var bg:FlxSprite;
    public var icon:ModIcon;
    public var label:FlxText;
    public function load(file:ModFile, ?padding:Int = 10){
        bg = new FlxSprite().makeGraphic(pWidth-padding*2, 80,0xFF2E2E2E);
        add(bg);

        Paths.currentMod = file.modName;
        icon = new ModIcon(20,0, file.modName);
        icon.y = ((height-icon.height)*0.5);
        add(icon);

        label = new FlxText(icon.x+icon.width+20,0,-1, file.modName);
        label.setFormat(FunkinFonts.VCR, 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        label.borderSize = label.borderQuality = 4;   
        label.y = (bg.height - label.height)*0.5;
        add(label);
    }
}