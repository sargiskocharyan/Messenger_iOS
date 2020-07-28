//
//  ContactsViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    var findedUsers: [User] = []
    var contactsMiniInformation: [User] = []
    var viewModel: ContactsViewModel?
    var onContactPage = true
    var isLoaded = false
    var isLoadedFoundUsers = false
    let refreshControl = UIRefreshControl()
    var tabbar: MainTabBarController?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tabbar = tabBarController as! MainTabBarController
        viewModel = tabbar?.contactsViewModel
        tableView.dataSource = self
        setNavigationItems()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        getContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
         getContacts()
        contactsMiniInformation = viewModel!.contacts
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isLoaded && viewModel!.contacts.count == 0 && onContactPage {
            removeView()
            setView("no_contacts".localized())
        }
        if findedUsers.count == 0 && isLoadedFoundUsers && !onContactPage {
            removeView()
            setView("there_is_no_result".localized())
        }
    }
    
    //MARK: Helper methods
    func setNavigationItems() {
        if onContactPage {
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
            self.navigationItem.title = "contacts".localized()
        } else {
            self.navigationItem.rightBarButtonItem = .init(title: "reset", style: .plain, target: self, action: #selector(backToContacts))
            self.navigationItem.title = "found_users"
        }
    }
    
    @objc func backToContacts() {
        contactsMiniInformation = viewModel!.contacts
        DispatchQueue.main.async {
            self.removeView()
            if self.viewModel!.contacts.count == 0 {
                self.setView("no_contacts".localized())
            }
            self.onContactPage = true
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
            self.navigationItem.title = "contacts".localized()
        }
    }
    
    @objc func handleAlertChange(sender: Any?) {
        let textField = sender as! UITextField
        if textField.text != "" {
            self.viewModel!.findUsers(term: (textField.text)!) { (responseObject, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "error_message".localized() , message: error?.rawValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                } else if responseObject != nil {
                    self.isLoadedFoundUsers = true
                    if responseObject?.users.count == 0 {
                        DispatchQueue.main.async {
                            self.contactsMiniInformation = []
                            self.tableView.reloadData()
                            self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                            self.navigationItem.title = "found_users".localized()
                            self.activityIndicator.stopAnimating()
                            self.setView("there_is_no_result".localized())
                        }
                        return
                    }
                    self.findedUsers = []
                    for i in 0..<responseObject!.users.count {
                        var a = false
                        for j in 0..<self.viewModel!.contacts.count {
                            if responseObject!.users[i]._id == self.viewModel!.contacts[j]._id {
                                a = true
                                break
                            }
                        }
                        if a == false {
                            self.findedUsers.append(responseObject!.users[i])
                        }
                    }
                    self.contactsMiniInformation = self.findedUsers.map({ (user) -> User in
                        User(name: user.name, lastname: user.lastname, university: nil, _id: user._id!, username: user.username, avaterURL: user.avatarURL, email: nil, info: user.info, phoneNumber: user.phoneNumber, birthday: user.birthday, address: user.address, gender: user.gender)
                    })
                    DispatchQueue.main.async {
                        self.removeView()
                        self.tableView.reloadData()
                        self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                        self.navigationItem.title = "found_users".localized()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.contactsMiniInformation = []
                self.tableView.reloadData()
                self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                self.navigationItem.title = "found_users".localized()
                self.activityIndicator.stopAnimating()
                self.setView("there_is_no_result".localized())
            }
        }
    }
    
    @objc func addButtonTapped() {
        onContactPage = false
        let alert = UIAlertController(title: "search_user".localized()
            , message: "enter_name_or_lastname_or_username".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.addTarget(self, action: #selector(self.handleAlertChange(sender:)), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setView(_ str: String) {
        DispatchQueue.main.async {
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
    
    func getContacts() {
        if !isLoaded {
            activityIndicator.startAnimating()
        }
            self.isLoaded = true
            if viewModel!.contacts.count == 0 {
                self.setView("no_contacts".localized())
                return
            }
            self.contactsMiniInformation = viewModel!.contacts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
        }
    }
}

//MARK: Extension
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource, ContactProfileDelegate {
    func removeContact() {
        contactsMiniInformation = viewModel!.contacts
        tableView.reloadData()
    }

    func addNewContact(contact: User) {
        self.onContactPage = true
        self.contactsMiniInformation = self.viewModel!.contacts
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
            self.navigationItem.title = "contacts".localized()
            self.activityIndicator.stopAnimating()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ContactProfileViewController.instantiate(fromAppStoryboard: .main)
        vc.delegate = self
        vc.id = contactsMiniInformation[indexPath.row]._id
        vc.contact = contactsMiniInformation[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        vc.onContactPage = onContactPage
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsMiniInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        removeView()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        cell.configure(contact: contactsMiniInformation[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}


