//
//  CallViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation
import WebRTC
import CoreData

let defaultSignalingServerUrl = URL(string: "wss://192.168.0.105:8080")!
let defaultIceServers = ["stun:stun.l.google.com:19302",
                         "stun:stun1.l.google.com:19302",
                         "stun:stun2.l.google.com:19302",
                         "stun:stun3.l.google.com:19302",
                         "stun:stun4.l.google.com:19302"]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
}

protocol CallListViewDelegate: class  {
    func handleCallClick(id: String)
    func handleClickOnSamePerson()
}

class CallListViewController: UIViewController {
    
    //MARK: Properties
    private let config = Config.default
    private var roomName: String?
    var onCall: Bool = false
    weak var delegate: CallListViewDelegate?
    var id: String?
    var viewModel = RecentMessagesViewModel()
    var calls: [FetchedCall] = []
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    //MARK: LifecyclesF
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        self.sort()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainTabBarController.center.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        getHistory()
        navigationItem.title = "Call history"
    }
    
    //MARK: Helper methods
    func getHistory() {
        activity.startAnimating()
        viewModel.getHistory { (calls) in
            self.activity.stopAnimating()
            self.viewModel.calls = calls
            if self.viewModel.calls.count == 0 {
                self.addNoCallView()
            }
        }
    }
    
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<viewModel.calls.count {
            for j in i..<viewModel.calls.count {
                let firstDate = viewModel.calls[i].time
                let secondDate = viewModel.calls[j].time
                if firstDate.compare(secondDate).rawValue == -1 {
                    let temp = viewModel.calls[i]
                    viewModel.calls[i] = viewModel.calls[j]
                    viewModel.calls[j] = temp
                }
            }
        }
    }
    
    func addNoCallView() {
       let label = UILabel()
        label.text = "You have no calls"
        label.tag = 20
        label.textAlignment = .center
        label.textColor = .lightGray
        self.tableView.addSubview(label)
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.anchor(top: view.topAnchor, paddingTop: 0, bottom: view.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 25, height: 48)
    }
    
    func handleCall(id: String, user: User) {
        self.id = id
        if viewModel.calls.count >= 15 {
            viewModel.deleteItem()
        }
        DispatchQueue.main.async {
            self.view.viewWithTag(20)?.removeFromSuperview()
            self.viewModel.save(newCall: FetchedCall(id: user._id, name: user.name, username: user.username, imageURL: user.avatarURL, isHandleCall: true, time: Date(), lastname: user.lastname), completion: {
                self.sort()
                self.tableView.reloadData()
            })
          
        }
    }
    

    func deleteAllData(entity: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try managedContext!.fetch(fetchRequest)
            for managedObject in results {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext!.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    func stringToDate(date: Date) -> String {
        let parsedDate = date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate)
        let month = calendar.component(.month, from: parsedDate)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay != day {
            return ("\(day).0\(month)")
        }
        let hour = calendar.component(.hour, from: parsedDate)
        let minutes = calendar.component(.minute, from: parsedDate)
        return ("\(hour):\(minutes)")
    }
    
    
    private func buildSignalingClient() -> SignalingClient {
        return SignalingClient()
    }
}

extension CallListViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension CallListViewController: CallTableViewDelegate {
    func callSelected(id: String) {
        let vc = ContactProfileViewController.instantiate(fromAppStoryboard: .main)
        vc.id = id
        vc.onContactPage = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CallListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.calls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! CallTableViewCell
        cell.calleId = viewModel.calls[indexPath.row].id
        print(viewModel.calls[indexPath.row].imageURL)
        cell.configureCell(call: viewModel.calls[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let call = viewModel.calls[indexPath.row]
        if onCall == false  {
            self.delegate?.handleCallClick(id: call.id)
            if viewModel.calls.count >= 15 {
                viewModel.deleteItem()
            }
            viewModel.save(newCall: FetchedCall(id: call.id, name: call.name, username: call.username, imageURL: call.imageURL, isHandleCall: false, time: Date(), lastname: call.lastname), completion: {
                self.sort()
                self.id = call.id
                self.tableView.reloadData()
                })
           
        } else if onCall && id != nil {
            if id == call.id {
                self.delegate?.handleClickOnSamePerson()
            }
        }
    }
}
