//
//  Bottle.swift
//  SaveBall
//
//  Created by paresh on 18/06/18.
//  Copyright © 2018 Saka paresh. All rights reserved.
//

import Foundation
import ARKit

class Bottle : SCNNode
{
    
    static let RECHARGE_TIME:TimeInterval = 0.9
//    init(image: UIImage) {
//        super.init()
//        self.addChildNode(self.material(img: image))
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    class func node(img: UIImage) -> SCNNode
    {
        
        let box = SCNBox(width: 0.04, height: 0.04, length: 0.04, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        
        //material.diffuse.contentsTransform =
            //SCNMatrix4Translate(SCNMatrix4MakeScale(-1, 1, 1), 1, 0, 0)
        //material.isDoubleSided = false
        box.materials = [material]
        let node = SCNNode(geometry: box)
       // node.physicsBody?.categoryBitMask = CollisionTypes.bottle.rawValue
        //node.physicsBody?.collisionBitMask = CollisionTypes.beachball.rawValue
        
        let body = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic,
                                  shape: nil)
        body.categoryBitMask = CollisionTypes.bottle.rawValue
        body.collisionBitMask = CollisionTypes.beachball.rawValue
         body.contactTestBitMask = CollisionTypes.beachball.rawValue
//        |CollisionTypes.wall.rawValue
        body.isAffectedByGravity = false
        body.mass = 5.5
        body.restitution = 1.0
        body.damping = 0.1
        body.friction = 21.0
        node.physicsBody = body
        let uuid = UUID().uuidString
        node.name = uuid
        return node
    }
    
    
}
