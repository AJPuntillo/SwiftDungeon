//
//  GameManager.swift
//  SwiftDungeon
//
//  Created by Puntillo Andrew J. on 3/12/18.
//  Copyright © 2018 Puntillo Andrew J. All rights reserved.
//

import Foundation
import GameKit

class GameManager {
    
    // Map
    private let map = Map(imageNamed: "SDP_Tilemap_Ground-Water")
    private var mapStartPosition = CGSize()
    
    // Entities
    let player = Player()
    var enemies:[Enemy] = []
    private var maxEnemies = 3
    private let enemyFactory = EnemyFactory()
    
    // Loading check
    var loading: Bool = false
    
    // UI
    var joystick: Joystick?
    var attackButton: AttackButton?
    
    // Scene
    weak var scene: GameScene?
    
    func startGame(size: CGSize) {
        mapStartPosition = size
        
        // Make Map
        map.zPosition = -1
        map.position = CGPoint(x: mapStartPosition.width + 1580, y: mapStartPosition.height / 2 + 50)
        map.setScale(2.5)
        map.physicsBody = SKPhysicsBody(texture: map.texture!, size: map.size)
        map.physicsBody?.isDynamic = false;
        
        // Make Player
        player.zPosition = 1
        player.position = map.playerSpawn
        player.setScale(5)
        
        //Init the Joystick
        joystick = Joystick()
        joystick?.start(size: size)
        
        //Init the Attack Button
        attackButton = AttackButton()
        attackButton?.start(size: size)
        
        // Add children to scene
        populateLevel()
        
        // Populate level with enemies
        populateEnemies()
    }

    func update(_ currentTime: TimeInterval) {
        
        // Update Player
        player.update(currentTime)
        player.setDirection(dir: (joystick?.dirVector)!)
        
        //Jump
        if ((joystick?.dirVector.y)! > CGFloat(0.4)) {
            player.jump()
        }
        
        //Checking if the player is grounded
        if ((player.physicsBody?.allContactedBodies().count) != 0) {
            player.state = PlayerState.IDLE
        }
        else {
            player.state = PlayerState.JUMPING
        }
        
        //Limiting BG movement
        if (player.position.x >= (scene?.size.width)! - 400 && (joystick?.dirVector.x)! < CGFloat(0.0)) {
            map.moveForward()
        }
        
        //Falling into the water
        if (player.position.y < 400) {
            player.isDead = true;
        }
        
        
        // Update Enemies and check for collisions
        var enemiesToBeDeleted: [Int] = []
        
        for enemy in (enemies) {
            if(!loading) {
                enemy.update(currentTime)
            }
            
            let playerCollision = enemy.collision(items: [player]).first
            
            if let _ = playerCollision  {
                //player.takeDamage()
                //print(player.health)
                //enemy.removeFromParent()
                //enemiesToBeDeleted.append(enemies.index(of: enemy)!)
                //enemy.death()
            }
            
            if (enemy.isDead) {
                enemy.removeFromParent()
                enemiesToBeDeleted.append(enemies.index(of: enemy)!)
            }
        }
        
        deleteEnemies(enemiesToBeDeleted)
 
        
        // Check to reload level
        if (player.isDead) {
            player.resetPlayer()
            reloadLevel()
        }
    }
    
    private func reloadLevel() {
        // Fade out
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.scene?.view?.alpha = 0.0
        }, completion: {
            (finished: Bool) -> Void in
            
            // Fade in
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.scene?.view?.alpha = 1.0
                
                // Set properties and add children when screen is faded
                self.resetLevel()
                self.populateLevel()
                self.populateEnemies()
                
            }, completion: nil)
        })
    }
    
    private func resetLevel() {
        scene?.removeAllChildren()
        enemies.removeAll()
        player.position = self.map.playerSpawn
        map.position = CGPoint(x: mapStartPosition.width + 1580, y: mapStartPosition.height / 2 + 50)
    }
    
    private func populateLevel() {
        scene?.addChild(map)
        scene?.addChild(player)
        scene?.addChild((joystick?.joystick)!)
        scene?.addChild((joystick?.joystickBase)!)
        scene?.addChild((attackButton)!)
    }
    
    private func populateEnemies() {
        for _ in 0..<maxEnemies {
            
            let randomIndex = Int(arc4random_uniform(UInt32(map.enemySpawns.count)))
            let randomLifetime = Double(arc4random_uniform(3) + 1)
            let randomBounce = CGFloat(arc4random_uniform(100) + 1)
            
            let eTemp = enemyFactory.createEnemy(randomLifetime, randomBounce)
            eTemp.position = map.enemySpawns[randomIndex]
            eTemp.setScale(5)
            scene?.addChild(eTemp)
            enemies.append(eTemp)
        }
    }
    
    //Helper function to properly remove the enemies from the array
    private func deleteEnemies(_ enemyIndex: [Int]) {
        let reversedIndex = enemyIndex.reversed()
        
        for index in reversedIndex {
            enemies.remove(at: index)
        }
    }
    
}

