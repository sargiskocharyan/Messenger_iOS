//
//  RecentMessagesViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class RecentMessagesViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    static let cellID = "messageCell"
    var chats: [Chat] = []
    var isLoaded: Bool = false
    let viewModel = RecentMessagesViewModel()
    let socketTaskManager = SocketTaskManager.shared
    var isLoadedMessages = false
    let refreshControl = UIRefreshControl()
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nc = (self.tabBarController?.viewControllers?[4]) as? UINavigationController
        let vc = nc?.viewControllers[0] as! ProfileViewController
        vc.delegate = self
        getChats()
        self.navigationController?.navigationBar.topItem?.title = "chats".localized()
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isLoadedMessages && chats.count == 0 {
            setView("You have no message")
        }
    }
    
    //MARK: Helper methods
    @objc func refreshData() {
        getChats()
    }
    
    @objc func addButtonTapped() {
        let vc = ContactsViewController.instantiate(fromAppStoryboard: .main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<chats.count {
            for j in i..<chats.count {
                guard chats[i].message != nil, chats[j].message != nil else {
                    break
                }
                let firstDate = formatter.date(from: chats[i].message!.createdAt ?? "")
                let secondDate = formatter.date(from: chats[j].message!.createdAt ?? "")
                if firstDate?.compare(secondDate!).rawValue == -1 {
                    let temp = chats[i]
                    chats[i] = chats[j]
                    chats[j] = temp
                }
            }
        }
    }
    
    func setView(_ str: String) {
        DispatchQueue.main.async {
            self.removeView()
            let noResultView = UIView(frame: self.view.frame)
            noResultView.tag = 1
            noResultView.backgroundColor = .white
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: self.view.frame.height))
            label.center = noResultView.center
            label.text = str
            label.textColor = .lightGray
            label.textAlignment = .center
            noResultView.addSubview(label)
            self.view.addSubview(noResultView)
        }
    }
    
    func removeView() {
        DispatchQueue.main.async {
            let resultView = self.view.viewWithTag(1)
            resultView?.removeFromSuperview()
        }
    }
    
    func stringToDate(date:String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let parsedDate = formatter.date(from: date)
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate!)
        let month = calendar.component(.month, from: parsedDate!)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay != day {
            return ("\(day).0\(month)")
        }
        let hour = calendar.component(.hour, from: parsedDate!)
        let minutes = calendar.component(.minute, from: parsedDate!)
        return ("\(hour):\(minutes)")
    }
    
    func getChats() {
        self.isLoaded = true
        if isLoadedMessages == false {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        }
        
        viewModel.getChats { (messages, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.activityIndicator.stopAnimating()
                }
            }
            else {
                if (messages != nil) {
                    self.isLoadedMessages = true
                    if messages?.count == 0 {
                        self.setView("You have no messages")
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                    } else {
                        self.chats = messages!.filter({ (chat) -> Bool in
                            return chat.message != nil
                        })
                        self.sort()
                        DispatchQueue.main.async {
                            self.removeView()
                            self.activityIndicator.stopAnimating()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func getnewMessage(message: Message) {
        var id = ""
        if message.sender?.id == SharedConfigs.shared.signedUser?.id {
            id = message.reciever ?? ""
        } else {
            id = (message.sender?.id! ?? "") as String
        }
        self.viewModel.getuserById(id: id) { (user, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.activityIndicator.stopAnimating()
                }
            } else if user != nil {
                DispatchQueue.main.async {
                    self.removeView()
                    let visibleViewController = self.navigationController?.visibleViewController
                    if visibleViewController is ChatViewController {
                        let chatViewController = visibleViewController as! ChatViewController
                        chatViewController.getnewMessage( message: message)
                    }
                }
                for i in 0..<self.chats.count {
                    if self.chats[i].id == id {
                        self.chats[i] = Chat(id: id, name: user!.name, lastname: user!.lastname, username: user!.username, message: message, recipientAvatarURL: user!.avatarURL)
                        self.sort()
                        DispatchQueue.main.async {
                            self.tableView?.reloadData()
                        }
                        return
                    }
                }
                self.chats.append(Chat(id: id, name: user!.name, lastname: user!.lastname, username: user!.username, message: message, recipientAvatarURL: user?.avatarURL))
                self.sort()
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        }
    }
}

//MARK: Extension
extension RecentMessagesViewController: UITableViewDelegate, UITableViewDataSource, ProfileViewControllerDelegate, UNUserNotificationCenterDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatViewController.instantiate(fromAppStoryboard: .main)
        vc.name = chats[indexPath.row].name
        vc.username = chats[indexPath.row].username
        vc.avatar = chats[indexPath.row].recipientAvatarURL
        vc.id = chats[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        removeView()
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath) as! RecentMessageTableViewCell
        cell.configure(chat: chats[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func changeLanguage(key: String) {
        self.navigationController?.navigationBar.topItem?.title = "chats".localized()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
