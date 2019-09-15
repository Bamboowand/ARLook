//
//  ARViewController.swift
//  ARLook
//
//  Created by ChenWei on 2019/9/12.
//  Copyright © 2019 Jacob. All rights reserved.
//

import UIKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    let configuation = ARWorldTrackingConfiguration()
    
    var model: SCNScene?
    @IBOutlet weak var arView: ARSCNView!
    
    // MARK: - View lifecircle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configuation.planeDetection = [.horizontal, .vertical]
        arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        arView.session.run(configuation)
        arView.delegate = self
        arView.scene.physicsWorld.contactDelegate = PhysicsSceneWorldModel.shared
        arView.automaticallyUpdatesLighting = true
        arView.autoenablesDefaultLighting = true
        
        PhysicsSceneWorldModel.shared.worldNode = arView.scene.rootNode
//        arView.showsStatistics = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.restartSession()
        
        guard let modelNode = model?.rootNode.childNodes[0].clone() else {
            fatalError("No found model")
        }
        modelNode.scale = SCNVector3(0.3, 0.3, 0.3)
        modelNode.position = SCNVector3(0, 0, -3)
        modelNode.physicsBody = PhysicsSceneWorldModel.shared.createEnemyBody(shapeNode: modelNode)
        arView.scene.rootNode.addChildNode(modelNode)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.arView.session.pause()
    }
    
    // MARK: - Private methods
    func restartSession() {
        self.arView.session.pause()
        self.arView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
        }
        self.arView.session.run(configuation, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.arView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    // MARK: - TopGestureRecognzier methods
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let (direction, position) = self.getUserVector()
        let bullet = SCNDataModel.shared.createBullet(position: position)
        bullet.physicsBody = PhysicsSceneWorldModel.shared.createBulletBody(shapeNode: bullet, orientation: direction, force: 80.0)
        self.arView.scene.rootNode.addChildNode(bullet)
        bullet.runAction(SCNAction.sequence([SCNAction.wait(duration: 2), SCNAction.removeFromParentNode()]))
        
    }

    // MARK: - ARSCNViewDelegate meyhods
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        node.addChildNode(SCNDataModel.shared.createFloor(planeAnchor: planeAnchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        node.addChildNode(SCNDataModel.shared.createFloor(planeAnchor: planeAnchor))
//        guard let planeAnchor = anchor as? ARPlaneAnchor,
//            let planNode = node.childNodes.first,
//            let plane = planNode.geometry as? SCNPlane else {
//            return
//        }
//        plane.width = CGFloat(planeAnchor.extent.x)
//        plane.width = CGFloat(planeAnchor.extent.z)
//        planNode.position = SCNVector3(CGFloat(planeAnchor.center.x), CGFloat(planeAnchor.center.y), CGFloat(planeAnchor.center.z))
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        node.enumerateChildNodes{ (childNode, _) in
            childNode.removeFromParentNode()
        }
    }

}

// MARK: - Extension
extension Int {
    var degreesToRadians: Double {
        return Double(self) * (.pi / 180)
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
