var therm:FlxSprite;
var thermBar:FlxSprite;
var typh:FlxSprite;
var status:Int = 1;
var thermStat:String = "t";
var thermLevel:Float = 0; //0-2
var lerpLevel:Float = 0;
var startPos:Float = 0;

var frostbiteGuide:FlxSprite;
var showingGuide:Bool = false;
var shownOnce:Bool = false;

function postCreate(){
    therm = new FlxSprite();
    therm.frames = Paths.getSparrowAtlas("Thermometer");
    therm.animation.addByPrefix("t1", "Therm1", 24, true);
    therm.animation.addByPrefix("t2", "Therm2", 24, true);
    therm.animation.addByPrefix("t3", "Therm3", 24, true);
    therm.animation.play("t1", true);  
    therm.screenCenter(FlxAxes.Y);
    therm.x += 50;
    therm.cameras = [PlayState.camHUD];

    thermBar = new FlxSprite(therm.x + 36, therm.y + 18).makeGraphic(15,320, 0xFF669cff);
    thermBar.cameras = [PlayState.camHUD];

    startPos = therm.y + 18;

    typh = new FlxSprite();
    typh.frames = Paths.getSparrowAtlas("TyphlosionVit");
    typh.animation.addByPrefix("t1", "Typh1 instance 1", 24, false);
    typh.animation.addByPrefix("t2", "Typh2 instance 1", 24, false);
    typh.animation.addByPrefix("t3", "Typh3 instance 1", 24, false);
    typh.animation.addByPrefix("t4", "Typh4 instance 1", 24, false);
    typh.animation.addByPrefix("t5", "Typh5 instance 1", 24, false);
    typh.animation.play(status, true);  
    typh.y = therm.y - (typh.frameHeight/2)-15;
    typh.x += 54;
    typh.cameras = [PlayState.camHUD];
    add(typh);
    add(thermBar);
    add(therm);

    frostbiteGuide = new FlxSprite(530, 370);
	frostbiteGuide.frames = Paths.getSparrowAtlas('Extras');
	frostbiteGuide.animation.addByPrefix('press', 'Spacebar', 24, true);
	frostbiteGuide.animation.play('press');
	frostbiteGuide.updateHitbox();
	frostbiteGuide.antialiasing = true;
	add(frostbiteGuide);
	frostbiteGuide.cameras = [PlayState.camHUD];
	frostbiteGuide.alpha = 0.0001;
}

function update(e){
    if (thermLevel > 1) thermLevel = 1;
    if (thermLevel < 0) thermLevel = 0;
    lerpLevel = FlxMath.lerp(thermLevel, lerpLevel, 1-(e*6));
    thermBar.y = (startPos)+ (320 - (((320/2)*lerpLevel)));
    thermBar.scale.y = lerpLevel/1;
    thermBar.updateHitbox();
    thermBar.y -=(320/2)*lerpLevel;
    if (FlxG.keys.pressed.C){
        thermLevel += e;
    }

    if (FlxG.keys.pressed.X){
        thermLevel -= e;
    }

    if (thermLevel >= 0.35 && !shownOnce)
    {
        if (!shownOnce) FlxTween.tween(frostbiteGuide, {alpha: 1.0}, 0.5, {ease: FlxEase.cubeInOut});
        shownOnce = true;
        showingGuide = true;
    }
    
    if (FlxG.keys.justPressed.SPACE)
    {
        FlxG.sound.play(Paths.sound("TyphlosionUse.ogg"));
        PlayState.gf.playAnim("hey", true);
        PlayState.gf.specialAnim = true;
        thermLevel -= 0.5;
        status += 1;
        shownOnce = true;
        if (showingGuide) FlxTween.tween(frostbiteGuide, {alpha: 0.0001}, 0.5, {ease: FlxEase.cubeInOut});
    }
}

function stepHit(s){
    var curIndex:Int = Math.floor(s / 16);
    if (PlayState.SONG.notes[curIndex] != null)
        if (PlayState.SONG.notes[curIndex].banger){
            if (s % 4 == 0) PlayState.camHUD.zoom += 0.01;
        }
}

function beatHit(d){
    thermLevel += 0.007;
    thermStat = "t" + (Math.floor(thermLevel / (1/3))+1);
    therm.animation.play(thermStat, true);  
    typh.animation.play("t"+status, true);
}