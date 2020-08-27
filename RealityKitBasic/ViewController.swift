//
//  ViewController.swift
//  RealityKitBasic
//
//  Created by Jack Chen on 8/12/20.
//  Copyright © 2020 ARo Cloud Co. All rights reserved.
//

import UIKit
import RealityKit
//Uses ARKit for anchors, allows for future multi-user AR experiances
//ARKit not neccessary for solo AR experiances
import ARKit

class ViewController: UIViewController {
    
    var roboAnchor: BruhWalk.Animoji!
    var man: Entity!
    var manModel: ModelEntity!
    
    @IBOutlet var arView: ARView!
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        let entity = try! ModelEntity.loadModel(named: "toy_ _vintage")
        
        //Add model to anchor entity
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
    */
    
    //@IBOutlet var imageStack: UIStackView!
    
    //When doing advanced applications, you want to delete advanced ar applications
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Add this so that didAdd anchors will be called
        arView.session.delegate = self
        
        setupARView()
        
        //UITap Gesture Recognizer
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recoginzer: ))))
    }
    
    //Mark: Setup Methods
    func setupARView() {
        
        //disable arView configurations
        arView.automaticallyConfigureSession = false
        
        //Create a new arView configuration with world tracking (Placee Objects into view)
        let configuration = ARWorldTrackingConfiguration()
        
        //Set plane detection Flags, this is an array of even values
        configuration.planeDetection = [.horizontal, .vertical]
        
        //Automatically texture environments -> add reflections, make objects in our enviroment as realistic as possible
        //Only avaliable for ios 12 & up
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
        
    }
    
    //Mark: Object Placement
    
    //used selector syntax (line 37) must add objc to get func handleTap to work
    @objc
    //When user taps, it calls this function
    func handleTap(recoginzer: UITapGestureRecognizer) {
        //Getting location in arView
        let location = recoginzer.location(in: arView)
        
        //use raycast to see if it is intersecting with any real world surface
        //use a raycast for the location user tapped on screen
        //estimatedPlane - not super accurate
        //horiztonal plane for this demo
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        //Does it actual hit a flat surface?
        //It returns when it hits an actual surface
        if let firstResult = results.first{
            
            //anchors are used for future multi-user AR experiances
            //Synchronizes scenes by having an anchor
            let anchor = ARAnchor(name: "BruhWalk", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
            
        //No result - error message
        } else {
            print("Object placement failed - couldn't find surface ")
        }
    }
    
    //Place an obejct into the world
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        
        //Force try since we know model exsists
        //Put optional try if you don't know exsists
        //let entity = try! BruhWalk.loadAnimoji()//(named: entityName)
        roboAnchor = try! BruhWalk.loadAnimoji()
        //Add gestures to model
        //Allows users to drag/rotate exsisting models
        //entity.generateCollisionShapes(recursive: true)
        //arView.installGestures([.rotation, .translation],for: entity)
        roboAnchor.generateCollisionShapes(recursive: true)
        //arView.installGestures([.rotation, .translation],for: )
        
        //Add model to anchor entity
        //let anchorEntity = AnchorEntity(anchor: anchor)
        //anchorEntity.addChild(entity)
        //arView.scene.addAnchor(anchorEntity)
        arView.scene.anchors.append(roboAnchor)
        man = roboAnchor.findEntity(named: "Prison")
        manModel = man.children.first as? ModelEntity
        //man = roboAnchor.findEntity(named: "Prison")
        //manModel = man.children.first as? ModelEntity
    }
}

extension ViewController: ARSessionDelegate {
    //handleTap used anchors
    //requires didAdd anchors
    func session (_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        //Place any numbers objects into the scene
        for anchor in anchors {
            if let  anchorName = anchor.name, anchorName == "BruhWalk" {
                placeObject(named: anchorName, for: anchor)
            }
        }
        
    }
}

