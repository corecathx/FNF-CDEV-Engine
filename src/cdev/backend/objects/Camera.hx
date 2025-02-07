package cdev.backend.objects;

import openfl.filters.ShaderFilter;
import openfl.display.Shader;

/**
 * Cool rotate fix and stuff woooh
 * Known issue: - Insane performance drops when camera fix is enabled
 */
class Camera extends FlxCamera {
    public function new(nX:Int = 0, nY:Int = 0, nWidth:Int = 0, nHeight:Int = 0, nZoom:Float = 0)
    {
        super(nX,nY,nWidth,nHeight,nZoom);
        flashSprite.scaleX = flashSprite.scaleY = (true ? 2 : 1);
    }

    override function set_zoom(nZoom:Float):Float
    {
        var fixZoom:Float = (true ? 0.5 : 1);
        
        zoom = (nZoom == 0) ? FlxCamera.defaultZoom : nZoom;
        setScale(zoom * fixZoom, zoom * fixZoom);
        return zoom;
    }

    /**
     * Adds a new shader to this camera.
     * @param shaders 
     */
    public function addShader(shaders:Array<Shader>) {
        if (!filtersEnabled) {
            if (Preferences.verboseLog)
                trace("Could not add shader to camera, filters are disabled.");
            return;
        }

        for (shader in shaders) {
            if (shader == null)
                continue;

            filters.push(new ShaderFilter(shader));
        }
    }
}