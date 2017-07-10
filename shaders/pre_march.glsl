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

vec3 rotateX(vec3 x, float an)
{
    float c = -cos(an);
    float s = -sin(an);
    return vec3(x.x, x.y * c - x.z * s, x.z * c + x.y * s);
}

vec3 rotateY(vec3 x, float an)
{
    float c = cos(an);
    float s = sin(an);
    return vec3(x.x * c - x.z * s, x.y, x.z * c + x.x * s);
}

vec3 rotateZ(vec3 x, float an)
{
    float c = cos(an);
    float s = sin(an);
    return vec3(x.x * c - x.y * s, x.y * c + x.x * s, x.z);
}
