function create(){
    PlayState.boyfriend.charCamPos = [230,-50];
    PlayState.dad.charCamPos[0] += 200;
    CDevConfig.offset = 0; // say goodbye to your offset
    trace("Loaded");
}

var text:FlxText;
var beat:Int = 0;

var missed:Bool = false;
function postCreate(){
    PlayState.defaultCamZoom -= 0.1;

    text = new FlxText(0,0,-1, "Hidden mode! Follow the opponent's movement!", 54);
    text.setFormat("wendy", 54, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
    //text.cameras = [PlayState.camHUD];
    text.scrollFactor.set();
    text.screenCenter();
    text.y += 250;
    add(text);
    text.borderSize = 4;
    text.visible = false;
    //PlayState.botplayTxt.text=" ";
}

function onNoteMiss(a){
    if (beat > 68 && beat < 100)
    {
        missed=true;
    }
}
function update(b){
    if (beat > 68 && beat < 100)
    {
        if (controls.LEFT_P || controls.DOWN_P){
            FlxG.sound.play(Paths.sound("kick"), 0.7);
            PlayState.boyfriend.playAnim((controls.LEFT_P ? "singLEFT" : "singDOWN"), true);
        }

        if (controls.UP_P || controls.RIGHT_P){
            FlxG.sound.play(Paths.sound("snare"), 0.7);
            PlayState.boyfriend.playAnim((controls.UP_P ? "singUP" : "singRIGHT"), true);
        }
    }
}
function beatHit(b){
    beat = b;
    if (b>4){
        if ((b+4)%20 == 19){
            PlayState.gf.playAnim("cheer", true);
            PlayState.gf.specialAnim = true;
        }
    }
    if (b == 68 || b == 100){
        PlayState.camHUD.visible = !PlayState.camHUD.visible;
        text.visible = !text.visible;
        if (PlayState.camHUD.visible){
            PlayState.defaultCamZoom -= 0.2;
        }else{
            PlayState.defaultCamZoom += 0.2;
        }
    }

    if (beat == 68){
        missed=false;
        text.text = "Hidden mode! Follow the opponent's movement!";
        text.screenCenter();
        text.y += 250;
    }
    if (beat == 84){
        missed=false;
        text.text = "Hidden mode! Follow the opponent's movement!";
        text.screenCenter();
        text.y += 250;
    }

    if (beat == 83){
        text.text = (missed?"Fail.":"Perfect!");
        text.screenCenter();
        text.y += 250;
    }
    if (beat == 99){
        text.text = (missed?"Fail.":"Perfect!");
        text.screenCenter();
        text.y += 250;
    }

    if (b >= 100 && b <= 164){
        FlxG.camera.zoom += 0.015;
        PlayState.camHUD.zoom += 0.03;
    }

    if (b == 172){
        FlxTween.tween(PlayState.dad,{alpha:0}, (Conductor.crochet)/1000, {ease:FlxEase.circInOut});
        FlxTween.tween(PlayState.dad.scale,{x:0,y:0}, (Conductor.crochet)/1000, {ease:FlxEase.circInOut});
        FlxG.sound.play(Paths.sound("gone.ogg"), 0.6);
    }
}