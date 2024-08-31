//
//  PhilosophersStoneApp.swift
//  PhilosophersStone
//
//  Created by Ryan Davis on 8/29/24.
//


import SwiftUI
import SceneKit

struct ContentView: View {
    var body: some View {
        SceneKitView()
            .frame(width: 1000, height: 1000)
    }
}

struct SceneKitView: NSViewRepresentable {
    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = SCNScene()
        let goldenRatio: CGFloat = 1.618
        
        // Updated scale factor calculation
        let targetSceneSize: CGFloat = 1.0
        // goldenRatio * 6.57 is an approximation of 10.634723105433096
        let referenceSize: CGFloat = 10.634723105433096 //goldenRatio * 6.57
        let scaleFactor: CGFloat = targetSceneSize / referenceSize
        
        // Constants adjusted with scale factor
        let circleRadius: CGFloat = 6.0 * scaleFactor
        let circleLength: CGFloat = 0.1 * scaleFactor
        
        // Create circle
        let circle = SCNCylinder(radius: circleRadius, height: circleLength)
        let circleNode = SCNNode(geometry: circle)
        circleNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .purple, to: .blue)
        circleNode.geometry?.firstMaterial?.transparency = 0.5
        circleNode.eulerAngles = SCNVector3(Double.pi / 2, 0, 0)
        
        // Create triangle (adjust position)
        let triangleHeight = circleRadius * goldenRatio
        let triangleWidth = circleRadius * sqrt(2)
        let triangleGeometry = SCNPyramid(width: triangleWidth, height: triangleHeight, length: circleLength)
        let triangleNode = SCNNode(geometry: triangleGeometry)
        triangleNode.position = SCNVector3(0, -circleRadius * 0.7, circleLength / 2)
        triangleNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .orange, to: .yellow)
        triangleNode.geometry?.firstMaterial?.transparency = 0.5
        
        // Create square (adjust size and position)
        let squareSize = triangleWidth * (goldenRatio / 3)
        let square = SCNBox(width: squareSize, height: squareSize, length: circleLength, chamferRadius: 0)
        let squareNode = SCNNode(geometry: square)
        let squareYOffset = -circleRadius * 0.75 + (triangleHeight - squareSize) / 2
        squareNode.position = SCNVector3(0, squareYOffset, circleLength / 2)
        squareNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .blue, to: .purple)
        squareNode.geometry?.firstMaterial?.transparency = 0.2
        
        // Add nodes to the scene
        scene.rootNode.addChildNode(circleNode)
        scene.rootNode.addChildNode(triangleNode)
        scene.rootNode.addChildNode(squareNode)
        
        // Add additional circles behind the original circle (adjust distances)
        let numCircles = 25
        let distanceBetweenCircles: CGFloat = 20.0 * scaleFactor
        let distanceForFirstCircle: CGFloat = 20.0 * scaleFactor
        let scaleForFirstCircle: CGFloat = squareSize / circleRadius
        
        for i in 0..<numCircles {
            let distance = distanceForFirstCircle + CGFloat(i) * distanceBetweenCircles
            let scale = scaleForFirstCircle / pow(goldenRatio, CGFloat(i))
            let backCircle = SCNCylinder(radius: circleRadius * scale, height: circleLength)
            let backCircleNode = SCNNode(geometry: backCircle)
            backCircleNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .purple, to: .blue)
            backCircleNode.geometry?.firstMaterial?.transparency = 0.5
            backCircleNode.eulerAngles = SCNVector3(Double.pi / 2, 0, 0)
            backCircleNode.position = SCNVector3(0, squareYOffset, -distance)
            
            scene.rootNode.addChildNode(backCircleNode)
        }
        
        // Add the new square with the same area as the large circle
        piRadiusSquared(to: scene, circleRadius: circleRadius, squareSize: squareSize, squareYOffset: squareYOffset, circleLength: circleLength)
        
        // Add new large square based on the adjusted ratio
        squareTheCircle(to: scene, smallSquareSize: squareSize, squareYOffset: squareYOffset, targetSceneSize: targetSceneSize, circleLength: circleLength)
        
        // Set up the camera (adjust position)
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, -2 * scaleFactor, 20 * scaleFactor)
        scene.rootNode.addChildNode(cameraNode)
        
        // Set up lighting (adjust position)
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, 10 * scaleFactor, 10 * scaleFactor)
        scene.rootNode.addChildNode(lightNode)
        
        // Set the scene to the view
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        
        // Add gradient background
        scnView.backgroundColor = NSColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = scnView.bounds
        gradientLayer.colors = [NSColor.cyan.cgColor, NSColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        scnView.layer?.insertSublayer(gradientLayer, at: 0)
        
        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {}
    
    private func createGradientImage(from startColor: NSColor, to endColor: NSColor) -> NSImage {
        let size = NSSize(width: 256, height: 256)
        let image = NSImage(size: size)
        image.lockFocus()
        
        let gradient = NSGradient(colors: [startColor, endColor])!
        gradient.draw(in: NSRect(origin: .zero, size: size), angle: 90)
        
        image.unlockFocus()
        return image
    }
    
    private func piRadiusSquared(to scene: SCNScene, circleRadius: CGFloat, squareSize: CGFloat, squareYOffset: CGFloat, circleLength: CGFloat) {
        // Calculate the area of the large circle
        let largeCircleArea = CGFloat.pi * circleRadius * circleRadius
        
        // Calculate the side length of the square with the same area
        let equalAreaSquareSideLength = sqrt(largeCircleArea)
        
        print("Pi R Squared Side Length: \(equalAreaSquareSideLength)")

        let equalAreaSquare = SCNBox(width: equalAreaSquareSideLength, height: equalAreaSquareSideLength, length: circleLength, chamferRadius: 0)
        let equalAreaSquareNode = SCNNode(geometry: equalAreaSquare)

        equalAreaSquareNode.position = SCNVector3(0, squareYOffset, circleLength * 10)

        equalAreaSquareNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .green, to: .yellow)
        equalAreaSquareNode.geometry?.firstMaterial?.transparency = 0.2

        scene.rootNode.addChildNode(equalAreaSquareNode)
    }
    
    private func squareTheCircle(to scene: SCNScene, smallSquareSize: CGFloat, squareYOffset: CGFloat, targetSceneSize: CGFloat, circleLength: CGFloat) {

        let largeSquare = SCNBox(width: targetSceneSize, height: targetSceneSize, length: circleLength, chamferRadius: 0)
        let largeSquareNode = SCNNode(geometry: largeSquare)

        largeSquareNode.position = SCNVector3(0, squareYOffset, circleLength * 10)

        largeSquareNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .red, to: .orange)
        largeSquareNode.geometry?.firstMaterial?.transparency = 0.2

        scene.rootNode.addChildNode(largeSquareNode)

        // Print the values for verification
        print("Perspective Method Side Length: \(targetSceneSize)")
    }
}

@main
struct PhilosophersStone: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
