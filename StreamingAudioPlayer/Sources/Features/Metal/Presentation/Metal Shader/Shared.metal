//
//  Shared.metal
//  FireSheider
//
//  Created by Arkadiy KAZAZYAN on 31/03/2025.
//

#include "Shared.h"

vertex FragmentInput vertex_main(uint vertexID [[vertex_id]]) {
    float4 vertices[] = {
        float4(-1.0, -1.0, 0.0, 1.0),
        float4( 1.0, -1.0, 0.0, 1.0),
        float4(-1.0,  1.0, 0.0, 1.0),
        float4( 1.0,  1.0, 0.0, 1.0)
    };
    return { vertices[vertexID] };
}
