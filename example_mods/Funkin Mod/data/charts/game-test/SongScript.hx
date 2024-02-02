function create(){
    PlayState.boyfriend.charCamPos = [230,-50];
    PlayState.dad.charCamPos[0] += 200;
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
    text.y += 200;
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
        text.visible = !text.visible;
        if (b == 100){
            PlayState.camHUD.alpha = 1;
            PlayState.defaultCamZoom -= 0.2;
        }else{
            PlayState.camHUD.alpha = 0.7;
            PlayState.defaultCamZoom += 0.2;
        }
    }

    if (b == 98){
        var i = 0;
        for (s in PlayState.playerStrums.members){
            FlxTween.tween(s, {y:(CDevConfig.saveData.downscroll ? FlxG.height - 160 : 70), alpha:1}, 1,{startDelay:0.12*i, ease:FlxEase.backInOut});
            i++;
        }
    }

    if (beat == 68){
        missed=false;
        text.text = "Hidden mode! Follow the opponent's arrows!";
        text.screenCenter();
        text.y += 250;

        var i = 0;
        for (s in PlayState.playerStrums.members){
            FlxTween.tween(s, {y:(CDevConfig.saveData.downscroll ? FlxG.height+100 : -100), alpha:0.0001}, 1,{startDelay:0.12*i, ease:FlxEase.backInOut});
            i++;
        }
    }
    if (beat == 84){
        missed=false;
        text.text = "Hidden mode! Follow the opponent's arrows!";
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
        var i = 0;
        for (s in PlayState.p2Strums.members){
            FlxTween.tween(s, {y:(CDevConfig.saveData.downscroll ? FlxG.height+100 : -100), alpha:0.0001}, 1,{startDelay:0.12*i, ease:FlxEase.backInOut});
            i++;
        }
        FlxTween.tween(PlayState.dad,{alpha:0}, (Conductor.crochet)/1000, {ease:FlxEase.circInOut});
        FlxTween.tween(PlayState.dad.scale,{x:0,y:0}, (Conductor.crochet)/1000, {ease:FlxEase.circInOut});
        FlxG.sound.play(Paths.sound("gone.ogg"), 0.6);
    }
}