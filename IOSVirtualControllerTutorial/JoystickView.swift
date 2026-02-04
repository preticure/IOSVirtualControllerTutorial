//
//  JoystickView.swift
//  IOSVirtualControllerTutorial
//
//  Created by preticure on 2026/02/04.
//

import SwiftUI

struct JoystickView: View {
    @Binding var joystickInput: CGPoint

    private let outerRadius: CGFloat = 75
    private let innerRadius: CGFloat = 30

    @State private var stickPosition: CGPoint = .zero

    var body: some View {
        ZStack {
            // Outer circle (base)
            Circle()
                .fill(Color.black.opacity(0.3))
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: outerRadius * 2, height: outerRadius * 2)

            // Inner circle (stick)
            Circle()
                .fill(Color.white.opacity(0.8))
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                .frame(width: innerRadius * 2, height: innerRadius * 2)
                .offset(x: stickPosition.x, y: stickPosition.y)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation
                    let distance = sqrt(
                        translation.width * translation.width + translation.height
                            * translation.height)
                    let maxDistance = outerRadius - innerRadius

                    if distance <= maxDistance {
                        stickPosition = CGPoint(x: translation.width, y: translation.height)
                    } else {
                        let angle = atan2(translation.height, translation.width)
                        stickPosition = CGPoint(
                            x: cos(angle) * maxDistance,
                            y: sin(angle) * maxDistance
                        )
                    }

                    joystickInput = CGPoint(
                        x: stickPosition.x / maxDistance,
                        y: stickPosition.y / maxDistance
                    )
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        stickPosition = .zero
                    }
                    joystickInput = .zero
                }
        )
    }
}

#Preview {
    ZStack {
        Color.gray
        JoystickView(joystickInput: .constant(.zero))
    }
}
