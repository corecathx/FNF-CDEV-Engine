package cdev.objects.notes;

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
        var sustainHeight:Float = (parent.length * (receptor.speed * Math.abs(receptor.scrollMult) * Note.pixel_per_ms)) - tailScaleHeight;
    
        x = sustainPos.xP;
        y = sustainPos.yP - (isDownscroll ? height : 0);
        alpha = 0.7;
    
        width = scaleWidth;
        if (parent.hit) {
            // Clipping Effect //
            var lenDiff = (parent.length - (Conductor.current.time - parent.time));
            var clip:Float = FlxMath.bound(lenDiff * (receptor.speed * Math.abs(receptor.scrollMult) * Note.pixel_per_ms), 0, sustainHeight);
            height = clip;
    
            // Lock Position //
            var bound:{low:Null<Float>, high:Null<Float>} = {
                low: !isDownscroll ? sustainPos.yR : null,
                high: isDownscroll ? sustainPos.yR - height : null, // Fix for downscroll to lock correctly
            }
            var value:Float = sustainPos.yP - (isDownscroll ? height : 0); // Adjust value for downscroll
            y = FlxMath.bound(value,bound.low,bound.high);
            if (!isDownscroll) 
                scrollY = sustainPos.yP - y;
    
        } else {
            height = sustainHeight;
        }
    
        super.draw();
    
        tailEnd.x = x;
        tailEnd.y = isDownscroll ? y - tailEnd.height : y + height;
        tailEnd.flipY = isDownscroll;
        tailEnd.alpha = alpha;
        tailEnd.draw();
    }    
    
    override function update(elapsed:Float):Void {
        super.update(elapsed);
    }

    override function updateVerticesData():Void {
        if (graphic == null)
            return;
    
        graphicVisible = true;
    
        vertices[0] = vertices[6] = 0.0;
        vertices[2] = vertices[4] = width;
    
        vertices[1] = vertices[3] = 0.0;
        vertices[5] = vertices[7] = height;

        var frame:FlxFrame = graphic.imageFrame.frame;
        uvtData[0] = uvtData[6] = 0;
        uvtData[2] = uvtData[4] = 1;

        uvtData[1] = uvtData[3] = -scrollY / frame.sourceSize.y;
        uvtData[5] = uvtData[7] = uvtData[1] + height / frame.sourceSize.y;
    
        if (height <= 0) 
            graphicVisible = false;
    }
}