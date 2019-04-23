//
//  SceneKitViewController.swift
//  iOSTableFinder
//
//  Created by Alexander Koglin on 14.11.18.
//  Copyright © 2018 Alexander Koglin. All rights reserved.
//

import UIKit
import SceneKit
import Foundation

// Next steps: iOS Device, ARKit-Integration
class SceneKitViewControllerVR: MixedRealityViewController {
    
    //nodes
    private var cameraStick:SCNNode!
    private var cameraXHolder:SCNNode!
    private var cameraYHolder:SCNNode!
    
    //movement
    private var controllerStoredDirection = float2(repeating: 0.0)
    private var cameraTouch:UITouch?
    
    var sceneView : SCNView {
        return view as! SCNView
    }
    
    var mainScene: SCNScene!
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupCamera()
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
    
    // MARK: - scene
    private func setupScene() {
        
        mainScene = SCNScene(named: "assets.scnassets/Scenes/RestaurantStage.scn")
        
        sceneView.allowsCameraControl = false
        sceneView.scene = mainScene
        sceneView.isPlaying = true
    }
    
    private func setupTapGestureRecognizer() {
        let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTableGesture(_:)))
        pressGestureRecognizer.minimumPressDuration = 1.0
        pressGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(pressGestureRecognizer)
    }
    
    // MARK: - camera
    private func setupCamera() {
        
        cameraStick = mainScene.rootNode.childNode(withName: "camera", recursively: false)!
        
    }
    
    private func panCameraHorizontally(_ direction:float2) {
        
        var directionToPan = direction
        let panReducer = Float(0.005)
        
        let currX = cameraStick.rotation
        let xRotationValue = currX.w - directionToPan.x * panReducer
        
        cameraStick.rotation = SCNVector4Make(0, 1, 0, xRotationValue)
    }
    
    private func moveCameraHorizontally(_ length:float2) {
        
        let oldPos = cameraStick.position
        
        let attenuationFactor = Float(0.1)
        
        let newPosX = oldPos.x + length.y * sin(cameraStick.rotation.w) * attenuationFactor
        let newPosZ = oldPos.z + length.y * cos(cameraStick.rotation.w) * attenuationFactor
        
        if doesCollide(SCNVector3(newPosX, 0, newPosZ)) {
            return
        }
        
        cameraStick.position.x = newPosX
        cameraStick.position.z = newPosZ
        
    }
    
    private func doesCollide(_ newPos:SCNVector3) -> Bool {
        
        if abs(newPos.x) < 5.0 && abs(newPos.z) < 5.0 {
            return false
        }
        
        return true
    }
    
    // MARK:- touches + movement
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.count > 0 {
            
            if cameraTouch == nil {
                
                cameraTouch = touches.first
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = cameraTouch {
            
            let displacement = float2(repeating: touch.location(in: view)) -
                float2(repeating: touch.previousLocation(in: view))
            
            let vMix = mix(controllerStoredDirection, displacement, t: 0.1)
            let vClamp = clamp(vMix, min: -1.0, max: 1.0)
            
            controllerStoredDirection = vClamp
            
            panCameraHorizontally(displacement)
            moveCameraHorizontally(controllerStoredDirection)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        controllerStoredDirection = float2(repeating: 0.0)
        cameraTouch = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        controllerStoredDirection = float2(repeating: 0.0)
        cameraTouch = nil
    }
    
}

extension SceneKitViewControllerVR : UIGestureRecognizerDelegate {
    
    @objc func handleTableGesture(_ gestureReconizer: UIGestureRecognizer) {
        
        if gestureReconizer.state == .ended {
            let location = gestureReconizer.location(in: sceneView)
            let hits = sceneView.hitTest(location)
            let result = hits.first
            
            if (result != nil) {
            
                removeDeskWithOverlays()
                
                var deskCoords = result!.worldCoordinates
                deskCoords.y = 0.5
                addDesk(at: deskCoords)

                var overlayCoords = result!.worldCoordinates
                overlayCoords.y = 2
                addDeskOverlay(at: overlayCoords)
                
            }
        }
    }
    
    private func addDesk(at pos: SCNVector3) {
        
        let scene = SCNScene(named: "assets.scnassets/Scenes/Desk.scn")

        let deskNode = SCNNode()
        deskNode.name = "desk"
        deskNode.position = pos
        for child: SCNNode in (scene?.rootNode.childNodes)! {
            deskNode.addChildNode(child)
        }
        
        sceneView.scene?.rootNode.addChildNode(deskNode)

    }
        
    private func addDeskOverlay(at pos: SCNVector3) {
        
        let scaleFactor = Float(0.05)
        var boxPosition = SCNVector3(x: pos.x, y: pos.y, z: pos.z)
        boxPosition.y += 1
        
        // add the table overlay box
        let boxGeo = SCNBox(width: 1.0, height: 1.0, length: 0.2, chamferRadius: 0.2)
        
        let boxNode = SCNNode(geometry: boxGeo)
        boxNode.name = "deskOverlay"
        boxNode.position = boxPosition
        boxNode.rotation = cameraStick.rotation
        sceneView.scene?.rootNode.addChildNode(boxNode)
        
        // add the table number to the box
        let textGeo = SCNText(string: "1", extrusionDepth: 8)
        textGeo.firstMaterial?.diffuse.contents = UIColor.black
        textGeo.font = UIFont.init(name: "Helvetica", size: 20)
        textGeo.chamferRadius = 0
        textGeo.flatness = 1
        textGeo.isWrapped = false
        
        let (min, max) = textGeo.boundingBox
        let dx:Float = Float(max.x - min.x)*scaleFactor
        let dy:Float = Float(max.y - min.y)*scaleFactor
        
        let textNode = SCNNode(geometry: textGeo)
        textNode.position = SCNVector3(x: -dx, y: -dy, z: 0)
        textNode.position.y += 0.05
        textNode.scale = SCNVector3Make(scaleFactor, scaleFactor, scaleFactor)
        boxNode.addChildNode(textNode)
        
    }
    
    fileprivate func removeDeskWithOverlays() {
        for childNode: SCNNode in (sceneView.scene?.rootNode.childNodes)! {
            if childNode.name == "desk"
            || childNode.name == "deskOverlay"
            {
                childNode.removeFromParentNode()
            }
        }
    }

}
