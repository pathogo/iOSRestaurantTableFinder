//
//  SceneKitViewControllerAR.swift
//  iOSTableFinder
//
//  Created by Alexander Koglin on 14.11.18.
//  Copyright © 2018 Alexander Koglin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Foundation

class SceneKitViewControllerAR: MixedRealityViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    var cameraDirection: SCNVector3?;
    
    var sceneView : ARSCNView {
        return view as! ARSCNView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let boxGeometry = SCNBox(width: 1000.0, height: 1000.0, length: 10.0, chamferRadius: 1.0)
        let boxNode = SCNNode(geometry: boxGeometry)
        scene.rootNode.addChildNode(boxNode)
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        setupTapGestureRecognizer()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func setupTapGestureRecognizer() {
        
        let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTableGesture(_:)))
        pressGestureRecognizer.minimumPressDuration = 1.0
        pressGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(pressGestureRecognizer)
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor(displayP3Red: 1, green: 0.5, blue: 3, alpha: 0.3)
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
}


extension SceneKitViewControllerAR : UIGestureRecognizerDelegate {
    
    @objc func handleTableGesture(_ recognizer: UIGestureRecognizer) {
        
        if recognizer.state == .ended {
            
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.columns.3
            let x = translation.x
            let y = translation.y
            let z = translation.z
            
            removeDeskWithOverlays()
            addDesk(at: SCNVector3(x,y,z))
            addDeskOverlay(at: SCNVector3(x,y,z))
            
        }
    }
    
    private func addDesk(at pos: SCNVector3) {
        
        let scene = SCNScene(named: "assets.scnassets/Scenes/Desk.scn")

        var deskPosition = SCNVector3(x: pos.x, y: pos.y, z: pos.z)
        deskPosition.y += 0.2

        let deskNode = SCNNode()
        deskNode.name = "desk"
        deskNode.physicsBody = .static()
        deskNode.physicsBody?.allowsResting = true
        deskNode.physicsBody?.isAffectedByGravity = false
        deskNode.scale = SCNVector3Make(Float(0.1), Float(0.1), Float(0.1))
        deskNode.position = pos
        for child: SCNNode in (scene?.rootNode.childNodes)! {
            deskNode.addChildNode(child)
        }
        
        sceneView.scene.rootNode.addChildNode(deskNode)
        
    }
        
    private func addDeskOverlay(at pos: SCNVector3) {
        
        let scaleFactor = Float(0.03)
        var boxPosition = SCNVector3(x: pos.x, y: pos.y, z: pos.z)
        boxPosition.y += 0.2
        
        // add the table overlay box
        let boxGeo = SCNBox(width: 1.0, height: 1.0, length: 0.2, chamferRadius: 0.2)
        
        //print("Coordinates: \(cameraDirection!.x), \(cameraDirection!.y), \(cameraDirection!.z)")
        
        let boxNode = SCNNode(geometry: boxGeo)
        boxNode.name = "deskOverlay"
        boxNode.position = boxPosition
        boxNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
        let normalizedX = cameraDirection!.x / (cameraDirection!.x + cameraDirection!.z)
        let normalizedZ = cameraDirection!.z / (cameraDirection!.x + cameraDirection!.z)
        let w = (normalizedX<0 ? -1 : 1) * acos(normalizedZ / (sqrt(pow(normalizedX,2) + pow(normalizedZ,2))))
        print("Width: \(Double(w))")
        boxNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: w)
        sceneView.scene.rootNode.addChildNode(boxNode)
        
        // add the table number to the box
        let textGeo = SCNText(string: "1", extrusionDepth: 8)
        textGeo.firstMaterial?.diffuse.contents = UIColor.black
        textGeo.font = UIFont.init(name: "Helvetica", size: 30)
        textGeo.chamferRadius = 0
        textGeo.flatness = 1
        textGeo.isWrapped = false
        
        let (min, max) = textGeo.boundingBox
        let dx:Float = Float(max.x - min.x)*scaleFactor
        let dy:Float = Float(max.y - min.y)*scaleFactor
        
        let textNode = SCNNode(geometry: textGeo)
        textNode.position = SCNVector3(x: -dx, y: -dy + 0.1, z: 0)
        textNode.scale = SCNVector3Make(scaleFactor, scaleFactor, scaleFactor)
        boxNode.addChildNode(textNode)
        
    }
    
    fileprivate func removeDeskWithOverlays() {
        for childNode: SCNNode in (sceneView.scene.rootNode.childNodes) {
            if childNode.name == "desk"
                || childNode.name == "deskOverlay"
            {
                childNode.removeFromParentNode()
            }
        }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        var xFovDegrees: Float?;
        var yFovDegrees: Float?;
        
        if xFovDegrees == nil || yFovDegrees == nil {
            let imageResolution = frame.camera.imageResolution
            let intrinsics = frame.camera.intrinsics
            xFovDegrees = 2 * atan(Float(imageResolution.width) / (2 * intrinsics[0,0])) * 180 / Float.pi
            yFovDegrees = 2 * atan(Float(imageResolution.height) / (2 * intrinsics[1,1])) * 180 / Float.pi
        }
        
        let cameraTransform = SCNMatrix4(frame.camera.transform)
        cameraDirection = SCNVector3(-1 * cameraTransform.m31,
                                         -1 * cameraTransform.m32,
                                         -1 * cameraTransform.m33)
    }

}
