function init() {
    runOnFreeplay = true;
}

function introStart() {
    var video:FlxVideo = new FlxVideo();
    video.play(Paths.video("game_cutscene"));
    video.onEndReached.add(function()
    {
        video.dispose();
        startSong();
        return;
    }, true);
}

function update(e) {
    /*if (FlxG.keys.justPressed.SPACE){
        startSong();
    }*/
}