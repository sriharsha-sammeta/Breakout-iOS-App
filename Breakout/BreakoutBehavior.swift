//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Sriharsha Sammeta on 06/04/15.
//  Copyright (c) 2015 Sriharsha Sammeta. All rights reserved.
//

import UIKit

protocol BreakoutBehaviorDelegate{
    func brickTouchedWithIdentity(identity:String)
    func ballWentOutOfBoundary()
}

class BreakoutBehavior: UIDynamicBehavior , UICollisionBehaviorDelegate{
    
    private lazy var collision:UICollisionBehavior = {
        let lazilyCreatedCollision = UICollisionBehavior()
        lazilyCreatedCollision.collisionMode = UICollisionBehaviorMode.Boundaries
        lazilyCreatedCollision.translatesReferenceBoundsIntoBoundary = false
        return lazilyCreatedCollision
        }()
    
    private var push: UIPushBehavior?{
        didSet{
            if push != nil {
                addChildBehavior(push!)
                push!.action = { [unowned self] in
                    self.removeChildBehavior(self.push ?? UIPushBehavior())
                    self.push = nil
                }
            }
        }
    }
    var delegate:BreakoutBehaviorDelegate?
    
//    private var attachment:UIAttachmentBehavior?{
//        willSet{
//            if let attach = attachment{
//                removeChildBehavior(attach)
//            }
//        }
//        didSet{
//            if let attach = attachment{
//                addChildBehavior(attach)
//            }
//        }
//    }
    
    private lazy var gravity:UIGravityBehavior = {
        let lazilyCreatedGravityBehaviour = UIGravityBehavior()
//        lazilyCreatedGravityBehaviour.gravityDirection = CGVector(dx: -1, dy: 0)
        return lazilyCreatedGravityBehaviour
        }()
    private lazy var ballBehavior: UIDynamicItemBehavior = {
       let lazilyCreatedDynamicItemBehaviour = UIDynamicItemBehavior()
        lazilyCreatedDynamicItemBehaviour.elasticity = 1.0
        lazilyCreatedDynamicItemBehaviour.friction = 0
        lazilyCreatedDynamicItemBehaviour.resistance = 0
        lazilyCreatedDynamicItemBehaviour.allowsRotation = false
        return lazilyCreatedDynamicItemBehaviour
    }()
    
    private var bricks:[String:UIView] = [String:UIView]()
    
    private var paddleView:UIView?{
        willSet{
                if let paddle = paddleView {
                    paddle.removeFromSuperview()
                }
        }
        didSet{
            if let paddle = paddleView {
                dynamicAnimator?.referenceView?.addSubview(paddle)
            }
        }
    }
    override init() {
        super.init()
        addChildBehavior(collision)
        addChildBehavior(gravity)
        addChildBehavior(ballBehavior)
        collision.collisionDelegate = self
    }
    
    func pushBalls(ball:UIView, magnitude:CGFloat , direction: CGVector){
        // configure pushbehavior
        var pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.pushDirection = direction
        pushBehavior.magnitude = magnitude
        
//        attachment = nil
        push = pushBehavior
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        println("collision happened at point \(p)")
        if let identity = identifier as? String {
            println(identity)
            if identity.hasPrefix(Names.brickPrefix){
                println("removin brick with identity: " + identity)
                delegate?.brickTouchedWithIdentity(identity)
                removeBrickWithName(identity)
            }
        }
    }
    
    func addBricks(brickWithNames:[String:UIView]){
        var onlyMove = !bricks.isEmpty
        for (brickName, brickView) in brickWithNames {
            if onlyMove && bricks[brickName] == nil {
                println("continue for " + brickName)
                continue
            }
            removeBrickWithName(brickName)
            if dynamicAnimator?.referenceView?.addSubview(brickView) != nil {
                bricks[brickName] = brickView
                println("adding brick with brickname:" + brickName)
                collision.addBoundaryWithIdentifier(brickName,
                    forPath: UIBezierPath(roundedRect: brickView.frame,
                    cornerRadius: brickView.layer.cornerRadius))
            }
        }
    }
    func removeBricks(){
        for (brickName,_) in bricks{
            removeBrickWithName(brickName)
        }
    }
    func removeBrickWithName(brickName:String){
        collision.removeBoundaryWithIdentifier(brickName)
        bricks[brickName]?.removeFromSuperview()
        bricks[brickName] = nil
    }
    
    func addBarrierForBoundaryPath(endPointsOfLine points:(point1:CGPoint,point2:CGPoint) ,boundaryIdentifier:String){
        collision.removeBoundaryWithIdentifier(boundaryIdentifier)
        collision.addBoundaryWithIdentifier(boundaryIdentifier,
            fromPoint: points.point1,
            toPoint: points.point2)
    }
    
    func addPaddle(paddle:UIView, usingIdentifier paddleIdentifier: String, isPaddleInViewBounds :Bool){
        
        collision.removeBoundaryWithIdentifier(paddleIdentifier)
        var paddleshouldBeAddedAgain = !isPaddleInViewBounds
        if paddleView == nil || paddleshouldBeAddedAgain {
            paddleView = paddle
        }else{
            paddleView!.frame.origin = paddle.frame.origin
            paddleView!.frame.size = paddle.frame.size
        }
        collision.addBoundaryWithIdentifier(paddleIdentifier, forPath: UIBezierPath(roundedRect: paddleView!.frame, cornerRadius: paddleView!.layer.cornerRadius))
    }
    
    
    
    func addBall(ball: UIView , onlyMove:Bool = false){
        if let paddle = paddleView {
            ball.frame.origin = CGPoint(x: paddle.frame.midX - (ball.bounds.width / 2), y: paddle.frame.origin.y - ball.bounds.height - 1)
            self.dynamicAnimator?.updateItemUsingCurrentState(ball)
        }
        if !onlyMove && dynamicAnimator?.referenceView?.addSubview(ball) != nil {
            collision.addItem(ball)
//            gravity.addItem(ball)
            ballBehavior.addItem(ball)
            println("added behaviors to ball \(ball.frame)")
            return
        }
        
        ballBehavior.addLinearVelocity(CGPoint(x: -ballBehavior.linearVelocityForItem(ball).x, y: -ballBehavior.linearVelocityForItem(ball).y), forItem: ball)

    }
    
    func isBallAtRest(ball:UIView)->Bool{
        return ballBehavior.linearVelocityForItem(ball) == CGPointZero
    }
    func removeBall(ballToRemove:UIView){
        collision.removeItem(ballToRemove)
//        gravity.removeItem(ballToRemove)
        ballBehavior.removeItem(ballToRemove)
        ballToRemove.removeFromSuperview()
        println("removed behaviors for ball and also from superView \(ballToRemove.frame)")
    }
    
    func changeBallElasticityTo(elasticity:CGFloat){
        ballBehavior.elasticity = elasticity
    }

    
}





