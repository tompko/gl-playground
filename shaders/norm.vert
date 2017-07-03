#version 450

in vec2 position;
out vec2 fragCoord;

void main() {
	gl_Position = vec4(position, 0.0, 1.0);
	fragCoord = (position + 1.0) / 2.0;
}
