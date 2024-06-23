package funkin.vis.grig.audio;

class ComplexType {
	public var real:Float;
	public var imag:Float;

	public function new(real:Float, imag:Float) {
		this.real = real;
		this.imag = imag;
	}
}

abstract Complex(ComplexType) from ComplexType to ComplexType
{
	public var real(get, set):Float;
	public var imag(get, set):Float;

	inline function get_real():Float
	{
		return this.real;
	}

	inline function set_real(n:Float)
	{
		return this.real = n;
	}

	inline function get_imag():Float
	{
		return this.imag;
	}

	inline function set_imag(n:Float)
	{
		return this.imag = n;
	}

	/**
		Constructs a complex number
	**/
	inline public function new(real:Float, imag:Float)
	{
		this = new ComplexType(real, imag);
	}

	inline function toString():String
	{
		return "(" + this.real + "," + this.imag + ")";
	}

	@:op(A + B)
	inline function sum(z:Complex):Complex
	{
		return new Complex(this.real + z.real, this.imag + z.imag);
	}

	@:op(A += B)
	inline function sumAssign(z:Complex):Complex
	{
		this.real = this.real + z.real;
		this.imag = this.imag + z.imag;
		return this;
	}

	@:op(A + B)
	inline function sumWithFloat(x:Float):Complex
	{
		return new Complex(this.real + x, this.imag);
	}

	@:op(A += B)
	inline function sumWithFloatAssign(x:Float):Complex
	{
		this.real = this.real + x;
		return this;
	}

	@:op(A - B)
	inline function subWithFloat(x:Float):Complex
	{
		return new Complex(this.real - x, this.imag);
	}

	@:op(A -= B)
	inline function subWithFloatAssign(x:Float):Complex
	{
		this.real = this.real - x;
		return this;
	}

	@:op(A - B)
	inline function sub(z:Complex):Complex
	{
		return new Complex(this.real - z.real, this.imag - z.imag);
	}
	@:op(A -= B)
	inline function subAssign(z:Complex):Complex
	{
		this.real = this.real - z.real;
		this.imag = this.imag - z.imag;
		return this;
	}

	@:op(A * B)
	inline function mul(z:Complex):Complex
	{
		return new Complex((this.real * z.real) - (this.imag * z.imag), (this.real * z.imag) + (this.imag * z.real));
	}

	@:op(A *= B)
	inline function mulAssign(z:Complex):Complex
	{
		var real = this.real;
		var imag = this.imag;
		this.real = (real * z.real) - (imag * z.imag);
		this.imag = (real * z.imag) + (imag * z.real);
		return this;
	}

	@:op(A * B)
	inline function mulWithFloat(x:Float):Complex
	{
		return new Complex(this.real * x, this.imag * x);
	}

	@:op(A *= B)
	inline function mulWithFloatAssign(x:Float):Complex
	{
		this.real = this.real * x;
		this.imag = this.imag * x;
		return this;
	}

	@:op(A / B)
	inline function div(z:Complex):Complex
	{
		var d = Complex.abs(z);
		return new Complex((this.real * z.real + this.imag * z.imag) / d, (this.imag * z.real - this.real * z.imag) / d);
	}

	@:op(A /= B)
	inline function divAssign(z:Complex):Complex
	{
		var d = Complex.abs(z);
		var real = this.real;
		var imag = this.imag;
		this.real = (real * z.real + imag * z.imag) / d;
		this.imag = (imag * z.real - real * z.imag) / d;
		return this;
	}

	@:op(A /= B)
	inline function divWithFloatAssign(x:Float):Complex
	{
		this.real = this.real / x;
		this.imag = this.imag / x;
		return this;
	}

	// Assignment Operators

	@:op(A == B)
	inline function equals(z:Complex):Bool
	{
		return this.real == z.real && this.imag == z.imag;
	}

	@:op(A != B)
	inline function notEquals(z:Complex):Bool
	{
		return this.real != z.real || this.imag != z.imag;
	}

	/**
		Constructs a complex number from magnitude and phase angle
	**/
	public static inline function fromPolar(norm:Float, phi:Float)
	{
		return new Complex(norm * Math.cos(phi), norm * Math.sin(phi));
	}

	/**
		Returns the magnitude of a complex number
	**/
	public static inline function abs(z:Complex):Float
	{
		return Math.sqrt(norm(z));
	}

	/**
		Returns the squared magnitude
	**/
	public static inline function norm(z:Complex):Float
	{
		return z.real * z.real + z.imag * z.imag;
	}

	public static inline function arg(z:Complex):Float
	{
		return Math.atan2(z.imag, z.real);
	}

	public static inline function sqrt(z:Complex):Complex
	{
		var m = Math.sqrt(Complex.norm(z));
		var a = Complex.arg(z) / 2.0;
		return Complex.fromPolar(m, a);
	}

	public static inline function exp(z:Complex):Complex
	{
		var m = Math.exp(z.real);
		return Complex.fromPolar(m, z.imag);
	}

	public static inline function expPhi(phi:Float):Complex
	{
		return new Complex(Math.cos(phi), Math.sin(phi));
	}

	public static inline function conj(z:Complex):Complex
	{
		return new Complex(z.real, -z.imag);
	}

	public static inline function pow(base:Complex, exponent:Float):Complex
	{
		var m = Complex.abs(base);
		var a = Complex.arg(base);

		var nM = Math.pow(m, exponent);
		var nA = a * exponent;

		return Complex.fromPolar(nM, nA);
	}

	public static inline function log(z:Complex):Complex
	{
		var m = Complex.abs(z);
		var a = Complex.arg(z);
		if (m > 0)
			return new Complex(Math.log(m), a);
		else
			return new Complex(Math.NaN, Math.NaN);
	}
}