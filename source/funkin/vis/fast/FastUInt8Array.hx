package funkin.vis.fast;

import lime.utils.ArrayBuffer;
import lime.utils.ArrayBufferView;
import lime.utils.UInt8Array;

@:forward
@:transitive
abstract FastUInt8Array(UInt8Array) from UInt8Array to UInt8Array {
    public inline function subarray(begin:Int, end:Null<Int> = null):UInt8Array
		return __subarray(begin, end);

    @:access(lime.utils)
    #if !no_typedarray_inline inline #end
    function __subarray(begin:Int, end:Null<Int> = null):UInt8Array
	{
		if (end == null) end = this.length;
		var len = end - begin;
		var byte_offset = this.toByteLength(begin) + this.byteOffset;

		//return new ArrayBufferView(0, Uint8).initBuffer(this.buffer, byte_offset, len);//new UInt8Array(this.buffer, byte_offset, len);
		return __initBufferWithLen(new ArrayBufferView(0, Uint8), this.buffer, byte_offset, len);//new UInt8Array(this.buffer, byte_offset, len);
    }

	@:access(lime.utils)
	#if !no_typedarray_inline inline #end
	static function __initBufferWithLen(view:ArrayBufferView, in_buffer:ArrayBuffer, in_byteOffset:Int, len:Int)
	{
		var elementSize = view.bytesPerElement;
		if (in_byteOffset < 0) throw TAError.RangeError;
		if (in_byteOffset % elementSize != 0) throw TAError.RangeError;

		var bufferByteLength = in_buffer.length;
		var newByteLength = len * elementSize;

		var newRange = in_byteOffset + newByteLength;
		if (newRange > bufferByteLength) throw TAError.RangeError;

		view.buffer = in_buffer;
		view.byteOffset = in_byteOffset;
		view.byteLength = newByteLength;
		view.length = Std.int(newByteLength / elementSize);

		return view;
	} // (buffer [, byteOffset [, length]])
}