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
        
        // New variable for triangle base angle (in degrees)
        let triangleBaseAngle: CGFloat = 82 // Adjust this value between 0 and 180

        // Create circle
        let circle = SCNCylinder(radius: circleRadius, height: circleLength)
        let circleNode = SCNNode(geometry: circle)
        circleNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .purple, to: .blue)
        circleNode.geometry?.firstMaterial?.transparency = 0.5
        circleNode.eulerAngles = SCNVector3(Double.pi / 2, 0, 0)
        
        // Create triangle (adjust position and shape)
        let triangleHeight = circleRadius * goldenRatio
        let triangleWidth = 2 * circleRadius * sin(triangleBaseAngle * .pi / 360)
        let triangleGeometry = SCNPyramid(width: triangleWidth, height: triangleHeight, length: circleLength)
        let triangleNode = SCNNode(geometry: triangleGeometry)
        
        // Calculate triangle position
        let triangleYOffset = -circleRadius * cos(triangleBaseAngle * .pi / 360)
        triangleNode.position = SCNVector3(0, triangleYOffset, circleLength / 2)
        triangleNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .orange, to: .yellow)
        triangleNode.geometry?.firstMaterial?.transparency = 0.5
        
        // Calculate square position
        let triangleBase = 2 * circleRadius * sin(triangleBaseAngle * .pi / 360)
        let squareSize = (triangleBase * triangleHeight) / (triangleBase + triangleHeight)
        let square = SCNBox(width: squareSize, height: squareSize, length: circleLength, chamferRadius: 0)
        let squareNode = SCNNode(geometry: square)
        
        // Adjust squareYOffset calculation
        let squareYOffset = triangleYOffset + (squareSize / 2) + 0.001
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
        
        // Add the spiral overlay
        addSpiralOverlay(to: scene, circleRadius: circleRadius, numCircles: numCircles, distanceBetweenCircles: distanceBetweenCircles, squareYOffset: squareYOffset, circleLength: circleLength, scaleFactor: scaleFactor)
        
        // Add the new square with the same area as the large circle
        piRadiusSquared(to: scene, circleRadius: circleRadius, squareSize: squareSize, squareYOffset: squareYOffset, circleLength: circleLength)
        
        // Add new large square based on the adjusted ratio
        squareTheCircle(to: scene, squareYOffset: squareYOffset, targetSceneSize: targetSceneSize, circleLength: circleLength)
        
        // Add new square based on the ratio of smaller shapes and golden ratio
        ratioMethod(to: scene, circleRadius: circleRadius, triangleHeight: triangleHeight, squareYOffset: squareYOffset, circleLength: circleLength)
        
        // Set up the camera (adjust position)
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, -2.4 * scaleFactor, 20 * scaleFactor) // Moved up slightly
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
    
    private func squareTheCircle(to scene: SCNScene, squareYOffset: CGFloat, targetSceneSize: CGFloat, circleLength: CGFloat) {
        
        let largeSquare = SCNBox(width: targetSceneSize, height: targetSceneSize, length: circleLength, chamferRadius: 0)
        let largeSquareNode = SCNNode(geometry: largeSquare)
        
        largeSquareNode.position = SCNVector3(0, squareYOffset, circleLength * 10)
        
        largeSquareNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .blue, to: .yellow)
        largeSquareNode.geometry?.firstMaterial?.transparency = 0.2
        
        scene.rootNode.addChildNode(largeSquareNode)
        
        // Print the values for verification
        print("Perspective Method Side Length: \(targetSceneSize)")
    }
    
    private func ratioMethod(to scene: SCNScene, circleRadius: CGFloat, triangleHeight: CGFloat, squareYOffset: CGFloat, circleLength: CGFloat) {
        let goldenRatio: CGFloat = 1.618
        
        // The triangle's base is equal to the circle's diameter
        let triangleBase = circleRadius * 2
        
        // Calculate the area of the triangle
        let triangleArea = 0.5 * triangleBase * triangleHeight
        
        // Adjust the estimation factor to get closer to the correct area
        let adjustmentFactor: CGFloat =  1.2 // 1.2 will go to 0.999986 and 1.200032 will go to .9999998 and 1.20003203056 goes to 0.9999999999971295 and 7500200191043059/6250000000000000 gives 1.0
        /*
         The 1.2 factor, when combined with φ², very closely approximates π in this specific geometric context. The 1.2 factor emerges as the value that, when multiplied by φ², gives us a close approximation of π.
         This relationship is specific to this geometric setup where:
         The triangle's height is based on the golden ratio
         The triangle's area is being used to estimate the circle's area
         The golden ratio is being used again in the area estimation
         The 1.2 factor effectively "corrects" for the discrepancies introduced by using the golden ratio-based triangle to estimate the circle's area. Thus a simple factor (1.2) can bridge the gap between these complex geometric relationships involving π and φ.
         */
        let estimatedCircleArea = triangleArea * goldenRatio * adjustmentFactor
        
        // Calculate the side length of the square with the estimated area
        let estimatedSquareSideLength = sqrt(estimatedCircleArea) // An actual Renaissance geometer would use the geometric mean instead, but our square root gets us to the same estimation.
        
        print("Ratio-based Method Side Length: \(estimatedSquareSideLength)")
        
        let ratioBasedSquare = SCNBox(width: estimatedSquareSideLength, height: estimatedSquareSideLength, length: circleLength, chamferRadius: 0)
        let ratioBasedSquareNode = SCNNode(geometry: ratioBasedSquare)
        
        ratioBasedSquareNode.position = SCNVector3(0, squareYOffset, circleLength * 10)
        
        ratioBasedSquareNode.geometry?.firstMaterial?.diffuse.contents = createGradientImage(from: .magenta, to: .blue)
        ratioBasedSquareNode.geometry?.firstMaterial?.transparency = 0.2
        
        scene.rootNode.addChildNode(ratioBasedSquareNode)
    }

    private func addSpiralOverlay(to scene: SCNScene, circleRadius: CGFloat, numCircles: Int, distanceBetweenCircles: CGFloat, squareYOffset: CGFloat, circleLength: CGFloat, scaleFactor: CGFloat) {
        let goldenRatio: CGFloat = 1.618
        let initialSpiralRadius: CGFloat = circleRadius
        let rotationsPerCircle: CGFloat = 0.5
        
        func createSpiralPoints(offset: CGFloat) -> [SCNVector3] {
            return (85...numCircles * 100).map { i -> SCNVector3 in
                let t = CGFloat(i) / 100.0
                let angle = t * 2 * .pi * rotationsPerCircle + offset
                let scaleFactor = pow(1 / goldenRatio, t)
                let currentRadius = initialSpiralRadius * scaleFactor
                let x = currentRadius * cos(angle)
                let y = currentRadius * sin(angle) + squareYOffset
                let z = -t * distanceBetweenCircles
                return SCNVector3(x, y, z)
            }
        }
        
        let spiralPoints1 = createSpiralPoints(offset: 0)
        let spiralPoints2 = createSpiralPoints(offset: .pi)
        
        let blueColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
        
        let geometry1 = SCNGeometry.line(points: spiralPoints1, color: blueColor)
        let geometry2 = SCNGeometry.line(points: spiralPoints2, color: blueColor)
        
        let node1 = SCNNode(geometry: geometry1)
        let node2 = SCNNode(geometry: geometry2)
        
        node1.position = SCNVector3(0, 0, circleLength / 2)
        node2.position = SCNVector3(0, 0, circleLength / 2)
        
        scene.rootNode.addChildNode(node1)
        scene.rootNode.addChildNode(node2)
    }
}
    
extension SCNGeometry {
    class func line(points: [SCNVector3], color: NSColor) -> SCNGeometry {
        let source = SCNGeometrySource(vertices: points)
        let element = SCNGeometryElement(indices: Array(0..<Int32(points.count)), primitiveType: .line)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.contents = color
        material.transparency = CGFloat(color.alphaComponent)
        geometry.materials = [material]
        
        return geometry
    }
    
    class func line(from startPoint: SCNVector3, to endPoint: SCNVector3, color: NSColor, width: CGFloat) -> SCNGeometry {
        let vertices: [SCNVector3] = [startPoint, endPoint]
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: [0, 1], primitiveType: .line)
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.contents = color
        geometry.materials = [material]
        
        return geometry
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
