//  BreakoutViewController.swift
//  Breakout
//
//  Created by Sriharsha Sammeta on 05/04/15.
//  Copyright (c) 2015 Sriharsha Sammeta. All rights reserved.

import UIKit

public struct Names{
    private static func barrierForBoundary(boundaryNum:Int)->String{
        return  gameViewBoundaryPrefix + "\(boundaryNum)"
    }
    public static let gameViewBoundaryPrefix = "GameView Boundary"
    private static func brickName(brickNum: CGFloat) ->String{
        return brickPrefix + "\(brickNum)"
    }
    public static let brickPrefix = "Brick"
    private static let paddleName = "Paddle Barrier"
    
    static let noOfBricksPerRow = "Number of Bricks Per Row"
    static let noOfRows = "Number of Brick Rows"
    static let ballBounciness = "Ball elasticity"
    static let noOfBalls = "Number of Balls"
}



class BreakoutViewController: UIViewController,BreakoutBehaviorDelegate
{
    @IBOutlet weak var gameView: UIView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var livesLabel: UILabel!
   
    
    lazy var animator:UIDynamicAnimator  = {
        let lazilyCreatedAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return lazilyCreatedAnimator
    }()
    
    lazy var breakoutBehavior: BreakoutBehavior = {
        let lazilyCreatedBreakoutBehavior = BreakoutBehavior()
        self.animator.addBehavior(lazilyCreatedBreakoutBehavior)
        lazilyCreatedBreakoutBehavior.delegate = self
        return lazilyCreatedBreakoutBehavior
    }()
    
    var numberOfBricksPerRow:CGFloat = 5 {
        didSet{
            reset()
        }
    }
    var numberOfRows:CGFloat = 5 {
        didSet{
            reset()
        }
    }
    let heightOfBrick:CGFloat = 20
    let spaceBetweenBricks:CGFloat = 5
    let paddleSize = CGSize(width: 80, height: 20)
    let ballSize = CGSize(width:20,height:20)
    var paddleDistanceFromBase:CGFloat {
        return gameView.bounds.height / 6
    }
    private var bricksSize:CGSize {
        get{
            var widthOfBrick = (gameView.bounds.width - (CGFloat(numberOfBricksPerRow) + 1) * spaceBetweenBricks) / CGFloat(numberOfBricksPerRow)
            return CGSize(width: widthOfBrick, height: heightOfBrick)
        }
    }
    private var brickRadius:CGFloat {
        return bricksSize.height / 2
    }
    private var paddleRadius:CGFloat {
        return paddleSize.height / 2
    }
    
    var numberOfBalls:Int = 1 {
        didSet{
            reset()
        }
    }
    var ballElasticity:CGFloat = 1 {
        didSet{
            breakoutBehavior.changeBallElasticityTo(ballElasticity)
        }
    }
    private var balls = [UIView]()
    private var score:Double = 0 {
        didSet{
            scoreLabel?.text = "Score: \(score)"
        }
    }
    private var lives:Int = 3{
        didSet{
            if lives <= 0 {
                lives = 0
            }
            livesLabel?.text = "Lives: x\(lives)"
        }
    }
    private var gameViewBounds:CGRect?
    
    func brickTouchedWithIdentity(identity: String) {
        score += 3
        println("Score updated to \(score)")
    }
    func ballWentOutOfBoundary() {
        lives--
        println("lives updated to \(lives)")
        if lives == 0{
            var alert = UIAlertController(title: "Game Over 😳😅 !", message: "You Scored: \(score)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Restart",
                style: UIAlertActionStyle.Default,
                handler: {(alert: UIAlertAction!) in
                    self.reset()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func addBricks(color: UIColor = UIColor.blueColor()){
        
        var bricks = [String:UIView]()
        breakoutBehavior.removeBricks()
        for var row:CGFloat = 1; row <= numberOfRows; row++ {
            for var brickNumberInRow:CGFloat = 1; brickNumberInRow <= numberOfBricksPerRow; brickNumberInRow++ {
                let brickOriginX = (spaceBetweenBricks * brickNumberInRow) + (bricksSize.width * (brickNumberInRow - 1))
                let brickOriginY = (spaceBetweenBricks * row) + (bricksSize.height * (row - 1)) + gameView.bounds.origin.y
                let brickOrigin = CGPoint(x: brickOriginX, y: brickOriginY)
                var brickView = UIView(frame: CGRect(origin: brickOrigin, size: bricksSize))
                brickView.layer.cornerRadius = brickRadius
                let brickNumber = ((row - 1) * numberOfBricksPerRow) + brickNumberInRow
                let brickName = Names.brickName(brickNumber)
                brickView.backgroundColor = color
                println("brick origin \(brickOrigin)")
                bricks[brickName] = brickView
            }
        }
        breakoutBehavior.addBricks(bricks)
    }
    
    
    
    func movePaddleToMidPoint(midPoint:CGPoint, usingColor color:UIColor = UIColor.greenColor()){
        var paddleOrigin =  CGPoint(x: midPoint.x - (paddleSize.width / 2), y: gameView.bounds.height - paddleDistanceFromBase)
        if paddleOrigin.x < animator.referenceView?.frame.minX {
            paddleOrigin = CGPoint(x:  gameView.frame.minX,y:paddleOrigin.y)
        }else if paddleOrigin.x + paddleSize.width > animator.referenceView?.frame.maxX{
            paddleOrigin = CGPoint(x: gameView.frame.maxX - paddleSize.width, y: paddleOrigin.y)
        }
        var paddleView = UIView(frame: CGRect(origin: paddleOrigin, size: paddleSize))
        paddleView.layer.cornerRadius = paddleRadius
        paddleView.backgroundColor = color
        breakoutBehavior.addPaddle(paddleView,usingIdentifier: Names.paddleName, isPaddleInViewBounds: gameView.bounds.contains(paddleView.bounds))
    }
    
    @IBAction func movePaddle(sender: UIPanGestureRecognizer) {
        var midPoint = sender.locationInView(gameView)
        switch sender.state{
        case .Began,.Changed,.Ended:
            movePaddleToMidPoint(midPoint)
            for ball in balls{
                if breakoutBehavior.isBallAtRest(ball){
                    breakoutBehavior.addBall(ball, onlyMove: true)
                }
            }
            default: break
        }
    }
    
    @IBAction func push(sender: UITapGestureRecognizer) {
        for ball in balls {
            var dx = CGFloat.random(100)
            var dy = CGFloat.random(100)
            let directionVector = CGVector(dx: dx, dy: dy)
            breakoutBehavior.pushBalls(ball,magnitude: ballSize.width / 100, direction: directionVector)
        }
    }
    
    func addBarrierForBoundary(){
        if let bounds = gameView?.bounds {
            println("inside barrier for boundarys ")
            var rightBottom = CGPoint(x: bounds.maxX, y: bounds.maxY)
            var rightTop = CGPoint(x: bounds.maxX, y: bounds.minY)
            var leftTop = CGPoint(x: bounds.minX, y: bounds.minY)
            var leftBottom = CGPoint(x: bounds.minX, y: bounds.maxY)
            println("\(rightBottom)")
            println("\(rightTop)")
            println("\(leftTop)")
            println("\(leftBottom)")
            var points = [(rightBottom,rightTop),(rightTop,leftTop),(leftTop,leftBottom)]
            for (index,point) in enumerate(points){
                breakoutBehavior.addBarrierForBoundaryPath(endPointsOfLine: (point.0,point.1), boundaryIdentifier: Names.barrierForBoundary(index))
            }
        }
    }
    
    func addBalls(){
        for ball in balls{
            breakoutBehavior.removeBall(ball)
        }
        balls.removeAll(keepCapacity: false)
        
        for count in 1...numberOfBalls{
            var tempBallView = UIView(frame: CGRect(origin: CGPoint(x: 200, y: 200), size: ballSize))
            tempBallView.layer.cornerRadius = ballSize.width / 2
            tempBallView.backgroundColor = UIColor.redColor()
            balls.append(tempBallView)
            breakoutBehavior.addBall(tempBallView)
        }
    }
    
    func resetLives(){
        lives = 3
    }
    func resetScore(){
        score = 0
    }
    
    func reset(){
        resetScore()
        resetLives()
        addBarrierForBoundary()
        addBricks()
        var paddlePoint = CGPoint(x: gameView.frame.midX, y: gameView.frame.midY)
        movePaddleToMidPoint(paddlePoint)
        addBalls()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("inside viewdidload")

        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.objectForKey(Names.noOfBalls) == nil {
            defaults.setInteger(numberOfBalls, forKey: Names.noOfBalls)
        }
        if defaults.objectForKey(Names.noOfBricksPerRow) == nil {
            defaults.setFloat(Float(numberOfBricksPerRow), forKey: Names.noOfBricksPerRow)
        }
        if defaults.objectForKey(Names.noOfRows) == nil {
            defaults.setFloat(Float(numberOfRows), forKey: Names.noOfRows)
        }
        if defaults.objectForKey(Names.ballBounciness) == nil {
            defaults.setFloat(Float(ballElasticity), forKey: Names.ballBounciness)
        }
        
        
        numberOfBalls = defaults.integerForKey(Names.noOfBalls)
        numberOfBricksPerRow = CGFloat(defaults.floatForKey(Names.noOfBricksPerRow))
        numberOfRows = CGFloat(defaults.floatForKey(Names.noOfRows))
        ballElasticity = CGFloat(defaults.floatForKey(Names.ballBounciness))

        
        breakoutBehavior.action = {
            [unowned self] in
            var ballsToRemove = self.balls.filter{
                if let superView = $0.superview {
                    var superBounds = CGRect(origin: CGPoint(x: superView.bounds.origin.x - self.ballSize.width, y: superView.bounds.origin.y - self.ballSize.height), size: CGSize(width: superView.bounds.width + 2 * self.ballSize.width, height: superView.bounds.height + 2 * self.ballSize.height))
                    return !CGRectContainsRect(superBounds, $0.frame)
                }
                return false
            }
            if !ballsToRemove.isEmpty {
                println("\(ballsToRemove)")
            }
            
            if ballsToRemove.count == self.balls.count{
                self.ballWentOutOfBoundary()
            }
            
            for ballToRemove in ballsToRemove{
                
                self.breakoutBehavior.addBall(ballToRemove,onlyMove:true)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        println("inside viewdidlayoutSubViews")
        if gameViewBounds == nil || gameViewBounds != gameView.bounds{
            gameViewBounds = gameView.bounds
            reset()
        }
    }
    
}
private extension CGFloat {
    
    static func random(num:CGFloat, onlyNegative:Bool = false )->CGFloat{
        var randomCGFloat = CGFloat(arc4random()) % num
        return onlyNegative && randomCGFloat > 0 ? -randomCGFloat : randomCGFloat
    }
    
}


    