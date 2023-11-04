package meta.states;

import game.Paths;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import game.cdev.CDevConfig;
import flixel.text.FlxText;
import flixel.FlxG;
class OutdatedState extends MusicBeatState{
    var selectionText:FlxText;
    //i wanted to make a in game download for the updates so the player
    //shouldn't have to download the engine from gamebanana
    override function create(){
        var bg:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('menuDesat', 'preload'));
        bg.scale.set(1.2,1.2);
        bg.alpha = 0.2;
        add(bg);

        var textShit:String = ''
        + 'Hey! You\'re using the old version of CDEV Engine!\n'
        + 'Your current version are ${CDevConfig.engineVersion}\n'
        + 'While the new version of CDEV Engine are ${TitleState.onlineVer}!\n'
        + '\nWould you like to update CDEV Engine to the new version?';

        var daText:FlxText = new FlxText(0,180, FlxG.width, textShit,30);
        daText.setFormat('VCR OSD Mono', 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        daText.screenCenter(X);
        add(daText);

        var eeee:String = ''
        + '[Z] - Yes\n'
        + '[X] - No\n'
        + '[C] - No, and do not show this again';
        selectionText = new FlxText(0,0,FlxG.width,eeee,18);
        selectionText.setFormat('VCR OSD Mono', 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        selectionText.screenCenter(X);
        selectionText.y = daText.y + daText.height + 100;
        add(selectionText);

        super.create();
    }

    override function update(elapsed:Float){
        if (FlxG.keys.justPressed.Z){
            FlxG.sound.play(Paths.sound('confirmMenu'));
            FlxG.sound.music.fadeOut(0.3, 0);
            //CDevConfig.utils.openURL('https://gamebanana.com/mods/346832');
            //FlxG.switchState(new MainMenuState());
            FlxG.switchState(new UpdateState());
        }
        if (FlxG.keys.justPressed.X){
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(new MainMenuState());
        }
        if (FlxG.keys.justPressed.C){
            CDevConfig.saveData.checkNewVersion = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.switchState(new MainMenuState());
        }
    }
}