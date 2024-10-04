package cdev.objects.play.notes;

import flixel.math.FlxRect;
import flixel.graphics.frames.FlxFrame;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.FlxGraphic;

class Sustain extends FlxTiledSprite {
    public static var originWidth:Float = 50;
    public static var scaleWidth:Float = originWidth * Note.noteScale;

    public static var tailOriginHeight:Float = 71;
    public static var tailScaleHeight:Float = tailOriginHeight * Note.noteScale;

    public var parent:Note = null;
    public var tailEnd:Sprite = null;
    public function new(parent:Note) {
        super(null,scaleWidth,0,false,true);
        this.parent = parent;
        this.frames = parent.frames;

        tailEnd = new Sprite();
        tailEnd.frames = this.frames;
    }

    public function init() {
        var _colorData:String = Note.animColor[parent.data];
        
        animation.addByPrefix("idle", _colorData + " hold piece", 24);
        animation.play("idle");
        loadGraphic(FlxGraphic.fromFrame(frames.frames[animation.frameIndex]), false);
    
        tailEnd.addAnim("idle", (_colorData == "purple" ? "pruple end hold" : _colorData + " hold end"), 24);
        tailEnd.playAnim("idle");
        tailEnd.setGraphicSize(scaleWidth,tailScaleHeight);
        tailEnd.updateHitbox();
    }

    override function destroy() {
        if (tailEnd != null) tailEnd.destroy();
        super.destroy();
    }
    
    /**
     * hi so uhh this code is awful
     */
    override function draw() {
        var receptor:ReceptorNote = parent.receptor;
        var isDownscroll:Bool = receptor.scrollMult < 0;
        // P = Parent // R = Receptor
        var sustainPos:{xP:Float,yP:Float,xR:Float,yR:Float} = {
            xP: parent.x + ((parent.width - width) * 0.5),
            yP: parent.y + (parent.height * 0.5),
            xR: receptor.x + ((parent.width - width) * 0.5),
            yR: receptor.y + (parent.height * 0.5),
        }
        var sustainHeight:Float = (parent.length * (receptor.speed * Math.abs(receptor.scrollMult) * Note.pixel_per_ms));
    
        x = sustainPos.xP;
        y = sustainPos.yP - (isDownscroll ? height : 0);
        alpha = parent.alpha * 0.7;
    
        width = scaleWidth;
        var clip:Float = sustainHeight;
        if (parent.hit) {
            // Clipping Effect //
            var lenDiff = (parent.length - (Conductor.current.time - parent.time));
            clip = FlxMath.bound(lenDiff * (receptor.speed * Math.abs(receptor.scrollMult) * Note.pixel_per_ms), - tailScaleHeight, sustainHeight);
            height = Math.abs(clip);
    
            // Lock Position //
            var bound:{low:Null<Float>, high:Null<Float>} = {
                low: !isDownscroll ? sustainPos.yR : null,
                high: isDownscroll ? sustainPos.yR - height : null,
            }
            var value:Float = sustainPos.yP - (isDownscroll ? height : 0);
            y = FlxMath.bound(value,bound.low,bound.high);
            if (clip < 0) {
                y += isDownscroll ? height : -height;
                visible = false;
            }

            if (!isDownscroll) 
                scrollY = sustainPos.yP - y;
    
        } else {
            height = sustainHeight;
        }
    
        if (visible) {
            cameras = parent.cameras;
            super.draw();
        }
    
        tailEnd.x = x;
        tailEnd.y = isDownscroll ? (clip > 0 ? y - tailEnd.height : y+height-tailEnd.height) : (clip > 0 ? y + height : y);
        tailEnd.flipY = isDownscroll;
        tailEnd.alpha = alpha;

        if (clip < 0) {
            var swagRect:FlxRect = tailEnd.clipRect;
			if (swagRect == null) 
				swagRect = FlxRect.get(0, 0, isDownscroll ? tailEnd.frameWidth : tailEnd.width / tailEnd.scale.x, tailEnd.frameHeight);

			if (isDownscroll) {
				if (tailEnd.y + tailEnd.height >= sustainPos.yR){
					swagRect.height = (sustainPos.yR - tailEnd.y) / tailEnd.scale.y;
					swagRect.y = tailEnd.frameHeight - swagRect.height;
				}
			} else {
				if (tailEnd.y <= sustainPos.yR){
					swagRect.y = (sustainPos.yR - tailEnd.y) / tailEnd.scale.y;
					swagRect.height = (tailEnd.height / tailEnd.scale.y) - swagRect.y;
				}
			}
			tailEnd.clipRect = swagRect;
        }

        if (visible) {
            tailEnd.cameras = parent.cameras;
            tailEnd.draw();
        }

    }    
    
    override function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    override function updateVerticesData():Void {
        if (graphic == null)
            return;
    
        graphicVisible = true;
    
        vertices[0] = vertices[6] = 0.0; //top left
        vertices[2] = vertices[4] = width; //top right
    
        vertices[1] = vertices[3] = 0.0; //bottom left
        vertices[5] = vertices[7] = height; //bottom right

        var frame:FlxFrame = graphic.imageFrame.frame;
        uvtData[0] = uvtData[6] = 0;
        uvtData[2] = uvtData[4] = 1;

        uvtData[1] = uvtData[3] = -scrollY / frame.sourceSize.y;
        uvtData[5] = uvtData[7] = uvtData[1] + height / frame.sourceSize.y;
    
        if (height <= 0) 
            graphicVisible = false;
    }
}