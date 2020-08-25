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
import Network

let defaultSignalingServerUrl = URL(string: Environment.socketUrl)! //TODO !!!! move to constants
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
    func handleCallClick(id: String, name: String, mode: VideoVCMode)
    func handleClickOnSamePerson()
}

class CallListViewController: UIViewController {
    
    
    
    //MARK: Properties
    private let config = Config.default
    private var roomName: String?
    var onCall: Bool = false
    weak var delegate: CallListViewDelegate?
    var id: String?
    var viewModel: RecentMessagesViewModel?
    var calls: [CallHistory] = []
    var activeCall: FetchedCall?
    var tabbar: MainTabBarController?
    var count = 0
    var otherContactsCount = 0
    static let callCellIdentifier = "callCell"
    var mainRouter: MainRouter?
    var networkCheck = NetworkCheck.sharedInstance()
    var badge: Int?
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    //MARK: LifecyclesF
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
            if let tabItems = self.tabbar?.tabBar.items {
                let tabItem = tabItems[0]
                tabItem.badgeValue = nil
            }
        }
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "calls".localized()
        if UIApplication.shared.applicationState.rawValue == 0 {
            if AppDelegate.shared.badge != nil {
                if AppDelegate.shared.badge! > 0 && viewModel!.calls.count > 0 {
                    AppDelegate.shared.badge = 0
                    let missed = viewModel?.calls.filter({ (call) -> Bool in
                        return call.status == CallStatus.missed.rawValue
                    })
                    tabbar?.viewModel?.checkCallAsSeen(callId: missed![0]._id!, completion: { (error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                            }
                        }
                    })
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabbar = tabBarController as? MainTabBarController
        MainTabBarController.center.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        let vc = tabbar!.viewControllers![2] as! UINavigationController
        let profileVC = vc.viewControllers[0] as! ProfileViewController
        profileVC.delegate = self
        if networkCheck.currentStatus == .satisfied {
            getCallHistory {
                if UIApplication.shared.applicationState.rawValue == 0 {
                if AppDelegate.shared.badge != nil {
                    if AppDelegate.shared.badge! > 0 && self.viewModel!.calls.count > 0 {
                        self.tabbar?.viewModel?.checkCallAsSeen(callId: self.viewModel!.calls[0]._id!, completion: { (error) in
                            if error == nil {
                                AppDelegate.shared.badge = 0
                                DispatchQueue.main.async {
                                    UIApplication.shared.applicationIconBadgeNumber = 0
                                    if let tabItems = self.tabbar?.tabBar.items {
                                        let tabItem = tabItems[0]
                                        tabItem.badgeValue = nil
                                    }
                                }
                                
                            } else {
                                DispatchQueue.main.async {
                                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                                }
                            }
                        })
                    }
                }
                }
            }
        } else {
            getCallHistoryFromDB()
        }
        networkCheck.addObserver(observer: self)
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
    }
    
    //MARK: Helper methods
    @objc func addButtonTapped() {
        mainRouter?.showContactsViewFromCallList()
    }
    
    func getHistory() {
//        activity.startAnimating()
        viewModel!.getHistory { (calls) in
//            self.activity.stopAnimating()
            self.viewModel!.calls = calls
            if self.viewModel!.calls.count == 0 {
                self.addNoCallView()
            }
        }
    }
    
    func stringToDate(date:String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let parsedDate = formatter.date(from: date)
        if parsedDate == nil {
            return nil
        } else {
            return parsedDate
        }
    }
    
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<viewModel!.calls.count {
            for j in i..<viewModel!.calls.count {
                let firstDate = stringToDate(date: viewModel!.calls[i].createdAt!)
                let secondDate = stringToDate(date: viewModel!.calls[j].createdAt!)
                if firstDate!.compare(secondDate!).rawValue == -1 {
                    let temp = viewModel!.calls[i]
                    viewModel!.calls[i] = viewModel!.calls[j]
                    viewModel!.calls[j] = temp
                }
            }
        }
    }
    
    
    func addNoCallView() {
        let label = UILabel()
        label.text = "you_have_no_calls".localized()
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
    
    func handleCall(id: String) {
        self.id = id
        //        if viewModel!.calls.count >= 15 {
        //            viewModel!.deleteItem(index: viewModel!.calls.count - 1)
        //        }
        DispatchQueue.main.async {
            self.view.viewWithTag(20)?.removeFromSuperview()   
        }
    }
    
    func getCallHistory(completion: @escaping (()->())) {
        self.tabbar?.viewModel?.getCallHistory(completion: { (calls, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if calls != nil {
                DispatchQueue.main.async {
                    self.viewModel?.saveCalls(calls: calls!, completion: { (calls, error) in
                        if calls != nil {
                            self.viewModel!.calls = calls!
                            self.sort()
                            self.tableView.reloadData()
                            completion()
                        }
                    })
                }
            }
        })
    }
    
    func getCallHistoryFromDB() {
        viewModel?.getHistory(completion: { (callsFromDB) in
//            self.sort()
            self.tableView.reloadData()
        })
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
    
    func showEndedCall(_ callHistory: CallHistory) {
        viewModel?.save(newCall: callHistory, completion: {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        })
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
    
    func callSelected(id: String, duration: String, callStartTime: Date?, callStatus: String, type: String, name: String, avatarURL: String) {
        var status: CallStatus?
        if callStatus == "ongoing" {
            status = .ongoing
        } else if callStatus == "missed" {
            status = .missed
        } else if callStatus == "accepted" {
            status = .accepted
        } else {
            status = .cancelled
        }
        mainRouter?.showCallDetailViewController(id: id, name: name, duration: duration, time: callStartTime!, callMode: status!, avatarURL: avatarURL)
    }
    
}

extension CallListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.calls.count
    }
    
    func getUser(_ cell: CallTableViewCell, _ indexPath: Int) {
        viewModel!.getuserById(id: cell.calleId!) { (user, error) in
            DispatchQueue.main.async {
                if error != nil {
                    cell.configureCell(contact: User(name: nil, lastname: nil, university: nil, _id: cell.calleId!, username: nil, avaterURL: nil, email: nil, info: nil, phoneNumber: nil, birthday: nil, address: nil, gender: nil), call: self.viewModel!.calls[indexPath])
                } else if user != nil {
                    var newArray = self.tabbar?.contactsViewModel?.otherContacts
                    newArray?.append(user!)
                    self.tabbar?.viewModel!.saveOtherContacts(otherContacts: newArray!, completion: { (users, error) in
                        self.tabbar?.contactsViewModel!.otherContacts = users!
                    })
                    cell.configureCell(contact: user!, call: self.viewModel!.calls[indexPath])
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.callCellIdentifier, for: indexPath) as! CallTableViewCell
        cell.calleId = viewModel!.calls[indexPath.row].caller == SharedConfigs.shared.signedUser?.id ? viewModel!.calls[indexPath.row].receiver : viewModel!.calls[indexPath.row].caller
        var existsInContactList = false
        count = tabbar!.contactsViewModel!.contacts.count
        otherContactsCount = tabbar!.contactsViewModel!.otherContacts.count
        for i in 0..<count {
            if tabbar?.contactsViewModel!.contacts[i]._id == cell.calleId {
                existsInContactList = true
                cell.configureCell(contact: tabbar!.contactsViewModel!.contacts[i], call: viewModel!.calls[indexPath.row])
                break
            }
        }
        if existsInContactList == false {
            for i in 0..<otherContactsCount {
                if tabbar?.contactsViewModel!.otherContacts[i]._id == cell.calleId {
                    existsInContactList = true
                    cell.configureCell(contact: tabbar!.contactsViewModel!.otherContacts[i], call: viewModel!.calls[indexPath.row])
                    break
                }
            }
            if existsInContactList == false {
                getUser(cell, indexPath.row)
            }
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.sort()
        tableView.beginUpdates()
        tabbar?.viewModel?.removeCall(id: viewModel?.calls[indexPath.row]._id ?? "", completion: { (error) in
            if error != nil {
                self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
            } else {
                DispatchQueue.main.async {
                    self.viewModel!.deleteItem(index: indexPath.row, completion: { (error)   in
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        if self.viewModel!.calls.count == 0 {
                            self.addNoCallView()
                        } else {
                            self.view.viewWithTag(20)?.removeFromSuperview()
                        }
                    })
                }
            }
        })
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func saveCall(startDate: Date?) {
        //        if viewModel!.calls.count >= 15 {
        //            viewModel!.deleteItem(index: viewModel!.calls.count - 1)
        //        }
        if startDate == nil {
            activeCall?.callDuration = 0
        } else {
            let userCalendar = Calendar.current
            let requestedComponent: Set<Calendar.Component> = [.hour, .minute, .second]
            let timeDifference = userCalendar.dateComponents(requestedComponent, from: startDate!, to: Date())
            let hourToSeconds = timeDifference.hour! * 3600
            let minuteToSeconds = timeDifference.minute! * 60
            let seconds = timeDifference.second!
            activeCall?.callDuration = hourToSeconds + minuteToSeconds + seconds
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        count = tabbar!.contactsViewModel!.contacts.count
        otherContactsCount = tabbar!.contactsViewModel!.otherContacts.count
        let call = viewModel!.calls[indexPath.row]
        activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: 0, calleeId: SharedConfigs.shared.signedUser!.id)
        activeCall?.time = Date()
        activeCall?.isHandleCall = false
        let calleeId = call.caller == SharedConfigs.shared.signedUser?.id ? call.receiver : call.caller
        if onCall == false  {
            self.delegate?.handleCallClick(id: (call.receiver == SharedConfigs.shared.signedUser?.id ? call.caller : call.receiver)!, name: (tableView.cellForRow(at: indexPath) as! CallTableViewCell).nameLabel.text ?? "", mode: .videoCall)
            
        } else if onCall && id != nil {
            if id == calleeId {
                self.delegate?.handleClickOnSamePerson()
            }
        }
    }
}

extension CallListViewController: NetworkCheckObserver {
    func statusDidChange(status: NWPath.Status) {
        print("status did change \(status)")
    }
}

extension CallListViewController: ProfileViewControllerDelegate {
    func changeLanguage(key: String) {
        self.tableView.reloadData()
    }
}
