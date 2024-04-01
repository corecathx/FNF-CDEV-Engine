package game.cdev.objects;

/**
 * Cool rotate fix and stuff woooh
 * Known issue: - Insane performance drops when camera fix is enabled
 */
class CDevCamera extends FlxCamera {
    public function new(nX:Int = 0, nY:Int = 0, nWidth:Int = 0, nHeight:Int = 0, nZoom:Float = 0)
    {
        super(nX,nY,nWidth,nHeight,nZoom);
        flashSprite.scaleX = flashSprite.scaleY = (CDevConfig.saveData.cameraFix ? 2 : 1); // whuh
    }

    override function set_zoom(nZoom:Float):Float
    {
        var fixZoom:Float = (CDevConfig.saveData.cameraFix ? 0.5 : 1);
        
        zoom = (nZoom == 0) ? FlxCamera.defaultZoom : nZoom;
        setScale(zoom * fixZoom, zoom * fixZoom);
        return zoom;
    }
}