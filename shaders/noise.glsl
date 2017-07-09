float hash12(vec2 p) {
		float h = dot(p,vec2(127.1,311.7));
    return fract(sin(h)*43758.5453123);
}

// 3d noise
float noise_3(in vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
		vec3 u = f*f*(3.0-2.0*f);

    vec2 ii = i.xy + i.z * vec2(5.0);
    float a = hash12( ii + vec2(0.0,0.0) );
		float b = hash12( ii + vec2(1.0,0.0) );
    float c = hash12( ii + vec2(0.0,1.0) );
		float d = hash12( ii + vec2(1.0,1.0) );
    float v1 = mix(mix(a,b,u.x), mix(c,d,u.x), u.y);

    ii += vec2(5.0);
    a = hash12( ii + vec2(0.0,0.0) );
		b = hash12( ii + vec2(1.0,0.0) );
    c = hash12( ii + vec2(0.0,1.0) );
		d = hash12( ii + vec2(1.0,1.0) );
    float v2 = mix(mix(a,b,u.x), mix(c,d,u.x), u.y);

    return max(mix(v1,v2,u.z),0.0);
}

float fbm(vec3 x)
{
    float r = 0.0;
    float w = 1.0, s = 1.0;
    for (int i=0; i<5; i++)
    {
        w *= 0.5;
        s *= 2.0;
        r += w * noise_3(s * x);
    }
    return r;
}
