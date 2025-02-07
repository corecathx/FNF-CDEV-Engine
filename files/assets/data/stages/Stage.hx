import cdev.objects.Sprite;
import cdev.backend.Assets;
function create(){
    var bg:Sprite = new Sprite(-600, -200).loadGraphic(Assets.image('stageback'));
    bg.scrollFactor.set(0.9, 0.9);
    bg.active = false;
    add(bg);
    
    var stageFront:Sprite = new Sprite(-650, 600).loadGraphic(Assets.image('stagefront'));
    stageFront.setScale(1.1);
    stageFront.scrollFactor.set(0.9, 0.9);
    stageFront.active = false;
    add(stageFront);

    var stageCurtains:Sprite = new Sprite(-500, -300).loadGraphic(Assets.image('stagecurtains'));
    stageFront.setScale(0.9);
    stageCurtains.scrollFactor.set(1.3, 1.3);
    stageCurtains.active = false;

    add(stageCurtains);
}

function update(e){
}
