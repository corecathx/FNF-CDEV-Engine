package cdev.states;

import flixel.text.FlxText;

class PlayState extends State
{
	override public function create()
	{
		super.create();

		var e = new FlxText(10,80,-1,"Hello, this is a complete rewrite version of CDEV Engine.\n"+
		"As of now, it's still on development stage and currently have nothing to play with.\n"+
		"\nThat's all i guess, bye!",13);
		e.font = Assets.fonts.JETBRAINS;
		add(e);
		e.screenCenter();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
