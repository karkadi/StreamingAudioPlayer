//
//  to.swift
//  FireSheider
//
//  Created by Arkadiy KAZAZYAN on 28/03/2025.
//

// Define the uniforms struct to match the shader
struct Uniforms {
    var time: Float              // 4 bytes
    var resolution: SIMD2<Float> // 8 bytes
    var mouse: SIMD2<Float>      // 8 bytes
    var mouseDown: Float
    var padding: Float           // 4 bytes (added to reach 24 bytes)
}
