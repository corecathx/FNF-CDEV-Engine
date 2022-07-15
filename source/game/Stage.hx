package game;
import states.PlayState;
import haxe.Json;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

//still an w.i.p?????????
//will be finished soon.
typedef StageJSONData =
{
    var stageZoom:Float;
    var pixelStage:Bool;
    var boyfriendPosition:Array<Float>;
    var girlfriendPosition:Array<Float>;
    var opponentPosition:Array<Float>;

    var sprites:Array<StageSprite>;
}

typedef StageSprite = //basically contains informations about stage sprites
{
    var position:Array<Float>;
    var imagePath:String;
    var imageScale:Float;
    var imageSF:Float;
    var imageAntialias:Bool;
    var imageAlpha:Float;
}

class Stage
{
    var stage:String = '';
    var stageJSON:StageJSONData;

    public static var BFPOS:Array<Float> = [770, 100];
    public static var GFPOS:Array<Float> = [400,130];
    public static var DADPOS:Array<Float> = [100, 100];

    public static var STAGEZOOM:Float = 1;
    public static var PIXELSTAGE:Bool = false;
    
	public function new(stage:String, group:FlxTypedGroup<FlxSprite>)
	{
        this.stage = stage;
        BFPOS = [770, 100];
        GFPOS = [400,130];
        DADPOS = [100, 100];

        STAGEZOOM = 0.7;
        PIXELSTAGE = false;
        
        createDaStage(group);

        if (!jsonWasNull){
            BFPOS = stageJSON.boyfriendPosition;
            GFPOS = stageJSON.girlfriendPosition;
            DADPOS = stageJSON.opponentPosition;

            STAGEZOOM = stageJSON.stageZoom;
            PIXELSTAGE = stageJSON.pixelStage;
        }
	}

    var jsonWasNull:Bool = false;

	function loadStageJSON()
	{
		if (stage != ''){
			var crapJSON = null;

			var charFile:String = Paths.modStage(stage);
			if (FileSystem.exists(charFile))
				crapJSON = File.getContent(charFile);

			var json:StageJSONData;
			if (crapJSON != null)
			{
				jsonWasNull = false;
				json = cast Json.parse(crapJSON);
				stageJSON = json;
			} else{
				jsonWasNull = true;
			}
		} else{
		}
	}

	function createDaStage(group:FlxTypedGroup<FlxSprite>)
	{
		loadStageJSON();
		if (!jsonWasNull)
		{
			for (i in 0...stageJSON.sprites.length)
			{
				var daSprite:FlxSprite = new FlxSprite();
				daSprite.loadGraphic(Paths.image(stageJSON.sprites[i].imagePath), 'shared');

				daSprite.scale.set(stageJSON.sprites[i].imageScale, stageJSON.sprites[i].imageScale);
				daSprite.antialiasing = stageJSON.sprites[i].imageAntialias;
				daSprite.setPosition(stageJSON.sprites[i].position[0], stageJSON.sprites[i].position[1]);
				daSprite.scrollFactor.set(stageJSON.sprites[i].imageSF, stageJSON.sprites[i].imageSF);
				daSprite.alpha = stageJSON.sprites[i].imageAlpha;
				daSprite.ID = i;
				group.add(daSprite);
			}
		}
		else
		{
			// do nothin'
		}
	}
}
