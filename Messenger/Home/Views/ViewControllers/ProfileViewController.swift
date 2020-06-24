//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import DropDown

class ProfileViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var switchMode: UISwitch!
    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var contactsLabel: UILabel!
    @IBOutlet weak var phoneTextLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var lastnameTextLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var darkModeView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var headerUsernameLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var logOutLanguageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var logOutDarkModeVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerEmailLabel: UILabel!
    
    //MARK: Properties
    var dropDown = DropDown()
    let viewModel = ProfileViewModel()
    let socketTaskManager = SocketTaskManager.shared
    let center = UNUserNotificationCenter.current()

    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.center.delegate = self
        setFlagImage()
        setBorder(view: contactView)
        setBorder(view: languageView)
        setBorder(view: darkModeView)
        setBorder(view: logoutView)
        checkInformation()
        configureImageView()
        addGestures()
        checkVersion()
        defineSwithState()
        localizeStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
             super.viewWillAppear(animated)
             checkInformation()
         }
    
    //MARK: Helper methods
    @IBAction func editButton(_ sender: Any) {
          let vc = EditInformationViewController.instantiate(fromAppStoryboard: .main)
          self.navigationController?.pushViewController(vc, animated: true)
      }
    
    
    func localizeStrings() {
           headerEmailLabel.text = "email".localized()
           headerUsernameLabel.text = "username".localized()
           phoneTextLabel.text = "phone:".localized()
           nameTextLabel.text = "name:".localized()
           lastnameTextLabel.text = "lastname:".localized()
           contactsLabel.text = "contacts".localized()
           languageLabel.text = "language".localized()
           darkModeLabel.text = "dark_mode".localized()
           logoutLabel.text = "log_out".localized()
           self.navigationController?.navigationBar.topItem?.title = "profile".localized()
       }
    
    func defineSwithState() {
        if SharedConfigs.shared.mode == "dark" {
            switchMode.isOn = true
        } else {
            switchMode.isOn = false
        }
    }
    
    func getnewMessage(message: Message) {
            self.scheduleNotification(center: self.center)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func setFlagImage() {
        if SharedConfigs.shared.appLang == AppLangKeys.Eng {
            flagImageView.image = UIImage(named: "English")
        } else if SharedConfigs.shared.appLang == AppLangKeys.Rus {
            flagImageView.image = UIImage(named: "Russian")
        } else if SharedConfigs.shared.appLang == AppLangKeys.Arm {
            flagImageView.image = UIImage(named: "Armenian")
        }
    }
    
    @IBAction func selectMode(_ sender: UISwitch) {
        if sender.isOn {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
            SharedConfigs.shared.setMode(selectedMode: "dark")
        } else {
            UIApplication.shared.windows.forEach { window in
                           window.overrideUserInterfaceStyle = .light
                       }
            SharedConfigs.shared.setMode(selectedMode: "light")
        }
    }
    
    func configureImageView() {
        userImageView.contentMode = . scaleAspectFill
        userImageView.layer.cornerRadius = 50
        userImageView.clipsToBounds = true
        userImageView.backgroundColor = .darkGray
        userImageView.image = UIImage(named: "noPhoto")
    }
    
    func addGestures() {
        let tapLogOut = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        logoutView.addGestureRecognizer(tapLogOut)
        let tapContacts = UITapGestureRecognizer(target: self, action: #selector(self.handleContactsTap(_:)))
        contactView.addGestureRecognizer(tapContacts)
        let tapLanguage = UITapGestureRecognizer(target: self, action: #selector(self.handleLanguageTab(_:)))
        languageView.addGestureRecognizer(tapLanguage)
    }
    
    @objc func handleContactsTap(_ sender: UITapGestureRecognizer? = nil) {
        let vc = ContactsViewController.instantiate(fromAppStoryboard: .main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleLanguageTab(_ sender: UITapGestureRecognizer? = nil) {
        addDropDown()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {        
        viewModel.logout { (error, code) in
            if (error != nil) {
                if code == 401 {
                    UserDataController().logOutUser()
                    DispatchQueue.main.async {
                        let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                        let nav = UINavigationController(rootViewController: vc)
                        let window: UIWindow? = UIApplication.shared.windows[0]
                        window?.rootViewController = nav
                        window?.makeKeyAndVisible()
                    }
                }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                return
            }
            else {
                DispatchQueue.main.async {
                    UserDataController().logOutUser()
                    let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                    let nav = UINavigationController(rootViewController: vc)
                    let window: UIWindow? = UIApplication.shared.windows[0]
                    window?.rootViewController = nav
                    window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    func setBorder(view: UIView) {
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        let color = UIColor.lightGray.withAlphaComponent(0.5)
        view.layer.borderColor = color.cgColor
    }
    
    func addDropDown() {
        dropDown.anchorView = languageView 
        dropDown.direction = .any
        dropDown.width = languageView.frame.width
        dropDown.dataSource = ["English", "Russian", "Armenian"]
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if item == "Russian" {
                self.flagImageView.image = UIImage(named: "Russian")
                SharedConfigs.shared.setAppLang(lang: AppLangKeys.Rus)
            } else if item == "English" {
                self.flagImageView.image = UIImage(named: "English")
                SharedConfigs.shared.setAppLang(lang: AppLangKeys.Eng)
            } else if item == "Armenian" {
                self.flagImageView.image = UIImage(named: "Armenian")
                SharedConfigs.shared.setAppLang(lang: AppLangKeys.Arm)
            }
            self.viewDidLoad()
        }
        dropDown.cellNib = UINib(nibName: "CustomCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? CustomCell else { return }
            
            cell.countryImageView.image = UIImage(named: "\(item)")
        }
        dropDown.show()
    }
    
    func checkInformation() {
        let user = SharedConfigs.shared.signedUser
        if user?.name == nil {
            nameLabel.text = "name".localized()
            nameLabel.textColor = .lightGray
        } else {
            nameLabel.text = user?.name
        }
        if user?.lastname == nil {
            lastnameLabel.text = "lastname".localized()
            lastnameLabel.textColor = .lightGray
        } else {
            lastnameLabel.text = user?.lastname
        }
        if user?.email == nil {
            emailLabel.text = "email".localized()
            emailLabel.textColor = .lightGray
        } else {
            emailLabel.text = user?.email
        }
        if user?.username == nil {
            usernameLabel.text = "username".localized()
            usernameLabel.textColor = .lightGray
        } else {
            usernameLabel.text = user?.username
        }
        
        if user?.university == nil {
            universityLabel.text = "university".localized()
            universityLabel.textColor = .lightGray
        } else {
            universityLabel.text = user?.university?.name
            switch SharedConfigs.shared.appLang {
            case "hy":
                universityLabel.text = user?.university?.name
            case "ru":
                universityLabel.text = user?.university?.nameRU
            case "en":
                universityLabel.text = user?.university?.nameEN
            default:
                universityLabel.text = user?.university?.nameEN
            }
        }
        
    }
    
    private func checkVersion() {
        if #available(iOS 13.0, *) {
            logOutDarkModeVerticalConstraint.priority = UILayoutPriority(rawValue: 990)
            logOutLanguageVerticalConstraint.priority = UILayoutPriority(rawValue: 900)
        } else {
            logOutDarkModeVerticalConstraint.priority = UILayoutPriority(rawValue: 900)
            logOutLanguageVerticalConstraint.priority = UILayoutPriority(rawValue: 990)
            darkModeView.isHidden = true
        }
    }
    
    
}
