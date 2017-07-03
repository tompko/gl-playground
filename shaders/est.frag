#version 450

uniform float iGlobalTime;
uniform ivec2 iResolution;
uniform ivec2 iMouse;

in vec2 fragCoord;
out vec4 fragColor;

#include "shaders/pre_march.glsl"

#define FAR 570.0
#define INFINITY 1e32
#define t iGlobalTime

#define FOV 80.0
#define FOG 1.0

vec3 light = vec3(20., 4., -10.);

SceneResult scene(vec3 o) {
	float d = min(fSphere(o, 10.0), abs(o.y+10.));
	return SceneResult(d, 2.0);
}

Material sceneMaterial(float materialIndex) {
	return Material(
		vec3(1.0),
		0.5,
		0.5,
		vec3(0.0)
	);
}

vec3 backgroundColour(vec3 eyeDir) {
	return vec3(0.012);
}

vec3 illuminatePoint(
		vec3 pos,
		vec3 eyeDir,
		vec3 normal,
		Material material,
		vec3 F0,
		float occlusion) {
	return pointLight(
		light,
		vec3(1.),
		pos,
		eyeDir,
		normal,
		material,
		F0,
		occlusion
	);
}

#include "shaders/post_march.glsl"
