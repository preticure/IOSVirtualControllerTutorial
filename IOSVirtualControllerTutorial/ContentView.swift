//
//  ContentView.swift
//  IOSVirtualController
//
//  Created by preticure on 2026/02/04.
//

import RealityKit
import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()

    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let mesh = MeshResource.generateBox(size: 0.2, cornerRadius: 0.005)
                let material = SimpleMaterial(color: .blue, isMetallic: false)
                let model = ModelEntity(mesh: mesh, materials: [material])

                content.add(model)
                viewModel.cubeEntity = model
            }
            .onChange(of: timeline.date) {
                viewModel.updateEntityPosition()
            }
            .overlay(alignment: .bottomLeading) {
                JoystickView(joystickInput: $viewModel.joystickInput)
            }
        }
    }
}

#Preview {
    ContentView()
}
