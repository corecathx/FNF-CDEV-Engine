package game;

import modding.CharacterData.AnimationArray;
import flixel.FlxG;
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

// still an w.i.p?????????
// will be finished soon.
typedef StageJSONData =
{
	var stageZoom:Float;
	var useCustomFollowLerp:Bool;
	var followLerp:Float;
	var boyfriendPosition:Array<Float>;
	var girlfriendPosition:Array<Float>;
	var opponentPosition:Array<Float>;

	var sprites:Array<StageSprite>;
}

typedef StageSprite = // basically contains informations about stage sprites
{
	// 1.1 only
	@:optional var animation:AnimationArray;
	@:optional var animType:String; // "beat-force" / "beat" / "normal"

	@:optional var position:Array<Float>;
	@:optional var imagePath:String;
	@:optional var imageScale:Float;
	@:optional var imageSF:Float;
	@:optional var imageAntialias:Bool;
	@:optional var imageAlpha:Float;
	@:optional var imageFlipX:Bool;
	var imageVar:String; // used string variables than using "id" numbers.
	var spriteType:String;
}

typedef BeatSprite =
{
	var anim:String;
	var sprite:FlxSprite;
}

typedef StageLayer =
{
	var sprite:SpriteStage;
	var bfFront:Bool;
	var gfFront:Bool;
	var dadFront:Bool;
}

class Stage
{
	var stage:String = "";
	var stageJSON:StageJSONData;

	public static var templateJSON:StageJSONData = {
		stageZoom: 0.8,
		useCustomFollowLerp: false,
		followLerp: 0.03,
		boyfriendPosition: [770, 100],
		girlfriendPosition: [400, 130],
		opponentPosition: [100, 100],
		sprites: [
			{
				spriteType: "gf",
				imageVar: "girlfriend",
			},
			{
				spriteType: "dad",
				imageVar: "opponent",
			},
			{
				spriteType: "bf",
				imageVar: "boyfriend",
			}
		]
	}

	public static var BFPOS:Array<Float> = [770, 100];
	public static var GFPOS:Array<Float> = [400, 130];
	public static var DADPOS:Array<Float> = [100, 100];

	public static var STAGEZOOM:Float = 1;
	public static var USECUSTOMFOLLOWLERP:Bool = false;
	public static var FOLLOW_LERP:Float = 0.03;

	public var bitmap_sprites:Array<SpriteStage> = [];
	public var normalAnim_sprites:Array<BeatSprite> = [];
	public var beatHit_sprites:Array<BeatSprite> = [];
	public var beatHit_force_sprites:Array<BeatSprite> = [];

	var play:PlayState;

	public function beatHit()
	{
		for (s in beatHit_sprites)
		{
			s.sprite.animation.play(s.anim);
		}
		for (s in beatHit_force_sprites)
		{
			s.sprite.animation.play(s.anim, true);
		}
	}
	var jsonWasNull:Bool = false;
	public function new(stage:String, pla:PlayState)
	{
		this.stage = stage;
		this.play = pla;
		BFPOS = [770, 100];
		GFPOS = [400, 130];
		DADPOS = [100, 100];

		STAGEZOOM = 0.8;
		USECUSTOMFOLLOWLERP = false;
		FOLLOW_LERP = 0.03;

		loadStageJSON();

		if (!jsonWasNull)
		{
			trace("it wasn't null");
			BFPOS = stageJSON.boyfriendPosition;
			GFPOS = stageJSON.girlfriendPosition;
			DADPOS = stageJSON.opponentPosition;

			STAGEZOOM = stageJSON.stageZoom;
			USECUSTOMFOLLOWLERP = stageJSON.useCustomFollowLerp;
			FOLLOW_LERP = stageJSON.followLerp;
		}
	}

	public function loadStageJSON()
	{
		if (stage != '')
		{
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
			}
			else
			{
				jsonWasNull = true;
			}
		}
	}

	public function createDaStage()
	{
		if (jsonWasNull)
		{
			trace("Unable to create the stage, can't find the JSON file");
			play.add(PlayState.gf);
			play.add(PlayState.dad);
			play.add(PlayState.boyfriend);
			return;
		}

		for (i in 0...stageJSON.sprites.length)
		{
			switch (stageJSON.sprites[i].spriteType)
			{
				case "bitmap":
					var daSprite:SpriteStage = new SpriteStage();
					daSprite.loadGraphic(Paths.image(stageJSON.sprites[i].imagePath), 'shared');
					daSprite.objectName = stageJSON.sprites[i].imageVar;
					daSprite.type = "bitmap";

					daSprite.scale.set(stageJSON.sprites[i].imageScale, stageJSON.sprites[i].imageScale);
					daSprite.antialiasing = stageJSON.sprites[i].imageAntialias;

					if (!CDevConfig.saveData.antialiasing)
						daSprite.antialiasing = false;

					daSprite.setPosition(stageJSON.sprites[i].position[0], stageJSON.sprites[i].position[1]);
					daSprite.scrollFactor.set(stageJSON.sprites[i].imageSF, stageJSON.sprites[i].imageSF);
					daSprite.alpha = stageJSON.sprites[i].imageAlpha;
					daSprite.ID = i;
					play.add(daSprite);
					bitmap_sprites.push(daSprite);
				case "sparrow":
					var daSprite:SpriteStage = new SpriteStage();
					daSprite.antialiasing = stageJSON.sprites[i].imageAntialias;

					if (!CDevConfig.saveData.antialiasing)
						daSprite.antialiasing = false;
					
					daSprite.objectName = stageJSON.sprites[i].imageVar;
					daSprite.type = "sparrow";
					daSprite.ID = i;
					daSprite.scrollFactor.set(stageJSON.sprites[i].imageSF, stageJSON.sprites[i].imageSF);
					daSprite.spritePath = stageJSON.sprites[i].imagePath;
					daSprite.setPosition(stageJSON.sprites[i].position[0], stageJSON.sprites[i].position[1]);

					var sparrowAtlas = Paths.getSparrowAtlas(stageJSON.sprites[i].imagePath, "shared");
					if (sparrowAtlas != null)
					{
						daSprite.frames = sparrowAtlas;

						if (stageJSON.sprites[i].animation != null)
						{
							var animName = "anim";
							var framerate = 24;
							var animType = "loop";
							if (stageJSON.sprites[i].animation.animPrefix != null)
								animName = stageJSON.sprites[i].animation.animPrefix;
							if (stageJSON.sprites[i].animation.fpsValue != null)
								framerate = stageJSON.sprites[i].animation.fpsValue;

							daSprite.animType = stageJSON.sprites[i].animType;
							daSprite.animation.addByPrefix(animName, animName, framerate, false);
							daSprite.animation.play(animName);
							daSprite.anim = stageJSON.sprites[i].animation;

							var beatSprite_anim:BeatSprite = {
								anim: animName,
								sprite: daSprite
							}
							trace(beatSprite_anim);
							trace(stageJSON.sprites[i].animType.toLowerCase());
							switch (stageJSON.sprites[i].animType.toLowerCase())
							{
								case "beat-force":
									beatHit_force_sprites.push(beatSprite_anim);
								case "beat":
									beatHit_sprites.push(beatSprite_anim);
								case "normal":
									normalAnim_sprites.push(beatSprite_anim);
							}
						}
					}
					play.add(daSprite);
				// checkSprites(stageJSON.sprites[i], i, daSprite);
				case "bf":
					play.add(PlayState.boyfriend);
				case "gf":
					play.add(PlayState.gf);
				case "dad":
					play.add(PlayState.dad);
			}
		}
	}

	var cool:Array<String> = ["bf", "gf", "dad"];

	public var sprites:Array<StageLayer> = [];

	public function checkSprites(jsonSprite:StageSprite, layer:Int, mainSprite:SpriteStage)
	{
		var bfLayer:Int = 0;
		var gfLayer:Int = 0;
		var dadLayer:Int = 0;

		// finding the position of characters in the json.
		var loop:Int = 0;
		for (s in stageJSON.sprites)
		{
			if (cool.contains(s.spriteType))
			{
				switch (s.spriteType)
				{
					case "bf":
						bfLayer = loop;
					case "gf":
						gfLayer = loop;
					case "dad":
						dadLayer = loop;
				}
			}
			loop++;
		}

		loop = 0;
		if (!cool.contains(jsonSprite.spriteType))
		{
			var a:StageLayer = {
				sprite: mainSprite,
				bfFront: (layer >= bfLayer),
				gfFront: (layer >= gfLayer),
				dadFront: (layer >= dadLayer)
			}
			sprites.push(a);
		}
	}

	public function destroy()
	{
		beatHit_sprites = [];
		beatHit_force_sprites = [];
	}
}

class SpriteStage extends FlxSprite
{
	public var objectName:String = "";
	public var animType:String = "";
	public var type:String = "bitmap"; // bitmap / sparrow / dad / bf / gf
	public var anim:AnimationArray = null;
	public var spritePath:String = "";
}
