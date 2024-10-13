package cdev.objects.menus;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;

class Alphabet extends FlxTypedSpriteGroup<AlphabetCharacter> {
    public var distance:FlxPoint = FlxPoint.get(20, 140);
    public var spacing:FlxPoint = FlxPoint.get(28, 60);

    public var bold(default, set):Bool;
    public var text(default,set):String = "";
    public function new(nX:Float, nY:Float, text:String, bold:Bool) {
        super(nX,nY);
        this.text = text;
        this.bold = bold;
    }

    function set_text(val:String):String {
        if (val == null) 
            val = "null";

        group.killMembers();

        if (val.length == 0)
            return text = val;

        var xPos:Float = 0;
        var yPos:Float = 0;

        for (character in val.split("")) {
            switch (character) {
                case '\n':
                    xPos = 0;
                    yPos += spacing.y * scale.y;
                case ' ':
                    xPos += spacing.x * scale.x;
                default:
                    var char:AlphabetCharacter = recycle(AlphabetCharacter);
                    char.setPosition(xPos, yPos);
                    char.setChar(character, bold);

                    char.scale.set(scale.x, scale.y);
                    char.updateHitbox();
        
                    xPos += char.width + 3;
                    add(char);
            }
        }

        return text = val;
    }

    function set_bold(val:Bool):Bool {
        if (members != null && bold != val && members.length > 0) {
            bold = val;
            text = text;
        }
        return val;
    }
}

class AlphabetCharacter extends Sprite {
    public var char:String = "";
    private var cachedSprite:Map<String, FlxAtlasFrames> = [];
    
    public function new(nX:Float, nY:Float) {
        super(nX, nY);
        cachedSprite["bold"] = Assets.sparrowAtlas("menus/text/bold");
        cachedSprite["default"] = Assets.sparrowAtlas("menus/text/default");
    }

    public function setBold(bold:Bool) {
        setChar(char, bold);
    }

    public function setChar(character:String, bold:Bool) {
        char = character;
        frames = cachedSprite[bold?"bold":"default"];
        var isAlphabet:Bool = "abcdefghijklmnopqrstuvwxyz".contains(char);
        var isNumber:Bool = "1234567890".contains(char);
        var isSymbol:Bool = "|~#$%()*+-:;<=>@[]^_.,'!?".contains(char);

        var anim:String = bold ? char.toUpperCase() : char;
        if (!animation.exists(anim)) 
            animation.addByPrefix(anim, anim, 24);
        animation.play(anim, true);
    }
}
