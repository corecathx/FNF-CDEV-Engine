package cdev.states.editors;

import cdev.objects.play.Stage;

class StageEditor extends State {
    var stage:Stage;
    override function create() {
        super.create();
        stage = new Stage(null,null,true);
        add(stage);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        var moveSpeed:Float = 300*elapsed;
        if (FlxG.keys.pressed.W) 
            FlxG.camera.scroll.y -= moveSpeed;
        if (FlxG.keys.pressed.A) 
            FlxG.camera.scroll.x -= moveSpeed;
        if (FlxG.keys.pressed.S) 
            FlxG.camera.scroll.y += moveSpeed;
        if (FlxG.keys.pressed.D) 
            FlxG.camera.scroll.x += moveSpeed;

        if (FlxG.keys.pressed.Q) 
            FlxG.camera.zoom -= 0.4*elapsed;
        if (FlxG.keys.pressed.E) 
            FlxG.camera.zoom += 0.4*elapsed;
    }
}