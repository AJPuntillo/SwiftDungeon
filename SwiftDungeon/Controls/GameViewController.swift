//
//  GameViewController.swift
//  SwiftDungeon
//
//  Created by Puntillo Andrew J. on 2/28/18.
//  Copyright © 2018 Puntillo Andrew J. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    
    var playButton: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.setTitle("PLAY", for: .normal)
        playButton.addTarget(self, action: #selector(Start), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func Start() {
        let scene = GameScene(size: CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        playButton.isHidden = true
    }
}
