//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import DropDown
import AVFoundation
import CoreData

protocol ProfileViewControllerDelegate: class {
    func changeLanguage(key: String)
}

protocol ProfileViewDelegate: class {
    func changeMode()
}

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var hidePersonalDataLabel: UILabel!
    @IBOutlet weak var switchMode: UISwitch!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var contactsLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var phoneTextLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var lastnameTextLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var darkModeView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var headerUsernameLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var logOutLanguageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var logOutDarkModeVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerEmailLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: Properties
    var dropDown = DropDown()
    var viewModel: ProfileViewModel?
    let center = UNUserNotificationCenter.current()
    var imagePicker = UIImagePickerController()
    static let nameOfDropdownCell = "CustomCell"
    weak var delegate: ProfileViewControllerDelegate?
    var mainRouter: MainRouter?
    weak var profileDelegate: ProfileViewDelegate?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setFlagImage()
        setBorder(view: contactView)
        setBorder(view: languageView)
        setBorder(view: darkModeView)
        setBorder(view: logoutView)
        setBorder(view: notificationView)
        checkVersion()
        setImage()
        configureImageView()
        addGestures()
        defineSwithState()
        localizeStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkInformation()
       
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: Helper methods
    @IBAction func editButton(_ sender: Any) {
        mainRouter?.showEditViewController()
    }
    
    @IBAction func changePhoneAction(_ sender: Any) {
        mainRouter?.showChangeEmailViewController(changingSubject: .phone)
    }
    
    func setImage() {
        ImageCache.shared.getImage(url: SharedConfigs.shared.signedUser?.avatarURL ?? "", id: SharedConfigs.shared.signedUser?.id ?? "", isChannel: false) { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
    }
    
    func localizeStrings() {
        hidePersonalDataLabel.text = "hide_personal_data".localized()
        headerEmailLabel.text = "email".localized()
        headerUsernameLabel.text = "username".localized()
        phoneTextLabel.text = "phone:".localized()
        nameTextLabel.text = "name:".localized()
        lastnameTextLabel.text = "lastname:".localized()
        contactsLabel.text = "contacts".localized()
        languageLabel.text = "language".localized()
        darkModeLabel.text = "dark_mode".localized()
        notificationLabel.text = "notifications".localized()
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
    
    func setFlagImage() {
        if SharedConfigs.shared.appLang == AppLangKeys.Eng {
            flagImageView.image = UIImage(named: "English")
        } else if SharedConfigs.shared.appLang == AppLangKeys.Rus {
            flagImageView.image = UIImage(named: "Russian")
        } else if SharedConfigs.shared.appLang == AppLangKeys.Arm {
            flagImageView.image = UIImage(named: "Armenian")
        }
    }
    
    @IBAction func changeEmailAction(_ sender: Any) {
        mainRouter?.showChangeEmailViewController(changingSubject: .email)
    }
    
    @IBAction func selectMode(_ sender: UISwitch) {
        profileDelegate?.changeMode()
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
        self.viewDidLoad()
    }
    
     func addCameraView(_ cameraView: UIView) {
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.backgroundColor = UIColor(red: 128/255, green: 94/255, blue: 251/255, alpha: 1)
        cameraView.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 0).isActive = true
        cameraView.rightAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 0).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        cameraView.isUserInteractionEnabled = true
        cameraView.contentMode = . scaleAspectFill
        cameraView.layer.cornerRadius = 15
        cameraView.clipsToBounds = true
    }
    
    func configureImageView() {
        let cameraView = UIView()
        view.addSubview(cameraView)
        userImageView.backgroundColor = .clear
        addCameraView(cameraView)
        let cameraImageView = UIImageView()
        cameraImageView.image = UIImage(named: "camera")
        cameraView.addSubview(cameraImageView)
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraImageView.backgroundColor = UIColor(red: 128/255, green: 94/255, blue: 251/255, alpha: 1)
        cameraImageView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: -5).isActive = true
        cameraImageView.rightAnchor.constraint(equalTo: cameraView.rightAnchor, constant: -5).isActive = true
        cameraImageView.topAnchor.constraint(equalTo: cameraView.topAnchor, constant: 5).isActive = true
        cameraImageView.leftAnchor.constraint(equalTo: cameraView.leftAnchor, constant: 5).isActive = true
        cameraImageView.isUserInteractionEnabled = true
        let tapCamera = UITapGestureRecognizer(target: self, action: #selector(self.handleCameraTap(_:)))
        cameraImageView.addGestureRecognizer(tapCamera)
        userImageView.contentMode = . scaleAspectFill
        userImageView.layer.cornerRadius = 50
        userImageView.clipsToBounds = true
    }
    
    func addGestures() {
        let tapLogOut = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        logoutView.addGestureRecognizer(tapLogOut)
        let tapContacts = UITapGestureRecognizer(target: self, action: #selector(self.handleContactsTap(_:)))
        contactView.addGestureRecognizer(tapContacts)
        let tapLanguage = UITapGestureRecognizer(target: self, action: #selector(self.handleLanguageTab(_:)))
        languageView.addGestureRecognizer(tapLanguage)
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(self.handleImageTap(_:)))
        let tapNotification = UITapGestureRecognizer(target: self, action: #selector(self.tapOnNotification(_:)))
        notificationView.addGestureRecognizer(tapNotification)
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapImage)
    }
    
    @objc func tapOnNotification(_ sender: UITapGestureRecognizer? = nil) {
        if SharedConfigs.shared.getNumberOfNotifications() > 0 {
            mainRouter?.showNotificationListViewController()
        }
    }
    
    @objc func handleCameraTap(_ sender: UITapGestureRecognizer? = nil) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                print("Permission allowed")
            } else {
                print("Permission don't allowed")
            }
        }
        let alert = UIAlertController(title: nil, message: "choose_one_of_this_app_to_upload_photo".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "camera".localized(), style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera;
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "album".localized(), style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
     func addCloseButton(_ imageView: UIImageView) {
        let closeButton = UIButton()
        imageView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 20).isActive = true
        closeButton.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -10).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        closeButton.isUserInteractionEnabled = true
        closeButton.setImage(UIImage(named: "closeColor"), for: .normal)
        closeButton.addTarget(self, action: #selector(dismissFullscreenImage), for: .touchUpInside)
    }
    
     func addDeleteMessageButton(_ imageView: UIImageView) {
        let deleteImageButton = UIButton()
        imageView.addSubview(deleteImageButton)
        deleteImageButton.translatesAutoresizingMaskIntoConstraints = false
        deleteImageButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -40).isActive = true
        deleteImageButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        deleteImageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        deleteImageButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        deleteImageButton.isUserInteractionEnabled = true
        deleteImageButton.setImage(UIImage(named: "trash"), for: .normal)
        deleteImageButton.addTarget(self, action: #selector(deleteAvatar), for: .touchUpInside)
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer? = nil) {
        if SharedConfigs.shared.signedUser?.avatarURL == nil {
            return
        }
        let imageView = UIImageView(image: userImageView.image)
        addCloseButton(imageView)
        imageView.backgroundColor = UIColor(named: "imputColor")
        addDeleteMessageButton(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tag = 3
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        imageView.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func deleteAvatar() {
        viewModel!.deleteAvatar { (error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
                return
            } else {
                let signedUser = SharedConfigs.shared.signedUser
                let user = UserModel(name: signedUser?.name, lastname: signedUser?.lastname, username: signedUser?.username, email: signedUser?.email, token: signedUser?.token, id: signedUser!.id, avatarURL: nil)
                UserDataController().populateUserProfile(model: user)
                DispatchQueue.main.async {
                    self.dismissFullscreenImage()
                    self.userImageView.image = UIImage(named: "noPhoto")
                }
            }
        }
    }
    
    @objc func dismissFullscreenImage() {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        view.viewWithTag(3)?.removeFromSuperview()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        activityIndicator.startAnimating()
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        viewModel!.uploadImage(image: image) { (error, avatarURL) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    self.activityIndicator.stopAnimating()
                }
            } else {
                ImageCache.shared.getImage(url: avatarURL ?? "", id: SharedConfigs.shared.signedUser?.id ?? "", isChannel: false) { (image) in
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    @objc func handleContactsTap(_ sender: UITapGestureRecognizer? = nil) {
        mainRouter?.showContactsViewControllerFromProfile()
    }
    
    @objc func handleLanguageTab(_ sender: UITapGestureRecognizer? = nil) {
        addDropDown()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {        
        viewModel!.logout(deviceUUID: UIDevice.current.identifierForVendor!.uuidString) { (error) in
            UserDefaults.standard.set(false, forKey: Keys.IS_REGISTERED)
            DispatchQueue.main.async {
                self.deleteAllRecords()
                UserDataController().logOutUser()
                AuthRouter().assemblyModule()
            }
            SocketTaskManager.shared.disconnect{}
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
            self.delegate?.changeLanguage(key: AppLangKeys.Arm)
            self.viewDidLoad()
            self.mainRouter?.callDetailViewController?.tableView?.reloadData()
        }
        dropDown.backgroundColor = UIColor(named: "dropDownColor")
        dropDown.cellNib = UINib(nibName: Self.nameOfDropdownCell, bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? CustomCell else { return }
            cell.countryImageView.image = UIImage(named: "\(item)")
        }
        dropDown.show()
    }
    
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CallEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func changeNotificationNumber() {
        UIApplication.shared.applicationIconBadgeNumber = SharedConfigs.shared.getNumberOfNotifications()
        if notificationCountLabel != nil {
            notificationCountLabel.text = "\(SharedConfigs.shared.getNumberOfNotifications())"
        }
    }
    
    func checkInformation() {
        let user = SharedConfigs.shared.signedUser
        changeNotificationNumber()
        if user?.name == nil {
            nameLabel.text = "not_defined".localized()
            nameLabel.textColor = .lightGray
        } else {
            nameLabel.text = user?.name
            nameLabel.textColor = UIColor(named: "color")
        }
        if user?.lastname == nil {
            lastnameLabel.text = "not_defined".localized()
            lastnameLabel.textColor = .lightGray
        } else {
            lastnameLabel.text = user?.lastname
            lastnameLabel.textColor = UIColor(named: "color")
        }
        if user?.email == nil {
            emailLabel.text = "not_defined".localized()
            emailLabel.textColor = .lightGray
        } else {
            emailLabel.text = user?.email
            emailLabel.textColor = UIColor(named: "color")
        }
        if user?.phoneNumber == nil {
            phoneLabel.text = "not_defined".localized()
            phoneLabel.textColor = .lightGray
        } else {
            phoneLabel.text = user?.phoneNumber
            phoneLabel.textColor = UIColor(named: "color")
        }
        if user?.username == nil {
            usernameLabel.text = "not_defined".localized()
            usernameLabel.textColor = .lightGray
        } else {
            usernameLabel.text = user?.username
            usernameLabel.textColor = UIColor(named: "color")
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

//MARK: Extension
extension ProfileViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension ProfileViewController: ChangeEmailViewControllerDelegate {
    func setEmail(email: String) {
        emailLabel.text = email
    }
    
    func setPhone(phone: String) {
        phoneLabel.text = phone
        phoneLabel.textColor = UIColor(named: "color")
    }
}
