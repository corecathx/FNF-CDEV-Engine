package meta.substates;

import game.system.FunkinThread;
import game.ImageUtils;
import openfl.geom.Point;
import openfl.display.BitmapData;
import game.ImageUtils.BitmapDrawThing;
import game.Stage.StageJSONData;
import game.CoolUtil;
import flixel.group.FlxSpriteGroup;
import meta.modding.char_editor.CharacterData.CharData;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import game.objects.HealthIcon;

using StringTools;

class StageListSubstate extends MusicBeatSubstate {
    public static var remember_y:Float = 0;
    var bg:FlxSprite;
    var butt_group:FlxSpriteGroup;
    var buttList:Array<StageListSprite> = [];

    var parent_state:Dynamic = null;
    var field_to_find:String = "";

    var allLoaded:Bool = false;
    public function new(parentState:Dynamic,field:String){
        super();
        parent_state = parentState;
        field_to_find = field;

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
        bg.alpha = 0.2;
        bg.scrollFactor.set();
        add(bg);

        butt_group = new FlxSpriteGroup((FlxG.width/2)-((FlxG.width/2)/2),remember_y);
        butt_group.scrollFactor.set();
        add(butt_group);

        var loadLabel:FlxText = new FlxText(0,0,-1,"Loading...",32);
        loadLabel.setFormat(FunkinFonts.VCR, 48, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        loadLabel.borderSize = 5;
        loadLabel.borderQuality = 5;
        loadLabel.scrollFactor.set();
        loadLabel.screenCenter();
        add(loadLabel);

        FunkinThread.doTask([
            ()->{
                var directories = [Paths.getPreloadPath('data/stages/'),Paths.mods('${Paths.currentMod}/data/stages/')];
                var stageList:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
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
                                stageList.push(charToCheck);
                            }
                        }
                    }
                }
        
                for (index => name in stageList) {
                    var n = new StageListSprite(0, 20 + (120 * index), name);
                    n.scrollFactor.set();
                    n.active = false;
                    buttList.push(n);
                }
            }
        ],(_)->{},()->{
            for (n in buttList){
                butt_group.add(n);
            }
            loadLabel.destroy();
            remove(loadLabel);
            allLoaded = true;
        }, (error:String)->{
            close();
        });

    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!allLoaded) return;
        if (FlxG.mouse.wheel > 0 || FlxG.mouse.wheel < 0){
            remember_y += FlxG.mouse.wheel * 50;
        }
        butt_group.y = FlxMath.lerp(remember_y,butt_group.y,1-(elapsed*12));
        for (obj in buttList){
            obj.alpha = 0.6;
            if (FlxG.mouse.overlaps(obj)){
                obj.alpha = 1;
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

class StageListSprite extends FlxSprite {
    public var label:FlxText;
    var supposedSizeWidth:Int = Std.int(FlxG.width*0.5);
    var supposedSizeHeight:Int = 100;
    public function new(nX:Float, nY:Float, name:String){
        super(nX,nY);
        label = new FlxText(0,0,-1,name,32);
        label.setFormat(FunkinFonts.VCR, 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        label.scrollFactor.set();
        generatePreview();
    }

    override function destroy() {
        label.destroy();
        super.destroy();
    }

    override function draw() {
        super.draw();    
        label.x = x + 20;
        label.y = y + (height-label.height)*0.5;
        label.draw();
    }

    function generatePreview(){
        var currentMod:String = "./"+Paths.mods('${Paths.currentMod}/');
        var path:String = currentMod +'data/stages/' + label.text + ".json";
        var crapJSON = null;

        var charFile:String = path;
        if (FileSystem.exists(charFile))
            crapJSON = File.getContent(charFile);

        var json:StageJSONData;
        if (crapJSON != null)
        {
            json = cast Json.parse(crapJSON);

            var bitArray:Array<BitmapDrawThing> = [];
            for (sprite in json.sprites){
                trace(currentMod + "images/" + sprite.imagePath + ".png");
                bitArray.push({
                    data: BitmapData.fromFile(currentMod + "images/" + sprite.imagePath + ".png"),
                    position: new Point(sprite.position[0], sprite.position[1])
                });
            }
            var newBitmap:BitmapData = ImageUtils.drawBitmapArray(bitArray);
            newBitmap = ImageUtils.resizeBitmapData(newBitmap, 0.5, 0.5);
            newBitmap = ImageUtils.bitmapFillAndClip(newBitmap, supposedSizeWidth, supposedSizeHeight);

            loadGraphic(newBitmap);
        } else {
            makeGraphic(supposedSizeWidth, supposedSizeHeight, 0xFF000000);
        }
    }
}