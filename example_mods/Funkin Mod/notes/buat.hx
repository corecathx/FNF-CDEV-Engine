function create(){
    loadTexture("notes/NOTE_assets");
    initialize();
    trace("Aaa");
}

function update(elapsed){
}

function onNoteHit(rating, isPlayer){
    trace(current.noteData)
    //if (isPlayer){
        switch(current.noteData){
            case 0,1:
                FlxG.sound.play(Paths.sound("kick.ogg"), 0.6);
            case 2,3:
                FlxG.sound.play(Paths.sound("snare.ogg"), 0.6);
        }
    //}

    trace("got hit!");
}

function onNoteMiss(){
    //Called when this missed this note.
}

function onNoteSpawn(){
    //Called when this note spawned.
}