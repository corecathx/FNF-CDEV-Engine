package meta.modding.song_editor;

import flixel.FlxSprite;
import meta.states.MusicBeatState;

class SongEditor extends MusicBeatState {
    var menuBG:FlxSprite;
    public function new(){
        super();

        menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		menuBG.color = 0xff0088ff;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.5;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);
    }

    override function update(elapsed:Float){
        super.update(elapsed);
    }
}