var blackBG:FlxSprite;
function createStage() {
    // Create the stage by coding it.
}

function create() {
    // This function will be executed when you're about to playing the song.
}

function postCreate(){
    // This function will be executed after the create function.
}

function onCountdown(counter) {
    // This function will be executed on song countdown.
    // 'counter' - Integer - Current countdown. [0 (Three),1 (Two),2 (One),3 (Go!)]
}

function onStartSong() {
    // When the song started, this function will be called.
    FlxTween.tween(PlayState.camHUD, {alpha: 0}, 1, {ease: FlxEase.linear});
}

function update(elapsed) {
    // This function will be executed on frame update.
    // 'elapsed' - Float - How many times does this Function called.
    PlayState.iconP1.angle = FlxMath.lerp(0,PlayState.iconP1.angle,FlxMath.bound(1-(elapsed*12),0,1));
    PlayState.iconP2.angle = FlxMath.lerp(0,PlayState.iconP2.angle,FlxMath.bound(1-(elapsed*12),0,1));

    for (i in 0...PlayState.playerStrums.members.length){
        if (CDevConfig.saveData.downscroll){
            PlayState.playerStrums.members[i].y = FlxMath.lerp(FlxG.height - 160,PlayState.playerStrums.members[i].y, FlxMath.bound(1 - (elapsed * 6), 0 , 1));
        } else{
            PlayState.playerStrums.members[i].y = FlxMath.lerp(70,PlayState.playerStrums.members[i].y, FlxMath.bound(1 - (elapsed * 6), 0 , 1));
        }
        
    }

    for (i in 0...PlayState.p2Strums.members.length){
        if (CDevConfig.saveData.downscroll){
            PlayState.p2Strums.members[i].y = FlxMath.lerp(FlxG.height - 160,PlayState.p2Strums.members[i].y, FlxMath.bound(1 - (elapsed * 6), 0 , 1));
        } else{
            PlayState.p2Strums.members[i].y = FlxMath.lerp(70,PlayState.p2Strums.members[i].y, FlxMath.bound(1 - (elapsed * 6), 0 , 1));
        }
    }
}

function p1NoteHit(noteData,isSustain) {
    // Executed when the player hits a note.
    // 'noteData' - Integer - The note data. [0 (Left), 1 (Down), 2 (Up), 3 (Right)]
    // 'isSustain' - Boolean - Is it a sustain note?

    if (!isSustain){
        if (CDevConfig.saveData.downscroll){
            PlayState.playerStrums.members[noteData].y += 20;
        } else{
            PlayState.playerStrums.members[noteData].y -= 20;  
        }
    }
}

function onNoteMiss(noteData) {
    // Executed when the player missed a note.
    // 'noteData' - Integer - The note data. [0 (Left), 1 (Down), 2 (Up), 3 (Right)]

    PlayState.camHUD.shake(0.009,0.2);
}

function p2NoteHit(noteData,isSustain) {
    // Executed when the opponent hits a note.
    // 'noteData' - Integer - The note data. [0 (Left), 1 (Down), 2 (Up), 3 (Right)]
    // 'isSustain' - Boolean - Is it a sustain note?

    if (!isSustain){
        if (CDevConfig.saveData.downscroll){
            PlayState.p2Strums.members[noteData].y += 20;
        } else{
            PlayState.p2Strums.members[noteData].y -= 20;  
        }
    }
        
}

function stepHit(curStep) {
    // Executed for every song steps.
    // 'curStep' - Integer - Current song steps

    switch (curStep){
        case 512:
            FlxTween.tween(PlayState.healthBarBG, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
            FlxTween.tween(PlayState.healthBar, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
            FlxTween.tween(PlayState.iconP1, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
            FlxTween.tween(PlayState.iconP2, {alpha: 0}, 1, {ease: FlxEase.cubeOut});
        case 632:
            PlayState.defaultCamZoom += 0.2;
        case 636:
            PlayState.defaultCamZoom += 0.4;
        case 640:
            PlayState.defaultCamZoom -= 0.6;
            FlxTween.tween(PlayState.healthBarBG, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
            FlxTween.tween(PlayState.healthBar, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
            FlxTween.tween(PlayState.iconP1, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
            FlxTween.tween(PlayState.iconP2, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
    }
}

var left:Bool = false;
function beatHit(curBeat) {
    // Executed for every song beats.
    // 'curBeat' - Integer - Current song beats
    left = !left;

    if (left){
        PlayState.iconP1.angle=10;
        PlayState.iconP2.angle=10;
    }else{
        PlayState.iconP1.angle=-10;
        PlayState.iconP2.angle=-10;
    }

    if (curBeat > 96 && curBeat <= 112){
        FlxG.camera.zoom += 0.020;
        PlayState.camHUD.zoom += 0.01;
    }
    switch (curBeat){
        case 32:
            FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.5, {ease: FlxEase.linear});
        case 64:
            PlayState.camHUD.flash(0xffffffff, 0.5);
            for (i in 0...PlayState.p2Strums.members.length){
                var xPos:Float = PlayState.p2Strums.members[i].x + 320;
                FlxTween.tween(PlayState.p2Strums.members[i], {x: xPos, angle:360}, 2, {ease: FlxEase.cubeOut});
                FlxTween.tween(PlayState.playerStrums.members[i], {alpha: 0}, 1, {ease: FlxEase.cubeOut});
            }
        case 71: 
            for (i in 0...PlayState.p2Strums.members.length){
                var xPos:Float = PlayState.p2Strums.members[i].x - 320;
                FlxTween.tween(PlayState.p2Strums.members[i], {x: xPos, angle:0}, 0.5, {ease: FlxEase.cubeOut});
                FlxTween.tween(PlayState.playerStrums.members[i], {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});
            }
        case 72:
            PlayState.camHUD.flash(0xffffffff, 0.5);
            for (i in 0...PlayState.playerStrums.members.length){
                var xPos:Float = PlayState.playerStrums.members[i].x - 320;
                FlxTween.tween(PlayState.playerStrums.members[i], {x: xPos, angle:-360}, 2, {ease: FlxEase.cubeOut});
                FlxTween.tween(PlayState.p2Strums.members[i], {alpha: 0}, 1, {ease: FlxEase.cubeOut});
            }
        case 79:
            for (i in 0...PlayState.playerStrums.members.length){
                var xPos:Float = PlayState.playerStrums.members[i].x + 320;
                FlxTween.tween(PlayState.playerStrums.members[i], {x: xPos, angle:0}, 0.5, {ease: FlxEase.cubeOut});
                FlxTween.tween(PlayState.p2Strums.members[i], {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});
            }
        //case 
        case 112, 114, 116:
            PlayState.defaultCamZoom += 0.2;
        case 119:
            PlayState.defaultCamZoom -= 0.6;
        case 120, 122, 124:
            PlayState.defaultCamZoom += 0.2;
        case 127:
            PlayState.defaultCamZoom -= 0.6;
    }
}


