package meta.states;

import sys.FileSystem;
import sys.io.File;
import openfl.display.BlendMode;
import flixel.addons.transition.FlxTransitionableState;
#if desktop import game.cdev.engineutils.Discord.DiscordClient; #end
import game.cdev.CDevConfig;
import flixel.tweens.FlxTween;
import game.objects.AttachedSprite;
import flixel.util.FlxGradient;
import game.objects.Alphabet;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import game.Paths;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

typedef CreditsInfo = {
	var title:Bool;
	var name:String;
	var description:String;
	var color:Int;
	var link:String;
	var modName:String;
}

class AboutState extends MusicBeatState
{
	var curSelected:Int = 1;

	var mainCredits:Array<CreditsInfo> = [];

	// used for mod credits.
	var grpCredit:FlxTypedGroup<Alphabet>;

	var bg:FlxSprite;
	private var versionSht:FlxText;

	override function create()
	{
		Paths.destroyLoadedImages();
		FlxG.save.flush();
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
		#if desktop
		// Updating Discord Rich Presence
		if (Main.discordRPC)
			DiscordClient.changePresence("Reading Engine's About Screen", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		checkCustomCredits();
		updateMainCredits();

		bg = new FlxSprite(-80).loadGraphic(Paths.image('aboutMenu', "preload"));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.8;
		bg.antialiasing = CDevConfig.saveData.antialiasing;
		add(bg);

		grpCredit = new FlxTypedGroup<Alphabet>();
		add(grpCredit);

		for (i in 0...mainCredits.length)
		{
			var isSelectable:Bool = !unselectableCredit(i);
			var creditText:Alphabet = new Alphabet(0, 70 * i, mainCredits[i].name, isSelectable, false);
			creditText.isMenuItem = true;
			creditText.screenCenter(X);
			if (isSelectable)
			{
				creditText.xAdd -= 70;
			}
			creditText.isOptionItem = true;
			creditText.targetY = i;
			grpCredit.add(creditText);

			if (isSelectable)
			{
				if (mainCredits[i].modName != "FNF") Paths.currentMod = mainCredits[i].modName;
				var icon:AttachedSprite = new AttachedSprite('credits/' + mainCredits[i].name);
				icon.xAdd = creditText.width + 10;
				icon.sprTracker = creditText;
				icon.yAdd = -30;

				add(icon);
			}
		}
		bg.color = mainCredits[curSelected].color;
		intendedColor = bg.color;

		versionSht = new FlxText(20, FlxG.height - 100, 1000, '', 24);
		versionSht.scrollFactor.set();
		versionSht.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionSht.screenCenter(X);
		add(versionSht);
		versionSht.borderSize = 2;
		changeSelection();

		super.create();
	}

	var intendedColor:Int = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}
		if (controls.ACCEPT)
		{
			CDevConfig.utils.openURL(mainCredits[curSelected].link);
		}
	}

	var colorTween:FlxTween;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = mainCredits.length - 1;
			if (curSelected >= mainCredits.length)
				curSelected = 0;
		}
		while (unselectableCredit(curSelected));
		var newColor:Int = mainCredits[curSelected].color;
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpCredit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCredit(bullShit - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}
		versionSht.text = mainCredits[curSelected].description;
	}

    private function unselectableCredit(num:Int):Bool
        {
            return mainCredits[num].title == true;
        }
    
	function checkCustomCredits()
	{
		for (s in 0...Paths.curModDir.length)
		{
			if (FileSystem.exists('cdev-mods/'+Paths.curModDir[s]+'/credits.txt'))
			{
				var fullText:String = File.getContent('cdev-mods/'+Paths.curModDir[s]+'/credits.txt');
				var splittedArray:Array<String> = fullText.split('\n');
				var textData:Array<CreditsInfo> = [];
	
				trace(splittedArray);
				for (actualText in splittedArray)
				{
					var bro:CreditsInfo = {
						title: false,
						name: "",
						description: "",
						color: 0xFF000000,
						link: "",
						modName: ""
					};
					var data:Array<Dynamic> = [];
					var arrayText:String = "";//actualText+'::${Paths.curModDir[s]}';
					//check if it's not a comment line.
					if (!actualText.startsWith('--')) {
						if (actualText.contains("::"))
						{
							data = actualText.trim().split('::');
						}else{
							data = [actualText.trim()];
						}
						bro = {
							title: !actualText.contains("::"),
							name: data[0],
							description: data[1],
							color: Std.parseInt(data[2]),
							link: data[3],
							modName: Paths.curModDir[s] //:mad:
						};

						textData.push(bro);
					}
				}
				for (i in textData)
				{
					mainCredits.push(i);
				}
			}
		}
	}

	function updateMainCredits(){
		var mainCred:Array<CreditsInfo> = [
			{
				title: true,
				name: "CDEV Engine",
				description: "",
				color: 0xFF000000,
				link: "",
				modName: "FNF"
			},
			{
				title: false,
				name: "CoreDev",
				description: "Programmer of CDEV Engine.",
				color: 0xFF005FAD,
				link: "https://twitter.com/core5570r",
				modName: 'FNF'
			},
			{
				title: true,
				name: "Friday Night Funkin",
				description: "",
				color: 0xFF000000,
				link: "",
				modName: "FNF"
			},
			{
				title: false,
				name: "Ninjamuffin99",
				description: "Programmer of Friday Night Funkin'.",
				color: 0xFFF73838,
				link: "https://twitter.com/ninja_muffin99",
				modName: 'FNF'
			},
			{
				title: false,
				name: "PhantomArcade3K",
				description: "Animator of Friday Night Funkin'.",
				color: 0xFFFFBB1B,
				link: "https://twitter.com/phantomarcade3k",
				modName: 'FNF'
			},
			{
				title: false,
				name:"Evilsk8r",
				description:"Artist of Friday Night Funkin'.",
				color: 0xFF53E52C,
				link:"https://twitter.com/evilsk8r",
				modName:'FNF'
			},
			{
				title: false,
				name: "KawaiSprite",
				description: "Composer of Friday Night Funkin'.",
				color: 0xFF6475F3,
				link: "https://twitter.com/kawaisprite",
				modName: 'FNF'
			}
		];

		for (c in mainCred){
			mainCredits.push(c);
		}
	}
}
