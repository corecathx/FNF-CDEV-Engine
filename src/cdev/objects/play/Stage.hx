package cdev.objects.play;

import cdev.backend.modding.scripting.Script;
import cdev.backend.modding.scripting.HScript;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class StageSprite extends Sprite {
    public var name:String = "";
}

/**
 * Used to handle in-game stages.
 */
class Stage extends FlxTypedSpriteGroup<Sprite> {
    /**
     * Spectator character, mainly used by Girlfriend.
     */
    public var spectator:Character;
    /**
     * Player character.
     */
    public var player:Character;
    /**
     * Opponent character.
     */
    public var opponent:Character;

    public var characters:Map<String, Character> = [];
    /**
     * Defines current PlayState this stage on.
     */
    public var parent:PlayState;

    public var script:HScript;
    /**
     * Create a new stage object.
     * @param parent PlayState
     * @param name Stage's name, will be used for scripting.
     * @param _player Character name used by player.
     * @param _opponent Character name used by opponent.
     * @param _spectator Character name used by spectator.
     */
    public function new(parent:PlayState, name:String = 'stage', _player:String = "bf", _opponent:String = "dad", _spectator:String = "gf") {
        super();
        this.parent = parent;
        
        var _usingSoftcode:Bool = false;
        // You could hardcode your own stage here!
        switch (name) {
            default:
                _usingSoftcode = true;
                script = Script.load('${Assets._STAGE_PATH}/$name');
                script.setScriptParent(this);
                
                script.call("create");
        
                initCharacters(_player, _opponent, _spectator);
        
                Conductor.instance.onBeatTick.add(onBeatHit);
                script.call("postCreate");
        }

        if (!_usingSoftcode) 
            initCharacters(_player, _opponent, _spectator);
    }

    function initCharacters(_player:String = "bf", _opponent:String = "dad", _spectator:String = "gf") {
        spectator = new Character(300,130,_spectator,false);
        group.add(spectator);

        player = new Character(670,100,_player,true);
        group.add(player);

        opponent = new Character(0,100,_opponent,false);
        group.add(opponent);
    }

    function createCharacter(xPos:Float, yPos:Float, name:String = "bf", player:Bool = false) {
        if (characters.exists(name)) {
            if (Preferences.verboseLog)
                Log.info("An existing character with "+name+" name already exists!");
            return null;
        }
        var char:Character = new Character(xPos, yPos, name, player);
        characters.set(name, char);
        return characters.get(name);
    }

    /**
     * Called on every frame.
     * @param elapsed Milliseconds passed since last frame.
     */
    override function update(elapsed:Float) {
        super.update(elapsed);
        script?.call("update", [elapsed]);
    }

    /**
     * Called when the stage is no longer being used.
     */
    override function destroy() {
        script?.call("onDestroy", []);
        script?.destroy();
        super.destroy();
    }

    /**
     * Called on every beat ticks.
     * @param beat Current Beat Count.
     */
    function onBeatHit(beat:Int) {
        script?.call("onBeatHit", [beat]);
        
        spectator?.dance();
        player?.dance();
        opponent?.dance();
        charactersDance();

        script?.call("onPostBeatHit", [beat]);
    }

    function charactersDance()  {
        for (i in characters.keys()) {
            characters.get(i)?.dance();
        }
    }
}