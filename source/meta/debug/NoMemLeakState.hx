package meta.debug;

import lime.utils.Preloader;

class NoMemLeakState extends MusicBeatState {
    var displayText:FlxText;
    var previewLogo:FlxSprite;
    override function create(){
        FlxG.sound.music.stop();
        previewLogo = new FlxSprite().loadGraphic(Paths.image("icon16", "shared"));
        previewLogo.setGraphicSize(Std.int(150));
        previewLogo.screenCenter();
        add(previewLogo);

        FlxG.stage.application.window.onDropFile.add(processDropFile);
        super.create();
    }
    var time:Float = 3;
    var time2:Float = 3;
    override function update(elapsed:Float){
        super.update(elapsed);
        previewLogo.angle += (30 * elapsed);

        if (FlxG.keys.justPressed.ESCAPE){
            FlxG.stage.application.window.onDropFile.remove(processDropFile);
            FlxG.switchState(new meta.states.MainMenuState());
        }
    }
    
    var redrawSprite:Bool = true;
    function processDropFile(data:String) 
    {
        if (redrawSprite){
            var width:Int = Std.int(FlxG.width);
			var height:Int = Std.int(FlxG.height);
			if(lastWaveformHeight != height && waveformSprite.pixels != null)
			{
				waveformSprite.pixels.dispose();
				waveformSprite.pixels.disposeImage();
				waveformSprite.makeGraphic(width, height, 0x00FFFFFF);
				lastWaveformHeight = height;
			}
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, width, height), 0x00FFFFFF);
        }
    }
}