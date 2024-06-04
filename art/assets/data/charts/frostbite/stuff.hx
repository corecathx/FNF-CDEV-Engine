var aberrationShader:GraphicsShader;
var abbCur:Float = 0.001;
var abbTarget:Float = 0.001;

var assSnow:GraphicsShader;
var whiteBlock:FlxSprite = new FlxSprite(-5000,-5000).makeGraphic(FlxG.width*10, FlxG.height*10, 0xFFFFFFFF);
function postCreate(){
    importScript("FunkinHX");
    FunkinHX.makeSprite("icon", 700,400, "icons/gold-icon");

    PlayState.dad.scrollFactor.set(0.9,0.9);
    PlayState.camHUD.alpha = 0;

    if (CDevConfig.saveData.shaders){
        aberrationShader = new FlxRuntimeShader(Paths.frag("aberration"), "");
        //assSnow = new FlxRuntimeShader(Paths.frag("snowfall"), "");
        FlxG.camera.setFilters([new ShaderFilter(aberrationShader)]);
    }

    add(whiteBlock);

    PlayState.camPosForced = [PlayState.boyfriend.x + 700, PlayState.boyfriend.y+50];
    PlayState.defaultCamZoom -= 0.2;
    FlxG.camera.zoom = PlayState.defaultCamZoom;
    PlayState.forceCameraPos = true;
}

function onStartSong(){
    FlxTween.tween(whiteBlock, {alpha: 0}, 5);
}

function onEvent(e, v1,v2){
    if (e == "shaderRise"){
        var parsed = (v1 != "" ? Std.parseFloat(v1) : 1);
        var time = (Conductor.crochet/1000)*Std.parseFloat(v1);
        FlxTween.num(0, 0.3, time,{ease:FlxEase.sineIn}, function(num){
            abbTarget = num;
            if (num == 0.3){
                abbTarget = 0.001;
            }
        });
    }
}
var t:Float = 0;
function update(e){
    t = Conductor.songPosition;
    if (assSnow != null){
        assSnow.setFloat("time", (t/1000)/2);
        assSnow.setFloat("intensity", 0.2);
        assSnow.setInt("amount", 10);
        //aberrationShader.data.effectTime.value = [abbCur];
    }
    if (FlxG.keys.pressed.V){
        t += e;
    }
    if (FlxG.keys.pressed.B){
        t -= e;
    }

    if (FlxG.keys.pressed.Z) FlxG.camera.angle -= 1;
    if (FlxG.keys.pressed.X) FlxG.camera.angle += 1;

    if (FlxG.keys.pressed.Q) PlayState.camHUD.angle -= 1;
    if (FlxG.keys.pressed.W) PlayState.camHUD.angle += 1;

    if (aberrationShader != null)
    {
        abbCur = FlxMath.lerp(abbCur, abbTarget, (e / (1 / 120)) * 0.06);
        aberrationShader.setFloat("aberration", abbCur);
        aberrationShader.setFloat("effectTime", abbCur);
    }
}

function beatHit(b){
    if (b == 16) FlxTween.tween(PlayState.camHUD, {alpha: 1}, 1);
}