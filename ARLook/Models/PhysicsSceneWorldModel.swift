//
//  PhysicsSceneWorldModel.swift
//  ARLook
//
//  Created by ChenWei on 2019/9/14.
//  Copyright © 2019 Jacob. All rights reserved.
//

import UIKit
import SceneKit

enum BitMaskCategry: Int {
    case bullet = 2
    case floor = 3
    case target = 4
    case enemy = 5
    case player = 6
}


class PhysicsSceneWorldModel: NSObject, SCNPhysicsContactDelegate {
    var worldNode: SCNNode?
    static let shared = PhysicsSceneWorldModel()
    static private(set) var defaultPower: Float = 80.0
    private override init() {
        
    }
    
    func createBulletBody(shapeNode: SCNNode, orientation: SCNVector3, force: Float = defaultPower) -> SCNPhysicsBody {
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: shapeNode, options: [SCNPhysicsShape.Option.keepAsCompound: 0]))
        body.isAffectedByGravity = true
        body.applyForce(SCNVector3(orientation.x * force, orientation.y * force, orientation.z * force), asImpulse: true)
        body.categoryBitMask = BitMaskCategry.bullet.rawValue
        body.collisionBitMask = BitMaskCategry.player.rawValue | BitMaskCategry.enemy.rawValue
        return body
    }
    
    func createEnemyBody(shapeNode: SCNNode) -> SCNPhysicsBody {
        let enemyBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: shapeNode, options: nil))
        enemyBody.categoryBitMask = BitMaskCategry.enemy.rawValue
        enemyBody.contactTestBitMask = BitMaskCategry.bullet.rawValue
        return enemyBody
    }
    
    func createPlayerBody(shapeNode: SCNNode) -> SCNPhysicsBody {
        let playerBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: shapeNode, options: nil))
        playerBody.categoryBitMask = BitMaskCategry.player.rawValue
        playerBody.contactTestBitMask = BitMaskCategry.bullet.rawValue
        return playerBody
    }
    
    
    // Mark: - SCNPhysicsContactDelegate methods
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB

        var bullet: SCNNode?
        var target: SCNNode?
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategry.bullet.rawValue {
            bullet = nodeA
            target = nodeB
        }
        else if nodeB.physicsBody?.categoryBitMask == BitMaskCategry.bullet.rawValue {
            bullet = nodeB
            target = nodeA
        }
        
        let confetti = SCNParticleSystem(named:"Confetti.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = bullet?.geometry
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        confettiNode.position = contact.contactPoint
        self.worldNode?.addChildNode(confettiNode)
        bullet?.removeFromParentNode()
        
        let fire = SCNParticleSystem(named:"Fire.scnp", inDirectory: nil)
        fire?.loops = false
        fire?.particleLifeSpan = 4
        fire?.emitterShape = target?.geometry
        let fireNode = SCNNode()
        fireNode.addParticleSystem(fire!)
        fireNode.position = contact.contactPoint
        self.worldNode?.addChildNode(fireNode)
        
    }
    
    
}
