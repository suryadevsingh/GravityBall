//
//  ContentView.swift
//  MotionView
//
//  Created by Suryadev Singh on 14/10/23.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    let motionManager = CMMotionManager()
    @State private var ballPosition = CGPoint(x: 0, y: 0)
    
    let circleRadius: CGFloat = 150
    let ballRadius: CGFloat = 25
    
    var body: some View {
        ZStack {
            Circle() // Boundary circle
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: circleRadius * 2, height: circleRadius * 2)
            
            Circle() // Ball
                .fill(Color.blue)
                .frame(width: ballRadius * 2, height: ballRadius * 2)
                .offset(x: ballPosition.x, y: ballPosition.y)
        }
        .onAppear {
            startMotionUpdates()
        }
        .onDisappear {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0  // Request 60 updates per second
            motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
                if let motion = motion {
                    let x = CGFloat(motion.gravity.x) * 30
                    let y = CGFloat(motion.gravity.y) * 30
                    
                    // Determine the potential new position
                    let newX = ballPosition.x + x
                    let newY = ballPosition.y - y
                    
                    // Check if the new position is inside the boundary
                    let distanceFromCenter = distanceBetween(point1: CGPoint(x: 0, y: 0), point2: CGPoint(x: newX, y: newY))
                    if distanceFromCenter <= (circleRadius - ballRadius) {
                        DispatchQueue.main.async {
                            ballPosition = CGPoint(x: newX, y: newY)
                        }
                    } else {
                        // If it's outside, move the ball along the direction but only up to the boundary
                        let angle = atan2(newY, newX)
                        let boundedX = (circleRadius - ballRadius) * cos(angle)
                        let boundedY = (circleRadius - ballRadius) * sin(angle)
                        DispatchQueue.main.async {
                            ballPosition = CGPoint(x: boundedX, y: boundedY)
                        }
                    }
                }
            }
        }
    }
    
    func distanceBetween(point1: CGPoint, point2: CGPoint) -> CGFloat {
        return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2))
    }
}

#Preview {
    ContentView()
}


