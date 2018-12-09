//
//  ControllVC.swift
//  SaveBall
//
//  Created by paresh on 18/06/18.
//  Copyright © 2018 Saka paresh. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ControllVC: UIViewController {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    var anchor : ARPlaneAnchor?
    var Bottles = [SCNNode]()
    var session = ARSession()
    var isPlaying = false
    var carryNode : SCNNode?
    var planeANode = SCNNode()
    var isThrowing = false
    var pointOfViewnode : SCNNode?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setSceneKit()
        DispatchQueue.main.async{
            self.btnPlay.isEnabled = false
        }
        self.carryNode = Beachball.nodeBox()
        
        let tapgest = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapgest.numberOfTapsRequired = 1
        self.sceneView.addGestureRecognizer(tapgest)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setConfiguaration()
    }
    
    func setSceneKit()
    {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.scene = SCNScene()
        sceneView.session = session
        sceneView.debugOptions  = [.showConstraints, .showLightExtents, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.scene.physicsWorld.contactDelegate = self
        
    }
    
    func setConfiguaration()
    {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        self.sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    @IBAction func btnPlayGame(_ sender: Any) {
        if self.isPlaying
        {
            
            self.Bottles.forEach { (node) in
                node.removeFromParentNode()
            }
            self.Bottles.removeAll()
            self.isPlaying = false
            self.btnPlay.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
        }
        else
        {
            if self.Bottles.count > 0
            {
                self.isPlaying = true
                self.nodePoint()
                self.btnPlay.setImage(#imageLiteral(resourceName: "pause-button"), for: .normal)
                
            }
        }
    }
    
    @objc func tap(tap: UIGestureRecognizer)
    {
        if !isPlaying{
            let tapLocation = tap.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.columns.3
            if self.isThrowing == false
            {
                self.isThrowing = true
                xPos = translation.x
                self.StartThrowingBoxes(position: translation)
                
            }
            else
            {
                self.isThrowing = false
                xPos = translation.x
                self.StartThrowingBoxes(position: translation)
            }
        }
        else{
            self.planeANode.removeFromParentNode()
//            carryNode!.position = SCNVector3(0.07 - 0.01,-0.25,-0.3)
//            self.pointOfViewnode?.position = SCNVector3(0,0,0.5)
            self.sceneView.pointOfView?.addChildNode(carryNode!)
            carryNode!.eulerAngles = SCNVector3(-60.0.degreesToRadians,0,30.0.degreesToRadians)
            let movePosAction = SCNAction.moveBy(x: 0.02, y: 0, z: 0, duration: 0.7)
            let moveNegAction = SCNAction.moveBy(x: -0.02, y: 0, z: 0, duration: 0.7)
            let sequence = SCNAction.sequence([movePosAction, moveNegAction])
            carryNode!.runAction(sequence)
            sceneView.pointOfView?.addChildNode(carryNode!)
            
            var totalX:Float = 0
            var totalZ:Float = 0
            
            for bottle in self.Bottles {
                
                totalX += bottle.position.x
                totalX += bottle.position.x
                totalZ += bottle.position.z
                totalZ += bottle.position.z
            }
            
            let centerPosition = SCNVector3(totalX / Float(self.Bottles.count * 2),
                                            self.Bottles[0].position.y,
                                            totalZ / Float(self.Bottles.count * 2))
            ///sceneView.scene.rootNode.addChildNode(Floor.node(position: centerPosition))
            
            let light = SCNLight()
            light.type = .spot
            light.shadowMode = .deferred
            light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            light.castsShadow = true
            let lightNode = SCNNode()
            lightNode.position = SCNVector3(centerPosition.x,
                                            centerPosition.y + 10,
                                            centerPosition.z)
            lightNode.look(at: SCNVector3(0,0,0))
            lightNode.light = light
            //sceneView.scene.rootNode.addChildNode(lightNode)
            
            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            let ambientLightNode = SCNNode()
            ambientLightNode.light = ambientLight
            sceneView.scene.rootNode.addChildNode(ambientLightNode)
            let location = tap.location(in: self.sceneView)
            self.playingTapped(location: location)
        }
    }
    
    func nodePoint()  {
        
        if let nodePoint = self.pointOfViewnode
        {
            //nodePoint.removeFromParentNode()
        }
        let BOX = SCNPlane(width: 0.03, height: 0.03)
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "if_Hunting_1_753892")
        BOX.materials = [material]
        
        let node = SCNNode(geometry: BOX)
        node.name = "Position"
        node.eulerAngles = SCNVector3Make(0, 0,-0.5)
        node.position = SCNVector3(0,0,-0.5)
        self.sceneView.pointOfView?.addChildNode(node)
        self.pointOfViewnode = node
    }
    
    var xPos:Float = 0.0
    func StartThrowingBoxes(position:simd_float4)
    {
        
        let nodebtl = Bottle.node(img: #imageLiteral(resourceName: "Bottle-PNG-Pic"))
        nodebtl.position = SCNVector3Make(xPos,position.y,position.z)
        xPos = xPos + 0.0001
        self.sceneView.scene.rootNode.addChildNode(nodebtl)
        self.Bottles.append(nodebtl)
        if self.isThrowing{
            if self.Bottles.count > 50
            {
                self.isThrowing = false
                self.Bottles.forEach { (node) in
                    node.removeFromParentNode()
                }
                self.Bottles.removeAll()
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(1000000000000000.0))) {
                if self.Bottles.count <= 49{
                    self.StartThrowingBoxes(position: position)
                }
            }
        }
    }
    
    private func playingTapped(location:CGPoint) {
        // shoot fireballs _exactly_ from the fireball tip of the carried wand.
        
        // the new fireball!
        let fireballNode = Beachball.nodeBall()
        fireballNode.name = UUID().uuidString
        
        sceneView.scene.rootNode.addChildNode(fireballNode)
        
        let currentFrame = sceneView.session.currentFrame!
        let n = SCNNode()
        sceneView.scene.rootNode.addChildNode(n)
        
        var closeTranslation = matrix_identity_float4x4
        closeTranslation.columns.3.z = -0.5
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        n.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        fireballNode.simdTransform = matrix_multiply(currentFrame.camera.transform, closeTranslation)
        
        let direction = (n.position - fireballNode.position).normalized
        
        if let wandNode = sceneView.pointOfView?.childNode(withName: "Wand", recursively: false), let tobottle = sceneView.pointOfView?.childNode(withName: "Plane", recursively: false){
            // all we need to do is to give the fireballNode the right starting position!!
            // use same direction vector
            
            fireballNode.position = wandNode.convertPosition(wandNode.position, to: tobottle)
            wandNode.position.z = -0.2
            wandNode.runAction(SCNAction.moveBy(x: 0, y: 0, z: -0.1, duration: Bottle.RECHARGE_TIME))
            carryNode?.scale = SCNVector3(0,0,0)
            carryNode?.runAction(SCNAction.scale(to: 1, duration: Bottle.RECHARGE_TIME)) {
                
            }
        }
        
        // fireball should come FROM THE TIP of the wand!
        
        fireballNode.physicsBody?.applyForce(direction * Beachball.INITIAL_VELOCITY, asImpulse: true)
        n.removeFromParentNode()
        fireballNode.runAction(SCNAction.wait(duration: Beachball.TTL)) {
            fireballNode.removeFromParentNode()
        }
    }
    
    
}

extension ControllVC : ARSCNViewDelegate, SCNPhysicsContactDelegate
{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else{
            return
        }
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIColor.white
        
        let body = SCNPhysicsBody(type: SCNPhysicsBodyType.static,
                                  shape: nil)
        
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        body.categoryBitMask = CollisionTypes.wall.rawValue
        body.collisionBitMask = CollisionTypes.beachball.rawValue
            //| CollisionTypes.bottle.rawValue
        body.contactTestBitMask = CollisionTypes.beachball.rawValue|CollisionTypes.wall.rawValue
        planeNode.name = "Plane"
        
        planeNode.physicsBody = body
        self.anchor = planeAnchor
        
        let nodebtl = Bottle.node(img: #imageLiteral(resourceName: "Bottle-PNG-Pic"))
        let position = SCNVector3Make(planeAnchor.center.x,planeNode.position.z,planeAnchor.center.z)
        nodebtl.position = position
        nodebtl.eulerAngles.x = .pi / 2
        planeNode.addChildNode(nodebtl)
        self.Bottles.append(nodebtl)
        let geometry = planeNode.geometry!
        let trailEmitter = self.createTrail(color: UIColor.red, geometry: geometry)
        planeNode.addParticleSystem(trailEmitter)
        self.planeANode = planeNode
        // 6
        DispatchQueue.main.async{
            self.btnPlay.isEnabled = true
        }
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        self.anchor = planeAnchor
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    func spawnShape(node:SCNNode?) {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let color = UIColor.red
        geometry.materials.first?.diffuse.contents = color
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    
        let trailEmitter = createTrail(color: color, geometry: geometry)
        geometryNode.addParticleSystem(trailEmitter)
        self.sceneView.scene.rootNode.addChildNode(geometryNode)
    }
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        DispatchQueue.main.async {
            self.lblStatus.text =  "didBegin contact"
        }
    }
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        self.lblStatus.text =  "didEnd contact"
        let body = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic,
                                  shape: nil)
        body.isAffectedByGravity = true
        if contact.nodeA.name != "Plane" || contact.nodeB.name != "Plane" && (contact.nodeA.name != contact.nodeB.name){
            var i = 0
            let node = self.Bottles.filter {(nodea) -> Bool in
                i += 1
                return nodea.name == contact.nodeB.name
                }
            if let first = node.first
            {
                self.createExplosion(geometry: first.geometry!, position: first.position, rotation: first.rotation)
                first.removeFromParentNode()
                //self.Bottles.remove(at: i)
            }
            else
            {
                let node = self.Bottles.filter {(nodeb) -> Bool in
                    i += 1
                    return nodeb.name == contact.nodeA.name
                }
                if let first = node.first
                {
                    self.createExplosion(geometry: first.geometry!, position: first.position, rotation: first.rotation)
                    first.removeFromParentNode()
                    //self.Bottles.remove(at: i)
                }
            }
        }
//        if contact.nodeA.name == "bottle" && contact.nodeB.name == "bottle"{
//            self.createExplosion(geometry: self.Bottles.first!.geometry!, position: self.Bottles.first!.position, rotation: self.Bottles.first!.rotation)
//        }
//        else if contact.nodeB.name == "bottle" && contact.nodeB.name != "bottle"
//        {
//            let trailEmitter = self.createTrail(color: UIColor.red, geometry: contact.nodeA.geometry!)
//            contact.nodeA.addParticleSystem(trailEmitter)
//             contact.nodeA.physicsBody?.isAffectedByGravity = true
//        }
        
    }
    
    func createExplosion(geometry: SCNGeometry, position: SCNVector3,
                         rotation: SCNVector4) {
        let explosion =
            SCNParticleSystem(named: "Explode.scnp", inDirectory:
                nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface
        let rotationMatrix =
            SCNMatrix4MakeRotation(rotation.w, rotation.x,
                                   rotation.y, rotation.z)
        let translationMatrix =
            SCNMatrix4MakeTranslation(position.x, position.y, position.z)
        let transformMatrix =
            SCNMatrix4Mult(rotationMatrix, translationMatrix)
        self.sceneView.scene.addParticleSystem(explosion, transform: transformMatrix)
    }
    
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        // 2
        let trail = SCNParticleSystem(named: "reactor.scnp", inDirectory: nil)!
        // 3
        //trail.particleColor = color
        // 4
       // trail.emitterShape = geometry
        // 5
        return trail
    }
    
    

}

public extension Float {
    public static func random(min min: Float, max: Float) -> Float {
        let r32 = Float(arc4random()) / Float(UInt32.max)
        return (r32 * (max - min)) + min
    }
}
