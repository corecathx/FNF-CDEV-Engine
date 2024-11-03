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
        var charList:Array<String> = val.split("");

        if (charList.length > 0) {
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
                        char.scale.set(scale.x, scale.y);
                        char.updateProp(character, bold, this);
            
                        xPos += char.width + 3;
                        add(char);
                }
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
    public var parent:Alphabet;
    private var cachedSprite:Map<String, FlxAtlasFrames> = [];
    
    public function new(nX:Float, nY:Float) {
        super(nX, nY);
        frames = Assets.sparrowAtlas("menus/fonts/funkin");
        animation.addByPrefix("error", "_no_char");
    }

    public function updateProp(character:String, bold:Bool, parent:Alphabet){
        this.parent = parent;
        setChar(character == null ? char : character, bold);
    }

    public function setChar(character:String, bold:Bool) {
        char = character;
        var uppercases:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZBACKSPACE";
        var suffix:String = (bold ? " bold" : (uppercases.contains(char) ? " capital" : " lowercase"));
        
        var anim:String = '${char.toLowerCase()}$suffix';
        if (!animation.exists(anim)) 
            animation.addByPrefix(anim, anim, 24);
        animation.play(anim, true);
        if (animation.curAnim == null) 
            animation.play("error",true);
    }

    override function updateHitbox() {
        super.updateHitbox();
        if (parent == null) return;
        offset.y = -(parent.height - height);
    }

    public function parseChar(char:String):String {
        return switch (char) {
            case "'": "apostraphie";
            case ",": "comma";
            case "“": "start parentheses";
            case "”": "end parentheses";
            case "/": "forward slash";
            case "!": "exclamation point";
            case "?": "question mark";
            case ".": "period";

            case "←": "left arrow";
            case "↓": "down arrow";
            case "↑": "up arrow";
            case "→": "right arrow";
            case "¤": "angry faic";
            case "×": "multiply x";
            case "♥": "heart";
            default: char;
        }
    }    
}
