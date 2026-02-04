//
//  GameViewController.swift
//  IOSVirtualControllerTutorial
//
//  Created by preticure on 2026/02/04.
//

import GameController
import SwiftUI
import UIKit

class GameViewController: GCEventViewController {
    private var hostingController: UIHostingController<ContentView>!

    override func viewDidLoad() {
        super.viewDidLoad()

        hostingController = UIHostingController(rootView: ContentView())

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
