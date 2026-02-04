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
    @State private var dragStartAngle: CGPoint = .zero

    var body: some View {
        ZStack {
            TimelineView(.animation) { timeline in
                RealityView { content in
                    let mesh = MeshResource.generateBox(size: 0.35, cornerRadius: 0.01)
                    let material = SimpleMaterial(color: .blue, isMetallic: false)
                    let model = ModelEntity(mesh: mesh, materials: [material])

                    model.components.set(
                        ModelDebugOptionsComponent(visualizationMode: .normal)
                    )

                    content.add(model)
                    viewModel.cubeEntity = model

                    let camera = Entity()
                    camera.components.set(PerspectiveCameraComponent())
                    camera.position = [0, 0, viewModel.cameraDistance]
                    camera.look(at: [0, 0, 0], from: camera.position, relativeTo: nil)
                    content.add(camera)
                    viewModel.cameraEntity = camera
                }
                .onChange(of: timeline.date) {
                    viewModel.updateEntityRotation()
                    viewModel.updateCameraPosition()
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let sensitivity: CGFloat = 0.01
                            viewModel.cameraAngle = CGPoint(
                                x: dragStartAngle.x + value.translation.width * sensitivity,
                                y: dragStartAngle.y - value.translation.height * sensitivity
                            )
                        }
                        .onEnded { _ in
                            dragStartAngle = viewModel.cameraAngle
                        }
                )
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
