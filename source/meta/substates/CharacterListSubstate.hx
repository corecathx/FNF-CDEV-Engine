package meta.substates;

import flixel.group.FlxSpriteGroup;
import meta.modding.char_editor.CharacterData.CharData;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import game.objects.HealthIcon;

using StringTools;

class CharacterListSubstate extends MusicBeatSubstate {
    public static var remember_y:Float = 0;
    var bg:FlxSprite;
    var butt_group:FlxSpriteGroup;
    var buttList:Array<CharacterListSprite> = [];

    var parent_state:Dynamic = null;
    var field_to_find:String = "";
    public function new(parentState:Dynamic,field:String){
        super();
        parent_state = parentState;
        field_to_find = field;

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
        bg.alpha = 0.2;
        bg.scrollFactor.set();
        add(bg);

        var directories = [Paths.getPreloadPath('data/characters/'),Paths.mods('${Paths.currentMod}/data/characters/')];
        var characterList:Array<String> = [];
        for (curDirectory in directories)
        {
            if (FileSystem.exists(curDirectory))
            {
                for (file in FileSystem.readDirectory(curDirectory))
                {
                    var path = haxe.io.Path.join([curDirectory, file]);
                    if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
                    {
                        var charToCheck:String = file.substr(0, file.length - 5);
                        characterList.push(charToCheck);
                    }
                }
            }
        }

        butt_group = new FlxSpriteGroup((FlxG.width/2)-((FlxG.width/2)/2),remember_y);
        butt_group.scrollFactor.set();
        add(butt_group);

        for (index => name in characterList) {
            var n = new CharacterListSprite(0, 20 + (120 * index), name);
            n.scrollFactor.set();
            butt_group.add(n);
            buttList.push(n);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.mouse.wheel > 0 || FlxG.mouse.wheel < 0){
            remember_y += FlxG.mouse.wheel * 50;
        }
        butt_group.y = FlxMath.lerp(remember_y,butt_group.y,1-(elapsed*12));
        for (obj in buttList){
            obj.alpha = 0.4;
            if (FlxG.mouse.overlaps(obj)){
                obj.alpha = 0.8;
                if (FlxG.mouse.justPressed){
                    try {
                        Reflect.setProperty(parent_state,field_to_find,obj.label.text);
                        trace("Got data: " + Reflect.getProperty(parent_state,field_to_find));
                        FlxG.sound.play(Paths.sound("confirmMenu"), 0.5);
                        close();
                    } catch (e){
                        close();
                        Log.error("Failed to set field from state, " + e.toString());
                    }
                }
            }
        }
        
        if (controls.BACK){
            close();
        }
    }

    override function destroy() {
        for (i in buttList){
            i.destroy();
        }
        super.destroy();
    }
}

class CharacterListSprite extends FlxSprite {
    public var label:FlxText;
    var icon:HealthIcon;
    public function new(nX:Float, nY:Float, name:String){
        super(nX,nY);
        makeGraphic(Std.int(FlxG.width*0.5), 100, 0xFF000000);
        alpha = 0.8;

        label = new FlxText(0,0,-1,name,32);
        label.setFormat(FunkinFonts.VCR, 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        label.scrollFactor.set();

        icon = new HealthIcon(getIconFromCharJSON(name));
        icon.setGraphicSize(80,80);
        icon.scrollFactor.set();
    }

    override function destroy() {
        label.destroy();
        icon.destroy();
        super.destroy();
    }

    override function draw() {
        super.draw();
        icon.x = x + 10;
        icon.y = y - 20;
        
        label.x = icon.x+icon.width + 20;
        label.y = y + (height-label.height)*0.5;

        icon.alpha = label.alpha = alpha + 0.2;
        icon.draw();
        label.draw();
    }

    function getIconFromCharJSON(char:String):String
    {
        var charPath:String = 'data/characters/' + char + '.json';
        var daRawJSON = null;
        #if ALLOW_MODS
        var path:String = Paths.modChar(char);
        if (!FileSystem.exists(path))
            path = Paths.char(char);

        if (!FileSystem.exists(path))
        #else
        var path:String = Paths.getPreloadPath(charPath);
        if (!Assets.exists(path))
        #end
        {
            path = Paths.char('bf');
        }

        if (FileSystem.exists(path))
        {
            #if ALLOW_MODS
            daRawJSON = File.getContent(path);
            #else
            daRawJSON = Assets.getText(path);
            #end
        }
        if (daRawJSON != null)
        {
            var parsedJSON:CharData = cast Json.parse(daRawJSON);
            return parsedJSON.iconName;
        }

        return 'face';
    }
}