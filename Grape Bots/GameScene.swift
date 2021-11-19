//
//  GameScene.swift
//  Grape Bots
//
//  Created by Bode Lash on 11/3/21.
//

import SpriteKit
import GameplayKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}


struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let target   : UInt32 = 0b01       // 1
  static let projectile: UInt32 = 0b10      // 2
  static let switchPart   : UInt32 = 0b11       // 1
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
      // 1
      var firstBody: SKPhysicsBody
      var secondBody: SKPhysicsBody
      if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
      } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
      }
     
      // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.target != 0) && (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            
            if let target = firstBody.node as? SKSpriteNode,
            let projectile = secondBody.node as? SKSpriteNode {
                
                projectileDidCollideWithMonster(projectile: projectile, monster: target)
            }
        }else if ((firstBody.categoryBitMask & PhysicsCategory.switchPart != 0) && (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            
            if let projectile = firstBody.node as? SKSpriteNode,
               let Switch = secondBody.node as? SKSpriteNode {
                
                projectileDidCollideWithSwitch(part: projectile, projectile: Switch)
            }
        }
        
        //if ((firstBody.categoryBitMask & PhysicsCategory.switchPart != 0) &&
        //    (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
        //    if let Switch = firstBody.node as? SKSpriteNode,
        //       let projectile = secondBody.node as? SKSpriteNode {
        //        print("Hit switch")
        //        projectileDidCollideWithSwitch(projectile: projectile, part: Switch)
        //    }
        //}
    }
}


class GameScene: SKScene {
    //var label : SKLabelNode!
    //var starfield: SKEmitterNode!
    //var player: SKSpriteNode!
    // 1
    
    var currentAmmo = 3
    var scorePoints = 0
    var switchMode = "blue"
    
    let player = SKSpriteNode(imageNamed: "player")
    
    let ammoLabel = SKLabelNode(fontNamed: "Helvetica Neue Medium")
    let scoreLabel = SKLabelNode(fontNamed: "Helvetica Neue Medium")
    let directionLabel = SKLabelNode(fontNamed: "Helvetica Neue Medium")
    let NumberValue1 = SKLabelNode(fontNamed: "Helvetica Neue Medium")
    let NumberValue2 = SKLabelNode(fontNamed: "Helvetica Neue Medium")
      
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.orange
        player.position = CGPoint(x: 0, y: 0)
        player.zPosition = 3
        addChild(player)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        player.zRotation = 0
        
        ammoLabel.text = String(currentAmmo)
        ammoLabel.fontSize = 65
        ammoLabel.fontColor = SKColor.black
        ammoLabel.position = CGPoint(x: -273, y: 420)
        ammoLabel.zPosition = 5
        addChild(ammoLabel)
        
        scoreLabel.text = "Score: " + String(scorePoints)
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: 0, y: -435)
        scoreLabel.zPosition = 5
        addChild(scoreLabel)
        
        directionLabel.text = "^"
        directionLabel.fontSize = 90
        directionLabel.fontColor = SKColor.black
        directionLabel.position = CGPoint(x: -150, y: 420)
        directionLabel.zPosition = 5
        //addChild(directionLabel)
        
        NumberValue1.text = "10"
        NumberValue1.fontSize = 35
        NumberValue1.fontColor = SKColor.black
        NumberValue1.position = CGPoint(x: 0, y: 420)
        NumberValue1.zPosition = 5
        addChild(NumberValue1)
        NumberValue2.text = "5"
        NumberValue2.fontSize = 35
        NumberValue2.fontColor = SKColor.black
        NumberValue2.position = CGPoint(x: 250, y: 420)
        NumberValue2.zPosition = 5
        addChild(NumberValue2)
        
        addSwitch()
        
        run(SKAction.repeatForever(
                SKAction.sequence([
                SKAction.run(addTarget),
                SKAction.wait(forDuration: 1.5)
            ])
        ))
        run(SKAction.repeatForever(
                SKAction.sequence([
                SKAction.run(rotatePlayer),
                SKAction.wait(forDuration: 0.8)
            ])
        ))
    }
    
    let Switch = SKSpriteNode(imageNamed: "BluSwitch")
    let redSwitchText = SKTexture(imageNamed: "RedSwitch")
    let bluSwitchText = SKTexture(imageNamed: "BluSwitch")
    let bluBlock = SKSpriteNode(imageNamed: "BluBlock")
    let redBlock = SKSpriteNode(imageNamed: "RedBlock")
    func addSwitch() {
        Switch.position = CGPoint(x: 230, y: 0)
        Switch.zPosition = 6
        Switch.texture = bluSwitchText
        Switch.setScale(0.4)
        
        Switch.physicsBody = SKPhysicsBody(rectangleOf: Switch.size)
        Switch.physicsBody?.isDynamic = true
        Switch.physicsBody?.categoryBitMask = PhysicsCategory.switchPart
        Switch.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        Switch.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(Switch)
    }
    
    func rotatePlayer() {
        //targetAmount = 1
        
        if scorePoints > -200 && scorePoints < 600 {
            scorePoints -= targetAmount * 4
        }else if scorePoints >= 600 {
            scorePoints -= targetAmount * 5
        }else {
            scorePoints -= targetAmount * 2
        }
        scoreLabel.text = "Score: " + String(scorePoints)
        //print("Turn1", player.zRotation)
        if player.zRotation == 0 {
            AimingDegree = degree45
            directionLabel.text = "/"
            player.zRotation = -0.75
        }else if player.zRotation == -0.75 {
            AimingDegree = degree90
            directionLabel.text = ">"
            player.zRotation = -1.6
        }else if player.zRotation <= -1.4 && player.zRotation >= -1.7 {
            AimingDegree = degree135
            directionLabel.text = ".."
            player.zRotation = -2.4
        }else if player.zRotation <= -2.3 && player.zRotation >= -2.6 {
            AimingDegree = degree180
            directionLabel.text = "."
            player.zRotation = -3.15
        }else if player.zRotation <= -3 && player.zRotation >= -3.5 {
            AimingDegree = degree225
            directionLabel.text = "/"
            player.zRotation = 2.35
        }else if player.zRotation >= 2.2 && player.zRotation <= 2.5 {
            AimingDegree = degree270
            directionLabel.text = "<"
            player.zRotation = 1.5
        }else if player.zRotation == 1.5 {
            AimingDegree = degree315
            directionLabel.text = "''"
            player.zRotation = 0.75
        }else if player.zRotation == 0.75 {
            AimingDegree = degree0
            directionLabel.text = "^"
            player.zRotation = 0
        }
    }
    
    
    let targetPositions = [
    [CGPoint(x: 200, y: 0), 0],[CGPoint(x: 200, y: 200), 1],[CGPoint(x: 200, y: -200), 2],
    [CGPoint(x: -200, y: 0), 3],[CGPoint(x: -200, y: 200), 4],[CGPoint(x: -200, y: -200), 5],
    [CGPoint(x: 0, y: 200), 6],[CGPoint(x: 0, y: -200), 7]]
    var targetChecks = [false,false,false,false,false,false,false,false]
    
    var targetAmount = 0
    func addTarget() {
        let newTargPosSelect = targetPositions.randomElement()!
        let newTargPos = newTargPosSelect[0]
        
        if targetAmount < 4 && targetChecks[newTargPosSelect[1] as! Int] == false {
            targetAmount += 1
            targetChecks[newTargPosSelect[1] as! Int] = true
            let target = SKSpriteNode(imageNamed: "Target")
            target.physicsBody = SKPhysicsBody(rectangleOf: target.size)
            target.physicsBody?.isDynamic = true
            target.physicsBody?.categoryBitMask = PhysicsCategory.target
            //target.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
            target.physicsBody?.collisionBitMask = PhysicsCategory.none
            
            target.position = newTargPos as! CGPoint
            target.zPosition = 0.3
            target.setScale(0.5)
          //monster.position = CGPoint(x: Int(TargetXPositions.randomElement()!), y: Int(TargetYPositions.randomElement()!))
            addChild(target)
        }
    }
    
    let randomMathNumbers = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,30,40,50,60,
                             70,80,90,100,55,26,35,46,64,72,88,91,
                             -1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,
                             -13,-14,-15,-16,-17,-18,-19,-20,-30,-40,
                             -50,-60,-70,-80,-90,-100,-55,-26,-35,-46,
                             -64,-72,-88,-91]
    func changeMathText() {
        NumberValue1.text = String(scorePoints)
        NumberValue2.text = String(scorePoints + randomMathNumbers.randomElement()!)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         for touch in touches {
              let location = touch.location(in: self)
              let touchedNode = atPoint(location)
              if touchedNode.name == "Symbol<" {
                //print("Less")
                let number1 = Int(NumberValue1.text!)
                let number2 = Int(NumberValue2.text!)
                if number1! < number2! {
                    //print("Correct!")
                    scorePoints += 10
                    if currentAmmo <= 6 {
                        currentAmmo += 1
                    }
                }else {
                    if scorePoints > -200 {
                        scorePoints -= 80
                    }
                    if currentAmmo > 0 {
                        currentAmmo -= 1
                    }
                }
                ammoLabel.text = String(currentAmmo)
                scoreLabel.text = "Score: " + String(scorePoints)
                changeMathText()
              }else if touchedNode.name == "Symbol>" {
                //print("Greater")
                let number1 = Int(NumberValue1.text!)
                let number2 = Int(NumberValue2.text!)
                if number1! > number2! {
                    //print("Correct!")
                    scorePoints += 10
                    if currentAmmo <= 6 {
                        currentAmmo += 1
                    }
                }else {
                    if scorePoints > -200 {
                        scorePoints -= 80
                    }
                    if currentAmmo > 0 {
                        currentAmmo -= 1
                    }
                }
                ammoLabel.text = String(currentAmmo)
                scoreLabel.text = "Score: " + String(scorePoints)
                changeMathText()
              }
         }
    }
    
    var degree0 = CGPoint(x:0,y:1000)/////
    var degree45 = CGPoint(x:800,y:800)///
    var degree90 = CGPoint(x:1000,y:0)/////
    var degree135 = CGPoint(x:800,y:-800)///
    var degree180 = CGPoint(x:0,y:-1000)/////
    var degree225 = CGPoint(x:-800,y:-800)///
    var degree270 = CGPoint(x:-1000,y:0)/////
    var degree315 = CGPoint(x:-800,y:800)///
    var AimingDegree = CGPoint(x:0,y:1000)
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentAmmo > 0 {
            currentAmmo = currentAmmo - 1
            ammoLabel.text = String(currentAmmo)
            
            let touchLocation = AimingDegree
            
            let projectile = SKSpriteNode(imageNamed: "grape")
            projectile.setScale(0.3)
            projectile.position = player.position
            projectile.zPosition = 0.5
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.isDynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
            //projectile.physicsBody?.contactTestBitMask = PhysicsCategory.target
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.switchPart
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            let offset = touchLocation - projectile.position
            addChild(projectile)
            
            let direction = offset.normalized()
            let shootAmount = direction * 1200
            
            let realDest = shootAmount + projectile.position
            let actionMove = SKAction.move(to: realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        if projectile.position == CGPoint(x:120.0, y: 0.0) {
            targetChecks[targetPositions[0][1] as! Int] = false
        }else if projectile.position == CGPoint(x:134.35028076171875, y:134.35028076171875) {
            targetChecks[targetPositions[1][1] as! Int] = false
        }else if projectile.position == CGPoint(x:134.35028076171875, y:-134.35028076171875) {
            targetChecks[targetPositions[2][1] as! Int] = false
        }else if projectile.position == CGPoint(x:-120.0, y: 0.0) {
            targetChecks[targetPositions[3][1] as! Int] = false
        }else if projectile.position == CGPoint(x:-134.35028076171875, y:134.35028076171875) {
            targetChecks[targetPositions[4][1] as! Int] = false
        }else if projectile.position == CGPoint(x:-134.35028076171875, y:-134.35028076171875) {
            targetChecks[targetPositions[5][1] as! Int] = false
        }else if projectile.position == CGPoint(x:0.0, y: 120.0) {
            targetChecks[targetPositions[6][1] as! Int] = false
        }else if projectile.position == CGPoint(x:0.0, y: -120.0) {
            targetChecks[targetPositions[7][1] as! Int] = false
        }
        //print(projectile.position, targetPositions[0][0] as! CGPoint)
        
        projectile.removeFromParent()
        monster.removeFromParent()
        targetAmount -= 1
        
        scorePoints += 50
        scoreLabel.text = "Score: " + String(scorePoints)
        
        currentAmmo += 1
        ammoLabel.text = String(currentAmmo)
        print("Hit target")
    }

    func projectileDidCollideWithSwitch(part: SKSpriteNode, projectile: SKSpriteNode) {
        part.removeFromParent()
        print("Switch hit")
        if switchMode == "blue" {
            switchMode = "red"
            projectile.texture = redSwitchText
        }else if switchMode == "red" {
            switchMode = "blue"
            projectile.texture = bluSwitchText
        }
    }
}
