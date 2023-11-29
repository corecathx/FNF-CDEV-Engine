// TitleState recreated in HScript

var blackScreen:FlxSprite;
var credGroup:Array<Alphabet> = [];
var textGroup:Array<Alphabet> = [];
var ngSpr:FlxSprite;
var yOffset:Float = 0;
var curWacky:Array<String> = [];
var wackyImage:FlxSprite;
var debugShit:Bool = false;
var checker:FlxBackdrop;
var speed:Float = 1;
var logoBl:FlxSprite;
var gfDance:FlxSprite;
var danceLeft:Bool = false;
var titleText:FlxSprite;
var bg:FlxSprite;
var skippedIntro:Bool = false;
var logoY:Float = 0;
var gfY:Float = 0;
var tTextY:Float = 0;

function create()
{
	trace(_static.get("initialized"));
	if (!_static.exists("initialized"))
		_static.set("initialized",false);
	trace(_static.exists("initialized") + " // " + _static.get("initialized"));
	bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	bg.antialiasing = CDevConfig.saveData.antialiasing;
	bg.scale.set(1.2, 1.2);
	bg.alpha = 0.4;
	add(bg);

	checker = new FlxBackdrop(Paths.image('checker'), FlxAxes.XY);
	checker.scale.set(1.5, 1.5);
	checker.color = 0xFF006AFF;
	checker.blend = BlendMode.LAYER;
	add(checker);
	checker.scrollFactor.set(0, 0.07);
	checker.alpha = 0.4;
	checker.updateHitbox();

	logoBl = new FlxSprite(-50, 10);
	logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
	logoBl.antialiasing = CDevConfig.saveData.antialiasing;
	logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
	logoBl.animation.play('bump');
	logoBl.updateHitbox();

	gfDance = new FlxSprite(FlxG.width * 0.4 + 50, FlxG.height * 0.07);
	gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
	gfDance.animation.addByIndices('danceLeft', 'GF Dancing Beat blue', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
	gfDance.animation.addByIndices('danceRight', 'GF Dancing Beat blue', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
	gfDance.antialiasing = CDevConfig.saveData.antialiasing;
	add(gfDance);
	add(logoBl);

	titleText = new FlxSprite(100, FlxG.height * 0.8);
	titleText.frames = Paths.getSparrowAtlas('titleEnter');
	titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
	titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
	titleText.antialiasing = CDevConfig.saveData.antialiasing;
	titleText.animation.play('idle');
	titleText.updateHitbox();
	titleText.scale.set(0.9, 0.9);
	add(titleText);

	logoY = logoBl.y;
	gfY = gfDance.y;
	tTextY = titleText.y;

	blackScreen = new FlxSprite(-1000, -1000).makeGraphic(2500, 2500, FlxColor.BLACK);
	add(blackScreen);

	ngSpr = new FlxSprite(0, FlxG.height * 0.52 + 30).loadGraphic(Paths.image('newgrounds_logo'));
	add(ngSpr);
	ngSpr.visible = false;
	ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
	ngSpr.updateHitbox();
	ngSpr.screenCenter(FlxAxes.X);
	ngSpr.antialiasing = CDevConfig.saveData.antialiasing;

	FlxG.mouse.visible = false;

	if (!_static.get("initialized")){
		Conductor.changeBPM(120);
		FlxG.sound.playMusic(Paths.music('funkinIntro'), 0.7);
		FlxG.sound.music.fadeIn(4, 0, 0.7);
		_static.set("initialized", true);
	} else{
		skipIntro();
	}

	FlxG.camera.zoom = 0.9;
}

var transitioning:Bool = false;
var intendedSpeed:Float = 1;

function update(elapsed:Float)
{
	bg.alpha = FlxMath.lerp(0.2, bg.alpha, CDevConfig.utils.bound(1 - (elapsed * 7), 0, 1));
	if (FlxG.sound.music != null)
		Conductor.songPosition = FlxG.sound.music.time;
	// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);
	speed = FlxMath.lerp(intendedSpeed, speed, CDevConfig.utils.bound(1 - (elapsed * 2), 0, 1));
	checker.x -= 0.45 / (CDevConfig.saveData.fpscap / 60);
	checker.y -= (0.16 / (CDevConfig.saveData.fpscap / 60)) * speed;

	var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
	if (pressedEnter && !transitioning && skippedIntro)
	{
		titleText.animation.play('press');
		intendedSpeed += 100;

		FlxG.camera.flash();
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

		transitioning = true;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			goToMain();
			closedState = true;
			current.changeState(new MainMenuState());
		});
	}

	if (pressedEnter && !skippedIntro)
	{
		skipIntro();
	}
}

function createCoolText(textArray:Array<String>, ?effect:String = "default")
{
	for (i in 0...textArray.length)
	{
		var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
		money.screenCenter(FlxAxes.X);
		money.y += (i * 60) + 200 + yOffset;
		money.effect = effect;
		add(money);
		credGroup.push(money);
		textGroup.push(money);
	}
}

var closedState:Bool = false;
var shouldUpdate:Bool = false;
var onlineVer:String = '';

function addMoreText(text:String, ?effect:String = "default")
{
	var coolText:Alphabet = new Alphabet(0, 0, text, true);
	coolText.screenCenter(FlxAxes.X);
	coolText.effect = effect;
	coolText.y += (textGroup.length * 60) + 200 + yOffset;
	add(coolText);
	credGroup.push(coolText);
	textGroup.push(coolText);
}

function deleteCoolText()
{
	while (textGroup.length > 0)
	{
		remove(textGroup[0]);
		credGroup.remove(textGroup[0]);
		textGroup.remove(textGroup[0]);
	}
}

function beatHit(curBeat)
{
	trace(curBeat);
	logoBl.animation.play('bump', true);
	danceLeft = !danceLeft;

	if (danceLeft)
		gfDance.animation.play('danceRight');
	else
		gfDance.animation.play('danceLeft');

	bg.alpha = 0.3;

	if (!skippedIntro)
	{
		switch (curBeat)
		{
			case 1:
				yOffset = -30; // Y offset of these intro texts or shit
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8r']);
			case 3:
				addMoreText('present');
			case 4:
				deleteCoolText();
			case 5:
				yOffset = 10;
				createCoolText(['Not Associated', 'With']);
			case 7:
				addMoreText('Newgrounds');
				ngSpr.visible = true;
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			case 9:
				createCoolText(["look at this"]);
			case 11:
				addMoreText("custom title stuff lmao");
			case 12:
				deleteCoolText();
			case 13:
				yOffset = 10;
				addMoreText('Friday');
			case 14:
				addMoreText('Night');
			case 15:
				addMoreText('Funkin');
			case 16:
				deleteCoolText();
				skipIntro();
		}
	}
}

function skipIntro():Void
{
	if (!skippedIntro)
	{
		deleteCoolText();
		// FlxG.camera.y = 720;
		logoBl.y = FlxG.height;
		gfDance.y = FlxG.height + 100;
		titleText.y = FlxG.height + 300;
		FlxTween.tween(logoBl, {y: logoY}, 2, {ease: FlxEase.circOut});
		FlxTween.tween(gfDance, {y: gfY}, 2, {ease: FlxEase.circOut});
		FlxTween.tween(titleText, {y: tTextY}, 2, {ease: FlxEase.circOut});

		remove(ngSpr);
		FlxG.camera.flash(FlxColor.WHITE, 1);
		remove(credGroup);
		remove(blackScreen);
		skippedIntro = true;
	}
}

function goToMain()
{
	FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.circOut});
}
