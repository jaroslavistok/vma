//
//  RegisteredUsersViewController.swift
//  5stars-starter
//
//  Created by Jaroslav Istok on 09/12/2016.
//  Copyright © 2016 Touch4IT. All rights reserved.
//

import UIKit
import Parse

class RegisteredUsersViewController: UITableViewController {
    var isPresented = false
    var shouldRefresh = false
    
    @IBAction func refresh(_ sender: Any) {
        self.users.removeAll()
        self.tableView.reloadData()
        populateTable()
    }
    
    @IBAction func logout(_ sender: Any) {
        var store = StateStorage()
        store.isRegistered = false
        store.registeredUserName = ""
        
        if isPresented {
            dismiss(animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "RegistrationViewController")
            present(signInVC, animated: true, completion: nil)
        }
    }
    
    var users = [UserItem]()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = CGFloat(80)
        createActivityIndicator()
        //populateTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.users.removeAll()
        self.tableView.reloadData()
        populateTable()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell \(indexPath.row)!")
        let selectedCell = tableView.cellForRow(at: indexPath)! as! RegisteredUserViewCell
        
        let ratingController = storyboard?.instantiateViewController(withIdentifier: "RatingViewController") as! RatingViewController
        
        ratingController.nickname = selectedCell.userNameLabel.text!
        ratingController.userName = selectedCell.userName!
        ratingController.userImage = selectedCell.userImageView.image!
        ratingController.userToRateStatus = Float(selectedCell.userStatus.text!)
        
        navigationController?.pushViewController(ratingController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! RegisteredUserViewCell
        let item = users[indexPath.row]
        if (item.nickname == ""){
            print(item.nickname)
            cell.userNameLabel.text = item.name
        } else {
            cell.userNameLabel.text = item.nickname
        }
        cell.userName = item.name
        
        
        cell.userStatus.text = String(item.status)
        cell.userImageView.image = item.image
        return cell
    }
    
    private func createActivityIndicator(){
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    private func populateTable(){

        let query = PFQuery(className: "ParseUser").selectKeys(["userName", "userImage", "nickName", "rating", "status"])
        self.activityIndicator.startAnimating()
    
        
        query.findObjectsInBackground { objects, error in
            guard let objects = objects else { return }
            
            let stateStorage = StateStorage()
            
            for (_, object) in objects.enumerated() {
                
                if object["userImage"] == nil  {
        
                    var userStatus = Float(0.0)
                    if (object["status"]) != nil {
                        userStatus = Float(object["status"] as! NSNumber)
                    }
                    var nickName = ""
                    if (object["nickName"]) != nil {
                        nickName = object["nickName"] as! String
                    }
                    var userName = ""
                    if (object["userName"]) != nil {
                        userName = object["userName"] as! String
                    }
                    
                    let user = UserItem(image: UIImage(named: "placeholder.png")!, name: userName, nickname: nickName, status: userStatus)
                    let storage = StateStorage()
                    if (user.name != storage.registeredUserName!){
                        self.addUserAndRefresh(user: user)
                    }
                    continue
                }
                
                let userImageData = object["userImage"] as! PFFile
                let userName = object["userName"] as! String
                
                var userNickname = ""
                var userStatus :Float = 0.00
                
                if (object["nickName"] != nil) {
                    userNickname = object["nickName"] as! String
                }
                
                if (object["status"] != nil) {
                    userStatus = object["status"] as! Float
                }
                
                userImageData.getDataInBackground { (imageData: Data?, error: Error?) -> Void in
                    guard error == nil else { return }
                    if (stateStorage.registeredUserName! != userName){
                        let image =  UIImage(data:imageData!)!
                        let userItem = UserItem(image: image, name: userName, nickname: userNickname, status: userStatus)
                        self.addUserAndRefresh(user: userItem)
                    }
                }
            }
        }
    }
    
    private func addUserAndRefresh(user: UserItem) -> Void {
        self.users.append(user)
        self.tableView.reloadData()
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.stopAnimating()
    }
    
    
    
}
