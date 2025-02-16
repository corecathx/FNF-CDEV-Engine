package cdev.states;

import flixel.group.FlxSpriteGroup;
import cdev.objects.ui.*;
import openfl.display.BitmapData;
import flixel.addons.display.FlxGridOverlay;

class TestUIState extends State
{
    var panel:Panel;
    var panel2:SelectionBox;
    var button:Button;
    var buttonTog:Button;
    var inputBox:InputBox;
    var check:Checkbox;

    var tabGroup:TabGroup;

	override public function create()
	{
		super.create();
        createBackground();

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

        tabGroup = new TabGroup(200, 200, 600, 200);
        tabGroup.add("General", (p:FlxSpriteGroup)->{
            p.add(new Text(0,0, "General", LEFT, 20));
            p.add(new Text(0,24, "Lorem ipsum wawawawaw dsads vvczxc", LEFT, 14));
        });
        tabGroup.add("View", (p:FlxSpriteGroup)->{
            p.add(new Text(0,0, "View", LEFT, 20));
            p.add(new Text(0,24, "super.view()", LEFT, 14));
        });
        tabGroup.add("Options", (p:FlxSpriteGroup)->{
            p.add(new Text(0,0, "Options", LEFT, 20));
            p.add(new Text(0,24, "WHAT", LEFT, 14));
        });
        tabGroup.add("Help", (p:FlxSpriteGroup)->{
            p.add(new Text(0,0, "Help", LEFT, 20));
            p.add(new Text(0,24, "HELP I'M DEAD :sob:", LEFT, 14));
        });
        add(tabGroup);

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
            tabGroup.width += 2;
        if (FlxG.keys.pressed.J)
            tabGroup.width -= 2;
        if (FlxG.keys.pressed.I)
            tabGroup.height -= 2;
        if (FlxG.keys.pressed.K)
            tabGroup.height += 2;      
         
        if (FlxG.keys.pressed.D)
            tabGroup.x += 2;
        if (FlxG.keys.pressed.A)
            tabGroup.x -= 2;
        if (FlxG.keys.pressed.W)
            tabGroup.y -= 2;
        if (FlxG.keys.pressed.S)
            tabGroup.y += 2;  


		if (FlxG.keys.justPressed.ESCAPE) 
			FlxG.switchState(new EngineInfoState());
	}

	override function destroy() {
		FlxG.camera.bgColor = 0xFF000000;
		super.destroy();
	}
}
