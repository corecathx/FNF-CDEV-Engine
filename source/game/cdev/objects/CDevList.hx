package game.cdev.objects;

import flixel.group.FlxSpriteGroup;

//wip
class CDevTooltip extends FlxSpriteGroup {
    var bgOutline:FlxSprite;
    var bgSprite:FlxSprite;

    var padding:Int = 10;
    var colors = {
        outline: 0xFF006EFF,
        bg: 0xFF121825
    }

    var sizes = {
        width: 1,
        height: 1
    }
    var borderSize:Float = 1;

    public var data(default, set):Array<Dynamic> = [
        //[spriteimage, Text]
    ];
    
    public var groupList:Array<Dynamic> = [
        //[bgDrop:FlxSprite, objects:FlxSprite, a:FlxText]
    ];

    public function new(nX:Float, nY:Float, nWidth:Int, nHeight:Int){
        super();
        sizes.width = nWidth;
        sizes.height = nHeight;
        x = nX;
        y = nY;
        changeColor(0xFF121825, 0xFF006EFF);
        init();
    }

    public function init(){
        bgOutline = new FlxSprite(x,y).makeGraphic(1,1,0xFFFFFFFF);
        bgOutline.setGraphicSize(Std.int((sizes.width+(borderSize)+(padding))), Std.int((sizes.height+(borderSize)+(padding))));
        bgOutline.color = colors.outline;
        add(bgOutline);

        bgSprite = new FlxSprite(padding,padding).makeGraphic(1,1,0xFFFFFFFF);
        bgSprite.setGraphicSize(Std.int((sizes.width-(borderSize)+(padding))), Std.int((sizes.height-(borderSize)+(padding))));
        bgSprite.color = colors.bg;
        add(bgSprite);
    }

    public function changeColor(bg:FlxColor, outline:FlxColor){
        colors.bg = bg;
        colors.outline = outline;
    }

    function set_data(value:Array<Dynamic>):Array<Dynamic> {
        updateObjects(value);
        
        return value;
    }

    function updateObjects(array:Array<Dynamic>){
        clearAll();
    }

    function addThis(a:Array<Dynamic>){
        for (i in a){
            
        }
    }

    function clearAll(){
        for (obj in groupList){
            if (members.contains(obj[0])) remove(obj[0]);
            if (members.contains(obj[1])) remove(obj[1]);
            if (members.contains(obj[2])) remove(obj[2]);
            groupList.remove(obj);
        }
    }
}