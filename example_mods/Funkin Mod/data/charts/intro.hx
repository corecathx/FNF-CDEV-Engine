function init() {
    runOnFreeplay = true;
}
var video:FlxVideo;
function introStart() {
    video = new FlxVideo();
    video.play(Paths.video("game_cutscene"));
    video.onEndReached.add(function()
    {
        video.dispose();
        startSong();
        return;
    }, true);
}

function update(e) {
    if (FlxG.keys.justPressed.SPACE){
        //startSong();
        video.stop();
        video.dispose();
        startSong();
    }
}