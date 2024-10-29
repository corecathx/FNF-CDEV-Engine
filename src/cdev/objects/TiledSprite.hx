package cdev.objects;

import flixel.util.FlxDestroyUtil;
import flixel.FlxCamera;
import flixel.math.FlxRect;
import flixel.math.FlxMatrix;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;

using flixel.util.FlxColorTransformUtil;

/**
 * Code made by Sword352 for FNF Eternal.
 * https://github.com/Sword352/FnF-Eternal/blob/dev/source/funkin/objects/TiledSprite.hx
 * 
 * Modified by CoreCat for usage in CDEV Engine.
 */

/**
 * A sprite object able to repeat a frame vertically.
 * NOTE: this has been specifically designed for sustain notes.
 */
class TiledSprite extends Sprite {
	/**
	 * How many times the frame should repeat.
	 * NOTE: relies on this sprite's `height`!
	 */
	public var tiles(get, set):Float;

	/**
	 * Defines the region to render for this sprite.
	 * Basically behaves as what `clipRect` does on a regular `FlxSprite`.
	 * Using `clipRect` on this sprite is not recommended!
	 */
	public var clipRegion:FlxRect;
	
	/**
	 * Reference to the tail frame to render.
	 * Can be set publicly using the `setTail` method.
	 */
	var _tailFrame:FlxFrame;
	
	/**
	 * A transformation matrix dedicated for the tail.
	 * The tail has it's own matrix for frame-specific stuff (eg. frame rotation).
	 */
	var _tailMat:FlxMatrix = new FlxMatrix();
	
	/**
	 * Buffer which stores the original texture coordinates of the current rendered frame.
	 * Allows us to safely modify the frame coordinates in order to clip the sprite.
	 */
	var _frameRect:FlxRect = FlxRect.get();

	//////////////////
	/// PUBLIC API ///
	
	/**
	 * Sets the tail for this sprite.
	 * @param animation Animation containing the desired tail frames. If `null`, no tail is rendered.
	 */
	public function setTail(animation:String):Void {
	    if (animation == null) {
	        _tailFrame = null;
	        return;
	    }
	    
	    var anim:FlxAnimation = this.animation.getByName(animation);
	    
	    if (anim == null) {
	        FlxG.log.warn('TiledSprite: Could not find tail animation "${animation}"!');
	        _tailFrame = null;
	        return;
	    }
	    
	    // copy the frame and modify coordinates to fix gaps
		var frame:FlxFrame = frames.frames[anim.frames[0]];
	    _tailFrame = frame.copyTo(_tailFrame);

		_tailFrame.sourceSize.y -= 2;
	    _tailFrame.frame.height -= 2;
	    _tailFrame.frame.y += 2;
	}

	/**
	 * Calculates the smallest globally aligned bounding box that encompasses this sprite's graphic as it
	 * would be displayed. Honors scrollFactor, rotation, scale, offset and origin.
	 * @param newRect Optional output `FlxRect`, if `null`, a new one is created.
	 * @param camera  Optional camera used for scrollFactor, if null `FlxG.camera` is used.
	 * @return A globally aligned `FlxRect` that fully contains the input sprite.
	 * @since 4.11.0
	 */
	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (newRect == null)
			newRect = FlxRect.get();
		
		if (camera == null)
			camera = FlxG.camera;
		
		newRect.setPosition(x, y);
		if (pixelPerfectPosition)
			newRect.floor();

		_scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);
		newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x;
		newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y;
		if (isPixelPerfectRender(camera))
			newRect.floor();

		// account for the sprite's height rather than the graphic's (fixes an issue where the sprite could prematurely be considered offscreen and stop rendering)
		newRect.setSize(frameWidth * Math.abs(scale.x), height);
		return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void {
		clipRegion = FlxDestroyUtil.put(clipRegion);
		_tailFrame = FlxDestroyUtil.destroy(_tailFrame);
		_frameRect = FlxDestroyUtil.put(_frameRect);
		_tailMat = null;
		super.destroy();
	}

	/////////////////
	/// RENDERING ///
	
	/**
	 * Drawing behaviour.
	 */
	override function draw():Void {
		if (tiles == 0 || clipRegion != null && clipRegion.isEmpty)
			return;

		super.draw();
	}

	/**
	 * Actually draw the sprite to camera.
	 * @param camera Target camera.
	 */
	override function drawComplex(camera:FlxCamera):Void {
	    getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(clipOffsetX(), clipOffsetY());
		_point.add(origin.x, origin.y);
        
		prepareMatrix(_frame, _matrix);
		prepareMatrix(_tailFrame, _tailMat);

		var drawItem:FlxDrawQuadsItem = camera.startQuadBatch(_frame.parent, colorTransform != null && colorTransform.hasRGBMultipliers(), colorTransform != null && colorTransform.hasRGBAOffsets(), blend, antialiasing, shader);

		for (i in 0...Math.ceil(tiles)) {
			var tileVisibility:Int = tileOnScreen(i);

			if (tileVisibility == -1)
				break;

			if (tileVisibility == 1)
				continue;

			drawTile(drawItem, i);
		}
    }

	/**
	 * Adds a tile to an `FlxDrawItem`, which will render it at a later time.
	 * @param item `FlxDrawQuadsItem` instance.
	 * @param tile Tile to draw.
	 */
	function drawTile(item:FlxDrawQuadsItem, tile:Int):Void {
	    var frameToDraw:FlxFrame = _frame;
	    var mat:FlxMatrix = _matrix;
	    
	    if (isTail(tile)) {
	        frameToDraw = _tailFrame;
	        mat = _tailMat;
	    }

		var offsetX:Float = frameToDraw.offset.x * Math.abs(scale.x);
		var offsetY:Float = frameToDraw.offset.y * Math.abs(scale.y);
	    
		rectCopy(_frameRect, frameToDraw.frame);

		if (isTilePartial(tile))
			clipPartialTile(frameToDraw);
			
		if (clipRegion != null)
		    applyClipRegion(frameToDraw, tile);
		    
		matrixTranslate(offsetX, offsetY);
		item.addQuad(frameToDraw, mat, colorTransform);

		matrixTranslate(-offsetX, -offsetY + frameToDraw.frame.height * Math.abs(scale.y));
		rectCopy(frameToDraw.frame, _frameRect);
	}
	
	/**
	 * Applies the `clipRegion` to a tile frame.
	 * @param frame Frame to clip.
	 * @param Tile Current tile.
	 */
	function applyClipRegion(frame:FlxFrame, tile:Int):Void {
	    var clipX:Float = FlxMath.bound(clipRegion.x / scale.x, 0, frame.frame.x);
	    var clipW:Float = FlxMath.bound(clipRegion.width / scale.x, 0, frame.frame.width);
	    
	    frame.frame.width = clipW; // - clipX;
	    frame.frame.x += clipX;
	}

	/**
	 * Clips a frame to match a partially filled tile.
	 * @param frame Tile frame to clip.
	 */
	function clipPartialTile(frame:FlxFrame):Void {
		var heightReduce:Float = computeTileClip(realHeight(), Math.ceil(tiles));
		
		if (frame.angle == FlxFrameAngle.ANGLE_0) {
            frame.frame.height -= heightReduce;
            frame.frame.y += heightReduce;
        }
        else if (frame.angle == FlxFrameAngle.ANGLE_90) {
            frame.frame.width -= heightReduce;
            frame.frame.x += heightReduce;
        }
		else {
			frame.frame.width -= heightReduce;
		}

		if (flipY)
		    matrixTranslate(0, -heightReduce * Math.abs(scale.y));
	}

	///////////////
	/// HELPERS ///
		
	/**
	 * Applies sprite properties to a transform matrix.
	 * @param frame Parent tile frame.
	 * @param matrix Matrix transform.
	 */
	function prepareMatrix(frame:FlxFrame, matrix:FlxMatrix):Void {
	    if (frame == null)
	        return;
	        
	    frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());

        // prepareMatrix applies frame offsets but we'll apply those ourselves later
        matrix.translate(-frame.offset.x, -frame.offset.y);
        
		matrix.translate(-origin.x, -origin.y);
		matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0 && angle != 0)
			matrix.rotateWithTrig(_cosAngle, _sinAngle);
		
		matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera)) {
			matrix.tx = Math.floor(matrix.tx);
			matrix.ty = Math.floor(matrix.ty);
		}
	}

	/**
	 * Returns an integer based on whether the tile is on screen.
	 * @param tile Current tile.
	 * @return Int
	 */
	function tileOnScreen(tile:Int):Int {
		var tileSize:Float = getHeightForTile(tile);

		// this tile and the nexts won't be on screen, returns -1 to break the loop
		if (_matrix.ty >= FlxG.height + (flipY ? tileSize : 0))
			return -1;

		var onScreen:Bool = (_matrix.ty > -tileSize && _matrix.ty < FlxG.height + (flipY ? tileSize : 0));

		// the tile is not on screen but the others may, returns 1 to continue the loop
		if (!onScreen) {
			matrixTranslate(0, tileSize);
			return 1;
		}

		// otherwise just render normally
		return 0;
	}

	/*
	function isTileOnScreen(tile:Int):Bool {
		// couldn't use getScreenBounds or isOnScreen because they're broken apparently, but this should get the job done

		var tileSize:Float = getHeightForTile(tile);
		var output:Bool = (_matrix.ty > -tileSize && _matrix.ty < FlxG.height + (flipY ? tileSize : 0));

		if (!output)
			matrixTranslate(0, tileSize);

		return output;
	}

	function stopRendering(tile:Int):Bool {
		var tileSize:Float = getHeightForTile(tile);
		return _matrix.ty >= FlxG.height + (flipY ? tileSize : 0);
	}
	*/

	/**
	 * Returns a value to remove from frame coordinates in order to properly clip a partial tile.
	 * @param height Height to render.
	 * @param tiles Total amount of tiles.
	 */
	function computeTileClip(height:Float, tiles:Int):Float {
		var tileHeight:Float = tileHeight();

	    if (_tailFrame == null)
	        return (tiles * tileHeight - height) / Math.abs(scale.y);

		var tailHeight:Float = tailHeight();
	   
	    if (height < tailHeight)
	        return (tailHeight - height) / Math.abs(scale.y);
	        
	    return (tailHeight + tileHeight * (tiles - 1) - height) / Math.abs(scale.y);
	}

	/**
	 * Returns whether the current tile is partially filled.
	 * @param tile Current tile.
	 */
	function isTilePartial(tile:Int):Bool {
		return (!flipY && tile == 0) || (flipY && tile + 1 == Math.ceil(tiles));
	}
	
	/**
	 * Returns whether the current tile is the tail.
	 * @param tile Current tile.
	 */
	function isTail(tile:Int):Bool {
	    return _tailFrame != null && ((!flipY && tile + 1 == Math.ceil(tiles)) || (flipY && tile == 0));
	}
	
	/**
	 * Appends `x` and `y` positions to the transform matrices by accounting for the angle property.
	 * @param x Horizontal position.
	 * @param y Vertical position.
	 */
	function matrixTranslate(x:Float, y:Float):Void {
	    var translateX:Float = (x * _cosAngle) - (y * _sinAngle);
	    var translateY:Float = (y * _cosAngle) + (x * _sinAngle);
	    
	    if (_tailFrame != null)
	        _tailMat.translate(translateX, translateY);
	        
	    _matrix.translate(translateX, translateY);
	}

	/**
	 * Copy coordinates from an `FlxRect` to another.
	 * @param first Target `FlxRect`.
	 * @param second `FlxRect` holding the informations to copy.
	 */
	inline function rectCopy(first:FlxRect, second:FlxRect):Void {
		first.x = second.x;
		first.y = second.y;
		first.width = second.width;
		first.height = second.height;
	}

	/**
	 * Returns the corresponding height for a tile.
	 * @param tile Tile to check.
	 * @return Float
	 */
	inline function getHeightForTile(tile:Int):Float {
		return isTail(tile) ? tailHeight() : tileHeight();
	}
	
	/**
	 * Returns the height to render for this sprite.
	 */
	inline function realHeight():Float {
	    return Math.max(0, height - FlxMath.bound(clipRegion != null ? clipRegion.y : 0, 0, height));
	}

	/**
	 * Returns the height of a single tile.
	 */
	inline function tileHeight():Float {
		return _frame.frame.height * Math.abs(scale.y);
	}
	
	/**
	 * Returns the tail's height.
	 */
	inline function tailHeight():Float {
	    return _tailFrame.frame.height * Math.abs(scale.y);
	}
	
	/**
	 * Returns the `x` position offset applied when clipping.
	 */
	inline function clipOffsetX():Float {
	    return FlxMath.bound(clipRegion != null ? clipRegion.x : 0, 0, width);
	}
	
	/**
	 * Returns the `y` position offset applied when clipping.
	 */
	inline function clipOffsetY():Float {
	    return (flipY ? 0 : FlxMath.bound(clipRegion != null ? clipRegion.y : 0, 0, height));
	}

	//////////////////
	/// PROPERTIES ///
	
	override function set_frame(v:FlxFrame):FlxFrame {
	    super.set_frame(v);
	    
	    if (v != null && _frame != null) {
	        // gap fix
			_frame.sourceSize.y -= 2;
	        _frame.frame.height -= 2;
	        _frame.frame.y += 1;
	    }
	    
	    return v;
	}
	
	override function set_angle(v:Float):Float {
		super.set_angle(v);
		updateTrig();
		return v;
	}

	function get_tiles():Float {
		var height:Float = realHeight();
		var tileHeight:Float = tileHeight();

	    if (_tailFrame == null)
	        return Math.max(0, height / tileHeight);
        
		var tailHeight:Float = tailHeight();
        
	    if (height < tailHeight)
	        return Math.max(0, height / tailHeight);
        
	    // increase by 1 to account for the tail
	    return Math.max(0, 1 + (height - tailHeight) / tileHeight);
	}

	function set_tiles(v:Float):Float {
	    if (_tailFrame == null)
	        height = tileHeight() * v;
	    else
	        height = (tailHeight() * Math.min(v, 1)) + (tileHeight() * Math.max(v - 1, 0));
	    
		return v;
	}
}