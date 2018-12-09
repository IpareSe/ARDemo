//
//  BeachBall.swift
//  SaveBall
//
//  Created by paresh on 18/06/18.
//  Copyright © 2018 Saka paresh. All rights reserved.
//

import Foundation
import Foundation
import SceneKit

class Beachball {
    static let TTL:TimeInterval = 5
    static let INITIAL_VELOCITY:Float = 4
    static let RADIUS:CGFloat = 0.06
    static let SIZE:CGFloat = 0.6
    static let METERS_PER_SECOND:CGFloat = 0.5
    static let HANDLE_LENGTH:CGFloat = 0.5
    static let HANDLE_TOP_RADIUS:CGFloat = 0.03
    static let HANDLE_BOTTOM_RADIUS:CGFloat = 0.02
    
    static let TIP_RADIUS:CGFloat = 0.06
    static let RECHARGE_TIME:TimeInterval = 0.25
    
    private static var sphere:SCNGeometry?
    private static var BOX:SCNGeometry?
    class func nodeBall() -> SCNNode {
        
        if sphere == nil {
            sphere = SCNSphere(radius: RADIUS)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            sphere!.materials = [material]
        }
        
        let node = SCNNode(geometry: sphere!)
        node.renderingOrder = 10
        
        
        let body = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic,
                                  shape: nil)
        body.categoryBitMask = CollisionTypes.beachball.rawValue
        body.collisionBitMask = CollisionTypes.solid.rawValue|CollisionTypes.wall.rawValue|CollisionTypes.bottle.rawValue
        body.contactTestBitMask = CollisionTypes.beachball.rawValue|CollisionTypes.wall.rawValue
        body.isAffectedByGravity = false
        body.mass = 0.9
        body.restitution = 0.75
        body.damping = 0.1
        body.friction = 0.1
        
        node.physicsBody = body
        node.name = "Ball"
        
        return node
    }
    
    class func nodeBox() -> SCNNode {
        
        
        let BOX = SCNBox(width: 0.02, height: 0.005, length: 0.01, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "if_Hunting_1_753892")
        BOX.materials = [material]
        
        let node = SCNNode(geometry: BOX)
        node.name = "Wand"
        return node
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    
    return left + (right * -1.0)
}

func *(vector:SCNVector3, multiplier:SCNFloat) -> SCNVector3 {
    
    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}

extension CGSize {
    var normalized:CGSize {
        get {
            let length = sqrt(width * width + height * height)
            
            return CGSize(width: width / length,
                          height: height / length)
        }
    }
}

func +(left:CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x,
                   y: left.y + right.y)
}

func -(left:CGPoint, right:CGPoint) -> CGPoint {
    
    return left + (right * -1.0)
}

func *(vector:CGPoint, multiplier:CGFloat) -> CGPoint {
    
    return CGPoint(x: vector.x * multiplier,
                   y: vector.y * multiplier)
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func distance(vector: CGPoint) -> CGFloat {
        return (self - vector).length()
    }
}

extension SCNVector3 {
    
    func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
        
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }
    
    var magnitude:SCNFloat {
        get {
            return sqrt(dotProduct(self))
        }
    }
    
    var normalized:SCNVector3 {
        get {
            let localMagnitude = magnitude
            let localX = x / localMagnitude
            let localY = y / localMagnitude
            let localZ = z / localMagnitude
            
            return SCNVector3(localX, localY, localZ)
        }
    }
    
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    func distance(vector: SCNVector3) -> Float {
        return (self - vector).length()
    }
}

enum CollisionTypes: Int {
    case solid = 1
    case bottle = 111
    case beachball = 2
    case wall = 4
}
