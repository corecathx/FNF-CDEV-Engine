function create(){
	PlayState.enableNoteTween = false;
	PlayState.playingLeftSide = true;
}
var hasFlipped:Array<Note> = [];

function update(e){
	var charToCheck = [PlayState.dad, PlayState.boyfriend];
	for (char in charToCheck){
		var name = PlayState.dad.animation.curAnim.name;
		if (StringTools.startsWith(name, "sing")){
			char.holdTimer += e;
			if (char.holdTimer >= (Conductor.crochet/1000)*2){
				char.dance();
			}
		}
	}
	
	for (i in 0...PlayState.notes.members.length){
		var note = PlayState.notes.members[i];
		if (!hasFlipped.contains(note)){
			note.mustPress = !note.mustPress;
			note.noAnim = true;
			//note.canIgnore = true;
			hasFlipped.push(note);
		}
	}	
}
var anims = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
function p1NoteHit(d,s){
	PlayState.boyfriend.playAnim(anims[d], true);
	PlayState.boyfriend.holdTimer = 0;
}

function p2NoteHit(d,s){
	PlayState.dad.playAnim(anims[d], true);
	PlayState.dad.holdTimer = 0;
}