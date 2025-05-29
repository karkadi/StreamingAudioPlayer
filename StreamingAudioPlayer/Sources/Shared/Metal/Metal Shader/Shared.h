
#pragma once

#include <metal_stdlib>

struct Uniforms {
    float time;
    float2 resolution;
    float2 mouse;
};

struct FragmentInput {
    float4 position [[position]];
};
