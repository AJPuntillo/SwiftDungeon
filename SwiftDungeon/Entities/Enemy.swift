//
//  Enemy.swift
//  SwiftDungeon
//
//  Created by Puntillo Andrew J. on 3/19/18.
//  Copyright © 2018 Puntillo Andrew J. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy : Entity, EnemyExplosion {
    
    //Animation
    private var textureAnimation: [SKTexture] = []
    //Check if already animating
    var isAnimating:Bool = false
    //SKAction for animation
    var animationAction:SKAction = SKAction()
    //Timer for animation
    var animTimer:Double = 0
    //Speed of Enemy
    private var velocity: CGFloat = 50
    //Life Timer
    var lifeTimer:Double = 0
    var maxLifeTime:Double = 0
    //Alive bool
    var isDead:Bool = false
    
    // Position of target to chase
    var targetPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    init() {
        super.init(imageName: "slime_idle_01")
        
        //Physics body
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.usesPreciseCollisionDetection = true;
        physicsBody?.isDynamic = true;
        physicsBody?.affectedByGravity = true;
        physicsBody?.allowsRotation = false;
        physicsBody?.restitution = 1.0;
        physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func moveToTarget() {
        let direction = CGPoint(x: targetPosition.x - position.x, y: targetPosition.y - position.y)
        
        if(direction.x > 0) {
            xScale = -5
        }
        else if (direction.x < 0) {
            xScale = 5
        }
        
        if(position.x > targetPosition.x) {
            position = CGPoint(x: position.x - (velocity * CGFloat(deltaTime)), y: position.y)
        }
        else if(position.x < targetPosition.x) {
            position = CGPoint(x: position.x + (velocity * CGFloat(deltaTime)), y: position.y)
        }
        
        if(position.y > targetPosition.y) {
            position = CGPoint(x: position.x, y: position.y - (velocity * CGFloat(deltaTime)))
        }
        else if(position.y < targetPosition.y) {
            position = CGPoint(x: position.x, y: position.y + (velocity * CGFloat(deltaTime)))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        //moveToTarget()
        
        //If it is animating, increment the animTimer until it has reached the total duration of the SKAction's animation time
        //Once the time has exceeded the duration, is is no longer animating
        if (isAnimating) {
            animTimer += deltaTime
            if (animTimer > animationAction.duration) {
                isAnimating = false
                animTimer = 0
                isDead = true;
            }
        }
        
        if (lifeTimer < maxLifeTime) {
            lifeTimer += deltaTime
        }
        else {
            explosion()
            //isDead = true
        }
    }

    //Protocol
    func explosion() {
        if (!isAnimating && !isDead) {
            isAnimating = true
            textureAnimation = [SKTexture(imageNamed: "explosion_1"),
                                SKTexture(imageNamed: "explosion_2"),
                                SKTexture(imageNamed: "explosion_3"),
                                SKTexture(imageNamed: "explosion_4"),
                                SKTexture(imageNamed: "explosion_5"),
                                SKTexture(imageNamed: "explosion_6"),
                                SKTexture(imageNamed: "explosion_7")]
            
            animationAction = SKAction.animate(with: textureAnimation, timePerFrame: 0.08)
            
            self.run(animationAction)
        }
    }
    
    func shiftEnemy(_ amount:CGFloat) {
        position.x -= amount
    }
}

