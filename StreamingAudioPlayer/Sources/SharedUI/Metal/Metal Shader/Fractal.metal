#include <metal_stdlib>
using namespace metal;

// Palette function
float3 palette(float d) {
    return mix(float3(0.2, 0.7, 0.9), float3(1.0, 0.0, 1.0), d);
}

// 2D rotation function
float2 rotate_fractal(float2 p, float a) {
    float c = cos(a);
    float s = sin(a);
    return p * float2x2(c, s, -s, c);
}

// Distance field function
float map(float3 p, float time) {
    p /= 1.0; // Scale position to make object 3 times larger
    for (int i = 0; i < 8; ++i) {
        float t = time * 0.2;
        p.xz = rotate_fractal(p.xz, t);
        p.xy = rotate_fractal(p.xy, t * 1.89);
        p.xz = abs(p.xz);
        p.xz -= 0.5;
    }
    return dot(sign(p), p) / 5.0 * 1.0; // Scale distance to maintain correct ray-marching
}

// Ray-marching function
float4 rm(float3 ro, float3 rd, float time) {
    float t = 0.0;
    float3 col = float3(0.0);
    float d;
    for (float i = 0.0; i < 64.0; i++) {
        float3 p = ro + rd * t;
        d = map(p, time) * 0.5;
        if (d < 0.02) {
            break;
        }
        if (d > 100.0) {
            break;
        }
        col += palette(length(p) * 0.1) / (400.0 * d);
        t += d;
    }
    return float4(col, 1.0 / (d * 100.0));
}

// Fragment shader
[[stitchable]] half4 fractal(float2 position,    // pixel coords (fragCoord)
                                            half4 inColor,      // input color (optional)
                                            float4 bounds,      // view bounds: x,y,width,height
                                            float iTime)        // time in seconds
{
    float2 iResolution = float2(bounds.z, bounds.w);
    float2 uv = (position.xy - iResolution.xy * 0.5) / iResolution.y;

    float3 ro = float3(0.0, 0.0, -50.0);
    ro.xz = rotate_fractal(ro.xz, iTime);

    float3 cf = normalize(-ro);
    float3 cs = normalize(cross(cf, float3(0.0, 1.0, 0.0)));
    float3 cu = normalize(cross(cf, cs));

    float3 uuv = ro + cf * 4.0 + uv.x * cs + uv.y * cu;
    float3 rd = normalize(uuv - ro);

    half4 col = half4(rm(ro, rd, iTime));

    return col;
}
