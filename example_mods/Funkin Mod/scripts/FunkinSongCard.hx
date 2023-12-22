if (PlayState.SONG.song == "game-test"){
    trace("yes");
    var bg:FlxSprite;
    var bgBlue:FlxSprite;
    var textTitle:FlxText;
    var textComposer:FlxText;
    function postCreate(){
        bg = new FlxSprite(0,100).makeGraphic(380, 65, FlxColor.BLACK);
        bg.alpha = 0.7;
        bg.cameras = [PlayState.camHUD];
        add(bg);

        bgBlue = new FlxSprite(bg.x + bg.width-20,bg.y).makeGraphic(20, bg.height, FlxColor.BLUE);
        bgBlue.alpha = 0.7;
        bgBlue.cameras = [PlayState.camHUD];
        add(bgBlue);
    
        var col = PlayState.dad.healthBarColors;
        textTitle = new FlxText(bg.x + 10, bg.y + 10, -1, PlayState.SONG.song, 30);
        textTitle.setFormat("VCR OSD Mono", 22, FlxColor.CYAN, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
        add(textTitle);
        textTitle.cameras = [PlayState.camHUD];
    
        textComposer = new FlxText(textTitle.x, textTitle.y + textTitle.height, -1, "Composer: Core5570R / CoreDev", 30);
        textComposer.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE(), FlxColor.BLACK);
        add(textComposer);
        textComposer.cameras = [PlayState.camHUD];

        for (i in [bg, bgBlue, textTitle, textComposer]){
            i.x -= 400;
        }
    }

    function onStartSong(){
        for (i in [bg, bgBlue, textTitle, textComposer]){
            FlxTween.tween(i, {x: i.x + 400}, 0.5, {ease:FlxEase.circInOut});
            new FlxTimer().start((Conductor.crochet*4)/1000, function(f){
                FlxTween.tween(i, {x: i.x - 400}, 0.5, {ease:FlxEase.circInOut, onComplete:function(e){
                    i.destroy();
                    remove(i);
                }});
            });
        }
    }
} else{
    trace("it's not");
}

