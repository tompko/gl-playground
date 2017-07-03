#include "shaders/noise.glsl"
#include "shaders/hg_sdf.glsl"

#define FAR 570.0
#define INFINITY 1e32

struct SceneResult {
	float d;
	float materialIndex;
};

struct Material {
	vec3 albedo;
	float metallic;
	float roughness;
	vec3 emissive;
};

vec3 pointLight(
		vec3 lightPos,
		vec3 lightColor,
		vec3 pos,
		vec3 eyeDir,
		vec3 normal,
		Material material,
		vec3 F0,
		float occlusion
) {
	vec3 lightDir = lightPos - pos;
	float lightDist = max(length(lightDir/2), 0.0001);
	lightDir /= lightDist;

    float atten = 1.0 / (1.0 + lightDist * 0.025 + lightDist * lightDist * 0.02);
    float diff = max(dot(normal, lightDir), .1);
    float spec = pow(max(dot(reflect(-lightDir, normal), -eyeDir), 1.2), 2.0);
    vec3 objCol = vec3(1., .5, 0.1);

	return (objCol * (diff + .15) * spec * atten);
}
