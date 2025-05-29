//
//  MetalView.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 09/04/2025.
//

import ComposableArchitecture
import MetalKit
import SwiftUI

struct MetalView: UIViewRepresentable {
    let renderingClient: any MetalRenderingClient

    init?(fragmentFunction: String) {
        if let renderingUseCase = try? DefaultMetalRenderingClient(
            mtkView: MTKView(),
            fragmentFunction: fragmentFunction) {
            self.renderingClient = renderingUseCase
        } else {
            return nil
        }
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false

        do {
            try renderingClient.configure(mtkView: mtkView)
        } catch {
            print("Failed to configure MetalView: \(error)")
        }

        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan))
        mtkView.addGestureRecognizer(panGesture)

        return mtkView
    }

    func updateUIView(_: MTKView, context _: Context) {
        // No updates needed for now
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(renderingUseCase: renderingClient)
    }

    class Coordinator {
        private let renderingUseCase: any MetalRenderingClient

        init(renderingUseCase: any MetalRenderingClient) {
            self.renderingUseCase = renderingUseCase
        }

        @objc func handlePan(gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            let isDown = (gesture.state == .began || gesture.state == .changed)
            renderingUseCase.updateMouse(location: location, isDown: isDown)
        }
    }
}

#Preview {
    MetalView(fragmentFunction: "fragment_main_matrix")
}
