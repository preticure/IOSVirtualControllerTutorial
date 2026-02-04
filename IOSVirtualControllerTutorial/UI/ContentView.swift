//
//  ContentView.swift
//  IOSVirtualController
//
//  Created by preticure on 2026/02/04.
//

import RealityKit
import SwiftUI

struct ContentView: View {
    @State private var sceneState = SceneState()
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
                    sceneState.cubeEntity = model

                    let camera = Entity()
                    camera.components.set(PerspectiveCameraComponent())
                    camera.position = [0, 0, sceneState.cameraDistance]
                    camera.look(at: [0, 0, 0], from: camera.position, relativeTo: nil)
                    content.add(camera)
                    sceneState.cameraEntity = camera
                }
                .onChange(of: timeline.date) {
                    sceneState.updateEntityRotation()
                    sceneState.updateCameraPosition()
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let sensitivity: CGFloat = 0.01
                            sceneState.cameraAngle = CGPoint(
                                x: dragStartAngle.x + value.translation.width * sensitivity,
                                y: dragStartAngle.y - value.translation.height * sensitivity
                            )
                        }
                        .onEnded { _ in
                            dragStartAngle = sceneState.cameraAngle
                        }
                )
            }

            VStack {
                Picker("Controller", selection: $sceneState.controllerType) {
                    ForEach(ControllerType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .frame(maxWidth: 300)

                Spacer()

                if sceneState.controllerType == .custom {
                    HStack {
                        CustomControllerView(joystickInput: $sceneState.joystickInput)
                            .padding(40)
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            sceneState.controllerType = .gcVirtual
        }
    }
}

#Preview {
    ContentView()
}
