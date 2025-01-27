#pragma header

uniform float borderWidth;
uniform bool borderVisible;

void main()
{
    vec4 textureColor = texture2D(bitmap, openfl_TextureCoordv);
    
    float leftEdge = openfl_TextureCoordv.x;
    float rightEdge = 1.0 - openfl_TextureCoordv.x;
    float topEdge = openfl_TextureCoordv.y;
    float bottomEdge = 1.0 - openfl_TextureCoordv.y;

    if (borderVisible && (leftEdge < borderWidth || rightEdge < borderWidth || topEdge < borderWidth || bottomEdge < borderWidth)) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    } else {
        gl_FragColor = textureColor; // Use original sprite color
    }
}
