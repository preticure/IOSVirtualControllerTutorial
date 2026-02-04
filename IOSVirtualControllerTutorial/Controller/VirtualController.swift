//
//  VirtualControllerManager.swift
//  IOSVirtualControllerTutorial
//
//  Created by preticure on 2026/02/04.
//

import GameController
import SwiftUI

@Observable
class VirtualController {
    var joystickInput: CGPoint = .zero

    private var virtualController: GCVirtualController?

    func register() {
        let virtualConfiguration = GCVirtualController.Configuration()
        virtualConfiguration.elements = [GCInputLeftThumbstick]

        virtualController = GCVirtualController(configuration: virtualConfiguration)

        virtualController?.connect { [weak self] error in
            if let error {
                print("Failed to connect virtual controller: \(error)")
                return
            }
            self?.setupHandlers()
        }
    }

    func unregister() {
        virtualController?.disconnect()
        virtualController = nil
        joystickInput = .zero
    }

    private func setupHandlers() {
        guard let controller = virtualController?.controller else { return }

        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = {
            [weak self] _, xValue, yValue in
            self?.joystickInput = CGPoint(x: CGFloat(xValue), y: CGFloat(yValue))
        }
    }
}
