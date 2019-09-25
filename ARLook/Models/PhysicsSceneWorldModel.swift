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
    @objc dynamic private(set) var score: Int = 0
    private override init() {
        
    }
    // MARK: - Public methods
    func reset() {
        self.score = 0
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
//        let enemyBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: shapeNode, options: nil))
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
    
    
    // MARK: - SCNPhysicsContactDelegate methods
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
        
        let confettiNode = SCNNode()
        confettiNode.position = contact.contactPoint
        confettiNode.scale = (target?.presentation.scale)!
        self.worldNode?.addChildNode(confettiNode)
        let confetti = SCNParticleSystem(named:"Confetti.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 0.6
        confetti?.emitterShape = bullet?.geometry
        confettiNode.addParticleSystem(confetti!)
        
        bullet?.removeFromParentNode()
        
        let fireNode = SCNNode()
        fireNode.rotation = target!.presentation.rotation
        fireNode.scale = target!.presentation.scale
        
        fireNode.position = contact.contactPoint
        self.worldNode?.addChildNode(fireNode)
        let fire = SCNParticleSystem(named:"Fire.scnp", inDirectory: nil)
        fire?.loops = false
        fire?.particleLifeSpan = 0.4
        fire?.emitterShape = target?.geometry
        fireNode.addParticleSystem(fire!)
        target?.removeFromParentNode()
        self.score += 1
        
    }
    
    
}
