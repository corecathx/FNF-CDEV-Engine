package cdev.objects.play.notes;

class Splash extends Sprite {
    var _anims:Array<Array<String>> = [
        ["left", "purple"],
        ["down", "blue"],
        ["up", "green"],
        ["right", "red"]
    ];
    var scaleFactor:Float = Note.noteScale + 0.3;
    public function new() {
        super(x,y);
        frames = Assets.sparrowAtlas("notes/splash/NOTE_splash");

        // Loading the animations.
        for (repeat in 1...3) 
            for (anim in _anims){
                addAnim('${anim[0]+repeat}', 'note impact $repeat ${anim[1]}', 24, false);
            }
               
        scale.set(scaleFactor,scaleFactor);
        // Kill this sprite if it's done playing it's animation.
        animation.finishCallback = (name:String)->{
            kill();
        };
    }

    public function init(note:Note) {
        playAnim(_anims[note.data][0]+(FlxG.random.int(1,2)), true);
        animation.timeScale = FlxG.random.float(0.8, 1.2);
        updateHitbox();

        alpha = 0.7;
        offset.set((width * 0.3) / scaleFactor, (height * 0.3) / scaleFactor);
    }
}