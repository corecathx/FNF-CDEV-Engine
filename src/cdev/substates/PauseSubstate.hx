package cdev.substates;

import cdev.states.MainMenuState;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import cdev.backend.Chart;
import cdev.states.PlayState;

/**
 * Pause screen on gameplay.
 */
class PauseSubState extends SubState {
    var allowControls:Bool = true;
    var pauseOptions(get,default):Array<{name:String, callback:Void->Void}>;
    function get_pauseOptions():Array<{name:String, callback:Void->Void}> {
        return [
            {
                name: "Resume", 
                callback: ()->{
                    allowControls = false;
    
                    FlxTween.tween(bg, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
                    for (index=>text in textGroup) {
                        FlxTween.tween(text, {alpha: 0, y: text.y - 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.1 + (0.2 * index), onComplete: (_)->{
                            text.destroy();
                        }});
                    }
                    for (item in grpOptions.members){
                        if (item.ID != currentSelection){
                            FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
                        } else{
                            FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3, onComplete:(_)->{
                                close();
                            }});
                        }
                    }
                }
            },
            {
                name: "Restart Song", 
                callback: ()->{
                    FlxG.resetState();
                }
            },
            {
                name: "Exit", 
                callback: ()->{
                    FlxG.switchState(new MainMenuState());
                }
            }
        ];
    }

    var bg:Sprite;

    var grpOptions:FlxTypedGroup<Alphabet>;
    var currentSelection(default,set):Int = 0;

    var textGroup:Array<Text> = [];
    var parent:PlayState;
    public function new(parent:PlayState) {
        super();
        this.parent = parent;
        bg = new Sprite().makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        bg.alpha = 0;
        bg.setScale(1/parent.camHUD.zoom);
        bg.angle = -parent.camHUD.angle;
        bg.scrollFactor.set();
        add(bg);
        FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

        grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

        for (index => option in pauseOptions) {
			var opt:Alphabet = new Alphabet(120, (FlxG.height * 0.48) + (120 * index), option.name, true);
			opt.menuItem = true;
			opt.target = index;
			opt.ID = index;
            opt.scrollFactor.set();
			grpOptions.add(opt);
		}

        /// Info texts that appears on top right of the game's window. ///
        var composer:String = Chart.getMeta(parent.chart, "Composer");
        var textList:Array<String> = ['
            ${parent.currentSong} // ${parent.currentDifficulty}', // Song Name + Difficulty
            '${composer == "" ? "" : "By " + composer}' // Composer name.
        ];
        for (index=>data in textList) {
            var _curText:String = data.trim();
            if (_curText == "") 
                continue;
            var text:Text = new Text(0, 15 + (32 * index), _curText, 32);
            text.x = FlxG.width - (text.width + 20);
            text.alpha = 0;
            text.scrollFactor.set();
            add(text);
            textGroup.push(text);
            
            FlxTween.tween(text, {alpha: 1, y: text.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3 + (0.2 * index)});
        }

        cameras = [parent.camHUD];
    }

    override function destroy() {
        grpOptions?.destroy();
        bg?.destroy();
        for (text in textGroup) {
            text?.destroy();
        }
        super.destroy();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!allowControls) 
            return;
        if (Controls.UI_UP_P) currentSelection -= 1;
        if (Controls.UI_DOWN_P) currentSelection += 1;
        if (Controls.ACCEPT) {
			pauseOptions[currentSelection].callback();
		}
    }

    function set_currentSelection(val:Int):Int {
        val = FlxMath.wrap(val,0,pauseOptions.length-1);
        FlxG.sound.play(Assets.sound("scrollMenu"),0.7);
        
        for (item in grpOptions.members) {
            item.target = item.ID - val;
            item.alpha = (item.target == 0) ? 1 : 0.7;
        }
        return currentSelection = val;
    }
}