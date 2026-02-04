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

    private let moveSpeed: Float = 0.02

    func updateEntityPosition() {
        guard let entity = cubeEntity else { return }

        let deltaX = Float(joystickInput.x) * moveSpeed
        let deltaZ = Float(-joystickInput.y) * moveSpeed

        entity.position.x += deltaX
        entity.position.z += deltaZ
    }
}
