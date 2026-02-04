//
//  GameViewModel.swift
//  IOSVirtualControllerTutorial
//
//  Created by preticure on 2026/02/04.
//

import RealityKit
import SwiftUI

@Observable
class GameViewModel {
    var joystickInput: CGPoint = .zero
    var cubeEntity: Entity?
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
    private let moveSpeed: Float = 0.02

    func updateEntityPosition() {
        guard let entity = cubeEntity else { return }

        let input: CGPoint
        switch controllerType {
        case .custom:
            input = joystickInput
        case .gcVirtual:
            input = virtualControllerManager.joystickInput
        }

        let deltaX = Float(input.x) * moveSpeed
        let deltaZ = Float(-input.y) * moveSpeed

        entity.position.x += deltaX
        entity.position.z += deltaZ
    }
}
