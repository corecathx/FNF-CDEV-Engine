package cdev.substates;

import cdev.objects.play.Character;

class GameOverSubState extends SubState {
    /**
     * Animation name that'll be called when the player just died.
     */
    public static var DEATH_ANIM_START:String = "firstDeath";
    /**
     * Animation name that'll be called after the player died.
     */
    public static var DEATH_ANIM_LOOP:String = "deathLoop";
    /**
     * Animation name that'll be called when the player restarts.
     */
    public static var DEATH_LOOP_END:String = "deathConfirm";
    /**
     * Audio file name that'll be used as the death background music.
     */
    public static var DEATH_BGM:String = "gameOver";
    /**
     * Audio file name that'll be used when the player restarts.
     */
    public static var DEATH_BGM_END:String = "gameOverEnd";
    /**
     * Defines wait time for the camera before panning to the player.
     */
    public static var CAMERA_WAIT_TIME:Float = 0.5;

    var parent:PlayState;
    var char:Character;
    var canConfirm:Bool = false;
    var camFollow:FlxObject;
    public function new(parent:PlayState, player:Character) {
        super();
        this.parent = parent;

        char = new Character(player.x, player.y, player.name, true, true);
        char.playAnim(DEATH_ANIM_START, true);
        char.animation.finishCallback = (name:String) -> {
            if (name == DEATH_ANIM_START) {
                char.playAnim(DEATH_ANIM_LOOP, true);
                FlxG.sound.playMusic(Assets.music("gameOver"));
                canConfirm = true;
            }
        }
        char.y = player.y;
        add(char);

        var _playerCenter:FlxPoint = char.getGraphicMidpoint();
        camFollow = new FlxObject(_playerCenter.x, _playerCenter.y, 1, 1);
        add(camFollow);

        FlxG.camera.target = null;
        FlxG.sound.play(Assets.sound("play/fnf_loss_sfx"));
    }

    var wait:Float = 0;
    var called:Bool = false;
    var endCalled:Bool = false;
    override function update(elapsed:Float) {
        super.update(elapsed);
        wait += elapsed;
        if (wait > CAMERA_WAIT_TIME && !called) {
            called = true;
            FlxG.camera.follow(camFollow, LOCKON, 6*elapsed);
        }

        if (Controls.ACCEPT) {
            if (!endCalled) {
                endCalled = true;
                char.playAnim("deathConfirm", true);
                FlxG.sound.music.stop();
                FlxG.sound.music.destroy();
                FlxG.sound.play(Assets.music(DEATH_BGM_END));
                FlxTimer.wait(0.7, () -> {
                    FlxG.camera.fade(FlxColor.BLACK, 2, false, () -> {
                        FlxG.switchState(new PlayState(parent?.currentSong));
                    });
                });
            } else {
                FlxG.camera.visible = false;
                FlxG.switchState(new PlayState(parent?.currentSong));
            }
        }
    }
}