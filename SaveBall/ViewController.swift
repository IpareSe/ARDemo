//
//  ViewController.swift
//  SaveBall
//
//  Created by paresh on 18/06/18.
//  Copyright © 2018 Saka paresh. All rights reserved.
//

import UIKit
import  SceneKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class Floor {
    class func node(position:SCNVector3) -> SCNNode {
        
        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.colorBufferWriteMask = SCNColorMask(rawValue: 1)
        let node = SCNNode(geometry: floor)
        node.physicsBody = SCNPhysicsBody(type: .static,
                                          shape: nil)
        node.physicsBody?.categoryBitMask = CollisionTypes.solid.rawValue
        node.physicsBody?.collisionBitMask = CollisionTypes.beachball.rawValue
        //node.physicsBody?.contactTestBitMask = CollisionTypes.fireball.rawValue|CollisionTypes.solid.rawValue
        node.position = position
        
        return node
    }
}
