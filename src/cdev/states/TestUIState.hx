package cdev.states;

import cdev.objects.ui.*;
import openfl.media.Sound;
import cdev.objects.Visualizer;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import cdev.objects.menus.Alphabet;
import openfl.display.BitmapData;
import flixel.text.FlxText;
import flixel.addons.display.FlxGridOverlay;

class TestUIState extends State
{
    var panel:Panel;
    var panel2:SelectionBox;
    var button:Button;
    var buttonTog:Button;
    var inputBox:InputBox;
    var check:Checkbox;
	override public function create()
	{
		super.create();
        createBackground();

        panel = new Panel(300,300, 100, 100);
        add(panel);

        panel2 = new SelectionBox();
        add(panel2);

        button = new Button(20,100, "This is a cool looking button", (_)->{
            trace("i'm depressed....");
        });
        add(button);

        buttonTog = new Button(20,140, "This one is a toggle: Enabled!", (status)->{
            if (status)
                buttonTog.label.text = "This one is a toggle: Enabled!";
            else 
                buttonTog.label.text = "This one is a toggle: Disabled!";
        });
        buttonTog.isToggle = true;
        add(buttonTog);

        inputBox = new InputBox(20,180, 200);
        inputBox.placeholder.text = "Hello! I'm an Input Box!";
        add(inputBox);

        check = new Checkbox(20, 210, "This is a checkbox");
        add(check);

        FlxG.mouse.visible = true;
	}

    function createBackground() {
		FlxG.camera.bgColor = 0xFF505050;
        var bmd:BitmapData = FlxGridOverlay.createGrid(10,10,FlxG.width, FlxG.height, true, 0xFF202020, 0xFF303030);
        var spr:Sprite = new Sprite().loadGraphic(bmd);
        add(spr);
        spr.alpha = 0.4;
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
        if (FlxG.keys.pressed.L)
            panel.width += 1;
        if (FlxG.keys.pressed.J)
            panel.width -= 1;
        if (FlxG.keys.pressed.I)
            panel.height -= 1;
        if (FlxG.keys.pressed.K)
            panel.height += 1;      
         
		if (FlxG.keys.justPressed.ESCAPE) 
			FlxG.switchState(new EngineInfoState());
	}

	override function destroy() {
		FlxG.camera.bgColor = 0xFF000000;
		super.destroy();
	}
}
