package cdev.objects.play.hud;

class HealthIcon extends Sprite {
    public var allowBeat:Bool = true;
    public var hasWinningIcon:Bool = false;
    public var iconOffset:Array<Float> = [0, 0];
    public var isPlayer:Bool = false;
    public function new(nGraphic:FlxGraphic, isPlayer:Bool = false) {
        super();
        this.isPlayer = isPlayer;
        if (nGraphic == null) return;
        loadGraphic(nGraphic, true, 150, 150);
        hasWinningIcon = (nGraphic.width > 300 && nGraphic.height <= 450);
		animation.add("idle", (hasWinningIcon ? [0,1,2] : [0,1]), 0, false, isPlayer);
		animation.play("idle");

		iconOffset[0] = (width - 150) / 2;
		iconOffset[1] = (height - 150) / 2;
    }
    
    override function updateHitbox()
    {
        super.updateHitbox();
        offset.x = iconOffset[0];
        offset.y = iconOffset[1];
    }

    public function changeFrame(frameNum:Int){
		if (animation.curAnim == null) return;
		animation.curAnim.curFrame = frameNum;
	}
}