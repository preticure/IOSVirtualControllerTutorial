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
        ZStack {
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
            }

            VStack {
                Picker("Controller", selection: $viewModel.controllerType) {
                    ForEach(ControllerType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .frame(maxWidth: 300)

                Spacer()

                if viewModel.controllerType == .custom {
                    HStack {
                        CustomControllerView(joystickInput: $viewModel.joystickInput)
                            .padding(40)
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            viewModel.controllerType = .gcVirtual
        }
    }
}

#Preview {
    ContentView()
}
