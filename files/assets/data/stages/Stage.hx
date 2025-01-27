import cdev.backend.Conductor;
import flixel.FlxG;
import flixel.FlxCamera;
var conduct:Conductor = Conductor.instance;
function update(e) {
    FlxG.camera.y = 0 + Math.abs(Math.sin((conduct.time / conduct.beat_ms) * Math.PI)) * 10;
    FlxG.state.camHUD.scroll.y = 0 + Math.abs(Math.sin((conduct.time / conduct.beat_ms) * Math.PI)) * 20;
}