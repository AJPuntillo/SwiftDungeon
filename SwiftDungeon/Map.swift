//
//  Map.swift
//  SwiftDungeon
//
//  Created by Puntillo Andrew J. on 3/12/18.
//  Copyright © 2018 Puntillo Andrew J. All rights reserved.
//

import Foundation
import SpriteKit

class Map : SKSpriteNode {
    
    // This is a base class that can be used
    // to make maps with different images and spawn points
    // but for now we will just use this class
    
    var playerSpawn = CGPoint(x: 200, y: 500)
    
    var enemySpawns:[CGPoint] = [CGPoint(x: 300, y: 1500), CGPoint(x: 500, y: 1500), CGPoint(x: 700, y: 1500), CGPoint(x: 900, y: 1500), CGPoint(x: 1100, y: 1500), CGPoint(x: 1300, y: 1500), CGPoint(x: 1500, y: 1500), CGPoint(x: 1700, y: 1500), CGPoint(x: 1900, y: 1500)]
    
    init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveForward() {
        if (position.x >= -1580) {
            position.x -= 7;
        }
    }
    
}
