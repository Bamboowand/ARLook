//
//  SCNDataModel.swift
//  ARLook
//
//  Created by ChenWei on 2019/9/11.
//  Copyright © 2019 Jacob. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

struct SCNData {
    var name: String
    var scene: SCNScene
    var image: UIImage
}

class SCNDataModel {
    static let shared = SCNDataModel()
    
    private(set) var models = [SCNData]()
    let arModeTitle = ["平面偵測", "圖像偵測"]
    let assets = "Assets.scnassets"
    private init() {
        guard let path = Bundle.main.path(forResource: assets, ofType: nil) else {
            fatalError("Not found" + assets)
        }
        do {
            let scnList = try FileManager.default.contentsOfDirectory(atPath: path)
            for fileName in scnList {
                guard let fileScn = SCNScene(named: fileName, inDirectory: assets, options: nil) else {
                    fatalError(fileName + "can't convert SCNScene")
                    continue
                }

                let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
                renderer.scene = fileScn
                
                let renderTime = TimeInterval(0)
                // Output size
                let size = CGSize(width: 100, height: 100)
                
                // Render the image
                let image = renderer.snapshot(atTime: renderTime, with: size,
                                              antialiasingMode: SCNAntialiasingMode.multisampling4X)
                models.append(SCNData(name: fileName, scene: fileScn, image: image))
            }
        }
        catch {
            fatalError(assets + "doesn't exist")
        }
    }
    
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let planeNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        let meterial = SCNMaterial()
        meterial.diffuse.contents = UIImage(named: "TexturesCom_WoodRough0009_S.jpg")
        meterial.locksAmbientWithDiffuse = true
        meterial.isDoubleSided = true
        //        planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "TexturesCom_WoodRough0009_S.jpg")
        //        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.geometry?.materials = [meterial]
        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x), CGFloat(planeAnchor.center.y), CGFloat(planeAnchor.center.z))
        planeNode.eulerAngles = SCNVector3(-90.degreesToRadians, 0, 0)
        let staticBody = SCNPhysicsBody.static()
        staticBody.physicsShape = SCNPhysicsShape(node: planeNode, options: nil)
        planeNode.physicsBody = staticBody
        return planeNode
    }
    
    func createBullet(position: SCNVector3) -> SCNNode {
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.2))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bullet.geometry?.firstMaterial?.emission.contents = UIColor.red
        bullet.position = position
        return bullet
    }
    
    
    
}
