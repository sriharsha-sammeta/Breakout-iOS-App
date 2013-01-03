//
//  BreakoutSettingsViewController.swift
//  Breakout
//
//  Created by Sriharsha Sammeta on 15/04/15.
//  Copyright (c) 2015 Sriharsha Sammeta. All rights reserved.
//

import UIKit

class BreakoutSettingsViewController: UIViewController {
    @IBOutlet weak var noOfBricksLabel: UILabel! {
        didSet{
            let defaults = NSUserDefaults.standardUserDefaults()
            if let bricksPerRow = defaults.objectForKey(Names.noOfBricksPerRow) as? CGFloat{
                println("inside bricks per row")
                noOfBricksLabel?.text = "No of Bricks per Row(\(bricksPerRow)):"
            }
        }
    }

    @IBOutlet weak var noOfRowsLabel: UILabel!{
        didSet{
            let defaults = NSUserDefaults.standardUserDefaults()
            if let noOfRows = defaults.objectForKey(Names.noOfRows) as? CGFloat{
                noOfRowsLabel?.text = "No of Rows(\(Float(noOfRows)))"
            }
        }
    }
    
    @IBOutlet weak var noOfBallsLabel: UILabel!{
        didSet{
            let defaults = NSUserDefaults.standardUserDefaults()
            if let noOfBalls = defaults.objectForKey(Names.noOfBalls) as? Int{
                noOfBallsLabel?.text = "No of Balls (\(noOfBalls))"
            }
        }
    }
    
    @IBOutlet weak var ballBouncinessLabel: UILabel! {
        didSet{
            let defaults = NSUserDefaults.standardUserDefaults()
            if let ballBounciness = defaults.objectForKey(Names.ballBounciness) as? CGFloat{
                ballBouncinessLabel?.text = "Bounciness (\(Float(ballBounciness)))"
            }
        }
    }
    
    
    
    @IBOutlet weak var bricksPerRowStepper: UIStepper!{
        didSet{
        }
    }
    @IBOutlet weak var bouncinessSlider: UISlider!{
        didSet{
            let defaults = NSUserDefaults.standardUserDefaults()
            if let ballBounciness = defaults.objectForKey(Names.ballBounciness) as? CGFloat{
                println("inside bounci slider")
                bouncinessSlider.value = Float(ballBounciness)
            }
        }
    }
    @IBOutlet weak var noOfRowsSlider: UISlider!{
        didSet{
            let defaults = NSUserDefaults.standardUserDefaults()
            if let noOfRows = defaults.objectForKey(Names.noOfRows) as? CGFloat{
                println("insde no of rows slider")
                noOfRowsSlider.value = Float(noOfRows)
            }
        }
    }
    @IBOutlet weak var noOfBallsSegmentedControl: UISegmentedControl!{
        didSet{
            let defaults = NSUserDefaults.standardUserDefaults()
            if let noOfBalls = defaults.objectForKey(Names.noOfBalls) as? Int{
                println("inside no of balls segmented controle")
                noOfBallsSegmentedControl.selectedSegmentIndex = noOfBalls - 1
            }
        }
    }
    
    @IBAction func noOfBricksPerRowChanged(sender: UIStepper) {
        if let bvc = tabBarController?.viewControllers?[0] as? BreakoutViewController{
            let defaults = NSUserDefaults.standardUserDefaults()
            bvc.numberOfBricksPerRow = CGFloat(sender.value)
            defaults.setFloat(Float(bvc.numberOfBricksPerRow), forKey: Names.noOfBricksPerRow)
            noOfBricksLabel.text = "No of Bricks per Row(\(sender.value)):"
            defaults.synchronize()
        }
    }
   
    @IBAction func noOfRows(sender: UISlider) {
        if let bvc = tabBarController?.viewControllers?[0] as? BreakoutViewController{
            let defaults = NSUserDefaults.standardUserDefaults()
            sender.value = round(sender.value)
            bvc.numberOfRows = CGFloat(sender.value)
            defaults.setFloat(Float(bvc.numberOfRows), forKey: Names.noOfRows)
            noOfRowsLabel.text = "No of Rows(\(sender.value)):"
            defaults.synchronize()
        }
    }
    
    @IBAction func noOfBalls(sender: UISegmentedControl) {
        if let bvc = tabBarController?.viewControllers?[0] as? BreakoutViewController{
            let defaults = NSUserDefaults.standardUserDefaults()
            bvc.numberOfBalls = sender.selectedSegmentIndex + 1
            defaults.setInteger(bvc.numberOfBalls, forKey: Names.noOfBalls)
            noOfBallsLabel.text = "No of Balls (\(bvc.numberOfBalls)):"
            defaults.synchronize()
        }
    }
    
    @IBAction func ballBouncinessChanged(sender: UISlider) {
        if let bvc = tabBarController?.viewControllers?[0] as? BreakoutViewController{
            let defaults = NSUserDefaults.standardUserDefaults()
            bvc.ballElasticity = CGFloat(sender.value)
            defaults.setFloat(Float(bvc.ballElasticity), forKey: Names.ballBounciness)
            ballBouncinessLabel.text = "Bounciness (\(sender.value)):"
            defaults.synchronize()
        }
    }
    
}
