struct TraceResult {
	float dist;
	vec3 hitPosition;
	float materialIndex;
};

// http://erleuchtet.org/~cupe/permanent/enhanced_sphere_tracing.pdf
float t_min = 0.001;
float t_max = FAR;
const int MAX_ITERATIONS = 90;

#define EPSILON .001
vec3 getNormal(vec3 pos)
{
	vec3 e = vec3(EPSILON, 0.0, 0.0);
	vec3 n;
	n.x = scene(pos + e.xyy).d - scene(pos - e.xyy).d;
	n.y = scene(pos + e.yxy).d - scene(pos - e.yxy).d;
	n.z = scene(pos + e.yyx).d - scene(pos - e.yyx).d;
	return normalize(n);
}

float softShadow(vec3 ro, vec3 lp, float k) {
    const int maxIterationsShad = 20;
    vec3 rd = (lp - ro); // Unnormalized direction ray.

    float shade = .9;
    float dist = 0.25;
    float end = max(length(rd), 0.001);
    float stepDist = end / float(maxIterationsShad);

    rd /= end;
    for (int i = 0; i < maxIterationsShad; i++) {
        float h = scene(ro + rd * dist).d;
        shade = min(shade, k*h/dist);

        dist += min(h, stepDist * 2.); 
        if (h < 0.001 || dist > end) break;
    }
    return min(max(shade, 0.7), 1.0);
}

float getAO(vec3 hitp, vec3 normal, float dist)
{
    float sdist = scene(hitp + normal * dist).d;
    return clamp(sdist / dist, 0.1, 1.0);
}

TraceResult trace(vec3 o, vec3 d) {
    float omega = 1.3;
    float t = t_min;
    float candidate_error = INFINITY;
    float candidate_t = t_min;
	TraceResult candidate = TraceResult(0., vec3(0.), 0.);
    float previousRadius = 0.;
    float stepLength = 0.;
    float pixelRadius = 0.001;
    float functionSign = sgn(scene(o).d);
    SceneResult mp;

    for (int i = 0; i < MAX_ITERATIONS; ++i) {
        mp = scene(d * t + o);
        float signedRadius = functionSign * mp.d;
        float radius = abs(signedRadius);
        bool sorFail = omega > 1. &&
        (radius + previousRadius) < stepLength;
        if (sorFail) {
            stepLength -= omega * stepLength;
            omega = 1.;
        } else {
			stepLength = signedRadius * omega;
        }
        previousRadius = radius;
        float error = radius / t;
        if (!sorFail && error < candidate_error) {
            candidate_t = t;
			candidate = TraceResult(t, d*t+o, mp.materialIndex);
            candidate_error = error;
        }
        if (!sorFail && error < pixelRadius || t > t_max) break;
        t += stepLength;
   	}
    if ((t > t_max || candidate_error > pixelRadius)) {
		return TraceResult(INFINITY, vec3(0.), 0.);
	}

	return candidate;
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy - .5;

    uv *= tan(radians (FOV) / 2.0) * 1.1;

    float 
        sk = sin(-t * .1) * 82.0, 
        ck = cos(-t * .1) * 82.0,
    	sh,
        ao,
        fog;

    vec3 
        vuv = vec3(0., 1., -0.), // up
    	ro = vec3(ck, 20., sk) + vec3(iMouse.x / 20.,iMouse.y / 10. - 1., 1.), // pos
    	vrp =  vec3(0., 0., 0.),
    	vpn = normalize(vrp - ro),
    	u = normalize(cross(vuv, vpn)),
    	v = cross(vpn, u),
    	vcv = (ro + vpn),
    	scrCoord = (vcv + uv.x * u * iResolution.x/iResolution.y + uv.y * v),
    	rd = normalize(scrCoord - ro),
    	sceneColor = rd,
        p2,
        sn;
	TraceResult tr = trace(ro, rd);
    
    ro += rd * tr.dist;
    
    sn = getNormal(ro);

    fog = smoothstep(FAR * FOG, 0., tr.dist) * 1.,
    sh = softShadow(ro, light, 2.),
    ao = getAO(ro, sn, 1.2);

    ao *= 1. + saturate(getAO(ro + sn * .2, sn, 0.5));
    ao *= saturate(getAO(ro + sn * 1.03, sn, 14.05));

	vec3 background = backgroundColour(rd);

    if (tr.dist < FAR) { 
		Material mat = sceneMaterial(tr.materialIndex);
        sceneColor = saturate(
			illuminatePoint(ro, rd, sn, mat, vec3(0.04), ao)
		);
        sceneColor *= ao;
        sceneColor *= sh;
        sceneColor = mix(sceneColor, background, saturate(tr.dist * 4.2 / FAR));
    } else {
        sceneColor = background;
    }

    fragColor = vec4(clamp(sceneColor, 0., 1.), 1.);
}
