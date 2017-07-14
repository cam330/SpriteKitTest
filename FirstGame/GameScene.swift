//
//  GameScene.swift
//  FirstGame
//
//  Created by Cameron Wilcox on 7/13/17.
//  Copyright © 2017 Cameron Wilcox. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Ball   : UInt32 = 0b1       // 1
}


func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
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

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    let manager = CMMotionManager()
    
    
    var circle:SKShapeNode!
    
    var shapeNodes : [SKShapeNode] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        var myX = Double()
        var myY = Double()
        
//        var newFrame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
//        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(oneLittleCircle),SKAction.wait(forDuration: 0.5)])))
        run(SKAction.repeat(SKAction.sequence([SKAction.run(oneLittleCircle),SKAction.wait(forDuration: 0.01)]), count: 100))
        
//        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.01
            manager.startAccelerometerUpdates(to: .main) {
                [weak self] (data: CMAccelerometerData?, error: Error?) in
                if let acceleration = data?.acceleration {
                    let rotation = atan2(acceleration.x, acceleration.y) - M_PI
                    //                    self?.imageView.transform = CGAffineTransform(rotationAngle: rotation)
                    let variable = CGAffineTransform(rotationAngle: CGFloat(rotation))
                    myX = Double(acceleration.x)
                    myY = Double(acceleration.y)
                    
                    print(myX)
                    print(myY)
                    let vector = CGVector(dx: myX, dy: myY)
//                    gravity.gravityDirection = vector
                    self?.physicsWorld.gravity = vector
                }
            }
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func oneLittleCircle(){
        circle = SKShapeNode(circleOfRadius: 10)
        let actualY = random(min: circle.frame.size.height/2, max: size.height - circle.frame.size.height/2)
        circle.position = CGPoint(x: actualY, y: frame.maxY)
        circle.strokeColor = SKColor.black
        circle.fillColor = .random()
        circle.glowWidth = 1.0
        circle.physicsBody?.usesPreciseCollisionDetection = true
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        circle.physicsBody!.affectedByGravity = true
        self.addChild(circle)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        var touchLocation = touch.location(in: self)
        
        let offset = touchLocation - circle.position
        
        let direction = offset.normalized()
        
        let realDest = direction + circle.position
        
        let actionMove = SKAction.move(to: realDest, duration: 1.0)
        circle.run(SKAction.sequence([actionMove]))
    }
    
}















