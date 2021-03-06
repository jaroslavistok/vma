//
//  RatingViewController.swift
//  5stars-starter
//
//  Created by Jaroslav Istok on 14/01/2017.
//  Copyright © 2017 Touch4IT. All rights reserved.
//

import UIKit
import Parse

class RatingViewController: UIViewController {

    public var userImage: UIImage?
    public var nickname: String?
    public var userName: String?
    
    public var assessmentUserStatus: Float?
    public var userToRateStatus: Float?
    public var starsSelected: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        statusLabelCenterX.constant -= view.bounds.width

        
    }
    
    func setCurrentStatus(){
        if (userToRateStatus! >= Float(1) && userToRateStatus! < Float(2)){
            oneStar.isSelected = true
            starsSelected = 1
        }
        if (userToRateStatus! >= Float(2) && userToRateStatus! < Float(3)){
            oneStar.isSelected = true
            twoStar.isSelected = true
            starsSelected = 2
        }
        
        if (userToRateStatus! >= Float(3) && userToRateStatus! < Float(4)){
            oneStar.isSelected = true
            twoStar.isSelected = true
            threeStar.isSelected = true
            starsSelected = 3
        }
        
        if (userToRateStatus! >= Float(4) && userToRateStatus! < Float(5)){
            oneStar.isSelected = true
            twoStar.isSelected = true
            threeStar.isSelected = true
            fourStar.isSelected = true
            starsSelected = 4
        }
        
        if (userToRateStatus! == Float(5)){
            oneStar.isSelected = true
            twoStar.isSelected = true
            threeStar.isSelected = true
            fourStar.isSelected = true
            fiveStar.isSelected = true
            starsSelected = 5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //animation
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            // 1. nastaviť constraint
            self.statusLabelCenterX.constant += self.view.bounds.width
            // 2. invalidate layout
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        var stateStorage = StateStorage()
        let registeredUser = stateStorage.registeredUserName
        let userToRate = nickname
        let welcomeString = "Welcome \(registeredUser!) do you want to give rating to \(userToRate!) ?"
        welcomeText.text = welcomeString
        userImageView.image = userImage!
        
        setCurrentStatus()
        
        saveButton.isEnabled = false
        
        statusLabel.text = statusLabel.text! + " " + String(describing: userToRateStatus!)
        
        let storage = StateStorage()
        let assesmentUserName = storage.registeredUserName
        let query = PFQuery(className: "ParseUser").selectKeys(["status"]).whereKey("userName", equalTo: assesmentUserName!)
        
        print(assesmentUserName!)
        
        query.findObjectsInBackground { [unowned self] objects, error in
            guard let objects = objects else { return }
            print("In closure \(error)")
            guard error == nil else {
                return
            }
            print("Obejcts count \(objects.count)")
            if (objects.count == 1){
                let object = objects[0]
                var status :Float = 5
                if (object["status"] != nil){
                    status = object["status"] as! Float
                }
                self.assessmentUserStatus = status
                print("assesment status \(self.assessmentUserStatus)")
            }
        }
    }
    @IBOutlet weak var saveButton: UIBarButtonItem!
    

    
    public func saveNewStatusAndRating(status: Float){
        let query = PFQuery(className: "ParseUser").selectKeys(["status"]).whereKey("userName", equalTo: userName!)

        
        query.findObjectsInBackground { [unowned self] objects, error in
            print("")
            guard let objects = objects else { return }
            print("In closure \(error)")
            guard error == nil else {
                return
            }
            print("Obejcts count \(objects.count)")
            if (objects.count == 1){
                let object = objects[0]
                object["status"] = status
                print("Status: \(status)")
                object.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                    if error == nil {
                        print("Status and rating updated")
                        _ = self.navigationController?.popToRootViewController(animated: true)
                        let rController = self.storyboard?.instantiateViewController(withIdentifier: "RegisteredUsersController") as! RegisteredUsersViewController
                        rController.shouldRefresh = true
                    } else {
                        print("nepodarilo sa updatovat status a rating")
                        print(error!)
                    }
                })
            }
        }
        
        
        
    }
    @IBAction func saveButtonAction(_ sender: Any) {
        let weight :Float = Float(assessmentUserStatus!) / Float(5.0)
        print("Weight: \(weight)")
        
        
        var rating : Float = 0.0
        if (starsSelected == 5){
            rating = +1 * 5 * 0.01 * weight
        } else {
            rating = Float(-1) * Float((5 - starsSelected!)) * 0.01 * weight
        }
        
        var newStatus = min(Float(userToRateStatus!) + rating, 5)
        if (newStatus < Float(0)){
            newStatus = Float(0)
        }
        
        saveNewStatusAndRating(status: newStatus)
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var statusLabelCenterX: NSLayoutConstraint!
    
    // buttons
    @IBOutlet weak var oneStar: UIButton!
    @IBOutlet weak var twoStar: UIButton!
    @IBOutlet weak var threeStar: UIButton!
    @IBOutlet weak var fourStar: UIButton!
    @IBOutlet weak var fiveStar: UIButton!
    
    func resetStates(){
        oneStar.isSelected = false
        twoStar.isSelected = false
        threeStar.isSelected = false
        fourStar.isSelected = false
        fiveStar.isSelected = false
    }
    
    @IBAction func oneStarAction(_ star: UIButton) {
        resetStates()
        star.isSelected = !star.isSelected
        starsSelected = 1
        saveButton.isEnabled = true
    }
    
    @IBAction func twoStarAction(_ star: UIButton) {
        resetStates()
        star.isSelected = !star.isSelected
        oneStar.isSelected = !oneStar.isSelected
        starsSelected = 2
        saveButton.isEnabled = true
    }
    
    @IBAction func threeStarAction(_ star: UIButton){
        resetStates()
        star.isSelected = !star.isSelected
        oneStar.isSelected = !oneStar.isSelected
        twoStar.isSelected = !twoStar.isSelected
        starsSelected = 3
        saveButton.isEnabled = true
    }
    
    @IBAction func fourStarAction(_ star: UIButton) {
        resetStates()
        star.isSelected = !star.isSelected
        oneStar.isSelected = !oneStar.isSelected
        twoStar.isSelected = !twoStar.isSelected
        threeStar.isSelected = !threeStar.isSelected
        starsSelected = 4
        saveButton.isEnabled = true
    }
    
    @IBAction func fiveStarAction(_ star: UIButton) {
        resetStates()
        star.isSelected = !star.isSelected
        oneStar.isSelected = !oneStar.isSelected
        twoStar.isSelected = !twoStar.isSelected
        threeStar.isSelected = !threeStar.isSelected
        fourStar.isSelected = !fourStar.isSelected
        starsSelected = 5
        saveButton.isEnabled = true
    }
}
