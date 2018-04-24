//
//  EnemyFactory.swift
//  SwiftDungeon
//
//  Created by Puntillo Andrew J. on 3/20/18.
//  Copyright © 2018 Puntillo Andrew J. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyFactory {
    
    // This class is useless for now nut it's being left in incase
    // there ever needs to be enemy variation
    
    func createEnemy(_ lifeTime:Double,_ bounce:CGFloat, _ velocity:CGFloat) -> Enemy {
        let tmp = Enemy()
        tmp.maxLifeTime = lifeTime
        tmp.physicsBody?.restitution = (bounce / 100.0)
        tmp.physicsBody?.velocity = CGVector(dx: velocity, dy: 0.0)
        return tmp
    }
    
}
