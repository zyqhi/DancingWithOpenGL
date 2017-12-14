attribute vec4 Position; // 1
attribute vec4 SourceColor; // 2

varying vec4 DestinationColor; // 3

uniform mat4 Projection;
uniform mat4 Modelview;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

void main(void) { // 4
    DestinationColor = SourceColor; // 5
    gl_Position = Projection * Modelview * Position; // 6
    TexCoordOut = TexCoordIn;
}
