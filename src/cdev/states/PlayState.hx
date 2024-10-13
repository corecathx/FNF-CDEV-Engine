package cdev.states;

import flixel.text.FlxText;

class PlayState extends State
{
	override public function create()
	{
		super.create();

		var e = new FlxText(10,80,-1,"Hello, this is a complete rewrite version of CDEV Engine.\n"+
		"As of now, it's still on development stage, press space for note test, press enter for menu test..\n"+
		"\nThat's all i guess, bye!",13);
		e.font = Assets.fonts.JETBRAINS;
		add(e);
		e.screenCenter();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.SPACE) {
			FlxG.switchState(new DebugState());
		}
		if (FlxG.keys.justPressed.ENTER) {
			FlxG.switchState(new MainMenuState());
		}
		if (FlxG.keys.justPressed.SHIFT) {
			FlxG.switchState(new TestingState());
		}
	}
}
