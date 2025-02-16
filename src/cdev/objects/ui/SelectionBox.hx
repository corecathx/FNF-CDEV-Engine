package cdev.objects.ui;

/**
 * Selection Box used in Editors.
 */
class SelectionBox extends Panel {
    public function new() {
        super(0, 0, 20, 20, "selection");
    }
    var lastPressed:FlxPoint = FlxPoint.get(0,0);
    var isDragging = false;
    var minDragDistance = 5;
    var fadeSpeed = 0.1;
    override function update(elapsed:Float) {
        if (FlxG.mouse.justPressed) {
            lastPressed.set(FlxG.mouse.x, FlxG.mouse.y);
            isDragging = false;
        }
        
        if (FlxG.mouse.pressed) {
            var newWidth = FlxG.mouse.x - lastPressed.x;
            var newHeight = FlxG.mouse.y - lastPressed.y;
        
            if (!isDragging && (Math.abs(newWidth) > minDragDistance || Math.abs(newHeight) > minDragDistance)) {
                isDragging = true;
                visible = true;
                alpha = 0; 
            }
        
            if (isDragging) {
                var drawX = (newWidth < 0) ? FlxG.mouse.x : lastPressed.x;
                var drawY = (newHeight < 0) ? FlxG.mouse.y : lastPressed.y;
        
                setPosition(drawX, drawY);
                setSize(Math.abs(newWidth), Math.abs(newHeight));
        
                if (alpha < 1) {
                    alpha += fadeSpeed;
                    if (alpha > 1) alpha = 1;
                }
            }
        } else {
            if (isDragging)
                isDragging = false;
        
            if (visible) {
                alpha -= fadeSpeed;
                if (alpha <= 0) {
                    alpha = 0;
                    visible = false;
                }
            }
        }  
    }
}