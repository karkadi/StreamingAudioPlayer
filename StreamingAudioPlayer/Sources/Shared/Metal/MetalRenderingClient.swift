//
//  MetalRenderingClient.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 09/04/2025.
//

import MetalKit

protocol MetalRenderingClient {
    func configure(mtkView: MTKView) throws
    func updateMouse(location: CGPoint, isDown: Bool)
    func updateResolution(size: CGSize)
    func render(in view: MTKView)
}

final class DefaultMetalRenderingClient: NSObject, MetalRenderingClient, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private var uniformsBuffer: MTLBuffer
    private var time: Float = 0

    init(mtkView: MTKView, fragmentFunction: String) throws {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let library = try? device.makeDefaultLibrary(bundle: .main)
        else { throw MetalError.initializationFailed }

        self.device = device
        self.commandQueue = commandQueue

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: fragmentFunction)
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat

        guard let pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        else { throw MetalError.pipelineCreationFailed }
        self.pipelineState = pipelineState

        var initialUniforms = Uniforms(
            time: 0.0,
            resolution: SIMD2<Float>(Float(mtkView.drawableSize.width), Float(mtkView.drawableSize.height)),
            mouse: SIMD2<Float>(0.0, 0.0),
            mouseDown: 0.0,
            padding: 0
        )
        guard let uniformsBuffer = device.makeBuffer(bytes: &initialUniforms,
                                                     length: MemoryLayout<Uniforms>.size,
                                                     options: .storageModeShared)
        else { throw MetalError.bufferCreationFailed }
        self.uniformsBuffer = uniformsBuffer

        super.init()
    }

    func configure(mtkView: MTKView) throws {
        mtkView.device = device
        mtkView.delegate = self
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    }

    func updateMouse(location: CGPoint, isDown: Bool) {
        let uniforms = uniformsBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
        uniforms[0].mouse = SIMD2<Float>(Float(location.x), Float(location.y))
        uniforms[0].mouseDown = isDown ? 1.0 : 0.0
    }

    func updateResolution(size: CGSize) {
        let uniforms = uniformsBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
        uniforms[0].resolution = SIMD2<Float>(Float(size.width), Float(size.height))
    }

    func render(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else { return }

        let uniforms = uniformsBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
        uniforms[0].time = time

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
        time += 0.01
    }

    // MTKViewDelegate methods
    func mtkView(_: MTKView, drawableSizeWillChange size: CGSize) {
        updateResolution(size: size)
    }

    func draw(in view: MTKView) {
        render(in: view)
    }
}

// Error type for Metal-specific failures
enum MetalError: Error {
    case initializationFailed
    case pipelineCreationFailed
    case bufferCreationFailed
}
