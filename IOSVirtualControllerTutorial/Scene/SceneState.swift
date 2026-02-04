//
//  SceneState.swift
//  IOSVirtualControllerTutorial
//
//  Created by preticure on 2026/02/04.
//

import RealityKit
import SwiftUI

@Observable
class SceneState {
    var joystickInput: CGPoint = .zero
    var cubeEntity: Entity?
    var cameraEntity: Entity?
    var cameraAngle: CGPoint = .zero
    let cameraDistance: Float = 1.0

    var controllerType: ControllerType = .custom {
        didSet {
            joystickInput = .zero
            switch controllerType {
                case .custom:
                    virtualControllerManager.unregister()
                case .gcVirtual:
                    virtualControllerManager.register()
            }
        }
    }

    let virtualControllerManager = VirtualController()
    private let rotationSpeed: Float = 0.05

    func updateEntityRotation() {
        guard let entity = cubeEntity else { return }

        let input: CGPoint
        switch controllerType {
            case .custom:
                input = joystickInput
            case .gcVirtual:
                input = virtualControllerManager.joystickInput
        }

        let rotationY = Float(input.x) * rotationSpeed
        let rotationX = Float(-input.y) * rotationSpeed

        let currentRotation = entity.transform.rotation
        let yRotation = simd_quatf(angle: rotationY, axis: [0, 1, 0])
        let xRotation = simd_quatf(angle: rotationX, axis: [1, 0, 0])

        entity.transform.rotation = yRotation * currentRotation * xRotation
    }

    func updateCameraPosition() {
        guard let camera = cameraEntity else { return }

        let horizontalAngle = Float(cameraAngle.x)
        let verticalAngle = Float(cameraAngle.y)

        // 垂直角度を制限（-80度〜80度）
        let clampedVertical = max(-.pi * 0.44, min(.pi * 0.44, verticalAngle))

        // 球面座標からカメラ位置を計算
        let x = cameraDistance * cos(clampedVertical) * sin(horizontalAngle)
        let y = cameraDistance * sin(clampedVertical)
        let z = cameraDistance * cos(clampedVertical) * cos(horizontalAngle)

        camera.position = [x, y, z]
        camera.look(at: [0, 0, 0], from: camera.position, relativeTo: nil)
    }
}
