package game.cdev.objects;

import flixel.addons.ui.FlxUIGroup;
import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.group.FlxSpriteGroup;

class CDevChartUI extends FlxSpriteGroup {
    var extendable_bg:FlxUI9SliceSprite;
    var main_button_spr:FlxSprite;

    var button_burg:FlxSprite;

    var isOpen:Bool = false;

    var intended_size:Float = 0;
    var intended_height:Float = 0;
    var initial_size = 47;
    
    var icons:Array<FlxSprite> = [];

    var menuStuffs:Array<Dynamic> = [];
    
    var big_width = 360;
    var big_height = 480;
    var main_focus:Int = -1;

    var ui_group:FlxSpriteGroup;
    var time:Float = 0;
    public function new(nX:Float, nY:Float, datas:Array<Dynamic>){
        super(nX, nY);
        menuStuffs = datas;
        var imageFile:Dynamic = Paths.image("ui/circle_menubg","shared");
        var iconGraphic:Dynamic = Paths.getSparrowAtlas("ui/icon_stuffs","shared");

        extendable_bg = new FlxUI9SliceSprite(0,0,imageFile,new openfl.geom.Rectangle(0,0,initial_size,initial_size), [20, 20, initial_size-20, initial_size-20]);
        extendable_bg.antialiasing = CDevConfig.saveData.antialiasing;
        add(extendable_bg);
        intended_size = initial_size;

        ui_group = new FlxSpriteGroup();
        add(ui_group);

        main_button_spr = new ChartUIMenu(imageFile, iconGraphic);
        main_button_spr.antialiasing = CDevConfig.saveData.antialiasing;
        add(main_button_spr);

        for (index => name in menuStuffs){
            var spr:FlxSprite = new FlxSprite();
            spr.frames = iconGraphic;
            spr.animation.addByPrefix(name[0], name[0], 24);
            spr.animation.play(name[0], true);
            spr.antialiasing = CDevConfig.saveData.antialiasing;
            spr.setPosition(0, (initial_size - spr.frameHeight) * 0.5);
            spr.active = false;
            add(spr);

            icons.push(spr);
        }
    }

    function updateClicks(obj:FlxSprite, curIndex:Int) {
        if (time < 0.7) return;
        if (FlxG.mouse.overlaps(obj) && FlxG.mouse.justPressed){
            if (main_focus != curIndex){
                main_focus = curIndex;
                menuStuffs[main_focus][2](ui_group);
                ui_group.antialiasing = false;
            } else {
                clear_uiGroup();
                main_focus = -1;
            }
            time = 0;
        }
    }

    function clear_uiGroup(){
        while (ui_group.members.length != 0){
            for (i in ui_group.members){
                //if (i != null) i.destroy();
                ui_group.members.remove(i);
            }
        }
    }

    public function getListStuff(){
        var makelist:Array<Dynamic> = [];
        for (i => l in menuStuffs){
            var nameCapitalized = CDevConfig.utils.capitalize(l[0]);
            makelist.push([icons[i], nameCapitalized, l[1]]);
        }
        return makelist;
    }

    override function update(elapsed:Float) {
        if (time < 10)
            time+=elapsed;
        main_button_spr.color = FlxG.mouse.overlaps(main_button_spr) ? 0xFFFFFFFF : 0xFFA0A0A0;
        if (FlxG.mouse.overlaps(main_button_spr) && FlxG.mouse.justPressed){
            isOpen = !isOpen;
            main_focus = -1;
            clear_uiGroup();
        }

        intended_size = (isOpen ? big_width : initial_size);
        intended_height = (main_focus != -1 ? big_height : initial_size);

        extendable_bg.resize(Std.int(FlxMath.lerp(intended_size, extendable_bg.width, 1-(elapsed*16))),Std.int(FlxMath.lerp(intended_height, extendable_bg.height, 1-(elapsed*16))));
        extendable_bg.x = main_button_spr.x - (extendable_bg.width - initial_size);
        extendable_bg.y = main_button_spr.y - (extendable_bg.height - initial_size);

        ui_group.x = extendable_bg.x + (initial_size/2);
        ui_group.y = extendable_bg.y + (initial_size/2);

        var loop:Int = 0;
        for (spr in icons){
            var percentage:Float = ((extendable_bg.width - initial_size) / (big_width - initial_size));
            var additionSize:Float = (((big_width-initial_size)/(menuStuffs.length+1)) * loop);
            
            spr.x = (main_button_spr.x) - ((additionSize+(initial_size*1.5))*percentage);

            if (main_focus == -1)
                spr.alpha = FlxMath.bound(percentage, 0, 1);
            else
                spr.alpha = FlxMath.lerp((main_focus == loop) ? 1 : 0, spr.alpha, 1-(elapsed*20));

            if (main_focus == -1){
                updateClicks(spr,loop);
            } else{
                if (main_focus == loop)
                    updateClicks(spr,loop);
            }
            loop++;
        }
        super.update(elapsed);
    }

    override function destroy() {
        if (extendable_bg != null) extendable_bg.destroy();
        if (main_button_spr != null) main_button_spr.destroy();
        super.destroy();
    }
}

class ChartUIMenu extends FlxSprite { 
    var burg_icon:FlxSprite;
    public function new(graphicFile:Dynamic, iconsGraphic:Dynamic){
        super();
        loadGraphic(graphicFile);

        burg_icon = new FlxSprite();
        burg_icon.frames = iconsGraphic;
        burg_icon.animation.addByPrefix("burg", "burg", 24);
        burg_icon.animation.play("burg", true);
        burg_icon.antialiasing = CDevConfig.saveData.antialiasing;
        burg_icon.scrollFactor.set();
    }

    override function draw() {
        super.draw();
        CDevConfig.utils.moveToCenterOfSprite(burg_icon, this);
        burg_icon.color = this.color;
        burg_icon.draw();
    }

    override function destroy() {
        if (burg_icon != null) burg_icon.destroy();
        super.destroy();
    }
}